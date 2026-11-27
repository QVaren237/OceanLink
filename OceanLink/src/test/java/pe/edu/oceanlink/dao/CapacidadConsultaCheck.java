package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.CapacidadEnlace;
import java.math.BigDecimal;

public class CapacidadConsultaCheck {
    private static int comprobaciones;

    private static CapacidadEnlace enlace(String total, String usada) {
        CapacidadEnlace enlace = new CapacidadEnlace();
        enlace.setCapacidadTotal(total == null ? null : new BigDecimal(total));
        enlace.setCapacidadUtilizada(usada == null ? null : new BigDecimal(usada));
        return enlace;
    }

    private static void verificar(boolean condicion, String mensaje) {
        if (!condicion) throw new AssertionError(mensaje);
        comprobaciones++;
    }

    public static void main(String[] args) {
        CapacidadEnlace enlace = enlace("1000", "50");
        verificar(enlace.getCapacidadDisponible().compareTo(new BigDecimal("950")) == 0, "Disponible resta la capacidad utilizada");
        verificar(enlace.getPorcentajeUtilizacion().compareTo(new BigDecimal("5")) == 0, "La utilización usa únicamente la capacidad utilizada");
        verificar("Normal".equals(enlace("100", "79.99").getNivelUtilizacion()), "Menos de 80 es normal");
        verificar("Alta".equals(enlace("100", "80").getNivelUtilizacion()), "80 exacto es alta");
        verificar("Alta".equals(enlace("100", "95").getNivelUtilizacion()), "95 exacto es alta");
        verificar("Crítica".equals(enlace("100", "95.01").getNivelUtilizacion()), "Mayor de 95 es crítica");
        verificar("Crítica".equals(enlace("100", "95.00001").getNivelUtilizacion()), "El redondeo visual no cambia el umbral");
        verificar(enlace("0", "0").getPorcentajeUtilizacion() == null, "No dividir entre cero");
        verificar(enlace(null, "0").getCapacidadDisponible() == null, "No inventar capacidad total");
        verificar(enlace("100", null).getCapacidadDisponible() == null, "No inventar utilización");
        verificar("Sin datos".equals(enlace(null, null).getNivelUtilizacion()), "Datos desconocidos");
        verificar(enlace("0.30", "0.10").getCapacidadDisponible().compareTo(new BigDecimal("0.20")) == 0, "Precisión decimal");
        enlace = enlace("100", "110");
        verificar(enlace.getCapacidadDisponible().signum() < 0, "Una inconsistencia no se oculta alterando el disponible");
        verificar(new BigDecimal(enlace.getAnchoProgreso()).compareTo(new BigDecimal("100")) == 0, "La barra no desborda");
        System.out.println(comprobaciones + " comprobaciones de capacidad correctas.");
    }
}
