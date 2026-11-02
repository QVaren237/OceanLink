package pe.edu.oceanlink.bean;

import java.math.BigDecimal;

public class RutaSegmento {
    private int idRuta;
    private int idSegmento;
    private int orden;
    private BigDecimal capacidadRuta = BigDecimal.ZERO;
    private String codigo;
    private int idEstacionOrigen;
    private int idEstacionDestino;
    private String nombreOrigen;
    private String nombreDestino;
    private String estado;
    private BigDecimal capacidadTotal = BigDecimal.ZERO;
    private BigDecimal capacidadUtilizada = BigDecimal.ZERO;
    private BigDecimal capacidadReservada = BigDecimal.ZERO;

    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int idRuta) { this.idRuta = idRuta; }
    public int getIdSegmento() { return idSegmento; }
    public void setIdSegmento(int idSegmento) { this.idSegmento = idSegmento; }
    public int getOrden() { return orden; }
    public void setOrden(int orden) { this.orden = orden; }
    public BigDecimal getCapacidadRuta() { return capacidadRuta; }
    public void setCapacidadRuta(BigDecimal capacidadRuta) { this.capacidadRuta = capacidadRuta; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
    public int getIdEstacionOrigen() { return idEstacionOrigen; }
    public void setIdEstacionOrigen(int idEstacionOrigen) { this.idEstacionOrigen = idEstacionOrigen; }
    public int getIdEstacionDestino() { return idEstacionDestino; }
    public void setIdEstacionDestino(int idEstacionDestino) { this.idEstacionDestino = idEstacionDestino; }
    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String nombreOrigen) { this.nombreOrigen = nombreOrigen; }
    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String nombreDestino) { this.nombreDestino = nombreDestino; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public BigDecimal getCapacidadTotal() { return capacidadTotal; }
    public void setCapacidadTotal(BigDecimal valor) { capacidadTotal = valor == null ? BigDecimal.ZERO : valor; }
    public BigDecimal getCapacidadUtilizada() { return capacidadUtilizada; }
    public void setCapacidadUtilizada(BigDecimal valor) { capacidadUtilizada = valor == null ? BigDecimal.ZERO : valor; }
    public BigDecimal getCapacidadReservada() { return capacidadReservada; }
    public void setCapacidadReservada(BigDecimal valor) { capacidadReservada = valor == null ? BigDecimal.ZERO : valor; }
    public BigDecimal getCapacidadDisponible() { return capacidadTotal.subtract(capacidadUtilizada).subtract(capacidadReservada); }
}
