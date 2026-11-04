package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.SupervisorDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import pe.edu.oceanlink.bean.SupervisorAfectado;

/** Controlador MVC de solo consulta para el Panel General del Supervisor. */
@WebServlet(name = "SupervisorServlet", urlPatterns = {"/supervisor/panel", "/supervisor/incidencias", "/supervisor/afectados", "/supervisor/reportes", "/SupervisorServlet"})
public class SupervisorServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        SupervisorDAO dao = new SupervisorDAO();
        String path = request.getServletPath();
        try {
            if ("/supervisor/reportes".equals(path)) {
                String tipo = request.getParameter("tipo");
                if (!"capacidad".equals(tipo) && !"servicios".equals(tipo)) tipo = "fallas";
                java.time.LocalDate inicio, fin;
                try {
                    String a = request.getParameter("inicio");
                    String b = request.getParameter("fin");
                    inicio = (a == null || a.isBlank()) ? null : java.time.LocalDate.parse(a);
                    fin = (b == null || b.isBlank()) ? null : java.time.LocalDate.parse(b);
                } catch (java.time.format.DateTimeParseException e) {
                    response.sendError(400, "Fecha inválida. Utiliza AAAA-MM-DD."); return;
                }
                if (inicio != null && fin != null && inicio.isAfter(fin)) {
                    response.sendError(400, "La fecha inicial no puede superar la final."); return;
                }
                java.util.ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> filas =
                    dao.listarReporte(tipo, inicio, fin);
                request.setAttribute("tipoReporte", tipo);
                request.setAttribute("fechaInicio", inicio == null ? "" : inicio.toString());
                request.setAttribute("fechaFin", fin == null ? "" : fin.toString());
                request.setAttribute("filasReporte", filas);
                request.getRequestDispatcher("/views/supervisor-reportes.jsp").forward(request,response);
                return;
            }
            if ("/supervisor/afectados".equals(path)) {
                String clave=request.getParameter("clave");
                if(clave == null || !clave.matches("[IM]:[0-9]{1,10}")) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST,"Identificador inválido");return;
                }
                request.setAttribute("afectados",dao.listarAfectados(clave));
                request.getRequestDispatcher("/views/supervisor-afectados.jsp").forward(request,response);
                return;
            }
            if ("/supervisor/incidencias".equals(path)) {
                request.setAttribute("eventos",dao.listarEventos());
                request.getRequestDispatcher("/views/supervisor-incidencias.jsp").forward(request,response);
                return;
            }
            request.setAttribute("resumen", dao.obtenerResumen());
            request.setAttribute("tramos", dao.listarTramosAltaUtilizacion());
            request.getRequestDispatcher("/views/supervisor-dashboard.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException("No se pudo consultar el panel de Supervisor.", ex);
        }
    }

}
