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
                String nombre = request.getParameter("nombre");
                String apellido = request.getParameter("apellido");
                String correo = request.getParameter("correo");
                String password = request.getParameter("password");
                String estado = request.getParameter("estado");
                String idRol = request.getParameter("idRol");

                Usuario usuarioGuardar = new Usuario();
                usuarioGuardar.setNombre(nombre);
                usuarioGuardar.setApellido(apellido);
                usuarioGuardar.setCorreo(correo);
                usuarioGuardar.setPassword(password);
                usuarioGuardar.setEstado(estado);
                usuarioGuardar.setIdRol(idRol == null || idRol.isEmpty() ? 0 : Integer.parseInt(idRol));

                if (idUsuario == null || idUsuario.isEmpty()) {
                    usuarioDao.crearUsuario(usuarioGuardar);
                } else {
                    usuarioGuardar.setIdUsuario(Integer.parseInt(idUsuario));
                    usuarioDao.actualizarUsuario(usuarioGuardar);
                }

                String op = (idUsuario == null || idUsuario.isEmpty()) ? "crear" : "editar";
                response.sendRedirect(request.getContextPath() + "/views/operacion-exito.jsp?mod=usuario&op=" + op);
                break;
        }
    }
}
