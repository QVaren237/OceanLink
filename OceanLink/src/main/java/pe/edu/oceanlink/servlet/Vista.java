package pe.edu.oceanlink.servlet;

import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.bean.Usuario;

public class Vista {

    public static String claseEstadoIncidencia(String estado) {
        if (estado == null) {
            return "pill-neutral";
        }
        switch (estado) {
            case "Detectada": return "pill-crit";
            case "En análisis": return "pill-ok";
            case "Reparación programada": return "pill-info";
            case "En reparación": return "pill-warn";
            case "Servicio restaurado": return "pill-restaurado";
            default: return "pill-neutral";
        }
    }

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

    public static String foto(HttpSession s) {
        Object o = (s == null) ? null : s.getAttribute("fotoPerfil");
        return (o instanceof String) ? (String) o : null;
    }

    public static String avatarAttr(HttpSession s) {
        String f = foto(s);
        return (f == null) ? "" :
            " style=\"background-image:url('" + f + "');background-size:cover;background-position:center;color:transparent\"";
    }
}
