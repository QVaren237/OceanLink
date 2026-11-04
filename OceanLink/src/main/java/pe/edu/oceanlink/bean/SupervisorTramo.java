package pe.edu.oceanlink.bean;

import java.math.BigDecimal;

public class SupervisorTramo {
    private String codigo;
    private String origen;
    private String destino;
    private String estado;
    private BigDecimal capacidadTotal;
    private BigDecimal capacidadDisponible;
    private BigDecimal porcentajeUtilizacion;

    public String getCodigo() { return codigo; }
    public void setCodigo(String valor) { this.codigo = valor; }
    public String getOrigen() { return origen; }
    public void setOrigen(String valor) { this.origen = valor; }
    public String getDestino() { return destino; }
    public void setDestino(String valor) { this.destino = valor; }
    public String getEstado() { return estado; }
    public void setEstado(String valor) { this.estado = valor; }
    public BigDecimal getCapacidadTotal() { return capacidadTotal; }
    public void setCapacidadTotal(BigDecimal valor) { this.capacidadTotal = valor; }
    public BigDecimal getCapacidadDisponible() { return capacidadDisponible; }
    public void setCapacidadDisponible(BigDecimal valor) { this.capacidadDisponible = valor; }
    public BigDecimal getPorcentajeUtilizacion() { return porcentajeUtilizacion; }
    public void setPorcentajeUtilizacion(BigDecimal valor) { this.porcentajeUtilizacion = valor; }
}
