package pe.edu.oceanlink.servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;

import pe.edu.oceanlink.bean.Servicio;
import pe.edu.oceanlink.dao.ServicioDAO;

@WebServlet(name = "ServicioServlet", urlPatterns = {"/ServicioServlet"})
public class ServicioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        ServicioDAO servicioDao = new ServicioDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                ArrayList<Servicio> listaServicios = servicioDao.obtenerListaServicios();
                request.setAttribute("lista", listaServicios);
                view = request.getRequestDispatcher("views/servicios.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                view = request.getRequestDispatcher("views/servicio-form.jsp");
                view.forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Servicio servicio = servicioDao.obtenerServicio(idEditar);
                if (servicio == null) {
                    response.sendRedirect(request.getContextPath() + "/ServicioServlet");
                } else {
                    request.setAttribute("servicio", servicio);
                    view = request.getRequestDispatcher("views/servicio-form.jsp");
                    view.forward(request, response);
                }
                break;

            case "borrar":
                int idBorrar = Integer.parseInt(request.getParameter("id"));
                if (servicioDao.obtenerServicio(idBorrar) != null) {
                    servicioDao.borrarServicio(idBorrar);
                }
                response.sendRedirect(request.getContextPath() + "/ServicioServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Importante para no tener problemas con tildes y ñ
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        ServicioDAO servicioDao = new ServicioDAO();

        switch (action) {
            case "guardar":
                String idStr = request.getParameter("idServicio");
                String nombre = request.getParameter("nombre");
                String descripcion = request.getParameter("descripcion");
                double precio = Double.parseDouble(request.getParameter("precio"));

                // Reutilizamos el método tal como sugiere la PPT (Validamos si existe ID)
                if (idStr == null || idStr.isEmpty()) {
                    servicioDao.crearServicio(nombre, descripcion, precio);
                } else {
                    int idServicio = Integer.parseInt(idStr);
                    servicioDao.actualizarServicio(idServicio, nombre, descripcion, precio);
                }
                response.sendRedirect(request.getContextPath() + "/ServicioServlet");
                break;
        }
    }
}