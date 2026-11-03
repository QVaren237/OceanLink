package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.util.ArrayList;

public class EvaluacionCapacidad {
    private ArrayList<CapacidadEnlace> segmentos = new ArrayList<>();
    private SolicitudCapacidad solicitud;
    private String ruc;
    private String estadoCliente;
    private String estadoRuta;
    private String comentarioEvaluacion;
    private String evaluador;
    private java.sql.Timestamp fechaEvaluacion;
    public SolicitudCapacidad getSolicitud(){return solicitud;}
    public void setSolicitud(SolicitudCapacidad valor){solicitud=valor;}
    public String getRuc(){return ruc;}
    public void setRuc(String valor){ruc=valor;}
    public String getEstadoCliente(){return estadoCliente;}
    public void setEstadoCliente(String valor){estadoCliente=valor;}
    public String getEstadoRuta(){return estadoRuta;}
    public void setEstadoRuta(String valor){estadoRuta=valor;}
    public String getComentarioEvaluacion(){return comentarioEvaluacion;}
    public void setComentarioEvaluacion(String valor){comentarioEvaluacion=valor;}
    public String getEvaluador(){return evaluador;}
    public void setEvaluador(String valor){evaluador=valor;}
    public java.sql.Timestamp getFechaEvaluacion(){return fechaEvaluacion;}
    public void setFechaEvaluacion(java.sql.Timestamp valor){fechaEvaluacion=valor;}
    public ArrayList<CapacidadEnlace> getSegmentos(){return segmentos;}
    public void setSegmentos(ArrayList<CapacidadEnlace> valor){segmentos=valor;}
    public BigDecimal getDisponible(){
        BigDecimal minimo=null;
        for(CapacidadEnlace s:segmentos){
            if(s.getCapacidadDisponible()==null)return null;
            if(minimo==null||s.getCapacidadDisponible().compareTo(minimo)<0)minimo=s.getCapacidadDisponible();
        }
        return minimo;
    }
    public boolean isEvaluable(){
        return solicitud!=null && java.util.Arrays.asList("Registrada","En evaluación","Pendiente por capacidad").contains(solicitud.getEstado());
    }
    public boolean isFactible(){
        if(solicitud==null||!"Activo".equals(estadoCliente)||!"Operativa".equals(estadoRuta)||segmentos.isEmpty()
                ||getDisponible()==null||solicitud.getCapacidadSolicitada()<=0)return false;
        for(CapacidadEnlace s:segmentos)if(!"Operativo".equals(s.getEstado())&&!"Degradado".equals(s.getEstado()))return false;
        return getDisponible().compareTo(BigDecimal.valueOf(solicitud.getCapacidadSolicitada()))>=0;
    }
}
