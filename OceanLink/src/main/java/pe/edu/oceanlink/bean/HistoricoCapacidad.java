package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Resumen mensual de las muestras guardadas en historial_capacidad. */
public class HistoricoCapacidad {
    private String periodo;
    private BigDecimal capacidadInstalada, sumaTrafico=BigDecimal.ZERO, pico, utilizacionMaxima, tendencia;
    private int muestrasTrafico;
    public String getPeriodo(){return periodo;}
    public void setPeriodo(String valor){periodo=valor;}
    public String getNombrePeriodo(){
        String nombre=YearMonth.parse(periodo).format(DateTimeFormatter.ofPattern("MMMM yyyy",new Locale("es","PE")));
        return Character.toUpperCase(nombre.charAt(0))+nombre.substring(1);
    }
    public BigDecimal getCapacidadInstalada(){return capacidadInstalada;}
    public BigDecimal getPromedio(){return muestrasTrafico==0?null:sumaTrafico.divide(BigDecimal.valueOf(muestrasTrafico),6,RoundingMode.HALF_UP);}
    public BigDecimal getPico(){return pico;}
    public BigDecimal getUtilizacionMaxima(){return utilizacionMaxima;}
    public BigDecimal getTendencia(){return tendencia;}
    public void setTendencia(BigDecimal valor){tendencia=valor;}
    public String getClaseUtilizacion(){return utilizacionMaxima==null?"neutral":utilizacionMaxima.compareTo(BigDecimal.valueOf(95))>0?"crit":utilizacionMaxima.compareTo(BigDecimal.valueOf(80))>=0?"warn":"ok";}

    // Las muestras se leen en orden cronológico; la última define la capacidad instalada del mes.
    public void agregarMuestra(BigDecimal total,BigDecimal utilizada,BigDecimal reservada){
        capacidadInstalada=total;
        if(utilizada!=null){sumaTrafico=sumaTrafico.add(utilizada);muestrasTrafico++;if(pico==null||utilizada.compareTo(pico)>0)pico=utilizada;}
        if(total!=null&&total.signum()>0&&utilizada!=null&&reservada!=null){
            BigDecimal porcentaje=utilizada.add(reservada).multiply(BigDecimal.valueOf(100)).divide(total,14,RoundingMode.HALF_UP);
            if(utilizacionMaxima==null||porcentaje.compareTo(utilizacionMaxima)>0)utilizacionMaxima=porcentaje;
        }
    }

    public static BigDecimal crecimiento(BigDecimal primero,BigDecimal ultimo){
        return primero==null||ultimo==null||primero.signum()<=0?null:
                ultimo.subtract(primero).multiply(BigDecimal.valueOf(100)).divide(primero,6,RoundingMode.HALF_UP);
    }
}
