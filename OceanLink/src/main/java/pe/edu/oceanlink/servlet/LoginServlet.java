package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.dao.LoginDAO;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.util.SesionContador;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario != null && usuario.getIdUsuario() > 0) {
            redirigirPorRol(usuario, request, response);
            return;
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");

        if ("logout".equals(accion)) {
            HttpSession s = request.getSession(false);
            if (s != null) s.invalidate();
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String correo = request.getParameter("correo");
        String password = request.getParameter("password");
        Usuario usuario = new LoginDAO().validarConHashEnJava(correo, password);

        // Credenciales incorrectas
        if (usuario == null) {
            request.setAttribute("error", "Usuario o contraseña incorrectos.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        // Cuenta inactiva: no se le permite ingresar
        if (!"Activo".equals(usuario.getEstado())) {
            request.setAttribute("error", "Tu cuenta está inactiva. Contacta al administrador.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Ingreso correcto
        HttpSession session = request.getSession();
        if (session.getAttribute("usuario") == null) {
            SesionContador.login(); // esta sesión pasa a estar activa
        }
        session.setAttribute("usuario", usuario);
        session.setAttribute("usuarioSesion", usuario);
        session.setAttribute("responsableSesion", usuario);
        session.setMaxInactiveInterval(600); // 10 minutos
        redirigirPorRol(usuario, request, response);
    }

    private void redirigirPorRol(Usuario u, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String ctx = request.getContextPath();
        String destino;
        switch (u.getIdRol()) {
            case 1: destino = "/PanelServlet";                   break; // Administrador
            case 2: destino = "/CapacityPlannerServlet";         break; // Capacity Planner
            case 3: destino = "/NetworkOperatorServlet";         break; // Network Operator
            case 4: destino = "/MaintenanceCoordinatorServlet";  break; // Maintenance Coordinator
            case 5: destino = "/SupervisorServlet";              break; // Supervisor
            default: destino = "/PanelServlet";                  break;
        }
        response.sendRedirect(ctx + destino);
    }
}
