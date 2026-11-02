package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.LandingStationDAO;
import pe.edu.oceanlink.bean.LandingStation;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "LandingStationServlet", value = "/LandingStationServlet")
public class LandingStationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        LandingStationDAO dao = new LandingStationDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                ArrayList<LandingStation> lista = dao.obtenerListaLandingStations();
                request.setAttribute("lista", lista);
                view = request.getRequestDispatcher("/views/landing-stations.jsp");
                view.forward(request, response);
                break;
            case "formCrear":
                view = request.getRequestDispatcher("/views/landing-station-form.jsp");
                view.forward(request, response);
                break;
            case "editar":
                String id = request.getParameter("id");
                LandingStation ls = dao.obtenerLandingStation(id);
                if (ls == null) {
                    response.sendRedirect(request.getContextPath() + "/LandingStationServlet");
                } else {
                    request.setAttribute("landingStation", ls);
                    view = request.getRequestDispatcher("/views/landing-station-form.jsp");
                    view.forward(request, response);
                }
                break;
            case "cambiarEstado":
                String idCambio = request.getParameter("id");
                String estado = request.getParameter("estado");
                dao.cambiarEstado(idCambio, estado);
                response.sendRedirect(request.getContextPath() + "/LandingStationServlet?action=lista");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        LandingStationDAO dao = new LandingStationDAO();

        switch (action) {
            case "crear":
                String idLandingStation = request.getParameter("idLandingStation");
                String codigo = request.getParameter("codigo");
                String nombre = request.getParameter("nombre");
                String ubicacion = request.getParameter("ubicacion");
                String estado = request.getParameter("estado");
                String descripcion = request.getParameter("descripcion");

                LandingStation guardar = new LandingStation();
                guardar.setCodigo(codigo);
                guardar.setNombre(nombre);
                guardar.setUbicacion(ubicacion);
                guardar.setEstado(estado);
                guardar.setDescripcion(descripcion);

                if (idLandingStation == null || idLandingStation.isEmpty()) {
                    dao.crearLandingStation(guardar);
                } else {
                    guardar.setIdLandingStation(Integer.parseInt(idLandingStation));
                    dao.actualizarLandingStation(guardar);
                }

                String op = (idLandingStation == null || idLandingStation.isEmpty()) ? "crear" : "editar";
                response.sendRedirect(request.getContextPath() + "/views/operacion-exito.jsp?mod=landing&op=" + op);
                break;
        }
    }
}
