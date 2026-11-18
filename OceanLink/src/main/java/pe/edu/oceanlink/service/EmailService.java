package pe.edu.oceanlink.service;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.InputStream;
import java.util.Properties;

public class EmailService {

    private static final Properties CONFIG = new Properties();

    static {
        try (InputStream input = EmailService.class
                .getClassLoader()
                .getResourceAsStream("mail.properties")) {

            if (input == null) {
                throw new IllegalStateException(
                        "No se encontró el archivo mail.properties"
                );
            }

            CONFIG.load(input);

        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void enviarCorreo(
            String destinatario,
            String asunto,
            String contenido
    ) throws Exception {

        String host = CONFIG.getProperty("mail.smtp.host");
        String puerto = CONFIG.getProperty("mail.smtp.port");
        String usuario = CONFIG.getProperty("mail.smtp.username");
        String password = CONFIG.getProperty("mail.smtp.password");
        String remitente = CONFIG.getProperty("mail.from");

        Properties propiedades = new Properties();

        propiedades.put("mail.smtp.host", host);
        propiedades.put("mail.smtp.port", puerto);
        propiedades.put("mail.smtp.auth", "true");
        propiedades.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(
                propiedades,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication
                    getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                usuario,
                                password
                        );
                    }
                }
        );

        Message mensaje = new MimeMessage(session);

        mensaje.setFrom(new InternetAddress(remitente));
        mensaje.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(destinatario)
        );

        mensaje.setSubject(asunto);
        mensaje.setContent(contenido, "text/html; charset=UTF-8");

        Transport.send(mensaje);
    }
}

