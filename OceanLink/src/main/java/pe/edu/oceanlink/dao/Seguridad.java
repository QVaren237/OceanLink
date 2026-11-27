package pe.edu.oceanlink.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class Seguridad {

    public static String sha256(String texto) {
        if (texto == null) return "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(texto.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {

            return texto;
        }
    }
}
