package pe.edu.oceanlink.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Utilidad para cifrar contraseñas con SHA-256 (Clase 9).
 * El hash no es reversible, por eso para validar se hashea lo que escribe
 * el usuario y se compara con lo guardado en la base de datos.
 */
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
            // Si algo falla, se devuelve el texto tal cual para no romper el flujo
            return texto;
        }
    }
}
