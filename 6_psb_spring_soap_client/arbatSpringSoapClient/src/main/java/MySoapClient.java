import com.amazonaws.services.lambda.runtime.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import ru.psbank.app.jur.olws.OLWS;
import ru.psbank.app.jur.olws.OLWSServiceLocator;
import ru.psbank.ent.*;
import ru.psbank.ent.Client;
import ru.psbank.ent.auth.xmlbean.PermissionForAuthBean;
import ru.psbank.ent.doc.Exctract;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class MySoapClient implements RequestHandler<Map<String, String>, String> {

    //private static final String psbSOAPServ = "https://online3.payment.ru:9443/OLWSWM/services/OLWS";
    private static final String psbSOAPServ = "https://online.payment.ru:9443/OLWSWM/services/OLWS";

    @Override
    public String handleRequest(Map<String, String> event, Context context) throws RuntimeException{

        String certName;
        String certKey;
        String account;
        int source_id = Integer.parseInt(event.get("source_id"));
        String dateFrom = event.get("datefrom");
        String dateTo = event.get("dateto");

        System.setProperty("org.apache.axis.components.logger.LogFactory",
                "org.apache.axis.components.logger.SimpleLogFactory");
        System.setProperty("org.apache.commons.logging.Log",
                "org.apache.commons.logging.impl.SimpleLog");
        System.setProperty("org.apache.commons.logging.simplelog.log.org.apache.axis",
                "DEBUG");

        LambdaLogger logger = context.getLogger();

        logger.log("-- DATE from " + dateFrom + " --");
        logger.log("-- DATE to " + dateTo + " --");

        try {
            logger.log("-- Getting BANK CREDENTIALS --");
            ResultSet credResultSet = DataService.getCredResultSet(source_id);
            if (credResultSet.next()){
                certName = credResultSet.getString("certname");
                certKey = credResultSet.getString("certkey");
                account = credResultSet.getString("account");
                logger.log("-- CREDENTIALS for account "+ account +" have been got --");
                logger.log("-- CERT FILE for account "+ account +" is "+ certKey + " --");
            }else {
                logger.log("-- Error CREDENTIALS is empty --");
                throw new SQLException();
            }
        } catch (SQLException | JsonProcessingException e) {
            logger.log(e.getMessage());
            e.printStackTrace();
            logger.log("-- ERROR with attempt to get BANK CREDENTIALS--");
            return e.getMessage();
        }
//        certName = "certificatePol.pfx";
//        certKey = "k87hDRgdOI564WfhjRt";
//        account = "123";


        //OLWSServiceLocator serviceLocator = new OLWSServiceLocator();
        //logger.log(dateFrom);
        //logger.log(dateTo);

        System.setProperty("https.protocols", "TLSv1.2");
        System.setProperty("axis.transport.http.HttpTransportPipe.dump", "true");
        System.setProperty("axis.transport.http.connection.timeout", "5000");
        System.setProperty("axis.transport.http.read.timeout", "10000");

        try (Socket socket = new Socket()) {
            logger.log("Resolving online.payment.ru");
            InetAddress address = InetAddress.getByName("online.payment.ru");
            logger.log("IP: " + address.getHostAddress());

            socket.connect(new InetSocketAddress("online.payment.ru", 9443), 5000);
            logger.log("Connected to online.payment.ru:9443");
        } catch (IOException e) {
            logger.log(e.getMessage());
        }

        try {
            DataService.setSslContext(certName, certKey, logger);

            OLWSServiceLocator serviceLocator = new OLWSServiceLocator();
            OLWS olws = serviceLocator.getOLWS(new URL(psbSOAPServ));

            logger.log("-- SOAP CLIENT IS CREATED --");
            //org.apache.axis.client.Stub stub = (org.apache.axis.client.Stub) olws;
            //stub._setProperty("axis.transport.http.HttpTransportPipe.dump", Boolean.TRUE);

            Filial[] filials = olws.getFilias();
            logger.log("-- SOAP CALL DONE.");
            serviceLocator.setMaintainSession(true);

            if (filials != null) {
                for (Filial filial : filials) {
                    logger.log("-- FILIAL --");
                    logger.log(filial.getId() + "\t" + filial.getName() + "\t" + filial.getDescription());
                    PermissionForAuthBean permissionForAuthBean = olws.getPermission(filial.getId());
                    permissionForAuthBean.setFilial(filial);

                    Client[] clients = olws.getClients();
                    if (clients != null) {
                        logger.log("-- CLIENTS --");
                        for (Client client: clients) {
                            logger.log(client.getId() + "\t" + client.getName() + "\t" + client.getINN());
                            Account[] accounts = client.getAccounts();
                            if (accounts != null) {
                                logger.log("-- ACCOUNTS --");
                                for (Account account_obj: accounts) {
                                    logger.log(account_obj.getCode());
                                    if (account_obj.getCode().equals(account)) {
                                        logger.log("-- MATCH --");
                                        Exctract exctract = olws.getExctract(account, dateFrom, dateTo);
                                        DataService.updateData(source_id, exctract, logger);
                                    }
                                }
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            logger.log(e.getMessage());
            e.printStackTrace();
            //return e.getMessage();
            //return e.getStackTrace().toString();
            throw new RuntimeException(Arrays.toString(e.getStackTrace()));

        }
        return "hello from Lambda";
    }

//    public static void main(String[] args) {
//        Map<String, String> params = new HashMap<>();
//        params.put("source_id", "22");
//        params.put("datefrom", "16.06.2025");
//        params.put("dateto", "22.06.2025");
//
//        Context context = new Context() {
//            @Override
//            public String getAwsRequestId() {
//                return "fake-request-id";
//            }
//
//            @Override
//            public String getLogGroupName() {
//                return "fake-log-group";
//            }
//
//            @Override
//            public String getLogStreamName() {
//                return "fake-log-stream";
//            }
//
//            @Override
//            public String getFunctionName() {
//                return null;
//            }
//
//            @Override
//            public String getFunctionVersion() {
//                return null;
//            }
//
//            @Override
//            public String getInvokedFunctionArn() {
//                return null;
//            }
//
//            @Override
//            public CognitoIdentity getIdentity() {
//                return null;
//            }
//
//            @Override
//            public ClientContext getClientContext() {
//                return null;
//            }
//
//            @Override
//            public int getRemainingTimeInMillis() {
//                return 0;
//            }
//
//            @Override
//            public int getMemoryLimitInMB() {
//                return 0;
//            }
//
//            @Override
//            public LambdaLogger getLogger() {
//                return new LambdaLogger() {
//                    @Override
//                    public void log(String s) {
//                        System.out.println("[LambdaLogger] " + s);
//                    }
//
//                    @Override
//                    public void log(byte[] bytes) {
//                        System.out.println("[LambdaLogger] " + bytes);
//                    }
//                };
//            }
//        };
//
//        MySoapClient test = new MySoapClient();
//        test.handleRequest(params, context);
//    }
}
