package pe.edu.oceanlink.bean;

import java.math.BigDecimal;

public class SupervisorResumen {
    private BigDecimal utilizacionPromedio = BigDecimal.ZERO;
    private int fallasActivas;
    private int mantenimientosSemana;
    private int tramosSaturados;

    public BigDecimal getUtilizacionPromedio() { return utilizacionPromedio; }
    public void setUtilizacionPromedio(BigDecimal valor) { this.utilizacionPromedio = valor; }
    public int getFallasActivas() { return fallasActivas; }
    public void setFallasActivas(int valor) { this.fallasActivas = valor; }
    public int getMantenimientosSemana() { return mantenimientosSemana; }
    public void setMantenimientosSemana(int valor) { this.mantenimientosSemana = valor; }
    public int getTramosSaturados() { return tramosSaturados; }
    public void setTramosSaturados(int valor) { this.tramosSaturados = valor; }
}
