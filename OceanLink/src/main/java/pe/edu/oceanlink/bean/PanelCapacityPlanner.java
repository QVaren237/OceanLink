package pe.edu.oceanlink.bean;

import java.util.ArrayList;

public class PanelCapacityPlanner {
    private int clientesActivos;
    private int segmentosMonitoreados;
    private int solicitudesPendientes;
    private int segmentosCriticos;
    private ArrayList<ServicioResumen> servicios = new ArrayList<>();

    public int getClientesActivos() { return clientesActivos; }
    public void setClientesActivos(int valor) { clientesActivos = valor; }
    public int getSegmentosMonitoreados() { return segmentosMonitoreados; }
    public void setSegmentosMonitoreados(int valor) { segmentosMonitoreados = valor; }
    public int getSolicitudesPendientes() { return solicitudesPendientes; }
    public void setSolicitudesPendientes(int valor) { solicitudesPendientes = valor; }
    public int getSegmentosCriticos() { return segmentosCriticos; }
    public void setSegmentosCriticos(int valor) { segmentosCriticos = valor; }
    public ArrayList<ServicioResumen> getServicios() { return servicios; }
}
