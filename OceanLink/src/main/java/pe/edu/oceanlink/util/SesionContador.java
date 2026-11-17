package pe.edu.oceanlink.util;

import java.util.concurrent.atomic.AtomicInteger;

/** Cuenta las sesiones de usuarios actualmente logueados (en memoria del servidor). */
public class SesionContador {
    private static final AtomicInteger ACTIVAS = new AtomicInteger(0);

    public static void login()  { ACTIVAS.incrementAndGet(); }
    public static void logout() { ACTIVAS.updateAndGet(v -> v > 0 ? v - 1 : 0); }
    public static int  activas(){ return ACTIVAS.get(); }
}
