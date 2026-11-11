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
import pe.edu.oceanlink.util.SesionRegistro;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        // Solo se da por iniciada si la sesión sigue vigente en el registro del servidor
        if (usuario != null && usuario.getIdUsuario() > 0
                && SesionRegistro.esValida(usuario.getCorreo(), session.getId())) {
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

        // Cerrar sesión: es GLOBAL (se cierra en todos los navegadores del usuario)
        if ("logout".equals(accion)) {
            HttpSession s = request.getSession(false);
            if (s != null) {
                Usuario u = (Usuario) s.getAttribute("usuario");
                if (u != null) SesionRegistro.cerrarUsuario(u.getCorreo());
                s.invalidate();
            }
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
        // Cuenta inactiva: no se le permite ingresar (mensaje solo para inactivos)
        if (!"Activo".equals(usuario.getEstado())) {
            request.setAttribute("error",
                    "Tu cuenta está inactiva.<br>Contacta al administrador (adrian.angles@oceanlink.test).");
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
        SesionRegistro.registrar(usuario.getCorreo(), session.getId()); // registra esta sesión
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
