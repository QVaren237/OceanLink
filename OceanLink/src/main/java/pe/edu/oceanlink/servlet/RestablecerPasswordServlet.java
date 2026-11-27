package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.servlet.RecuperacionPasswordService;

import java.io.IOException;

@WebServlet("/RestablecerPasswordServlet")
public class RestablecerPasswordServlet extends HttpServlet {

    private final RecuperacionPasswordService servicio =
            new RecuperacionPasswordService();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        try {
            if (!servicio.tokenValido(token)) {
                request.setAttribute("error",
                        "El enlace no es válido o ha expirado.");
                request.getRequestDispatcher("/restablecer-password.jsp")
                        .forward(request, response);
                return;
            }

            request.setAttribute("token", token);

            request.getRequestDispatcher("/restablecer-password.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                    "Error al verificar el token de recuperación.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmarPassword = request.getParameter("confirmarPassword");

        if (password == null || password.length() < 8) {
            request.setAttribute("error",
                    "La contraseña debe tener al menos 8 caracteres.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/restablecer-password.jsp")
                    .forward(request, response);
            return;
        }

        if (!password.equals(confirmarPassword)) {
            request.setAttribute("error",
                    "Las contraseñas no coinciden.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/restablecer-password.jsp")
                    .forward(request, response);
            return;
        }

        try {
            boolean actualizado =
                    servicio.restablecerPassword(token, password);

            if (actualizado) {
                request.setAttribute("mensaje",
                        "¡Tu contraseña se actualizó correctamente!");
                request.getRequestDispatcher("/restablecer-password.jsp")
                        .forward(request, response);
            } else {
                request.setAttribute("error",
                        "El enlace no es válido, ya fue utilizado o ha expirado.");
                request.getRequestDispatcher("/restablecer-password.jsp")
                        .forward(request, response);
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Error al restablecer la contraseña.", e);
        }
    }
}
