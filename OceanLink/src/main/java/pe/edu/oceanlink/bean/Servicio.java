package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.time.LocalDate;

/** Representa la tabla servicio de OceanLink_DB_FIXED.sql. */
public class Servicio {
    private int idServicio;
    private String codigo;
    private int idCliente;
    private int idRuta;
    private String origen;
    private String destino;
    private BigDecimal capacidadContratada;
    private LocalDate fechaActivacion;
    private String estado;

    // Columnas adicionales de los JOIN para mostrar información en JSP.
    private String razonSocialCliente;
    private String nombreRuta;

    public Servicio() { }

    public int getIdServicio() { return idServicio; }
    public void setIdServicio(int idServicio) { this.idServicio = idServicio; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }
    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int idRuta) { this.idRuta = idRuta; }
    public String getOrigen() { return origen; }
    public void setOrigen(String origen) { this.origen = origen; }
    public String getDestino() { return destino; }
    public void setDestino(String destino) { this.destino = destino; }
    public BigDecimal getCapacidadContratada() { return capacidadContratada; }
    public void setCapacidadContratada(BigDecimal capacidadContratada) { this.capacidadContratada = capacidadContratada; }
    public LocalDate getFechaActivacion() { return fechaActivacion; }
    public void setFechaActivacion(LocalDate fechaActivacion) { this.fechaActivacion = fechaActivacion; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getRazonSocialCliente() { return razonSocialCliente; }
    public void setRazonSocialCliente(String razonSocialCliente) { this.razonSocialCliente = razonSocialCliente; }
    public String getNombreRuta() { return nombreRuta; }
    public void setNombreRuta(String nombreRuta) { this.nombreRuta = nombreRuta; }
}
