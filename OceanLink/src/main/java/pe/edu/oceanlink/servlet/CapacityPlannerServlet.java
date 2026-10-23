package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.dao.RutaDAO;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CapacityPlannerServlet", value = {"/CapacityPlannerServlet", "/capacity-planner", "/capacity-planner/panel"})
public class CapacityPlannerServlet extends HttpServlet {
    private static final String VISTAS = "/views/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || "panel".equals(action)) {
            request.setAttribute("titulo", "Panel General");
            request.setAttribute("seccion", "panel");
            try {
                request.setAttribute("panel", new RutaDAO().obtenerResumenPanel());
            } catch (SQLException | ClassNotFoundException e) {
                log("No se pudo cargar el panel de Capacity Planner", e);
                response.setStatus(500);
                request.setAttribute("error", "No se pudo cargar el resumen. Verifica la conexión con MySQL e inténtalo nuevamente.");
            }
            request.getRequestDispatcher(VISTAS + "capacity-planner-panel.jsp").forward(request, response);
        } else if ("perfil".equals(action)) {
            request.setAttribute("titulo", "Mi perfil");
            request.setAttribute("seccion", "perfil");
            request.getRequestDispatcher(VISTAS + "capacity-planner-perfil.jsp").forward(request, response);
        } else if ("sesionCerrada".equals(action)) {
            request.setAttribute("titulo", "Sesión cerrada");
            request.setAttribute("seccion", "sesion");
            request.getRequestDispatcher(VISTAS + "capacity-planner-sesion-cerrada.jsp").forward(request, response);
        } else {
            response.sendError(400, "Acción no válida.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        if (!"cerrarSesion".equals(request.getParameter("action"))) {
            response.sendError(400, "Acción no válida.");
            return;
        }
        HttpSession sesion = request.getSession(false);
        if (sesion != null) sesion.invalidate();
        response.sendRedirect(request.getContextPath() + "/capacity-planner/panel?action=sesionCerrada");
    }
}
