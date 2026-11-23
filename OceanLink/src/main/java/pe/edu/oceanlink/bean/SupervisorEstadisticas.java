package pe.edu.oceanlink.bean;

import java.util.ArrayList;

/**
 * Almacena los indicadores estadísticos del Supervisor.
 * Es una clase de consulta: no modifica información.
 */
public class SupervisorEstadisticas {

    private int totalIncidencias;
    private int incidenciasAbiertas;
    private int incidenciasCerradas;
    private int incidenciasGraves;

    private int totalMantenimientos;
    private int segmentosInvolucrados;
    private int clientesRelacionados;
    private final ArrayList<SupervisorDatoGrafico> severidades = new ArrayList<>();
    private final ArrayList<SupervisorMes> meses = new ArrayList<>();

    public ArrayList<SupervisorDatoGrafico> getSeveridades() {
        return severidades;
    }

    public ArrayList<SupervisorMes> getMeses() {
        return meses;
    }

    public int getMaximoMensual() {
        int maximo = 1;
        for (SupervisorMes mes : meses) {
            maximo = Math.max(maximo, Math.max(mes.getIncidencias(), mes.getMantenimientos()));
        }
        return maximo;
    }

    public int getTotalIncidencias() {
        return totalIncidencias;
    }

    public void setTotalIncidencias(int valor) {
        this.totalIncidencias = valor;
    }

    public int getIncidenciasAbiertas() {
        return incidenciasAbiertas;
    }

    public void setIncidenciasAbiertas(int valor) {
        this.incidenciasAbiertas = valor;
    }

    public int getIncidenciasCerradas() {
        return incidenciasCerradas;
    }

    public void setIncidenciasCerradas(int valor) {
        this.incidenciasCerradas = valor;
    }

    public int getIncidenciasGraves() {
        return incidenciasGraves;
    }

    public void setIncidenciasGraves(int valor) {
        this.incidenciasGraves = valor;
    }

    public int getTotalMantenimientos() {
        return totalMantenimientos;
    }

    public void setTotalMantenimientos(int valor) {
        this.totalMantenimientos = valor;
    }

    public int getSegmentosInvolucrados() {
        return segmentosInvolucrados;
    }

    public void setSegmentosInvolucrados(int valor) {
        this.segmentosInvolucrados = valor;
    }

    public int getClientesRelacionados() {
        return clientesRelacionados;
    }

    public void setClientesRelacionados(int valor) {
        this.clientesRelacionados = valor;
    }
}
