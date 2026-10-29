
package pe.edu.oceanlink.bean;

import java.sql.Timestamp;

public class ObservacionIncidencia {

    private int idObservacion;
    private int idIncidencia;
    private String tipo;
    private String detalle;
    private Timestamp fechaRegistro;
    private String codigoIncidencia;
    private String tituloIncidencia;

    public ObservacionIncidencia() {
    }

    public int getIdObservacion() {
        return idObservacion;
    }

    public void setIdObservacion(int idObservacion) {
        this.idObservacion = idObservacion;
    }

    public int getIdIncidencia() {
        return idIncidencia;
    }

    public void setIdIncidencia(int idIncidencia) {
        this.idIncidencia = idIncidencia;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getDetalle() {
        return detalle;
    }

    public void setDetalle(String detalle) {
        this.detalle = detalle;
    }

    public Timestamp getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Timestamp fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getCodigoIncidencia() {
        return codigoIncidencia;
    }

    public void setCodigoIncidencia(String codigoIncidencia) {
        this.codigoIncidencia = codigoIncidencia;
    }

    public String getTituloIncidencia() {
        return tituloIncidencia;
    }

    public void setTituloIncidencia(String tituloIncidencia) {
        this.tituloIncidencia = tituloIncidencia;
    }
}
