package pe.edu.oceanlink.bean;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Conteos de los dos tipos de eventos en un mes del período consultado. */
public class SupervisorMes {
    private static final DateTimeFormatter FORMATO = DateTimeFormatter.ofPattern("MMM yyyy", new Locale("es", "PE"));

    private final String etiqueta;
    private final int incidencias;
    private final int mantenimientos;

    public SupervisorMes(String mes, int incidencias, int mantenimientos) {
        this.etiqueta = YearMonth.parse(mes).format(FORMATO);
        this.incidencias = incidencias;
        this.mantenimientos = mantenimientos;
    }

    public String getEtiqueta() {
        return etiqueta;
    }

    public int getIncidencias() {
        return incidencias;
    }

    public int getMantenimientos() {
        return mantenimientos;
    }
}
