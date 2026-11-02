package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.RolDAO;
import pe.edu.oceanlink.dao.UsuarioDAO;
import pe.edu.oceanlink.bean.Usuario;

import java.io.IOException;
import java.util.ArrayList;
import java.sql.SQLException;

@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        UsuarioDAO usuarioDao = new UsuarioDAO();
        RolDAO rolDao = new RolDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                ArrayList<Usuario> listaUsuarios = usuarioDao.obtenerListaUsuarios();
                request.setAttribute("lista", listaUsuarios);
                view = request.getRequestDispatcher("/views/usuarios.jsp");
                view.forward(request, response);
                break;
            case "formCrear":
                request.setAttribute("roles", rolDao.obtenerListaRoles());
                view = request.getRequestDispatcher("/views/usuario-form.jsp");
                view.forward(request, response);
                break;
            case "editar":
                String userId = request.getParameter("id");
                Usuario usuario = usuarioDao.obtenerUsuario(userId);
                if (usuario == null) {
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                } else {
                    request.setAttribute("usuario", usuario);
                    request.setAttribute("roles", rolDao.obtenerListaRoles());
                    view = request.getRequestDispatcher("/views/usuario-form.jsp");
                    view.forward(request, response);
                }
                break;
            case "cambiarEstado":
                String idCambio = request.getParameter("id");
                String estado = request.getParameter("estado");
                usuarioDao.cambiarEstado(idCambio, estado);
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet?action=lista");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        UsuarioDAO usuarioDao = new UsuarioDAO();

        switch (action) {
            case "crear":
                String idUsuario = request.getParameter("idUsuario");
                String nombre = texto(request.getParameter("nombre"));
                String apellido = texto(request.getParameter("apellido"));
                String correo = texto(request.getParameter("correo"));
                String password = request.getParameter("password");
                String estado = request.getParameter("estado");
                String idRol = request.getParameter("idRol");

                Usuario usuarioGuardar = new Usuario();
                usuarioGuardar.setNombre(nombre);
                usuarioGuardar.setApellido(apellido);
                usuarioGuardar.setCorreo(correo);
                usuarioGuardar.setPassword(password);
                usuarioGuardar.setEstado(estado);
                boolean edicion = idUsuario != null && !idUsuario.isEmpty();
                request.setAttribute("esEdicion", edicion);
                try {
                    if (edicion) usuarioGuardar.setIdUsuario(idPositivo(idUsuario));
                    usuarioGuardar.setIdRol(idPositivo(idRol));
                    validarUsuario(usuarioGuardar, edicion);
                    if (edicion) {
                        usuarioDao.actualizarUsuario(usuarioGuardar);
                    } else {
                        usuarioDao.crearUsuario(usuarioGuardar);
                    }
                } catch (IllegalArgumentException e) {
                    mostrarError(request, response, usuarioGuardar, e.getMessage());
                    return;
                } catch (SQLException e) {
                    log("No se pudo guardar el usuario", e);
                    String mensaje = e.getErrorCode() == 1062
                            ? "El correo ya está registrado. Ingresa otro correo."
                            : e.getErrorCode() == 1452
                            ? "El rol seleccionado no existe. Selecciona un rol válido."
                            : "No se pudo guardar el usuario. Actualiza el listado o inténtalo nuevamente.";
                    mostrarError(request, response, usuarioGuardar, mensaje);
                    return;
                } catch (ClassNotFoundException e) {
                    log("No se pudo cargar el controlador JDBC", e);
                    mostrarError(request, response, usuarioGuardar,
                            "No se pudo conectar con la base de datos. Revisa la configuración del servidor.");
                    return;
                }

                String op = (idUsuario == null || idUsuario.isEmpty()) ? "crear" : "editar";
                response.sendRedirect(request.getContextPath() + "/views/operacion-exito.jsp?mod=usuario&op=" + op);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
        }
    }

    private static String texto(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private static int idPositivo(String valor) {
        try {
            int id = Integer.parseInt(valor);
            if (id > 0) return id;
        } catch (NumberFormatException e) {
            // Un identificador inválido se presenta como error del formulario.
        }
        throw new IllegalArgumentException("Selecciona un rol válido y verifica el identificador del usuario.");
    }

    private static void validarUsuario(Usuario usuario, boolean edicion) {
        if (usuario.getNombre().isEmpty() || usuario.getNombre().length() > 50
                || usuario.getApellido().isEmpty() || usuario.getApellido().length() > 50) {
            throw new IllegalArgumentException("Nombre y apellido son obligatorios y admiten hasta 50 caracteres cada uno.");
        }
        if (usuario.getCorreo().length() > 50
                || !usuario.getCorreo().matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) {
            throw new IllegalArgumentException("Ingresa un correo válido de hasta 50 caracteres.");
        }
        String clave = usuario.getPassword();
        if ((!edicion && (clave == null || clave.isBlank())) || (clave != null && clave.length() > 256)) {
            throw new IllegalArgumentException("La contraseña es obligatoria al registrar y admite hasta 256 caracteres.");
        }
        if (!"Activo".equals(usuario.getEstado()) && !"Inactivo".equals(usuario.getEstado())) {
            throw new IllegalArgumentException("Selecciona un estado válido: Activo o Inactivo.");
        }
    }

    private void mostrarError(HttpServletRequest request, HttpServletResponse response,
                              Usuario usuario, String mensaje) throws ServletException, IOException {
        usuario.setPassword(null);
        request.setAttribute("usuario", usuario);
        request.setAttribute("errorUsuario", mensaje);
        request.setAttribute("roles", new RolDAO().obtenerListaRoles());
        request.getRequestDispatcher("/views/usuario-form.jsp").forward(request, response);
    }
}
