package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.RolDAO;
import pe.edu.oceanlink.dao.UsuarioDAO;
import pe.edu.oceanlink.util.SesionContador;

import java.io.IOException;

@WebServlet(name = "PanelServlet", value = "/PanelServlet")
public class PanelServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UsuarioDAO usuarioDao = new UsuarioDAO();
        RolDAO rolDao = new RolDAO();

        request.setAttribute("totalUsuarios", usuarioDao.contarUsuarios());
        request.setAttribute("usuariosActivos", usuarioDao.contarUsuariosActivos());
        request.setAttribute("totalRoles", rolDao.contarRoles());
        request.setAttribute("recientes", usuarioDao.obtenerUsuariosRecientes(5));
        request.setAttribute("sesionesActivas", SesionContador.activas()); // sesiones realmente abiertas

        request.getRequestDispatcher("/views/panel.jsp").forward(request, response);
    }
}
