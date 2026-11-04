package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Consulta de capacidad; no modifica la infraestructura ni las reservas. */
public class CapacidadEnlace {
    private int idSegmento;
    private String codigo;
    private String nombreOrigen;
    private String nombreDestino;
    private String ubicacionOrigen;
    private String ubicacionDestino;
    private String estado;
    private String descripcion;
    private BigDecimal capacidadTotal;
    private BigDecimal capacidadUtilizada;
    private BigDecimal capacidadReservada;
    private BigDecimal longitudKm;
    public int getIdSegmento() { return idSegmento; }
    public void setIdSegmento(int valor) { idSegmento = valor; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String valor) { codigo = valor; }
    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String valor) { nombreOrigen = valor; }
    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String valor) { nombreDestino = valor; }
    public String getUbicacionOrigen() { return ubicacionOrigen; }
    public void setUbicacionOrigen(String valor) { ubicacionOrigen = valor; }
    public String getUbicacionDestino() { return ubicacionDestino; }
    public void setUbicacionDestino(String valor) { ubicacionDestino = valor; }
    public String getEstado() { return estado; }
    public void setEstado(String valor) { estado = valor; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String valor) { descripcion = valor; }
    public BigDecimal getCapacidadTotal() { return capacidadTotal; }
    public void setCapacidadTotal(BigDecimal valor) { capacidadTotal = valor; }
    public BigDecimal getCapacidadUtilizada() { return capacidadUtilizada; }
    public void setCapacidadUtilizada(BigDecimal valor) { capacidadUtilizada = valor; }
    public BigDecimal getCapacidadReservada() { return capacidadReservada; }
    public void setCapacidadReservada(BigDecimal valor) { capacidadReservada = valor; }
    public BigDecimal getLongitudKm() { return longitudKm; }
    public void setLongitudKm(BigDecimal valor) { longitudKm = valor; }

    public String getNombre() { return nombreOrigen + " - " + nombreDestino; }
    // El módulo de alertas de la maqueta usa un umbral preventivo del 85%.
    public boolean isAlertaSaturacion() {
        return getPorcentajeUtilizacion()!=null && getCapacidadAsignada().multiply(BigDecimal.valueOf(100))
                .compareTo(capacidadTotal.multiply(BigDecimal.valueOf(85)))>=0;
    }
    public boolean isAlertaCritica() {
        return isAlertaSaturacion() && getCapacidadAsignada().multiply(BigDecimal.valueOf(100))
                .compareTo(capacidadTotal.multiply(BigDecimal.valueOf(95)))>0;
    }
    public BigDecimal getCapacidadAsignada() {
        return capacidadUtilizada == null || capacidadReservada == null ? null
                : capacidadUtilizada.add(capacidadReservada);
    }
    public BigDecimal getCapacidadDisponible() {
        return capacidadTotal == null || getCapacidadAsignada() == null ? null
                : capacidadTotal.subtract(getCapacidadAsignada());
    }
    // La maqueta representa la ocupación utilizada + reservada respecto de la capacidad física.
    public BigDecimal getPorcentajeUtilizacion() {
        return capacidadTotal == null || capacidadTotal.signum() <= 0 || getCapacidadAsignada() == null
                ? null : getCapacidadAsignada().multiply(BigDecimal.valueOf(100))
                        .divide(capacidadTotal, 6, RoundingMode.HALF_UP);
    }
    public String getNivelUtilizacion() {
        if (getPorcentajeUtilizacion() == null) return "Sin datos";
        BigDecimal ocupacion = getCapacidadAsignada().multiply(BigDecimal.valueOf(100));
        if (ocupacion.compareTo(capacidadTotal.multiply(BigDecimal.valueOf(95))) > 0) return "Crítica";
        if (ocupacion.compareTo(capacidadTotal.multiply(BigDecimal.valueOf(80))) >= 0) return "Alta";
        return "Normal";
    }
    public String getClaseUtilizacion() {
        String nivel = getNivelUtilizacion();
        return "Crítica".equals(nivel) ? "crit" : "Alta".equals(nivel) ? "warn" : "Normal".equals(nivel) ? "ok" : "neutral";
    }
    public String getAnchoProgreso() {
        BigDecimal porcentaje = getPorcentajeUtilizacion();
        return porcentaje == null ? "0" : porcentaje.max(BigDecimal.ZERO).min(BigDecimal.valueOf(100)).toPlainString();
    }
}
