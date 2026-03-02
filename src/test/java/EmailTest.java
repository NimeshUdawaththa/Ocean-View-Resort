import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

/**
 * Standalone email test — run via: mvnw exec:java -Dexec.mainClass=EmailTest
 * Shows the EXACT error if sending fails.
 */
public class EmailTest {

    public static void main(String[] args) throws Exception {
        // Merge stderr into stdout so we capture all output
        System.setErr(System.out);

        String FROM     = "kavidunimesh3000@gmail.com";
        String PASSWORD = "hymirfgovyjsoinf";
        String TO       = "kavidunimesh3000@gmail.com";  // send to yourself to test

        System.out.println("=== Email Test START ===");
        System.out.println("From : " + FROM);
        System.out.println("To   : " + TO);

        Properties props = new Properties();
        props.put("mail.smtp.auth",       "true");
        props.put("mail.smtp.host",       "smtp.gmail.com");
        props.put("mail.smtp.port",       "465");
        props.put("mail.smtp.ssl.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM, PASSWORD);
            }
        });
        session.setDebug(true);

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(TO));
        msg.setSubject("OceanView Resort - Email Test");
        msg.setText("This is a test email from OceanView Resort system.");

        System.out.println("\nConnecting to SMTP...");
        try (Transport transport = session.getTransport("smtp")) {
            transport.connect("smtp.gmail.com", 465, FROM, PASSWORD);
            System.out.println("Connected OK!");
            transport.sendMessage(msg, msg.getAllRecipients());
            System.out.println("\n=== SUCCESS: Email sent to " + TO + " ===");
        } catch (Throwable t) {
            System.out.println("\n=== FAILED ===");
            System.out.println("Error type   : " + t.getClass().getName());
            System.out.println("Error message: " + t.getMessage());
            t.printStackTrace(System.out);
        }
        System.out.flush();
    }
}
