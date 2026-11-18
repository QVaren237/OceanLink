
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

    // Genera un token seguro para recuperar la contraseña.
    private String generarToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes);
    }

    // Envía el enlace de recuperación al correo del usuario.
    public void solicitarRecuperacion(
            String correo, String urlRecuperacion) throws Exception {

        Integer idUsuario =
                recuperacionDAO.obtenerIdUsuarioActivoPorCorreo(correo);

        // No revela si el correo está registrado.
        if (idUsuario == null) {
            return;
        }

        String token = generarToken();

        String tokenHash = Seguridad.sha256(token);

        // El enlace tendrá una validez de 30 minutos.
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

    // Comprueba el token y cambia la contraseña.
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
    // Verifica si el enlace de recuperación sigue siendo válido.
    public boolean tokenValido(String token) throws Exception {
        if (token == null || token.isBlank()) {
            return false;
        }

        String tokenHash = Seguridad.sha256(token);

        return recuperacionDAO.obtenerUsuarioPorTokenValido(tokenHash) != null;
    }


}
