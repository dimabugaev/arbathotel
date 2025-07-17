import com.amazonaws.services.lambda.runtime.LambdaLogger;
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
import java.util.Arrays;

public class SoapContainerRunner {
    
    private static final String psbSOAPServ = "https://online.payment.ru:9443/OLWSWM/services/OLWS";

    public static void main(String[] args) {
        // Get parameters from environment variables
        String sourceIdStr = System.getenv("source_id");
        String dateFrom = System.getenv("datefrom");
        String dateTo = System.getenv("dateto");
        
        if (sourceIdStr == null || dateFrom == null || dateTo == null) {
            System.err.println("Missing required environment variables: source_id, datefrom, dateto");
            System.exit(1);
        }
        
        int source_id = Integer.parseInt(sourceIdStr);
        
        System.out.println("Starting SOAP client with parameters:");
        System.out.println("source_id: " + source_id);
        System.out.println("datefrom: " + dateFrom);
        System.out.println("dateto: " + dateTo);

        String certName;
        String certKey;
        String account;

        System.setProperty("org.apache.axis.components.logger.LogFactory",
                "org.apache.axis.components.logger.SimpleLogFactory");
        System.setProperty("org.apache.commons.logging.Log",
                "org.apache.commons.logging.impl.SimpleLog");
        System.setProperty("org.apache.commons.logging.simplelog.log.org.apache.axis",
                "DEBUG");

        try {
            System.out.println("-- Getting BANK CREDENTIALS --");
            ResultSet credResultSet = DataService.getCredResultSet(source_id);
            if (credResultSet.next()){
                certName = credResultSet.getString("certname");
                certKey = credResultSet.getString("certkey");
                account = credResultSet.getString("account");
                System.out.println("-- CREDENTIALS for account "+ account +" have been got --");
                System.out.println("-- CERT FILE for account "+ account +" is "+ certKey + " --");
            }else {
                System.out.println("-- Error CREDENTIALS is empty --");
                throw new SQLException();
            }
        } catch (SQLException | JsonProcessingException e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
            System.err.println("-- ERROR with attempt to get BANK CREDENTIALS--");
            System.exit(1);
        }

        System.setProperty("https.protocols", "TLSv1.2");
        System.setProperty("axis.transport.http.HttpTransportPipe.dump", "true");
        System.setProperty("axis.transport.http.connection.timeout", "5000");
        System.setProperty("axis.transport.http.read.timeout", "10000");

        try (Socket socket = new Socket()) {
            System.out.println("Resolving online.payment.ru");
            InetAddress address = InetAddress.getByName("online.payment.ru");
            System.out.println("IP: " + address.getHostAddress());

            socket.connect(new InetSocketAddress("online.payment.ru", 9443), 5000);
            System.out.println("Connected to online.payment.ru:9443");
        } catch (IOException e) {
            System.err.println(e.getMessage());
        }

        try {
            DataService.setSslContext(certName, certKey, new ConsoleLogger());

            OLWSServiceLocator serviceLocator = new OLWSServiceLocator();
            OLWS olws = serviceLocator.getOLWS(new URL(psbSOAPServ));

            System.out.println("-- SOAP CLIENT IS CREATED --");

            Filial[] filials = olws.getFilias();
            System.out.println("-- SOAP CALL DONE.");
            serviceLocator.setMaintainSession(true);

            if (filials != null) {
                for (Filial filial : filials) {
                    System.out.println("-- FILIAL --");
                    System.out.println(filial.getId() + "\t" + filial.getName() + "\t" + filial.getDescription());
                    PermissionForAuthBean permissionForAuthBean = olws.getPermission(filial.getId());
                    permissionForAuthBean.setFilial(filial);

                    Client[] clients = olws.getClients();
                    if (clients != null) {
                        System.out.println("-- CLIENTS --");
                        for (Client client: clients) {
                            System.out.println(client.getId() + "\t" + client.getName() + "\t" + client.getINN());
                            Account[] accounts = client.getAccounts();
                            if (accounts != null) {
                                System.out.println("-- ACCOUNTS --");
                                for (Account account_obj: accounts) {
                                    System.out.println(account_obj.getCode());
                                    if (account_obj.getCode().equals(account)) {
                                        System.out.println("-- MATCH --");
                                        Exctract exctract = olws.getExctract(account, dateFrom, dateTo);
                                        DataService.updateData(source_id, exctract, new ConsoleLogger());
                                    }
                                }
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
        
        System.out.println("SOAP task completed successfully");
    }
    
    // Console logger implementation that implements LambdaLogger interface
    private static class ConsoleLogger implements LambdaLogger {
        @Override
        public void log(String message) {
            System.out.println(message);
        }
        
        @Override
        public void log(byte[] message) {
            System.out.println(new String(message));
        }
    }
} 