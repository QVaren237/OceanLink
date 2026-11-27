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
import pe.edu.oceanlink.dao.UsuarioDAO;
import java.util.Base64;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

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

        if (usuario == null) {
            request.setAttribute("error", "Usuario o contraseña incorrectos.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if (!usuario.isCuentaActivada()) {
            request.setAttribute("error",
                    "Tu cuenta todavía no está activada. Revisa tu correo electrónico y utiliza el enlace de activación.<br>Si necesitas ayuda, escribe al administrador (adrian.angles@oceanlink.test).");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        if (!"Activo".equals(usuario.getEstado())) {
            request.setAttribute("error",
                    "Tu cuenta está inactiva.<br>Contacta al administrador (adrian.angles@oceanlink.test).");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        if (session.getAttribute("usuario") == null) {
            SesionContador.login();
        }
        session.setAttribute("usuario", usuario);
        session.setAttribute("usuarioSesion", usuario);
        session.setAttribute("responsableSesion", usuario);
        session.setMaxInactiveInterval(600);

        try {
            byte[] __f = new UsuarioDAO().obtenerFoto(usuario.getIdUsuario());
            if (__f != null && __f.length > 0) {
                String __fmt = (__f.length >= 8 && __f[0] == (byte) 0x89) ? "png" : "jpeg";
                session.setAttribute("fotoPerfil", "data:image/" + __fmt + ";base64," + Base64.getEncoder().encodeToString(__f));
            } else {
                session.removeAttribute("fotoPerfil");
            }
        } catch (Exception e) {  }
        SesionRegistro.registrar(usuario.getCorreo(), session.getId());
        redirigirPorRol(usuario, request, response);
    }

    private void redirigirPorRol(Usuario u, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String ctx = request.getContextPath();
        String destino;
        switch (u.getIdRol()) {
            case 1: destino = "/PanelServlet";                   break;
            case 2: destino = "/CapacityPlannerServlet";         break;
            case 3: destino = "/NetworkOperatorServlet";         break;
            case 4: destino = "/MaintenanceCoordinatorServlet";  break;
            case 5: destino = "/SupervisorServlet";              break;
            default: destino = "/PanelServlet";                  break;
        }
        response.sendRedirect(ctx + destino);
    }
}
