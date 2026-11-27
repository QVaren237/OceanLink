package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.bean.SupervisorReporteFila;
import pe.edu.oceanlink.dao.SupervisorDAO;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;

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

        SupervisorDAO dao = new SupervisorDAO();
        ArrayList<SupervisorReporteFila> filas;
        try {
            filas = dao.listarReporte(tipo, inicio, fin);
        } catch (SQLException ex) {
            throw new ServletException("Error al consultar los datos del reporte CSV.", ex);
        }

        String prefijo;
        String[] cabeceras;
        switch (tipo) {
            case "capacidad":
                prefijo = "uso-capacidad";
                cabeceras = new String[]{"Segmento", "Fecha Registro", "Capacidad Total", "Capacidad Disponible", "Utilización"};
                break;
            case "servicios":
                prefijo = "servicios-por-cliente";
                cabeceras = new String[]{"Cliente", "Fecha Activación", "Servicio", "Ruta", "Capacidad Contratada"};
                break;
            default:
                prefijo = "historico-fallas";
                cabeceras = new String[]{"ID Evento", "Fecha Resolución", "Tramo", "Impacto Potencial", "Estado Final"};
        }

        int numero = siguienteNumero(request.getSession(), tipo);
        String nombre = prefijo + "-" + numero + ".csv";
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombre + "\"");
        response.setHeader("Cache-Control", "no-store");

        PrintWriter writer = response.getWriter();
        writer.write('\uFEFF');
        escribirFila(writer, cabeceras);
        for (SupervisorReporteFila fila : filas) {
            escribirFila(writer, new String[]{
                    fila.getC1(), fila.getC2(), fila.getC3(), fila.getC4(), fila.getC5()
            });
        }
        writer.flush();
    }

    private static int siguienteNumero(HttpSession sesion, String tipo) {
        String atributo = "supervisor.csv.descargas." + tipo;
        synchronized (sesion) {
            Integer anterior = (Integer) sesion.getAttribute(atributo);
            int numero = anterior == null ? 1 : anterior + 1;
            sesion.setAttribute(atributo, numero);
            return numero;
        }
    }

    private static LocalDate leerFecha(String valor) {
        return valor == null || valor.isBlank() ? null : LocalDate.parse(valor);
    }

    private static String escapar(String valor) {
        if (valor == null) valor = "";
        valor = valor.replace("\r", " ").replace("\n", " ");
        String sinEspacios = valor.stripLeading();
        if (!sinEspacios.isEmpty() && "=+-@".indexOf(sinEspacios.charAt(0)) >= 0) {
            valor = "'" + valor;
        }
        if (valor.indexOf(';') >= 0 || valor.indexOf('"') >= 0) {
            return "\"" + valor.replace("\"", "\"\"") + "\"";
        }
        return valor;
    }

    private static void escribirFila(PrintWriter writer, String[] campos) {
        for (int i = 0; i < campos.length; i++) {
            if (i > 0) writer.print(';');
            writer.print(escapar(campos[i]));
        }
        writer.print("\r\n");
    }
}
