package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import pe.edu.oceanlink.service.RecuperacionPasswordService;

import java.io.IOException;

@WebServlet(name = "RecuperarPasswordServlet",
        value = "/RecuperarPasswordServlet")
public class RecuperarPasswordServlet extends HttpServlet {

    private final RecuperacionPasswordService recuperacionService =
            new RecuperacionPasswordService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/recuperar-password.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String correo = request.getParameter("correo");

        if (correo == null || correo.isBlank()) {
            request.setAttribute("error",
                    "Ingresa tu correo electrónico.");

            request.getRequestDispatcher("/recuperar-password.jsp")
                    .forward(request, response);
            return;
        }

        try {
            String urlRecuperacion =
                    request.getScheme() + "://"
                            + request.getServerName()
                            + (request.getServerPort() == 80
                            || request.getServerPort() == 443
                            ? ""
                            : ":" + request.getServerPort())
                            + request.getContextPath()
                            + "/RestablecerPasswordServlet";

            recuperacionService.solicitarRecuperacion(
                    correo.trim(),
                    urlRecuperacion
            );

            request.setAttribute("mensaje",
                    "Si el correo está registrado y activo, "
                            + "recibirás un enlace para recuperar tu contraseña.");

        } catch (Exception e) {

            getServletContext().log(
                    "Error al solicitar recuperación de contraseña", e);

            request.setAttribute("error",
                    "No se pudo procesar la solicitud. Inténtalo nuevamente.");
        }

        request.getRequestDispatcher("/recuperar-password.jsp")
                .forward(request, response);
    }
}
