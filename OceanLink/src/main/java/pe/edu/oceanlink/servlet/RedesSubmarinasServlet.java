package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.LandingStationDAO;
import pe.edu.oceanlink.dao.SegmentoDAO;
import pe.edu.oceanlink.bean.Segmento;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "RedesSubmarinasServlet", value = "/RedesSubmarinasServlet")
public class RedesSubmarinasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        SegmentoDAO dao = new SegmentoDAO();
        LandingStationDAO lsDao = new LandingStationDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                ArrayList<Segmento> lista = dao.obtenerListaSegmentos();
                request.setAttribute("lista", lista);
                view = request.getRequestDispatcher("/views/redes-submarinas.jsp");
                view.forward(request, response);
                break;
            case "formCrear":
                // Las estaciones se usan para los combos de origen y destino
                request.setAttribute("estaciones", lsDao.obtenerListaLandingStations());
                view = request.getRequestDispatcher("/views/redes-submarinas-form.jsp");
                view.forward(request, response);
                break;
            case "editar":
                String id = request.getParameter("id");
                Segmento segmento = dao.obtenerSegmento(id);
                if (segmento == null) {
                    response.sendRedirect(request.getContextPath() + "/RedesSubmarinasServlet");
                } else {
                    request.setAttribute("segmento", segmento);
                    request.setAttribute("estaciones", lsDao.obtenerListaLandingStations());
                    view = request.getRequestDispatcher("/views/redes-submarinas-form.jsp");
                    view.forward(request, response);
                }
                break;
            case "cambiarEstado":
                String idCambio = request.getParameter("id");
                String estado = request.getParameter("estado");
                dao.cambiarEstado(idCambio, estado);
                response.sendRedirect(request.getContextPath() + "/RedesSubmarinasServlet?action=lista");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        SegmentoDAO dao = new SegmentoDAO();

        switch (action) {
            case "crear":
                String idSegmento = request.getParameter("idSegmento");
                String codigo = request.getParameter("codigo");
                String idOrigen = request.getParameter("idEstacionOrigen");
                String idDestino = request.getParameter("idEstacionDestino");
                String estado = request.getParameter("estado");
                String descripcion = request.getParameter("descripcion");

                Segmento guardar = new Segmento();
                guardar.setCodigo(codigo);
                guardar.setIdEstacionOrigen(idOrigen == null || idOrigen.isEmpty() ? 0 : Integer.parseInt(idOrigen));
                guardar.setIdEstacionDestino(idDestino == null || idDestino.isEmpty() ? 0 : Integer.parseInt(idDestino));
                guardar.setCapacidadTotal(parseDouble(request.getParameter("capacidadTotal")));
                guardar.setCapacidadUtilizada(parseDouble(request.getParameter("capacidadUtilizada")));
                guardar.setCapacidadReservada(parseDouble(request.getParameter("capacidadReservada")));
                guardar.setLongitudKm(parseDouble(request.getParameter("longitudKm")));
                guardar.setEstado(estado);
                guardar.setDescripcion(descripcion);

                if (idSegmento == null || idSegmento.isEmpty()) {
                    dao.crearSegmento(guardar);
                } else {
                    guardar.setIdSegmento(Integer.parseInt(idSegmento));
                    dao.actualizarSegmento(guardar);
                }

                String op = (idSegmento == null || idSegmento.isEmpty()) ? "crear" : "editar";
                response.sendRedirect(request.getContextPath() + "/views/operacion-exito.jsp?mod=redes&op=" + op);
                break;
        }
    }

    // Convierte texto a double; si viene vacío o inválido devuelve 0
    private double parseDouble(String valor) {
        if (valor == null || valor.trim().isEmpty()) return 0;
        try {
            return Double.parseDouble(valor.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
