package pe.edu.oceanlink.servlet;

import com.lowagie.text.DocumentException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.bean.SupervisorEstadisticas;
import pe.edu.oceanlink.dao.SupervisorDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

@WebServlet({"/supervisor/estadisticas", "/supervisor/estadisticas/pdf"})
public class SupervisorEstadisticasServlet extends HttpServlet {

    private static final String VISTA = "/views/supervisor-estadisticas.jsp";
    private static final ZoneId ZONA_LIMA = ZoneId.of("America/Lima");
    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean pdf = "/supervisor/estadisticas/pdf".equals(request.getServletPath());
        response.setHeader("Cache-Control", "no-store");

        LocalDate inicio = null;
        LocalDate fin = null;
        String error = null;
        try {
            String inicioParam = request.getParameter("inicio");
            String finParam = request.getParameter("fin");
            if (inicioParam == null && finParam == null) {
                fin = LocalDate.now(ZONA_LIMA);
                inicio = fin.minusMonths(12).plusDays(1);
            } else {
                inicio = leerFecha(inicioParam);
                fin = leerFecha(finParam);
                if (inicio.isAfter(fin)) {
                    error = "La fecha de inicio debe ser anterior o igual a la fecha de fin.";
                }
            }
        } catch (DateTimeParseException ex) {
            error = "Ingresa ambas fechas en el formato AAAA-MM-DD, con años entre 1000 y 9999.";
        }

        if (error != null) {
            if (pdf) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, error);
                return;
            }
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("errorPeriodo", error);
        } else {
            SupervisorEstadisticas estadisticas;
            try {
                estadisticas = new SupervisorDAO().obtenerEstadisticas(inicio, fin);
            } catch (SQLException ex) {
                throw new ServletException("No se pudieron consultar las estadísticas del Supervisor.", ex);
            }

            String periodo = inicio.format(FORMATO_FECHA) + " al " + fin.format(FORMATO_FECHA);
            if (pdf) {
                escribirPdf(response, estadisticas, inicio, fin, periodo);
                return;
            }
            request.setAttribute("estadisticas", estadisticas);
            request.setAttribute("periodo", periodo);
        }
        request.setAttribute("inicio", inicio);
        request.setAttribute("fin", fin);
        request.getRequestDispatcher(VISTA).forward(request, response);
    }

    private LocalDate leerFecha(String valor) {
        if (valor == null || !valor.matches("[0-9]{4}-[0-9]{2}-[0-9]{2}") || valor.startsWith("0")) {
            throw new DateTimeParseException("Fecha fuera del formato esperado", valor == null ? "" : valor, 0);
        }
        return LocalDate.parse(valor);
    }

    private void escribirPdf(HttpServletResponse response, SupervisorEstadisticas datos,
                             LocalDate inicio, LocalDate fin, String periodo)
            throws IOException, ServletException {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"oceanlink-estadisticas-" + inicio + "-" + fin + ".pdf\"");

        try {
            SupervisorEstadisticasPdf.escribir(response.getOutputStream(), datos, periodo);
        } catch (DocumentException ex) {
            throw new ServletException("No se pudo generar el PDF de estadísticas.", ex);
        }
    }
}
