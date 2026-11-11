package pe.edu.oceanlink.servlet;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.util.SesionRegistro;

import java.io.IOException;

/**
 * Guardián de sesión (Clase 9, diapositivas 28-29).
 * Se ejecuta en CADA pedido y valida que exista una sesión iniciada y que
 * siga vigente en el registro del servidor. Si no, reenvía al login.
 * Así un link copiado o un segundo navegador no pueden ver las vistas sin
 * sesión, y al cerrar sesión en un lado se cierra en TODOS.
 */
@WebFilter("/*")
public class SesionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String ctx = request.getContextPath();
        String path = request.getRequestURI().substring(ctx.length());

        // Rutas públicas: login, recursos y páginas de "sesión cerrada"
        boolean publica =
                path.equals("/") ||
                path.equals("/index.jsp") ||
                path.equals("/login.jsp") ||
                path.equals("/LoginServlet") ||
                path.endsWith("sesion-cerrada.jsp") ||
                path.startsWith("/css/") ||
                path.startsWith("/assets/");

        if (publica) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        Usuario usuario = (session == null) ? null : (Usuario) session.getAttribute("usuario");

        boolean valida = usuario != null
                && SesionRegistro.esValida(usuario.getCorreo(), session.getId());

        if (valida) {
            chain.doFilter(req, res);
        } else {
            if (session != null) session.invalidate();
            response.sendRedirect(ctx + "/LoginServlet");
        }
    }
}
