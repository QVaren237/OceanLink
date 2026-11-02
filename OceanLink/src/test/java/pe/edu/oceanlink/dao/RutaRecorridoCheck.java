package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Ruta;
import pe.edu.oceanlink.bean.RutaSegmento;
import java.util.ArrayList;
import java.util.Arrays;

/** Verificación ejecutable con Java 17; no requiere librerías de pruebas adicionales. */
public class RutaRecorridoCheck {
    private static int comprobaciones;

    public static void main(String[] args) {
        Ruta ruta = ruta(1, 3);
        aceptar(ruta, tramo(1, 1, 2, "Operativo"), tramo(2, 2, 3, "Degradado"));
        aceptar(ruta, tramo(1, 2, 1, "Operativo"), tramo(2, 3, 2, "Operativo"));
        rechazar(ruta, tramo(2, 2, 3, "Operativo"), tramo(1, 1, 2, "Operativo"));
        rechazar(ruta, tramo(1, 1, 2, "Operativo"));
        rechazar(ruta);
        rechazar(ruta, tramo(1, 1, 2, "Operativo"), tramo(1, 2, 3, "Operativo"));
        rechazar(ruta, tramo(1, 1, 2, "Operativo"), tramo(2, 2, 1, "Operativo"), tramo(3, 1, 3, "Operativo"));
        rechazar(ruta, tramo(1, 1, 3, "Fuera de servicio"));
        rechazar(ruta, tramo(1, 1, 3, "En mantenimiento"));
        ruta.setEstado("No operativa");
        aceptar(ruta, tramo(1, 1, 3, "Fuera de servicio"));
        ruta.setEstado("Inventado");
        rechazar(ruta, tramo(1, 1, 3, "Operativo"));
        rechazar(ruta(1, 1), tramo(1, 1, 1, "Operativo"));
        Ruta sinCodigo = ruta(1, 3); sinCodigo.setCodigo(" ");
        rechazar(sinCodigo, tramo(1, 1, 3, "Operativo"));
        Ruta larga = ruta(1, 3); larga.setDescripcion("x".repeat(256));
        rechazar(larga, tramo(1, 1, 3, "Operativo"));
        System.out.println("Recorridos: " + comprobaciones + " comprobaciones correctas.");
    }

    private static Ruta ruta(int origen, int destino) {
        Ruta ruta = new Ruta();
        ruta.setCodigo("RUT-CHECK"); ruta.setNombre("Ruta de prueba");
        ruta.setIdEstacionOrigen(origen); ruta.setIdEstacionDestino(destino);
        return ruta;
    }

    private static RutaSegmento tramo(int id, int origen, int destino, String estado) {
        RutaSegmento tramo = new RutaSegmento();
        tramo.setIdSegmento(id); tramo.setCodigo("SEG-" + id);
        tramo.setIdEstacionOrigen(origen); tramo.setIdEstacionDestino(destino); tramo.setEstado(estado);
        return tramo;
    }

    private static void aceptar(Ruta ruta, RutaSegmento... tramos) {
        RutaDAO.validarRecorrido(ruta, new ArrayList<>(Arrays.asList(tramos)));
        comprobaciones++;
    }

    private static void rechazar(Ruta ruta, RutaSegmento... tramos) {
        try { RutaDAO.validarRecorrido(ruta, new ArrayList<>(Arrays.asList(tramos))); }
        catch (IllegalArgumentException e) { comprobaciones++; return; }
        throw new AssertionError("Se aceptó un recorrido inválido.");
    }
}
