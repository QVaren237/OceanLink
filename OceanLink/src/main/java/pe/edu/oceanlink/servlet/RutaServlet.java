package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.bean.Ruta;
import pe.edu.oceanlink.bean.RutaSegmento;
import pe.edu.oceanlink.dao.RutaDAO;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RutaServlet", value = {"/RutaServlet", "/capacity-planner/rutas"})
public class RutaServlet extends HttpServlet {
    private static final String VISTAS = "/views/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        RutaDAO dao = new RutaDAO();
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        try {
            switch (action) {
                case "lista":
                    mostrarLista(request, response, dao);
                    break;
                case "formCrear":
                    mostrarFormulario(request, response, dao, new Ruta());
                    break;
                case "editar":
                case "detalle":
                    Ruta ruta = dao.obtenerRuta(idPositivo(request.getParameter("id")));
                    if (ruta == null) { response.sendError(404, "La ruta no existe."); return; }
                    if ("editar".equals(action)) mostrarFormulario(request, response, dao, ruta);
                    else {
                        request.setAttribute("ruta", ruta);
                        request.setAttribute("titulo", "Detalle de ruta");
                        request.getRequestDispatcher(VISTAS + "ruta-detalle.jsp").forward(request, response);
                    }
                    break;
                default:
                    response.sendError(400, "Acción no válida.");
            }
        } catch (IllegalArgumentException e) {
            response.sendError(400, "El identificador de ruta no es válido.");
        } catch (SQLException | ClassNotFoundException e) {
            mostrarErrorConexion(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        RutaDAO dao = new RutaDAO();
        String action = request.getParameter("action");
        if ("desactivar".equals(action)) {
            try {
                dao.desactivarRuta(idPositivo(request.getParameter("id")));
                response.sendRedirect(request.getContextPath() + "/capacity-planner/rutas?resultado=desactivada");
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", e.getMessage());
                mostrarListaSegura(request, response, dao);
            } catch (SQLException | ClassNotFoundException e) {
                log("No se pudo desactivar la ruta", e);
                request.setAttribute("error", mensajeSql(e));
                mostrarListaSegura(request, response, dao);
            }
            return;
        }
        if (!"guardar".equals(action)) { response.sendError(400, "Acción no válida."); return; }
        Ruta ruta = new Ruta();
        try {
            ruta.setIdRuta(idOpcional(request.getParameter("idRuta")));
            ruta.setCodigo(texto(request, "codigo"));
            ruta.setNombre(texto(request, "nombre"));
            ruta.setDescripcion(texto(request, "descripcion"));
            ruta.setEstado(texto(request, "estado"));
            ruta.setIdEstacionOrigen(idOpcional(request.getParameter("idEstacionOrigen")));
            ruta.setIdEstacionDestino(idOpcional(request.getParameter("idEstacionDestino")));
            String[] segmentos = request.getParameterValues("idSegmento");
            if (segmentos != null) {
                for (String id : segmentos) {
                    RutaSegmento tramo = new RutaSegmento();
                    tramo.setIdSegmento(idPositivo(id));
                    ruta.getSegmentos().add(tramo);
                }
            }
        } catch (IllegalArgumentException e) {
            response.sendError(400, "Los identificadores enviados no son válidos.");
            return;
        }
        boolean nueva = ruta.getIdRuta() == 0;
        try {
            if (nueva) dao.crearRuta(ruta);
            else dao.actualizarRuta(ruta);
            response.sendRedirect(request.getContextPath() + "/capacity-planner/rutas?resultado=" + (nueva ? "creada" : "actualizada"));
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            mostrarFormularioSeguro(request, response, dao, ruta);
        } catch (SQLException | ClassNotFoundException e) {
            log("No se pudo guardar la ruta", e);
            request.setAttribute("error", mensajeSql(e));
            mostrarFormularioSeguro(request, response, dao, ruta);
        }
    }

    private void mostrarLista(HttpServletRequest request, HttpServletResponse response, RutaDAO dao) throws SQLException, ClassNotFoundException, ServletException, IOException {
        request.setAttribute("lista", dao.obtenerListaRutas());
        request.setAttribute("titulo", "Gestión de rutas");
        request.getRequestDispatcher(VISTAS + "rutas.jsp").forward(request, response);
    }

    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response, RutaDAO dao, Ruta ruta) throws SQLException, ClassNotFoundException, ServletException, IOException {
        if (ruta.getIdRuta() > 0) {
            Ruta actual = dao.obtenerRuta(ruta.getIdRuta());
            if (actual == null) { response.sendError(404, "La ruta no existe."); return; }
            ruta.setCantidadServicios(actual.getCantidadServicios());
            ruta.setCantidadSolicitudes(actual.getCantidadSolicitudes());
        }
        request.setAttribute("ruta", ruta);
        request.setAttribute("estaciones", dao.obtenerEstaciones());
        request.setAttribute("segmentos", dao.obtenerSegmentos());
        request.setAttribute("titulo", ruta.getIdRuta() == 0 ? "Registrar ruta" : "Editar ruta");
        request.getRequestDispatcher(VISTAS + "ruta-form.jsp").forward(request, response);
    }

    private void mostrarFormularioSeguro(HttpServletRequest request, HttpServletResponse response, RutaDAO dao, Ruta ruta) throws ServletException, IOException {
        try { mostrarFormulario(request, response, dao, ruta); }
        catch (SQLException | ClassNotFoundException e) { mostrarErrorConexion(request, response, e); }
    }

    private void mostrarListaSegura(HttpServletRequest request, HttpServletResponse response, RutaDAO dao) throws ServletException, IOException {
        try { mostrarLista(request, response, dao); }
        catch (SQLException | ClassNotFoundException e) { mostrarErrorConexion(request, response, e); }
    }

    private void mostrarErrorConexion(HttpServletRequest request, HttpServletResponse response, Exception e) throws ServletException, IOException {
        log("Error de acceso a datos de rutas", e);
        response.setStatus(500);
        request.setAttribute("titulo", "Rutas");
        request.setAttribute("error", "No se pudieron cargar las rutas. Verifica la conexión con la base de datos e inténtalo nuevamente.");
        request.getRequestDispatcher(VISTAS + "rutas.jsp").forward(request, response);
    }

    private String mensajeSql(Exception e) {
        if (e instanceof SQLException) {
            int codigo = ((SQLException) e).getErrorCode();
            if (codigo == 1062) return "El código de ruta ya existe. Ingresa otro código.";
            if (codigo == 1452) return "La infraestructura seleccionada cambió. Actualiza el formulario.";
        }
        return "No se guardaron los cambios. Verifica la conexión con MySQL e inténtalo nuevamente.";
    }

    private int idOpcional(String valor) {
        return valor == null || valor.isBlank() ? 0 : idPositivo(valor);
    }

    private int idPositivo(String valor) {
        int id = Integer.parseInt(valor);
        if (id <= 0) throw new IllegalArgumentException("Identificador inválido.");
        return id;
    }

    private String texto(HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }
}
