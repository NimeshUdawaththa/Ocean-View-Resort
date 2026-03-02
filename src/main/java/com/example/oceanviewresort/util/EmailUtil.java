package com.example.oceanviewresort.util;

import com.example.oceanviewresort.dto.BillDTO;
import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.util.Properties;

/**
 * Utility class for sending bill emails to guests.
 *
 * Usage:
 *   EmailUtil.sendBill(toEmail, bill);
 */
public final class EmailUtil {

    private EmailUtil() {}   // static-only utility

    private static final String FROM_EMAIL = "kavidunimesh3000@gmail.com";   // your Gmail address
    private static final String PASSWORD   = "hymirfgovyjsoinf";             // Gmail App Password

    /**
     * Sends the guest bill as a styled HTML email.
     *
     * @param toEmail  recipient address
     * @param bill     fully-populated BillDTO
     * @throws MessagingException on any SMTP or transport error
     */
    public static void sendBill(String toEmail, BillDTO bill) throws MessagingException {

        Properties properties = new Properties();
        properties.put("mail.smtp.auth",       "true");
        properties.put("mail.smtp.host",       "smtp.gmail.com");
        properties.put("mail.smtp.port",       "465");
        properties.put("mail.smtp.ssl.enable", "true");

        Session session = Session.getInstance(properties,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
                    }
                });

        session.setDebug(true); // prints full SMTP log in Tomcat console

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM_EMAIL));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Your Bill \u2013 " + bill.getReservationNumber() + " | OceanView Resort");
        msg.setContent(buildHtml(bill), "text/html; charset=utf-8");

        Transport.send(msg);
        System.out.println("[EmailUtil] Bill sent to " + toEmail + " (" + bill.getReservationNumber() + ")");
    }

    // ── Cancellation email ────────────────────────────────────────────────────

    /**
     * Sends a cancellation confirmation email to the guest.
     *
     * @param toEmail     guest email address
     * @param reservation the cancelled Reservation entity
     * @throws MessagingException on any SMTP or transport error
     */
    public static void sendCancellation(String toEmail,
            com.example.oceanviewresort.model.Reservation reservation)
            throws MessagingException {

        Properties properties = new Properties();
        properties.put("mail.smtp.auth",       "true");
        properties.put("mail.smtp.host",       "smtp.gmail.com");
        properties.put("mail.smtp.port",       "465");
        properties.put("mail.smtp.ssl.enable", "true");

        Session session = Session.getInstance(properties,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
                    }
                });

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM_EMAIL));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        msg.setSubject("Reservation Cancelled \u2013 " + reservation.getReservationNumber() + " | OceanView Resort");
        msg.setContent(buildCancelHtml(reservation), "text/html; charset=utf-8");

        Transport.send(msg);
        System.out.println("[EmailUtil] Cancellation email sent to " + toEmail + " (" + reservation.getReservationNumber() + ")");
    }

    private static String buildCancelHtml(com.example.oceanviewresort.model.Reservation r) {
        String checkIn  = r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "N/A";
        String checkOut = r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "N/A";
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'/><style>"
            + "body{margin:0;padding:0;background:#f0f4f8;font-family:Arial,sans-serif;}"
            + ".wrap{max-width:580px;margin:32px auto;background:#fff;border-radius:14px;"
            + "      overflow:hidden;box-shadow:0 6px 28px rgba(0,50,80,.13);}"
            + ".hdr{background:linear-gradient(135deg,#c0392b,#e74c3c);padding:34px 40px;"
            + "     text-align:center;color:#fff;}"
            + ".hdr h1{margin:0;font-size:25px;letter-spacing:.4px;}"
            + ".hdr p{margin:6px 0 0;font-size:14px;opacity:.85;}"
            + ".body{padding:28px 40px;}"
            + ".notice{background:#fff3e0;border-left:4px solid #e67e22;border-radius:8px;"
            + "        padding:14px 18px;margin-bottom:22px;font-size:14px;color:#7d4e00;line-height:1.6;}"
            + "table{width:100%;border-collapse:collapse;}"
            + "td{padding:11px 6px;font-size:14px;border-bottom:1px solid #eef4f7;color:#2a4a5e;}"
            + ".lbl{color:#7a95a8;width:55%;}"
            + ".val{text-align:right;font-weight:600;color:#1e3a4a;}"
            + ".ftr{background:#f0f7fa;padding:18px 40px;text-align:center;"
            + "     font-size:12px;color:#7a95a8;border-top:1px solid #e6eff5;}"
            + "</style></head><body>"
            + "<div class='wrap'>"
            +   "<div class='hdr'><h1>&#9875; OceanView Resort</h1><p>Reservation Cancellation Notice</p></div>"
            +   "<div class='body'>"
            +     "<p style='font-size:15px;color:#2a4a5e;margin-bottom:18px;'>Dear <strong>" + esc(r.getGuestName()) + "</strong>,</p>"
            +     "<div class='notice'>&#9888;&nbsp; Your reservation has been <strong>cancelled</strong>. "
            +     "If a payment was made, a full refund will be processed within <strong>5&ndash;7 business days</strong> "
            +     "to your original payment method.</div>"
            +     "<table>"
            +       cancelRow("Reservation No.",  esc(r.getReservationNumber()))
            +       cancelRow("Guest Name",        esc(r.getGuestName()))
            +       cancelRow("Room Type",         esc(r.getRoomType()))
            +       cancelRow("Check-in Date",     checkIn)
            +       cancelRow("Check-out Date",    checkOut)
            +       cancelRow("Status",            "<span style='color:#c0392b;font-weight:800;'>CANCELLED</span>")
            +     "</table>"
            +   "</div>"
            +   "<div class='ftr'>We hope to welcome you again at OceanView Resort."
            +     "<br/>For any queries, please contact our front desk.</div>"
            + "</div>"
            + "</body></html>";
    }

    private static String cancelRow(String label, String value) {
        return "<tr><td class='lbl'>" + label + "</td><td class='val'>" + value + "</td></tr>";
    }

    private static String buildHtml(BillDTO b) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'/><style>"
            + "body{margin:0;padding:0;background:#f0f4f8;font-family:Arial,sans-serif;}"
            + ".wrap{max-width:580px;margin:32px auto;background:#fff;border-radius:14px;"
            + "      overflow:hidden;box-shadow:0 6px 28px rgba(0,50,80,.13);}"
            + ".hdr{background:linear-gradient(135deg,#0a4f6e,#1aa3c8);padding:34px 40px;"
            + "     text-align:center;color:#fff;}"
            + ".hdr h1{margin:0;font-size:25px;letter-spacing:.4px;}"
            + ".hdr p{margin:6px 0 0;font-size:14px;opacity:.85;}"
            + ".body{padding:28px 40px;}"
            + ".greeting{font-size:15px;color:#2a4a5e;margin-bottom:22px;line-height:1.6;}"
            + "table{width:100%;border-collapse:collapse;}"
            + "td{padding:11px 6px;font-size:14px;border-bottom:1px solid #eef4f7;color:#2a4a5e;}"
            + ".lbl{color:#7a95a8;width:55%;}"
            + ".val{text-align:right;font-weight:600;color:#1e3a4a;}"
            + ".totrow td{font-size:16px;font-weight:800;color:#0a4f6e;"
            + "           border-top:2.5px solid #0a4f6e;border-bottom:none;padding-top:14px;}"
            + ".ftr{background:#f0f7fa;padding:18px 40px;text-align:center;"
            + "     font-size:12px;color:#7a95a8;border-top:1px solid #e6eff5;}"
            + "</style></head><body>"
            + "<div class='wrap'>"
            +   "<div class='hdr'><h1>&#9875; OceanView Resort</h1><p>Guest Bill &amp; Invoice</p></div>"
            +   "<div class='body'>"
            +     "<p class='greeting'>Dear <strong>" + esc(b.getGuestName()) + "</strong>,"
            +     "<br/>Thank you for staying with us. Please find your bill summary below.</p>"
            +     "<table>"
            +       row("Reservation No.",          esc(b.getReservationNumber()))
            +       row("Guest Name",               esc(b.getGuestName()))
            +       row("Address",                  b.getAddress() != null && !b.getAddress().isBlank()
                                                       ? esc(b.getAddress()) : "\u2014")
            +       row("Contact",                  esc(b.getContactNumber()))
            +       row("Room Type",                esc(b.getRoomType()))
            +       row("Check-in Date",            esc(b.getCheckInDate()))
            +       row("Check-out Date",           esc(b.getCheckOutDate()))
            +       row("Nights",                   String.valueOf(b.getNights()))
            +       row("Rate / Night",             "$" + esc(b.getRatePerNight()))
            +       row("Subtotal",                 "$" + esc(b.getSubtotal()))
            +       row("Tax (" + esc(b.getTaxRate()) + ")", "$" + esc(b.getTax()))
            +       "<tr class='totrow'><td class='lbl'>TOTAL AMOUNT</td>"
            +         "<td class='val'>$" + esc(b.getTotal()) + "</td></tr>"
            +     "</table>"
            +   "</div>"
            +   "<div class='ftr'>We look forward to welcoming you again at OceanView Resort."
            +     "<br/>For enquiries, please contact our front desk.</div>"
            + "</div>"
            + "</body></html>";
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static String row(String label, String value) {
        return "<tr><td class='lbl'>" + label + "</td><td class='val'>" + value + "</td></tr>";
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }


}
