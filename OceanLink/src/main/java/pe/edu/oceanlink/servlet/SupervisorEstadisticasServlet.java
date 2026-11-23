package pe.edu.oceanlink.servlet;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.bean.SupervisorDatoGrafico;
import pe.edu.oceanlink.bean.SupervisorEstadisticas;
import pe.edu.oceanlink.bean.SupervisorMes;
import pe.edu.oceanlink.dao.SupervisorDAO;

import java.awt.Color;
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
    private static final String NOTA_CLIENTES = "El conteo de clientes se basa en las rutas actuales de sus servicios "
            + "no cancelados. Indica una afectación potencial.";
    private static final Color TINTA = new Color(32, 60, 62);
    private static final Color TEAL = new Color(6, 107, 113);
    private static final Color MORADO = new Color(120, 100, 166);
    private static final Color BORDE = new Color(219, 233, 231);

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
        request.setAttribute("notaClientes", NOTA_CLIENTES);
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

        Document documento = new Document();
        try {
            PdfWriter.getInstance(documento, response.getOutputStream());
            documento.addTitle("OceanLink | Estadísticas del Supervisor");
            documento.open();
            documento.add(new Paragraph("OceanLink | Estadísticas del Supervisor",
                    new Font(Font.HELVETICA, 20, Font.BOLD, TEAL)));
            documento.add(new Paragraph("Período consultado: " + periodo,
                    new Font(Font.HELVETICA, 11, Font.NORMAL, TINTA)));

            PdfPTable indicadores = tabla("Indicador", "Cantidad");
            fila(indicadores, "Incidencias detectadas", String.valueOf(datos.getTotalIncidencias()));
            fila(indicadores, "Incidencias abiertas", String.valueOf(datos.getIncidenciasAbiertas()));
            fila(indicadores, "Incidencias cerradas", String.valueOf(datos.getIncidenciasCerradas()));
            fila(indicadores, "Incidencias graves (críticas o altas)", String.valueOf(datos.getIncidenciasGraves()));
            fila(indicadores, "Mantenimientos", String.valueOf(datos.getTotalMantenimientos()));
            fila(indicadores, "Segmentos involucrados", String.valueOf(datos.getSegmentosInvolucrados()));
            fila(indicadores, "Clientes relacionados", String.valueOf(datos.getClientesRelacionados()));
            documento.add(indicadores);

            PdfPTable severidad = tabla("Severidad de las incidencias", "Cantidad");
            for (SupervisorDatoGrafico dato : datos.getSeveridades()) {
                severidad.addCell(celdaDato(dato.getEtiqueta()));
                severidad.addCell(celdaBarra(dato.getCantidad(), datos.getTotalIncidencias(), TEAL));
            }
            documento.add(severidad);

            if (datos.getMeses().isEmpty()) {
                Paragraph sinEventos = new Paragraph("No se registraron incidencias ni mantenimientos en este período.");
                sinEventos.setSpacingBefore(12);
                documento.add(sinEventos);
            } else {
                PdfPTable tendencia = tabla("Mes", "Incidencias detectadas", "Mantenimientos");
                int maximo = datos.getMaximoMensual();
                for (SupervisorMes mes : datos.getMeses()) {
                    tendencia.addCell(celdaDato(mes.getEtiqueta()));
                    tendencia.addCell(celdaBarra(mes.getIncidencias(), maximo, TEAL));
                    tendencia.addCell(celdaBarra(mes.getMantenimientos(), maximo, MORADO));
                }
                documento.add(tendencia);
            }

            Paragraph nota = new Paragraph("Las incidencias se agrupan por fecha de detección y su estado refleja el "
                    + "cierre registrado. Los mantenimientos se agrupan por fecha de inicio. " + NOTA_CLIENTES,
                    new Font(Font.HELVETICA, 9, Font.NORMAL, TINTA));
            nota.setSpacingBefore(14);
            documento.add(nota);
        } catch (DocumentException ex) {
            throw new ServletException("No se pudo generar el PDF de estadísticas.", ex);
        } finally {
            documento.close();
        }
    }

    private PdfPTable tabla(String... encabezados) {
        PdfPTable tabla = new PdfPTable(encabezados.length);
        tabla.setWidthPercentage(100);
        tabla.setSpacingBefore(13);
        tabla.setHeaderRows(1);
        for (String encabezado : encabezados) {
            PdfPCell celda = new PdfPCell(new Phrase(encabezado, new Font(Font.HELVETICA, 10, Font.BOLD, Color.WHITE)));
            celda.setPadding(7);
            celda.setBackgroundColor(TEAL);
            celda.setBorderColor(TEAL);
            tabla.addCell(celda);
        }
        return tabla;
    }

    private void fila(PdfPTable tabla, String... valores) {
        for (String valor : valores) {
            tabla.addCell(celdaDato(valor));
        }
    }

    private PdfPCell celdaDato(String valor) {
        PdfPCell celda = new PdfPCell(new Phrase(valor, new Font(Font.HELVETICA, 10, Font.NORMAL, TINTA)));
        celda.setPadding(6);
        celda.setBorderColor(BORDE);
        return celda;
    }

    private PdfPCell celdaBarra(int cantidad, int maximo, Color color) {
        PdfPCell celda = new PdfPCell();
        celda.setPadding(6);
        celda.setBorderColor(BORDE);
        celda.addElement(new Paragraph(String.valueOf(cantidad), new Font(Font.HELVETICA, 10, Font.NORMAL, TINTA)));
        PdfPTable barra = new PdfPTable(cantidad == 0 || cantidad == maximo
                ? new float[]{1} : new float[]{cantidad, maximo - cantidad});
        barra.setWidthPercentage(100);
        barra.setSpacingBefore(3);
        barra.addCell(tramoBarra(cantidad == 0 ? BORDE : color));
        if (cantidad > 0 && cantidad < maximo) {
            barra.addCell(tramoBarra(BORDE));
        }
        celda.addElement(barra);
        return celda;
    }

    private PdfPCell tramoBarra(Color color) {
        PdfPCell tramo = new PdfPCell();
        tramo.setBorder(PdfPCell.NO_BORDER);
        tramo.setFixedHeight(5);
        tramo.setBackgroundColor(color);
        return tramo;
    }
}

