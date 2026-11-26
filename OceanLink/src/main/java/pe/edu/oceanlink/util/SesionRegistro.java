package pe.edu.oceanlink.util;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class SesionRegistro {

    private static final Map<String, Set<String>> ACTIVAS = new ConcurrentHashMap<>();

    public static void registrar(String correo, String idSesion) {
        if (correo == null || idSesion == null) return;
        ACTIVAS.computeIfAbsent(correo, k -> ConcurrentHashMap.newKeySet()).add(idSesion);
    }

    public static void cerrarUsuario(String correo) {
        if (correo != null) ACTIVAS.remove(correo);
    }

    public static void quitarSesion(String correo, String idSesion) {
        if (correo == null || idSesion == null) return;
        Set<String> s = ACTIVAS.get(correo);
        if (s != null) {
            s.remove(idSesion);
            if (s.isEmpty()) ACTIVAS.remove(correo);
        }
    }

    public static boolean esValida(String correo, String idSesion) {
        if (correo == null || idSesion == null) return false;
        Set<String> s = ACTIVAS.get(correo);
        return s != null && s.contains(idSesion);
    }
}
