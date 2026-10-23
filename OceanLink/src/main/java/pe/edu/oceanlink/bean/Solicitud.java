package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Solicitud {
    private int idSolicitud;
    private String codigo;
    private int idCliente;
    private String clienteNombre;
    private int idRuta;
    private String rutaNombre;
    private BigDecimal capacidadSolicitada;
    private LocalDate fechaSolicitud;
    private LocalDate fechaLimite;
    private String motivo;
    private String estado;
    private String observacion;
    private int idUsuario;

    public int getIdSolicitud() { return idSolicitud; }
    public void setIdSolicitud(int v) { idSolicitud = v; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String v) { codigo = v; }
    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int v) { idCliente = v; }
    public String getClienteNombre() { return clienteNombre; }
    public void setClienteNombre(String v) { clienteNombre = v; }
    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int v) { idRuta = v; }
    public String getRutaNombre() { return rutaNombre; }
    public void setRutaNombre(String v) { rutaNombre = v; }
    public BigDecimal getCapacidadSolicitada() { return capacidadSolicitada; }
    public void setCapacidadSolicitada(BigDecimal v) { capacidadSolicitada = v; }
    public LocalDate getFechaSolicitud() { return fechaSolicitud; }
    public void setFechaSolicitud(LocalDate v) { fechaSolicitud = v; }
    public LocalDate getFechaLimite() { return fechaLimite; }
    public void setFechaLimite(LocalDate v) { fechaLimite = v; }
    public String getMotivo() { return motivo; }
    public void setMotivo(String v) { motivo = v; }
    public String getEstado() { return estado; }
    public void setEstado(String v) { estado = v; }
    public String getObservacion() { return observacion; }
    public void setObservacion(String v) { observacion = v; }
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int v) { idUsuario = v; }
}
