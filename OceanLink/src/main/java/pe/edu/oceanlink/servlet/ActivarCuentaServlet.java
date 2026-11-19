
package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.UsuarioDAO;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ActivarCuentaServlet", value = "/activar-cuenta")
public class ActivarCuentaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        if (token == null || token.isBlank()) {
            request.setAttribute("error", "El enlace de activación no es válido.");
            request.getRequestDispatcher("/activar-cuenta.jsp").forward(request, response);
            return;
        }

        try {
            UsuarioDAO dao = new UsuarioDAO();

            if (dao.tokenActivacionValido(token)) {
                request.setAttribute("token", token);
                request.setAttribute("tokenValido", true);
            } else {
                request.setAttribute("error",
                        "El enlace ha vencido, ya fue utilizado o no es válido. Solicita al administrador un nuevo enlace.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            getServletContext().log("Error al validar el enlace de activación", e);
            request.setAttribute("error",
                    "No se pudo comprobar el enlace. Inténtalo nuevamente más tarde.");
        }

        request.getRequestDispatcher("/activar-cuenta.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmarPassword = request.getParameter("confirmarPassword");

        if (token == null || token.isBlank()) {
            request.setAttribute("error", "El enlace de activación no es válido.");
            request.getRequestDispatcher("/activar-cuenta.jsp").forward(request, response);
            return;
        }

        if (password == null || password.length() < 8 || password.length() > 256) {
            mostrarFormulario(request, response, token,
                    "La contraseña debe tener entre 8 y 256 caracteres.");
            return;
        }

        if (!password.equals(confirmarPassword)) {
            mostrarFormulario(request, response, token,
                    "Las contraseñas no coinciden.");
            return;
        }

        try {
            UsuarioDAO dao = new UsuarioDAO();

            boolean activada = dao.activarCuenta(token, password);

            if (activada) {
                request.setAttribute("exito",
                        "¡Tu cuenta ha sido activada correctamente! Ya puedes iniciar sesión.");
            } else {
                request.setAttribute("error",
                        "El enlace ha vencido, ya fue utilizado o no es válido.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            getServletContext().log("Error al activar la cuenta", e);
            request.setAttribute("error",
                    "No se pudo activar tu cuenta. Inténtalo nuevamente más tarde.");
        }

        request.getRequestDispatcher("/activar-cuenta.jsp").forward(request, response);
    }

    private void mostrarFormulario(HttpServletRequest request,
                                   HttpServletResponse response,
                                   String token,
                                   String mensaje)
            throws ServletException, IOException {

        try {
            UsuarioDAO dao = new UsuarioDAO();

            if (dao.tokenActivacionValido(token)) {
                request.setAttribute("token", token);
                request.setAttribute("tokenValido", true);
                request.setAttribute("error", mensaje);
            } else {
                request.setAttribute("error",
                        "El enlace ha vencido, ya fue utilizado o no es válido.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            getServletContext().log("Error al comprobar el enlace de activación", e);
            request.setAttribute("error",
                    "No se pudo comprobar el enlace. Inténtalo nuevamente más tarde.");
        }

        request.getRequestDispatcher("/activar-cuenta.jsp").forward(request, response);
    }
}
