package pe.edu.oceanlink.bean;

import java.math.BigDecimal;
import java.util.ArrayList;

public class Ruta {
    private int idRuta;
    private String codigo = "";
    private String nombre = "";
    private int idEstacionOrigen;
    private int idEstacionDestino;
    private String estado = "Operativa";
    private String descripcion = "";
    // Datos del JOIN para las vistas.
    private String nombreOrigen;
    private String nombreDestino;
    private int cantidadSegmentos;
    private int cantidadServicios;
    private int cantidadSolicitudes;
    private ArrayList<RutaSegmento> segmentos = new ArrayList<>();

    public int getIdRuta() { return idRuta; }
    public void setIdRuta(int idRuta) { this.idRuta = idRuta; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public int getIdEstacionOrigen() { return idEstacionOrigen; }
    public void setIdEstacionOrigen(int idEstacionOrigen) { this.idEstacionOrigen = idEstacionOrigen; }
    public int getIdEstacionDestino() { return idEstacionDestino; }
    public void setIdEstacionDestino(int idEstacionDestino) { this.idEstacionDestino = idEstacionDestino; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public String getNombreOrigen() { return nombreOrigen; }
    public void setNombreOrigen(String nombreOrigen) { this.nombreOrigen = nombreOrigen; }
    public String getNombreDestino() { return nombreDestino; }
    public void setNombreDestino(String nombreDestino) { this.nombreDestino = nombreDestino; }
    public int getCantidadSegmentos() { return cantidadSegmentos; }
    public void setCantidadSegmentos(int cantidadSegmentos) { this.cantidadSegmentos = cantidadSegmentos; }
    public int getCantidadServicios() { return cantidadServicios; }
    public void setCantidadServicios(int cantidadServicios) { this.cantidadServicios = cantidadServicios; }
    public int getCantidadSolicitudes() { return cantidadSolicitudes; }
    public void setCantidadSolicitudes(int cantidadSolicitudes) { this.cantidadSolicitudes = cantidadSolicitudes; }
    public ArrayList<RutaSegmento> getSegmentos() { return segmentos; }
    public void setSegmentos(ArrayList<RutaSegmento> segmentos) { this.segmentos = segmentos; }
    public boolean isEnUso() { return cantidadServicios > 0 || cantidadSolicitudes > 0; }

    public BigDecimal getCapacidadDisponible() {
        BigDecimal disponible = null;
        for (RutaSegmento tramo : segmentos) {
            BigDecimal actual = tramo.getCapacidadDisponible();
            disponible = disponible == null ? actual : disponible.min(actual);
        }
        return disponible == null ? BigDecimal.ZERO : disponible;
    }
}
