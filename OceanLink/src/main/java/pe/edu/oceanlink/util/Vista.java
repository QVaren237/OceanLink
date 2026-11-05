package pe.edu.oceanlink.util;

import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.bean.Usuario;

/** Helpers para mostrar en las vistas el usuario que inició sesión (barra superior). */
public class Vista {

    private static Usuario u(HttpSession s) {
        Object o = (s == null) ? null : s.getAttribute("usuario");
        return (o instanceof Usuario) ? (Usuario) o : null;
    }

    public static String nombre(HttpSession s) {
        Usuario x = u(s);
        if (x == null) return "";
        String n = (x.getNombre() == null ? "" : x.getNombre()) + " " + (x.getApellido() == null ? "" : x.getApellido());
        return n.trim();
    }

    public static String rol(HttpSession s) {
        Usuario x = u(s);
        return (x == null || x.getNombreRol() == null) ? "" : x.getNombreRol();
    }

    public static String iniciales(HttpSession s) {
        Usuario x = u(s);
        if (x == null) return "";
        String i = "";
        if (x.getNombre() != null && !x.getNombre().isEmpty()) i += x.getNombre().charAt(0);
        if (x.getApellido() != null && !x.getApellido().isEmpty()) i += x.getApellido().charAt(0);
        return i.toUpperCase();
    }
}
