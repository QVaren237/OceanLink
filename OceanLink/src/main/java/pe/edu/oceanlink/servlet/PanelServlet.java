package pe.edu.oceanlink.servlet;

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

@WebServlet(name = "PanelServlet", value = "/PanelServlet")
public class PanelServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UsuarioDAO usuarioDao = new UsuarioDAO();
        RolDAO rolDao = new RolDAO();

        // Datos reales para los indicadores del panel
        int totalUsuarios = usuarioDao.contarUsuarios();
        int usuariosActivos = usuarioDao.contarUsuariosActivos();
        int totalRoles = rolDao.contarRoles();
        ArrayList<Usuario> recientes = usuarioDao.obtenerUsuariosRecientes(4);

        request.setAttribute("totalUsuarios", totalUsuarios);
        request.setAttribute("usuariosActivos", usuariosActivos);
        request.setAttribute("totalRoles", totalRoles);
        request.setAttribute("recientes", recientes);

        request.getRequestDispatcher("/views/panel.jsp").forward(request, response);
    }
}

