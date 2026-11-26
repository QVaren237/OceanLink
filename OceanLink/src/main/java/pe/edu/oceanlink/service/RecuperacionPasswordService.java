package pe.edu.oceanlink.service;

import pe.edu.oceanlink.dao.RecuperacionPasswordDAO;
import pe.edu.oceanlink.util.Seguridad;

import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Base64;

public class RecuperacionPasswordService {

    private final RecuperacionPasswordDAO recuperacionDAO =
            new RecuperacionPasswordDAO();

    private static final SecureRandom RANDOM = new SecureRandom();

    private String generarToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes);
    }

    public void solicitarRecuperacion(
            String correo, String urlRecuperacion) throws Exception {

        Integer idUsuario =
                recuperacionDAO.obtenerIdUsuarioActivoPorCorreo(correo);

        if (idUsuario == null) {
            return;
        }

        String token = generarToken();

        String tokenHash = Seguridad.sha256(token);

        Timestamp expiracion = Timestamp.from(
                Instant.now().plusSeconds(30 * 60)
        );

        recuperacionDAO.guardarToken(
                idUsuario,
                tokenHash,
                expiracion
        );

        String enlace = urlRecuperacion + "?token=" + token;

        String asunto = "Recuperación de contraseña - OceanLink";

        String contenido =
                "<h2>Recuperación de contraseña</h2>"
                        + "<p>Hemos recibido una solicitud para cambiar "
                        + "tu contraseña de OceanLink.</p>"
                        + "<p>Haz clic en el siguiente enlace:</p>"
                        + "<p><a href=\"" + enlace + "\">"
                        + "Restablecer mi contraseña</a></p>"
                        + "<p>Este enlace vence en 30 minutos.</p>"
                        + "<p>Si no solicitaste este cambio, ignora este correo.</p>";

        EmailService.enviarCorreo(correo, asunto, contenido);
    }

    public boolean restablecerPassword(
            String token, String nuevaPassword) throws Exception {

        if (token == null || token.isBlank()
                || nuevaPassword == null || nuevaPassword.isBlank()) {
            return false;
        }

        String tokenHash = Seguridad.sha256(token);

        return recuperacionDAO.actualizarPasswordConToken(
                tokenHash,
                nuevaPassword
        );
    }

    public boolean tokenValido(String token) throws Exception {
        if (token == null || token.isBlank()) {
            return false;
        }

        String tokenHash = Seguridad.sha256(token);

        return recuperacionDAO.obtenerUsuarioPorTokenValido(tokenHash) != null;
    }

}
