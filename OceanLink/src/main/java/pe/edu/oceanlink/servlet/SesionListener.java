package pe.edu.oceanlink.servlet;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.util.SesionContador;
import pe.edu.oceanlink.util.SesionRegistro;

@WebListener
public class SesionListener implements HttpSessionListener {
    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession s = se.getSession();
        Usuario u = (Usuario) s.getAttribute("usuario");
        if (u != null) {
            SesionContador.logout();
            SesionRegistro.quitarSesion(u.getCorreo(), s.getId());
        }
    }
}
