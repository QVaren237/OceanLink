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
 * Filtro de seguridad (Clase 9 + control de acceso por ROL).
 * Se ejecuta en CADA pedido y hace 3 cosas:
 *   1) Agrega cabeceras de seguridad web (anti-clickjacking, anti-sniffing).
 *   2) Valida que exista una sesión iniciada y vigente (diapositivas 28-29).
 *   3) Autoriza por ROL: cada rol solo entra a sus propias vistas/servlets.
 *      Si un rol intenta abrir el módulo de otro (p. ej. pegando el link del
 *      Administrador en la barra), se le muestra "Acceso denegado".
 */
@WebFilter("/*")
public class SesionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // (1) Cabeceras de seguridad web en todas las respuestas
        response.setHeader("X-Content-Type-Options", "nosniff");   // evita adivinar el tipo de archivo
        response.setHeader("X-Frame-Options", "SAMEORIGIN");       // evita clickjacking (meter la pág. en un iframe)
        response.setHeader("Referrer-Policy", "no-referrer");       // no filtra la URL a otros sitios

        String ctx = request.getContextPath();
        String path = request.getRequestURI().substring(ctx.length());

        // El menu JSP se incluye en las vistas y no se sirve como archivo.
        if ("/views/supervisor-sidebar.jsp".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Rutas públicas: login, recursos y páginas de "sesión cerrada"
        boolean publica =
                path.equals("/") ||
                        path.equals("/index.jsp") ||
                        path.equals("/login.jsp") ||
                        path.equals("/LoginServlet") ||

                        // Recuperación de contraseña: rutas públicas
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

        // (2) Validar que la sesión exista y siga vigente en el servidor
        HttpSession session = request.getSession(false);
        Usuario usuario = (session == null) ? null : (Usuario) session.getAttribute("usuario");
        boolean sesionValida = usuario != null
                && SesionRegistro.esValida(usuario.getCorreo(), session.getId());

        if (!sesionValida) {
            if (session != null) session.invalidate();
            response.sendRedirect(ctx + "/LoginServlet");
            return;
        }

        // (3) Autorización por ROL: ¿este rol puede entrar a esta ruta?
        int rolRequerido = rolDeLaRuta(path);
        if (rolRequerido != 0 && usuario.getIdRol() != rolRequerido) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN); // 403
            request.getRequestDispatcher("/sin-permiso.jsp").forward(request, response);
            return;
        }

        chain.doFilter(req, res);
    }

    /**
     * Devuelve el rol (1..5) que puede acceder a esa ruta, o 0 si es compartida.
     *   1 Administrador · 2 Capacity Planner · 3 Network Operator
     *   4 Maintenance Coordinator · 5 Supervisor
     */
    private int rolDeLaRuta(String path) {
        String p = path.toLowerCase();

        // --- Por SERVLET ---
        if (p.equals("/panelservlet") || p.equals("/usuarioservlet") || p.equals("/clienteservlet")
                || p.equals("/landingstationservlet") || p.equals("/redessubmarinasservlet")) return 1;
        if (p.startsWith("/capacity-planner") || p.equals("/capacityplannerservlet") || p.equals("/rutaservlet")) return 2;
        if (p.equals("/networkoperatorservlet")) return 3;
        if (p.startsWith("/maintenance-coordinator") || p.equals("/maintenancecoordinatorservlet")) return 4;
        if (p.startsWith("/supervisor")) return 5; // /supervisor/panel, /SupervisorServlet, /supervisor/exportar-csv

        // --- Por VISTA (/views/*.jsp) ---
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
        if (p.equals("/acceso-por-rol.html")) return 1;

        return 0; // ruta compartida / sin rol específico
    }
}
