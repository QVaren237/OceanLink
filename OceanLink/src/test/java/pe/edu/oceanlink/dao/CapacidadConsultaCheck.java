package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.CapacidadEnlace;
import java.math.BigDecimal;

/** Ejecutar como aplicación Java, sin dependencias de pruebas adicionales. */
public class CapacidadConsultaCheck {
    private static int comprobaciones;

    private static CapacidadEnlace enlace(String total, String usada, String reservada) {
        CapacidadEnlace enlace = new CapacidadEnlace();
        enlace.setCapacidadTotal(total == null ? null : new BigDecimal(total));
        enlace.setCapacidadUtilizada(usada == null ? null : new BigDecimal(usada));
        enlace.setCapacidadReservada(reservada == null ? null : new BigDecimal(reservada));
        return enlace;
    }

    private static void verificar(boolean condicion, String mensaje) {
        if (!condicion) throw new AssertionError(mensaje);
        comprobaciones++;
    }

    public static void main(String[] args) {
        CapacidadEnlace enlace = enlace("1000", "50", "20");
        verificar(enlace.getCapacidadDisponible().compareTo(new BigDecimal("930")) == 0, "Disponible resta utilizada y reservada");
        verificar(enlace.getPorcentajeUtilizacion().compareTo(new BigDecimal("7")) == 0, "La ocupación incluye reservas, como el HTML");
        verificar("Normal".equals(enlace("100", "69.99", "10").getNivelUtilizacion()), "Menos de 80 es normal");
        verificar("Alta".equals(enlace("100", "70", "10").getNivelUtilizacion()), "80 exacto es alta");
        verificar("Alta".equals(enlace("100", "85", "10").getNivelUtilizacion()), "95 exacto es alta");
        verificar("Crítica".equals(enlace("100", "85.01", "10").getNivelUtilizacion()), "Mayor de 95 es crítica");
        verificar("Crítica".equals(enlace("100", "95.00001", "0").getNivelUtilizacion()), "El redondeo visual no cambia el umbral");
        verificar(enlace("0", "0", "0").getPorcentajeUtilizacion() == null, "No dividir entre cero");
        verificar(enlace(null, "0", "0").getCapacidadDisponible() == null, "No inventar capacidad total");
        verificar(enlace("100", null, "0").getCapacidadDisponible() == null, "No inventar utilización");
        verificar(enlace("100", "0", null).getCapacidadDisponible() == null, "No inventar reserva");
        verificar("Sin datos".equals(enlace(null, null, null).getNivelUtilizacion()), "Datos desconocidos");
        verificar(enlace("0.30", "0.10", "0.10").getCapacidadDisponible().compareTo(new BigDecimal("0.10")) == 0, "Precisión decimal");
        enlace = enlace("100", "110", "0");
        verificar(enlace.getCapacidadDisponible().signum() < 0, "Una inconsistencia no se oculta alterando el disponible");
        verificar(new BigDecimal(enlace.getAnchoProgreso()).compareTo(new BigDecimal("100")) == 0, "La barra no desborda");
        System.out.println(comprobaciones + " comprobaciones de capacidad correctas.");
    }
}
