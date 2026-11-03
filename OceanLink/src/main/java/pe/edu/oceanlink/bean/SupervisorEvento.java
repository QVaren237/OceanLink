package pe.edu.oceanlink.bean;

/** Evento de incidencia o mantenimiento consultado por Supervisor (solo lectura). */
public class SupervisorEvento {
    private String codigo, tipo, tramo, gravedad, estado;
    private String clave; // I:id o M:id
    public String getCodigo(){return codigo;}
    public void setCodigo(String v){codigo=v;}
    public String getTipo(){return tipo;}
    public void setTipo(String v){tipo=v;}
    public String getTramo(){return tramo;}
    public void setTramo(String v){tramo=v;}
    public String getGravedad(){return gravedad;}
    public void setGravedad(String v){gravedad=v;}
    public String getEstado(){return estado;}
    public void setEstado(String v){estado=v;}
    public String getClave(){return clave;}
    public void setClave(String v){clave=v;}
}
