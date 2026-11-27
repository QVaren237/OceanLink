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
import pe.edu.oceanlink.servlet.SesionRegistro;

import java.io.IOException;

@WebFilter("/*")
public class SesionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "SAMEORIGIN");
        response.setHeader("Referrer-Policy", "no-referrer");

        String ctx = request.getContextPath();
        String path = request.getRequestURI().substring(ctx.length());

        if ("/views/supervisor-sidebar.jsp".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        boolean publica =
                path.equals("/") ||
                        path.equals("/index.jsp") ||
                        path.equals("/login.jsp") ||
                        path.equals("/LoginServlet") ||

                        path.equals("/RecuperarPasswordServlet") ||
                        path.equals("/RestablecerPasswordServlet") ||
                        path.equals("/recuperar-password.jsp") ||
                        path.equals("/restablecer-password.jsp") ||

                        path.endsWith("sesion-cerrada.jsp") ||
                        path.startsWith("/css/") ||
                        path.startsWith("/assets/");

        if (publica) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        Usuario usuario = (session == null) ? null : (Usuario) session.getAttribute("usuario");
        boolean sesionValida = usuario != null
                && SesionRegistro.esValida(usuario.getCorreo(), session.getId());

        if (!sesionValida) {
            if (session != null) session.invalidate();
            response.sendRedirect(ctx + "/LoginServlet");
            return;
        }

        int rolRequerido = rolDeLaRuta(path);
        if (rolRequerido != 0 && usuario.getIdRol() != rolRequerido) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher("/sin-permiso.jsp").forward(request, response);
            return;
        }

        chain.doFilter(req, res);
    }

    private int rolDeLaRuta(String path) {
        String p = path.toLowerCase();

        if (p.equals("/panelservlet") || p.equals("/usuarioservlet") || p.equals("/clienteservlet")
                || p.equals("/landingstationservlet") || p.equals("/redessubmarinasservlet")) return 1;
        if (p.startsWith("/capacity-planner") || p.equals("/capacityplannerservlet") || p.equals("/rutaservlet")) return 2;
        if (p.equals("/networkoperatorservlet")) return 3;
        if (p.startsWith("/maintenance-coordinator") || p.equals("/maintenancecoordinatorservlet")) return 4;
        if (p.startsWith("/supervisor")) return 5;

        if (p.startsWith("/views/")) {
            String v = p.substring("/views/".length());
            if (v.startsWith("no-")) return 3;
            if (v.startsWith("mc-")) return 4;
            if (v.startsWith("supervisor-")) return 5;
            if (v.startsWith("capacity-planner") || v.startsWith("capacidad") || v.startsWith("alerta")
                    || v.startsWith("historico") || v.startsWith("ruta") || v.startsWith("servicio")) return 2;
            if (v.startsWith("panel") || v.startsWith("usuario") || v.startsWith("cliente")
                    || v.startsWith("landing-station") || v.startsWith("redes-submarinas")
                    || v.startsWith("operacion-exito") || v.startsWith("acceso-por-rol")) return 1;
        }
        if (p.equals("/acceso-por-rol.html") || p.equals("/acceso-por-rol.jsp")) return 1;

        return 0;
    }
}
