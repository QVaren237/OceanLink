package pe.edu.oceanlink.bean;

import java.time.LocalDateTime;

public class Incidencia {
    private int idIncidencia;
    private String codigo;
    private String titulo;
    private String descripcion;
    private String severidad;
    private String estado;
    private LocalDateTime fechaDeteccion;
    private LocalDateTime fechaCierre;
    private int idUsuario;
    private String usuarioNombre;
    private String segmentos;

    public int getIdIncidencia() { return idIncidencia; }
    public void setIdIncidencia(int v) { idIncidencia = v; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String v) { codigo = v; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String v) { titulo = v; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String v) { descripcion = v; }
    public String getSeveridad() { return severidad; }
    public void setSeveridad(String v) { severidad = v; }
    public String getEstado() { return estado; }
    public void setEstado(String v) { estado = v; }
    public LocalDateTime getFechaDeteccion() { return fechaDeteccion; }
    public void setFechaDeteccion(LocalDateTime v) { fechaDeteccion = v; }
    public LocalDateTime getFechaCierre() { return fechaCierre; }
    public void setFechaCierre(LocalDateTime v) { fechaCierre = v; }
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int v) { idUsuario = v; }
    public String getUsuarioNombre() { return usuarioNombre; }
    public void setUsuarioNombre(String v) { usuarioNombre = v; }
    public String getSegmentos() { return segmentos; }
    public void setSegmentos(String v) { segmentos = v; }
}
