
package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import pe.edu.oceanlink.bean.Incidencia;
import pe.edu.oceanlink.bean.SolicitudCapacidad;
import pe.edu.oceanlink.dao.IncidenciaDAO;
import pe.edu.oceanlink.dao.ObservacionIncidenciaDAO;
import pe.edu.oceanlink.dao.SegmentoConsultaDAO;
import pe.edu.oceanlink.dao.SolicitudCapacidadDAO;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.UUID;

@WebServlet(name = "NetworkOperatorServlet",
        value = "/NetworkOperatorServlet")
public class NetworkOperatorServlet extends HttpServlet {

    private final IncidenciaDAO incidenciaDAO = new IncidenciaDAO();
    private final ObservacionIncidenciaDAO eventoDAO =
            new ObservacionIncidenciaDAO();
    private final SegmentoConsultaDAO segmentoDAO =
            new SegmentoConsultaDAO();
    private final SolicitudCapacidadDAO solicitudDAO =
            new SolicitudCapacidadDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null) {
            action = "panel";
        }

        try {
            switch (action) {

                case "panel":
                    ArrayList<Incidencia> incidencias =
                            incidenciaDAO.listar("", "");

                    request.setAttribute("incidencias", incidencias);
                    request.setAttribute("landingStations", segmentoDAO.contarLandingStations());
                    request.setAttribute(
                            "segmentos", segmentoDAO.listar("", ""));

                    forward(request, response, "/views/no-panel.jsp");
                    break;

                case "sesionCerrada":
                    forward(request, response, "/views/no-sesion-cerrada.jsp");
                    break;

                case "redes":
                    request.setAttribute("landingStations", segmentoDAO.contarLandingStations());
                    request.setAttribute("incidenciasActivas", incidenciaDAO.listarAbiertas().size());
                    request.setAttribute(
                            "lista",
                            segmentoDAO.listar(
                                    request.getParameter("buscar"),
                                    request.getParameter("estado")));

                    forward(request, response,
                            "/views/no-estado-red.jsp");
                    break;

                case "incidencias":
                    request.setAttribute(
                            "lista",
                            incidenciaDAO.listar(
                                    request.getParameter("buscar"),
                                    request.getParameter("estado")));

                    forward(request, response,
                            "/views/no-incidencias.jsp");
                    break;

                case "nuevaIncidencia":
                    request.setAttribute(
                            "segmentos", segmentoDAO.listar("", ""));

                    forward(request, response,
                            "/views/no-incidencia-form.jsp");
                    break;

                case "detalleIncidencia":
                    cargarDetalle(request,
                            parseId(request.getParameter("id")));

                    forward(request, response,
                            "/views/no-incidencia-detalle.jsp");
                    break;

                case "actualizarIncidencia":
                    cargarDetalle(request,
                            parseId(request.getParameter("id")));

                    forward(request, response,
                            "/views/no-incidencia-actualizar.jsp");
                    break;

                case "restauracion":
                    cargarDetalle(request,
                            parseId(request.getParameter("id")));

                    forward(request, response,
                            "/views/no-incidencia-restauracion.jsp");
                    break;

                case "observacion":
                    cargarDetalle(request,
                            parseId(request.getParameter("id")));

                    forward(request, response,
                            "/views/no-incidencia-observacion.jsp");
                    break;

                case "historial":
                    int idHistorial =
                            parseId(request.getParameter("id"));

                    if (idHistorial > 0) {
                        ArrayList<Incidencia> seleccion = new ArrayList<>();
                        Incidencia elegida = incidenciaDAO.obtener(idHistorial);
                        if (elegida != null) seleccion.add(elegida);
                        request.setAttribute("lista", seleccion);
                        request.setAttribute("eventos", eventoDAO.listarPorIncidencia(idHistorial));
                    } else {
                        request.setAttribute("lista", incidenciaDAO.listar("", ""));
                    }

                    forward(request, response,
                            "/views/no-historial.jsp");
                    break;

                case "solicitudes":
                    request.setAttribute(
                            "lista",
                            solicitudDAO.listar(
                                    request.getParameter("buscar"),
                                    request.getParameter("estado")));

                    forward(request, response,
                            "/views/no-solicitudes.jsp");
                    break;

                case "nuevaSolicitud":
                    if(!solicitudDAO.esNetworkOperator(usuarioSolicitante(request))){
                        response.sendError(403,"Solo Network Operator puede registrar solicitudes.");return;
                    }
                    request.setAttribute("motivos", solicitudDAO.listarMotivos());
                    request.setAttribute("servicios", solicitudDAO.listarServicios());
                    request.setAttribute(
                            "clientes", solicitudDAO.listarClientes());

                    request.setAttribute(
                            "rutas", solicitudDAO.listarRutas());

                    forward(request, response,
                            "/views/no-solicitud-form.jsp");
                    break;

                case "detalleSolicitud":
                    request.setAttribute("resumenReserva", solicitudDAO.obtenerResumenReserva(parseId(request.getParameter("id"))));
                    request.setAttribute(
                            "solicitud",
                            solicitudDAO.obtener(
                                    parseId(request.getParameter("id"))));

                    forward(request, response,
                            "/views/no-solicitud-detalle.jsp");
                    break;

                case "exito":
                    request.setAttribute(
                            "tipo", request.getParameter("tipo"));

                    forward(request, response, "/views/no-exito.jsp");
                    break;

                case "perfil":
                    forward(request, response, "/views/no-perfil.jsp");
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                                    + "/NetworkOperatorServlet?action=panel");
                    break;
            }

        } catch (Exception e) {
            throw new ServletException(
                    "Error al procesar la solicitud de Network Operator", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        try {
            if ("guardarPerfil".equals(action)) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "La edición de perfil no está disponible.");
                return;
            }
            if ("cerrarSesion".equals(action)) {
                if (request.getSession(false) != null) request.getSession(false).invalidate();
                response.sendRedirect(request.getContextPath()
                        + "/NetworkOperatorServlet?action=sesionCerrada");
                return;
            }
            if ("crearIncidencia".equals(action)) {

                String titulo = trim(request.getParameter("titulo"));
                String descripcion =
                        trim(request.getParameter("descripcion"));
                String severidad = request.getParameter("severidad");
                String[] segmentos =
                        request.getParameterValues("segmentos");

                if (titulo.isEmpty()
                        || descripcion.isEmpty()
                        || severidad == null
                        || segmentos == null
                        || segmentos.length == 0) {

                    request.setAttribute(
                            "error",
                            "Completa los campos obligatorios y selecciona al menos una red.");

                    request.setAttribute(
                            "segmentos", segmentoDAO.listar("", ""));

                    forward(request, response,
                            "/views/no-incidencia-form.jsp");
                    return;
                }

                Incidencia incidencia = new Incidencia();

                incidencia.setCodigo(
                        "INC-" + UUID.randomUUID()
                                .toString().substring(0, 8).toUpperCase());

                incidencia.setTitulo(titulo);
                incidencia.setDescripcion(descripcion);
                incidencia.setSeveridad(severidad);
                incidencia.setEstado("Detectada");

                int idUsuario = parseId(
                        request.getParameter("idUsuario"));

                incidencia.setIdUsuario(idUsuario > 0 ? idUsuario : 3);

                int id = incidenciaDAO.crear(incidencia, segmentos);

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=incidencia&id=" + id);
                return;
            }

            if ("actualizarEstado".equals(action)) {

                int id = parseId(request.getParameter("id"));
                String estado = request.getParameter("nuevoEstado");

                if (estado == null || estado.trim().isEmpty()) {
                    request.setAttribute(
                            "error", "El estado es obligatorio.");

                    cargarDetalle(request, id);

                    forward(request, response,
                            "/views/no-incidencia-actualizar.jsp");
                    return;
                }

                incidenciaDAO.actualizarEstado(
                        id, estado, request.getParameter("observacion"));

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=actualizacion&id=" + id);
                return;
            }

            if ("registrarRestauracion".equals(action)) {

                int id = parseId(request.getParameter("id"));
                String resultado = request.getParameter("resultado");
                String detalle = trim(
                        request.getParameter("observaciones"));

                if (resultado == null
                        || resultado.isEmpty()
                        || detalle.isEmpty()) {

                    request.setAttribute(
                            "error",
                            "Completa el resultado y las observaciones.");

                    cargarDetalle(request, id);

                    forward(request, response,
                            "/views/no-incidencia-restauracion.jsp");
                    return;
                }

                String nuevoEstado =
                        "Servicio restablecido".equals(resultado)
                                ? "Servicio restaurado" : "En análisis";

                incidenciaDAO.actualizarEstado(
                        id, nuevoEstado,
                        "Restauración: " + resultado + ". " + detalle);

                eventoDAO.registrar(
                        id, "RESTAURACION", resultado + ". " + detalle);

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=restauracion&id=" + id);
                return;
            }

            if ("registrarObservacion".equals(action)) {

                int id = parseId(request.getParameter("id"));
                String detalle =
                        trim(request.getParameter("observacion"));

                if (detalle.isEmpty()) {
                    request.setAttribute(
                            "error", "La observación es obligatoria.");

                    cargarDetalle(request, id);

                    forward(request, response,
                            "/views/no-incidencia-observacion.jsp");
                    return;
                }

                eventoDAO.registrar(id, "OBSERVACION", detalle);

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=observacion&id=" + id);
                return;
            }

            if ("crearSolicitud".equals(action)) {
                if(!solicitudDAO.esNetworkOperator(usuarioSolicitante(request))){
                    response.sendError(403,"Solo Network Operator puede registrar solicitudes.");return;
                }

                String cliente = request.getParameter("idCliente");
                String ruta = request.getParameter("idRuta");
                String capacidad = request.getParameter("capacidad");
                String motivo = trim(request.getParameter("motivo"));
                if ("__otro__".equals(motivo)) {
                    motivo = trim(request.getParameter("motivoPersonalizado"));
                }

                if (cliente == null
                        || ruta == null
                        || capacidad == null
                        || capacidad.trim().isEmpty()
                        || motivo.isEmpty() || motivo.length() > 255) {

                    request.setAttribute(
                            "error", "Completa todos los campos obligatorios. El motivo debe tener entre 1 y 255 caracteres.");
                    request.setAttribute("motivos", solicitudDAO.listarMotivos());
                    request.setAttribute("servicios", solicitudDAO.listarServicios());

                    request.setAttribute(
                            "clientes", solicitudDAO.listarClientes());

                    request.setAttribute(
                            "rutas", solicitudDAO.listarRutas());

                    forward(request, response,
                            "/views/no-solicitud-form.jsp");
                    return;
                }

                try {
                SolicitudCapacidad solicitud =
                        new SolicitudCapacidad();
                String servicio = trim(request.getParameter("idServicio"));
                if (!servicio.isEmpty()) solicitud.setIdServicio(Integer.valueOf(servicio));

                solicitud.setCodigo(
                        "SOL-" + UUID.randomUUID()
                                .toString().substring(0, 8).toUpperCase());

                solicitud.setIdCliente(Integer.parseInt(cliente));
                solicitud.setIdRuta(Integer.parseInt(ruta));
                solicitud.setCapacidadSolicitada(
                        Double.parseDouble(capacidad));

                solicitud.setFechaLimite(
                        parseDate(request.getParameter("fechaLimite")));

                solicitud.setMotivo(motivo);
                solicitud.setObservacion(
                        request.getParameter("observacion"));
                solicitud.setIdUsuario(usuarioSolicitante(request));

                solicitudDAO.crear(solicitud);
                } catch (IllegalArgumentException e) {
                    response.setStatus(400);
                    request.setAttribute("error", e instanceof NumberFormatException ? "Selecciona un cliente, ruta y servicio válidos." : e.getMessage());
                    request.setAttribute("motivos", solicitudDAO.listarMotivos());
                    request.setAttribute("clientes", solicitudDAO.listarClientes());
                    request.setAttribute("rutas", solicitudDAO.listarRutas());
                    request.setAttribute("servicios", solicitudDAO.listarServicios());
                    forward(request,response,"/views/no-solicitud-form.jsp");
                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=solicitud");
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/NetworkOperatorServlet?action=panel");

        } catch (Exception e) {
            throw new ServletException(
                    "No se pudo guardar la operación. "
                            + "Verifica los datos y la conexión a MySQL.", e);
        }
    }

    private void cargarDetalle(HttpServletRequest request, int id) {
        request.setAttribute("incidencia", incidenciaDAO.obtener(id));
        request.setAttribute(
                "eventos", eventoDAO.listarPorIncidencia(id));
        request.setAttribute("serviciosAfectados", incidenciaDAO.listarServiciosAfectados(id));
        request.setAttribute("responsableIncidencia", incidenciaDAO.obtenerResponsable(id));
    }

    private void forward(HttpServletRequest request,
                         HttpServletResponse response,
                         String ruta)
            throws ServletException, IOException {

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(ruta);

        dispatcher.forward(request, response);
    }

    private int usuarioSolicitante(HttpServletRequest request) {
        Object cuenta=request.getSession().getAttribute("usuarioSesion");
        // Mantiene el usuario de demostración del módulo mientras se integra el login.
        return cuenta instanceof pe.edu.oceanlink.bean.Usuario
                ? ((pe.edu.oceanlink.bean.Usuario)cuenta).getIdUsuario() : 3;
    }

    private int parseId(String valor) {
        try {
            return Integer.parseInt(valor);
        } catch (Exception e) {
            return 0;
        }
    }

    private String trim(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private Date parseDate(String valor) {
        try {
            return valor == null || valor.isBlank()
                    ? null : Date.valueOf(valor);
        } catch (Exception e) {
            return null;
        }
    }
}
