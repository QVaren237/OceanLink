package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Servicio {
    private int idServicio, idCliente, idRuta;
    private String codigo, origen, destino, estado, clienteNombre, rutaNombre;
    private BigDecimal capacidadContratada;
    private LocalDate fechaActivacion;

    public int getIdServicio(){return idServicio;}
    public void setIdServicio(int v){idServicio=v;}
    public int getIdCliente(){return idCliente;}
    public void setIdCliente(int v){idCliente=v;}
    public int getIdRuta(){return idRuta;}
    public void setIdRuta(int v){idRuta=v;}
    public String getCodigo(){return codigo;}
    public void setCodigo(String v){codigo=v;}
    public String getOrigen(){return origen;}
    public void setOrigen(String v){origen=v;}
    public String getDestino(){return destino;}
    public void setDestino(String v){destino=v;}
    public String getEstado(){return estado;}
    public void setEstado(String v){estado=v;}
    public String getClienteNombre(){return clienteNombre;}
    public void setClienteNombre(String v){clienteNombre=v;}
    public String getRutaNombre(){return rutaNombre;}
    public void setRutaNombre(String v){rutaNombre=v;}
    public BigDecimal getCapacidadContratada(){return capacidadContratada;}
    public void setCapacidadContratada(BigDecimal v){capacidadContratada=v;}
    public LocalDate getFechaActivacion(){return fechaActivacion;}
    public void setFechaActivacion(LocalDate v){fechaActivacion=v;}
}
