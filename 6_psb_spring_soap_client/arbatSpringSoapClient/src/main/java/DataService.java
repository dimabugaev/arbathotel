import com.amazonaws.auth.*;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.secretsmanager.AWSSecretsManager;
import com.amazonaws.services.secretsmanager.AWSSecretsManagerClient;
import com.amazonaws.services.secretsmanager.model.GetSecretValueRequest;
import com.amazonaws.services.secretsmanager.model.GetSecretValueResult;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import ru.psbank.ent.doc.*;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.nio.file.Paths;
import java.security.*;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;


class DataService {

    private static final String s3Bucket = "arbat-hotel-additional-data";
    private static final String s3CertKey = "psb-cert/";
    private static final String TrustStorePSB = "PJSC.cer";

    private static final String trustStorePath = System.getProperty("java.io.tmpdir") + File.separator + "psbcer.truststore";
    private static final String keyStorePath = System.getProperty("java.io.tmpdir") + File.separator + "psbkey.truststore";

    private static Map<String, String> originalSSL = new HashMap<>();
    private static Connection dbConn = null;

    private static final AWSCredentialsProvider provider = new DefaultAWSCredentialsProviderChain();
    //for local debug
    //private static final AWSCredentialsProvider provider = new ProfileCredentialsProvider("arbathotelserviceterraformuser");

    //Map<String, String> doc_types_map = new HashMap<>();

    private static Connection getDBConnection() throws JsonProcessingException, SQLException {

        clearSSLParams();

        Connection conn = null;

        String secretName = System.getenv("RDS_SECRET");
        if (secretName == null){
            secretName = "dev-rds-instance";
        }


        AWSSecretsManager secretsManager = AWSSecretsManagerClient.builder()
                .withRegion(Regions.EU_CENTRAL_1)
                .withCredentials(provider)
                .build();

        GetSecretValueRequest getSecretValueRequest = new GetSecretValueRequest().withSecretId(secretName);

        GetSecretValueResult result = null;

        result = secretsManager.getSecretValue(getSecretValueRequest);

        if (result != null) {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode jsonNode = mapper.readTree(result.getSecretString());

            String jdbcURL = "jdbc:postgresql://"+ jsonNode.get("host").asText() + ":5432/"+ jsonNode.get("dbname").asText();
            conn = DriverManager.getConnection(jdbcURL, jsonNode.get("username").asText(), jsonNode.get("password").asText());
        }

        restoreSSLParams();
        return conn;
    }

    private static String getCredQueryString(){
        StringBuilder queryRes = new StringBuilder("select ");
        queryRes.append("source_external_key as account, ");
        queryRes.append("source_username as certname, ");
        queryRes.append("source_password as certkey ");
        queryRes.append("from operate.sources where id = ?");

        return queryRes.toString();
    }

    static ResultSet getCredResultSet(int source_id) throws SQLException, JsonProcessingException {
        if (dbConn == null){
            dbConn = getDBConnection();
        }

        PreparedStatement preparedStatement = dbConn.prepareStatement(getCredQueryString());
        preparedStatement.setInt(1, source_id);

        return preparedStatement.executeQuery();
    }

    static Map<String, String> setSslContext(String keyStoreNamePSB, String password, LambdaLogger logger) throws GeneralSecurityException, IOException {

        if (!keyStoreNamePSB.endsWith(".pfx")) {
            logger.log("-- ERROR bad keystore name " + keyStoreNamePSB + " --");
            throw new RuntimeException("bad keystore name");
        }

        clearSSLParams();

        if (originalSSL.size() > 0){
            restoreSSLParams();

            if (!originalSSL.get("javax.net.ssl.keyStorePassword").equals(password)){
                clearSSLParams();
                logger.log("--OLD-- " + password);
                logger.log("--NEW-- " + originalSSL.get("javax.net.ssl.keyStorePassword"));
            }else {
                return originalSSL;
            }
        }

        Security.setProperty("ssl.SocketFactory.provider", "");
        Security.setProperty("ssl.ServerSocketFactory.provider", "");

        logger.log("-- Prepare to set certificates --");

        AmazonS3 s3Client = AmazonS3Client.builder()
                .withRegion(Regions.EU_CENTRAL_1)
                .withCredentials(provider)
                .build();

        KeyStore keystore = KeyStore.getInstance("PKCS12");
        KeyStore trustStore = KeyStore.getInstance("JKS");
        keystore.load(null, null);


//        Enumeration<String> aliases = keystore.aliases();
//        while (aliases.hasMoreElements()) {
//            String alias = aliases.nextElement();
//            Certificate cert = keystore.getCertificate(alias);
//            logger.log("Alias: " + alias);
//            logger.log("Certificate: " + cert);
//        }

        logger.log("-- Creating cert STREAMS --");

        try(InputStream truststoreInputStream = s3Client.getObject(s3Bucket, s3CertKey + TrustStorePSB).getObjectContent().getDelegateStream();
            InputStream keystoreInputStream = s3Client.getObject(s3Bucket, s3CertKey + keyStoreNamePSB).getObjectContent().getDelegateStream()) {

            //logger.log("-- TRUSTSTORE was read vol " + truststoreInputStream.available() + " bytes --");
            //logger.log("-- KEYSTORE was read vol " + keystoreInputStream.available() + " bytes --");

            logger.log("-- TRUSTSTORE was read vol --");
            logger.log("-- KEYSTORE was read vol --");


            //keystore.store(new FileOutputStream(keyStorePath), "keystorePassword".toCharArray());

            keystore.load(keystoreInputStream, password.toCharArray());

//            while (keystore.aliases().hasMoreElements()){
//                String al = keystore.aliases().nextElement();
//                keystore.deleteEntry(al);
//                logger.log("--Aliase-- " + al);
//            }

            trustStore.load(null, null);
            CertificateFactory certificateFactory = CertificateFactory.getInstance("X.509");
            Certificate trustCert = certificateFactory.generateCertificate(truststoreInputStream);
            trustStore.setCertificateEntry("trust", trustCert);


            //certificateFactory.

            trustStore.store(new FileOutputStream(trustStorePath), "123".toCharArray());
            System.setProperty("javax.net.ssl.trustStore", trustStorePath);
            System.setProperty("javax.net.ssl.trustStorePassword", "123");
            System.setProperty("javax.net.ssl.trustStoreType", "JKS");

            keystore.store(new FileOutputStream(keyStorePath), password.toCharArray());
            System.setProperty("javax.net.ssl.keyStore", keyStorePath);
            System.setProperty("javax.net.ssl.keyStoreType", "PKCS12");
            System.setProperty("javax.net.ssl.keyStorePassword", new String(password));


            logger.log("Cert data have been sat to the ssl settings");

            saveSSLParams();

            logger.log("-- SSL settings was SAVE --");

        }catch (IOException e){
            logger.log("-- ERROR creating cert STREAMS --");
            logger.log(Arrays.toString(e.getStackTrace()));
            throw e;
        }
        return originalSSL;
    }

    static boolean updateData(int source_id, Exctract exctract, LambdaLogger log) throws SQLException, JsonProcessingException {

        SimpleDateFormat formatter = new SimpleDateFormat("ddMMyyyy");
        String tempTableName = "temp_psb_table_update_"+ source_id + "_" + formatter.format(exctract.getFrom().getTime());

        if (dbConn == null){
                dbConn = getDBConnection();
        }

        if (dbConn.isValid(0)){

            PreparedStatement createTempTable = dbConn.prepareStatement(getCreateTempTableQuery(tempTableName));
            createTempTable.execute();

            PreparedStatement insertDataStatement = dbConn.prepareStatement(getInsertIntoTempQuery(source_id, tempTableName, exctract, log));
            insertDataStatement.executeUpdate();

            java.sql.Date sqlDateFrom = new Date(exctract.getFrom().getTimeInMillis() + 10800000);
            java.sql.Date sqlDateTo = new Date(exctract.getTo().getTimeInMillis() + 10800000);
            PreparedStatement uploadDataStatement = dbConn.prepareStatement(getUploadFromTempQuery(tempTableName));
            uploadDataStatement.setInt(1, source_id);
            //uploadDataStatement.setInt(2, source_id);
            uploadDataStatement.setInt(4, source_id);
            uploadDataStatement.setInt(7, source_id);
            uploadDataStatement.setInt(11, source_id);
            uploadDataStatement.setDate(2, sqlDateFrom);
            uploadDataStatement.setDate(5, sqlDateFrom);
            uploadDataStatement.setDate(8, sqlDateFrom);
            uploadDataStatement.setDate(9, sqlDateFrom);
            uploadDataStatement.setDate(12, sqlDateFrom);
            uploadDataStatement.setDate(3, sqlDateTo);
            uploadDataStatement.setDate(6, sqlDateTo);
            uploadDataStatement.setDate(10, sqlDateTo);
            uploadDataStatement.setDate(13, sqlDateTo);
            uploadDataStatement.executeUpdate();
        }


        return true;
    }

    private static void saveSSLParams(){
        List<String> listOfSSL = new ArrayList<>();
        listOfSSL.add("javax.net.ssl.trustStore");
        listOfSSL.add("javax.net.ssl.trustStorePassword");
        listOfSSL.add("javax.net.ssl.trustStoreType");
        listOfSSL.add("javax.net.ssl.keyStore");
        listOfSSL.add("javax.net.ssl.keyStoreType");
        listOfSSL.add("javax.net.ssl.keyStorePassword");

        listOfSSL.forEach(val -> originalSSL.put(val, System.getProperty(val)));
    }

    private static void clearSSLParams(){
        originalSSL.forEach((key, val) -> System.clearProperty(key));
    }

    private static void restoreSSLParams(){
        originalSSL.forEach((key, val) -> { if (val==null)
                                                System.clearProperty(key);
                                            else
                                                System.setProperty(key, val);});
    }

    private static String getCreateTempTableQuery(String tempTableName){
        return "drop table if exists " + tempTableName + "; " +
                "create temp table "+ tempTableName +"( "+
                    "source_id int, "+
                    "doc_id bigint, "+
                    "kb varchar, "+
                    "po varchar, "+
                    "account varchar, "+
                    "contragent varchar, "+
                    "contragent_inn varchar, "+
                    "conversion decimal(18,2), "+
                    "debit boolean, "+
                    "description varchar, "+
                    "outer_account varchar, "+
                    "summa_rur decimal(18,2), "+

                    "bank_work_id bigint, "+
                    "row_date date, "+
                    "first_signed boolean, "+
                    "number_doc varchar, "+
                    "reciever varchar, "+
                    "second_signed boolean, "+
                    "summa decimal(18,2), "+
                    "third_signed boolean);";
    }

    private static String getInsertIntoTempQuery(int source_id, String tempTableName, Exctract exctract, LambdaLogger log){

        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        StringBuilder queryRes = new StringBuilder("insert into " + tempTableName + " values ");

        ExtractRow[] resultRows = exctract.getExctractRows();
        int count = 0;
        for (ExtractRow paymentdatarow: resultRows) {
            DocHeader docHeader = paymentdatarow.getDoc(); //if null we need to create a null data object manually

            if (count > 0) queryRes.append(", ");
            //row_data
            queryRes.append("(").append(source_id).append(", ");
            queryRes.append(docHeader.getId()).append(", ");
            queryRes.append("'").append(paymentdatarow.getKB()).append("'").append(", ");
            queryRes.append("'").append(paymentdatarow.getPO()).append("'").append(", ");
            queryRes.append("'").append(paymentdatarow.getAccount()).append("'").append(", ");
            queryRes.append("'").append(StringHelper.escapeSQL(paymentdatarow.getContragent())).append("'").append(", ");
            //queryRes.append("'").append(paymentdatarow.getContragent()).append("'").append(", ");
            queryRes.append("'").append(paymentdatarow.getContragentINN()).append("'").append(", ");
            queryRes.append(paymentdatarow.getConversion()).append(", ");
            queryRes.append(StringHelper.boolSQL(paymentdatarow.isDebit())).append(", ");
            queryRes.append("'").append(StringHelper.escapeSQL(paymentdatarow.getDescription())).append("'").append(", ");
            queryRes.append("'").append(paymentdatarow.getOuterAccount()).append("'").append(", ");
            queryRes.append(paymentdatarow.getSummaRUR()).append(", ");
            //doc_data
            //log.log(docHeader.getDate().getTime().toString());
            queryRes.append("'").append(docHeader.getBankWorkId()).append("'").append(", ");
            queryRes.append("'").append(formatter.format(docHeader.getDate().getTime())).append("'").append(", ");
            queryRes.append(StringHelper.boolSQL(docHeader.isFirstSigned())).append(", ");
            queryRes.append("'").append(docHeader.getNumberDoc()).append("'").append(", ");
            queryRes.append("'").append(docHeader.getReciever()).append("'").append(", ");
            queryRes.append(StringHelper.boolSQL(docHeader.isSecondSigned())).append(", ");
            queryRes.append(docHeader.getSumma()).append(", ");
            queryRes.append(StringHelper.boolSQL(docHeader.isThirdSigned())).append(")");

            count ++;
        }
        queryRes.append(";");

        if (count == 0) {
            return "";
        }

        return queryRes.toString().replaceAll("'null'", "NULL");
    }

    private static String getUploadFromTempQuery(String tempTableName){
        StringBuilder queryRes = new StringBuilder();
        queryRes.append("delete from banks_raw.psb_docs_rows where ");
        //queryRes.append("source_id = ? and doc_id in (select id from banks_raw.psb_docs where source_id = ? and row_date >= ? and row_date <= ?); ");
        queryRes.append("source_id = ? and doc_id in (select id from banks_raw.psb_docs where row_date >= ? and row_date <= ?); ");
        queryRes.append("delete from banks_raw.psb_docs where source_id = ? and row_date >= ? and row_date <= ?; ");

        queryRes.append("delete from banks_raw.loaded_data_by_period where source_id = ? and period_month = date_trunc('month', ?::date)::date; ");

        queryRes.append("insert into banks_raw.psb_docs ");
        queryRes.append("select distinct ");
        queryRes.append("doc_id as id, source_id, bank_work_id, row_date, first_signed, number_doc, reciever, second_signed, summa, third_signed ");
        queryRes.append("from ").append(tempTableName).append("; ");

        queryRes.append("insert into banks_raw.psb_docs_rows ");
        queryRes.append("select ");
        queryRes.append("source_id, doc_id, row_date, kb, po, account, contragent, contragent_inn, conversion, debit, description, outer_account, summa_rur ");
        queryRes.append("from ").append(tempTableName).append("; ");

        queryRes.append("insert into banks_raw.loaded_data_by_period ");
        queryRes.append("with my_union as ( ");
        queryRes.append("select ");
        queryRes.append("source_id, ");
        queryRes.append("date_trunc('month', ?::date)::date as period_month, ");
        queryRes.append("?::date as loaded_date, ");
        queryRes.append("case when debit = True then summa_rur else 0 end as debet, ");
        queryRes.append("case when debit = True then 0 else summa_rur end as credit ");
        queryRes.append("from ").append(tempTableName).append(" ");
        queryRes.append("union all ");
        queryRes.append("select ");
        queryRes.append("?, ");
        queryRes.append("date_trunc('month', ?::date)::date, ");
        queryRes.append("?::date, ");
        queryRes.append("0, ");
        queryRes.append("0 ) ");
        queryRes.append("select ");
        queryRes.append("source_id, ");
        queryRes.append("period_month, ");
        queryRes.append("loaded_date, ");
        queryRes.append("sum(debet) as debet, ");
        queryRes.append("sum(credit) as credit ");
        queryRes.append("from my_union ");
        queryRes.append("group by 1, 2, 3; ");

        return queryRes.toString();

    }

}
