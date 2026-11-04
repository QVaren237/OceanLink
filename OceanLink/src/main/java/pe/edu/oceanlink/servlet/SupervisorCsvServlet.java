package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.bean.SupervisorReporteFila;
import pe.edu.oceanlink.dao.SupervisorDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;

/** Exporta reportes del Supervisor, siguiendo el patrón PdfServlet del laboratorio IWEB. */
@WebServlet("/supervisor/exportar-csv")
public class SupervisorCsvServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tipo = request.getParameter("tipo");
        if (tipo == null || (!tipo.equals("fallas") && !tipo.equals("capacidad") && !tipo.equals("servicios"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de informe inválido.");
            return;
        }

        LocalDate inicio;
        LocalDate fin;
        try {
            inicio = leerFecha(request.getParameter("inicio"));
            fin = leerFecha(request.getParameter("fin"));
        } catch (DateTimeParseException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Formato de fecha inválido (AAAA-MM-DD).");
            return;
        }
        if (inicio != null && fin != null && inicio.isAfter(fin)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "La fecha inicial no puede superar la final.");
            return;
        }

        // La misma consulta usada en la tabla JSP garantiza el mismo filtro de resultados.
        SupervisorDAO dao = new SupervisorDAO();
        ArrayList<SupervisorReporteFila> filas;
        try {
            filas = dao.listarReporte(tipo, inicio, fin);
        } catch (SQLException ex) {
            throw new ServletException("Error al consultar los datos del reporte CSV.", ex);
        }

        String nombre;
        String[] cabeceras;
        switch (tipo) {
            case "capacidad":
                nombre = "uso-capacidad.csv";
                cabeceras = new String[]{"Segmento", "Fecha Registro", "Capacidad Total", "Capacidad Disponible", "Utilización"};
                break;
            case "servicios":
                nombre = "servicios-por-cliente.csv";
                cabeceras = new String[]{"Cliente", "Fecha Activación", "Servicio", "Ruta", "Capacidad Contratada"};
                break;
            default:
                nombre = "historico-fallas.csv";
                cabeceras = new String[]{"ID Evento", "Fecha Resolución", "Tramo", "Impacto Potencial", "Estado Final"};
        }

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombre + "\"");
        response.setHeader("Cache-Control", "no-store");

        PrintWriter writer = response.getWriter();
        writer.write('\uFEFF'); // BOM UTF-8: facilita la lectura de tildes en Excel.
        escribirFila(writer, cabeceras);
        for (SupervisorReporteFila fila : filas) {
            escribirFila(writer, new String[]{
                    fila.getC1(), fila.getC2(), fila.getC3(), fila.getC4(), fila.getC5()
            });
        }
        writer.flush();
    }

    private static LocalDate leerFecha(String valor) {
        return valor == null || valor.isBlank() ? null : LocalDate.parse(valor);
    }

    /** Escapa comillas/separadores y neutraliza fórmulas en hojas de cálculo. */
    private static String escapar(String valor) {
        if (valor == null) valor = "";
        valor = valor.replace("\r", " ").replace("\n", " ");
        String sinEspacios = valor.stripLeading();
        if (!sinEspacios.isEmpty() && "=+-@".indexOf(sinEspacios.charAt(0)) >= 0) {
            valor = "'" + valor;
        }
        return "\"" + valor.replace("\"", "\"\"") + "\"";
    }

    private static void escribirFila(PrintWriter writer, String[] campos) {
        for (int i = 0; i < campos.length; i++) {
            if (i > 0) writer.print(',');
            writer.print(escapar(campos[i]));
        }
        writer.print("\r\n");
    }
}
