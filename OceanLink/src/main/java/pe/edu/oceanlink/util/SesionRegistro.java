package pe.edu.oceanlink.util;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Registro de sesiones activas por usuario (en memoria del servidor).
 * Guarda, para cada correo, los ids de sesión abiertos (uno por navegador/pestaña).
 * Al cerrar sesión se borran TODOS los del correo => el logout es global:
 * se cierra la sesión en Chrome, Edge y cualquier pestaña copiada a la vez.
 */
public class SesionRegistro {

    private static final Map<String, Set<String>> ACTIVAS = new ConcurrentHashMap<>();

    /** Al iniciar sesión: registra el id de sesión de ese correo. */
    public static void registrar(String correo, String idSesion) {
        if (correo == null || idSesion == null) return;
        ACTIVAS.computeIfAbsent(correo, k -> ConcurrentHashMap.newKeySet()).add(idSesion);
    }

    /** Logout GLOBAL: elimina todas las sesiones del correo (cualquier navegador). */
    public static void cerrarUsuario(String correo) {
        if (correo != null) ACTIVAS.remove(correo);
    }

    /** Quita una sola sesión (p. ej. cuando expira por inactividad). */
    public static void quitarSesion(String correo, String idSesion) {
        if (correo == null || idSesion == null) return;
        Set<String> s = ACTIVAS.get(correo);
        if (s != null) {
            s.remove(idSesion);
            if (s.isEmpty()) ACTIVAS.remove(correo);
        }
    }

    /** ¿La sesión sigue siendo válida para ese correo? */
    public static boolean esValida(String correo, String idSesion) {
        if (correo == null || idSesion == null) return false;
        Set<String> s = ACTIVAS.get(correo);
        return s != null && s.contains(idSesion);
    }
}
