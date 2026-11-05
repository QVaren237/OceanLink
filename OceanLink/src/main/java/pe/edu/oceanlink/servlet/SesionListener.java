package pe.edu.oceanlink.servlet;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import pe.edu.oceanlink.util.SesionContador;

@WebListener
public class SesionListener implements HttpSessionListener {
    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        if (se.getSession().getAttribute("usuario") != null) {
            SesionContador.logout();
        }
    }
}
