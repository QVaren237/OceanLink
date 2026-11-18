package pe.edu.oceanlink;

import pe.edu.oceanlink.service.EmailService;

public class PruebaCorreo {

    public static void main(String[] args) {

        try {
            EmailService.enviarCorreo(
                    "a20216316@pucp.edu.pe",
                    "Prueba de correo - OceanLink",
                    "<h2>¡Hola!</h2>"
                            + "<p>Este es un correo de prueba de OceanLink.</p>"
                            + "<p>La conexión con Mailtrap funciona correctamente.</p>"
            );

            System.out.println("Correo enviado correctamente.");

        } catch (Exception e) {
            System.out.println("Error al enviar el correo:");
            e.printStackTrace();
        }
    }
}
