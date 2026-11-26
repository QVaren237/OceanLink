package pe.edu.oceanlink.util;

public class Validacion {

    public static boolean esCorreoValido(String correo) {

        if (correo == null || correo.isBlank()) {
            return false;
        }

        if (correo.length() > 50) {
            return false;
        }

        String formatoCorreo =
                "^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.[A-Za-z]{2,}$";

        return correo.matches(formatoCorreo);
    }
}
