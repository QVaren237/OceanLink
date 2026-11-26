package pe.edu.oceanlink.servlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.dao.UsuarioDAO;
import pe.edu.oceanlink.util.SesionRegistro;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.Base64;

@WebServlet(name = "PerfilServlet", urlPatterns = {"/PerfilServlet"})
@MultipartConfig(
        maxFileSize = 2097152,
        maxRequestSize = 3145728
)
public class PerfilServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    private Usuario obtenerUsuario(HttpSession session) {
        Object cuenta = session.getAttribute("usuarioSesion");

        if (!(cuenta instanceof Usuario)) {
            cuenta = session.getAttribute("usuario");
        }

        return cuenta instanceof Usuario ? (Usuario) cuenta : null;
    }

    private String obtenerNombreRol(int idRol) {
        switch (idRol) {
            case 1: return "Administrador";
            case 2: return "Capacity Planner";
            case 3: return "Network Operator";
            case 4: return "Maintenance Coordinator";
            case 5: return "Supervisor";
            default: return "Usuario";
        }
    }

    private String obtenerPanel(int idRol) {
        switch (idRol) {
            case 1:
                return "/PanelServlet";

            case 2:
                return "/CapacityPlannerServlet";

            case 3:
                return "/NetworkOperatorServlet?action=panel";

            case 4:
                return "/maintenance-coordinator/mantenimientos";

            case 5:
                return "/SupervisorServlet";

            default:
                return "/LoginServlet";
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        Usuario cuenta = obtenerUsuario(session);

        if (cuenta == null || cuenta.getIdUsuario() <= 0
                || cuenta.getIdRol() < 1 || cuenta.getIdRol() > 5) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        cargarDatosPerfil(request, cuenta);

        request.getRequestDispatcher("/views/perfil.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        Usuario actual = obtenerUsuario(session);

        if (actual == null || actual.getIdUsuario() <= 0
                || actual.getIdRol() < 1 || actual.getIdRol() > 5) {
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
            return;
        }

        String nombre = trim(request.getParameter("nombre"));
        String apellido = trim(request.getParameter("apellido"));
        String correo = trim(request.getParameter("correo"));

        String claveActual = request.getParameter("claveActual");
        String nuevaPassword = request.getParameter("nuevaPassword");
        String confirmarPassword = request.getParameter("confirmarPassword");

        if (nuevaPassword == null) nuevaPassword = "";
        if (confirmarPassword == null) confirmarPassword = "";

        byte[] foto = null;

        boolean quitarFoto =
                "true".equals(request.getParameter("quitarFoto"));

        try {

            if (nombre.isEmpty() || apellido.isEmpty()) {
                throw new IllegalArgumentException(
                        "El nombre y apellido son obligatorios."
                );
            }

            if (nombre.length() > 50 || apellido.length() > 50) {
                throw new IllegalArgumentException(
                        "El nombre y apellido admiten hasta 50 caracteres."
                );
            }

            if (correo.length() > 50 ||
                    !correo.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) {
                throw new IllegalArgumentException(
                        "Ingresa un correo electrónico válido."
                );
            }

            if (claveActual == null || claveActual.isEmpty()) {
                throw new IllegalArgumentException(
                        "Ingresa tu contraseña actual."
                );
            }

            if (nuevaPassword.length() > 256) {
                throw new IllegalArgumentException(
                        "La nueva contraseña admite hasta 256 caracteres."
                );
            }

            if (!nuevaPassword.equals(confirmarPassword)) {
                throw new IllegalArgumentException(
                        "Las contraseñas nuevas no coinciden."
                );
            }

            Part archivo = request.getPart("foto");

            if (archivo != null && archivo.getSize() > 0) {

                String tipo = archivo.getContentType();

                if (!"image/jpeg".equals(tipo)
                        && !"image/png".equals(tipo)) {
                    throw new IllegalArgumentException(
                            "La foto debe estar en formato JPG o PNG."
                    );
                }

                if (archivo.getSize() > 2097152) {
                    throw new IllegalArgumentException(
                            "La fotografía no debe superar los 2 MB."
                    );
                }

                try (InputStream entrada = archivo.getInputStream()) {
                    foto = entrada.readAllBytes();
                }
            }

            Usuario editado = new Usuario();

            editado.setIdUsuario(actual.getIdUsuario());
            editado.setNombre(nombre);
            editado.setApellido(apellido);
            editado.setCorreo(correo);
            editado.setPassword(nuevaPassword);

            editado.setIdRol(actual.getIdRol());
            editado.setEstado(actual.getEstado());

            String correoAnterior = actual.getCorreo();

            usuarioDAO.actualizarPerfil(
                    editado,
                    claveActual,
                    foto,
                    quitarFoto
            );

            actual.setNombre(nombre);
            actual.setApellido(apellido);
            actual.setCorreo(correo);

            session.setAttribute("usuario", actual);
            session.setAttribute("usuarioSesion", actual);
            session.setAttribute("responsableSesion", actual);

            if (!correoAnterior.equalsIgnoreCase(correo)) {
                SesionRegistro.cerrarUsuario(correoAnterior);
                SesionRegistro.registrar(correo, session.getId());
            }

            if (quitarFoto) {
                session.removeAttribute("fotoPerfil");
            } else if (foto != null && foto.length > 0) {
                String __fmt = (foto.length >= 8 && foto[0] == (byte) 0x89) ? "png" : "jpeg";
                session.setAttribute("fotoPerfil",
                        "data:image/" + __fmt + ";base64," + Base64.getEncoder().encodeToString(foto));
            }

            response.sendRedirect(
                    request.getContextPath() + obtenerPanel(actual.getIdRol())
            );

        } catch (IllegalArgumentException e) {

            request.setAttribute("error", e.getMessage());

            cargarDatosPerfil(request, actual);

            request.getRequestDispatcher("/views/perfil.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            log("Error al actualizar el perfil del usuario.", e);

            if (e.getErrorCode() == 1062) {
                request.setAttribute(
                        "error",
                        "Este correo electrónico ya está registrado."
                );
            } else {
                request.setAttribute(
                        "error",
                        "No se pudo actualizar el perfil. Inténtalo nuevamente."
                );
            }

            cargarDatosPerfil(request, actual);

            request.getRequestDispatcher("/views/perfil.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            log("Error inesperado al actualizar el perfil.", e);

            request.setAttribute(
                    "error",
                    "Ocurrió un error al procesar tu solicitud."
            );

            cargarDatosPerfil(request, actual);

            request.getRequestDispatcher("/views/perfil.jsp")
                    .forward(request, response);
        }
    }

    private void cargarDatosPerfil(HttpServletRequest request,
                                   Usuario cuenta) {

        request.setAttribute("cuenta", cuenta);

        request.setAttribute(
                "nombreRol",
                obtenerNombreRol(cuenta.getIdRol())
        );

        request.setAttribute(
                "urlPanel",
                request.getContextPath() + obtenerPanel(cuenta.getIdRol())
        );

        try {
            byte[] foto = usuarioDAO.obtenerFoto(cuenta.getIdUsuario());

            if (foto != null && foto.length > 0) {

                String formato = foto.length >= 8
                        && foto[0] == (byte) 0x89
                        ? "png" : "jpeg";

                request.setAttribute(
                        "fotoPerfil",
                        "data:image/" + formato + ";base64,"
                                + Base64.getEncoder().encodeToString(foto)
                );
            }

        } catch (SQLException e) {
            log("No se pudo cargar la fotografía del perfil.", e);
        }
    }

    private String trim(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
