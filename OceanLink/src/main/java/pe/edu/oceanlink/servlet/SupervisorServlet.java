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
                String fechaInicio = request.getParameter("inicio");
                String fechaFin = request.getParameter("fin");
                java.time.LocalDate inicio = null;
                java.time.LocalDate fin = null;
                String errorPeriodo = null;
                try {
                    inicio = leerFechaReporte(fechaInicio);
                    fin = leerFechaReporte(fechaFin);
                    if (inicio != null && fin != null && inicio.isAfter(fin)) {
                        errorPeriodo = "La fecha de inicio debe ser anterior o igual a la fecha de fin.";
                    }
                } catch (java.time.format.DateTimeParseException e) {
                    errorPeriodo = "Fecha inválida. Utiliza AAAA-MM-DD.";
                }

                request.setAttribute("tipoReporte", tipo);
                request.setAttribute("fechaInicio", fechaInicio == null || fechaInicio.isBlank() ? "" : fechaInicio);
                request.setAttribute("fechaFin", fechaFin == null || fechaFin.isBlank() ? "" : fechaFin);
                if (errorPeriodo == null) {
                    request.setAttribute("filasReporte", dao.listarReporte(tipo, inicio, fin));
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("errorPeriodo", errorPeriodo);
                }
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

    private java.time.LocalDate leerFechaReporte(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        if (!valor.matches("[1-9][0-9]{3}-[0-9]{2}-[0-9]{2}")) {
            throw new java.time.format.DateTimeParseException("Fecha fuera del formato esperado", valor, 0);
        }
        return java.time.LocalDate.parse(valor);
    }
}
