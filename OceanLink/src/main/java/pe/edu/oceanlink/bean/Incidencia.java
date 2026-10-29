
package pe.edu.oceanlink.bean;

import java.sql.Timestamp;

public class Incidencia {

    private int idIncidencia;
    private String codigo;
    private String titulo;
    private String descripcion;
    private String severidad;
    private String estado;
    private Timestamp fechaDeteccion;
    private Timestamp fechaCierre;
    private int idUsuario;
    private String redes;

    public Incidencia() {
    }

    public int getIdIncidencia() {
        return idIncidencia;
    }

    public void setIdIncidencia(int idIncidencia) {
        this.idIncidencia = idIncidencia;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getSeveridad() {
        return severidad;
    }

    public void setSeveridad(String severidad) {
        this.severidad = severidad;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Timestamp getFechaDeteccion() {
        return fechaDeteccion;
    }

    public void setFechaDeteccion(Timestamp fechaDeteccion) {
        this.fechaDeteccion = fechaDeteccion;
    }

    public Timestamp getFechaCierre() {
        return fechaCierre;
    }

    public void setFechaCierre(Timestamp fechaCierre) {
        this.fechaCierre = fechaCierre;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getRedes() {
        return redes;
    }

    public void setRedes(String redes) {
        this.redes = redes;
    }
}
