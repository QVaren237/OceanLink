package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import pe.edu.oceanlink.bean.Incidencia;
import pe.edu.oceanlink.bean.SolicitudCapacidad;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.dao.UsuarioDAO;
import pe.edu.oceanlink.dao.IncidenciaDAO;
import pe.edu.oceanlink.dao.ObservacionIncidenciaDAO;
import pe.edu.oceanlink.dao.SegmentoConsultaDAO;
import pe.edu.oceanlink.dao.SolicitudCapacidadDAO;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.UUID;

@MultipartConfig(maxFileSize = 2097152, maxRequestSize = 3145728)
@WebServlet(name = "NetworkOperatorServlet",
        value = "/NetworkOperatorServlet")
public class NetworkOperatorServlet extends HttpServlet {

    private static final String BORRADOR_RESTAURACION = "borradorRestauracion";

    private static class BorradorRestauracion {
        final int id;
        final String resultado;
        final String observaciones;
        final String codigo = UUID.randomUUID().toString();

        BorradorRestauracion(int id, String resultado, String observaciones) {
            this.id = id;
            this.resultado = resultado;
            this.observaciones = observaciones;
        }
    }

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
                    request.setAttribute("motivos", solicitudDAO.listarMotivos());
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
                    request.setAttribute("idIncidencia", parseId(request.getParameter("id")));

                    forward(request, response, "/views/no-exito.jsp");
                    break;

                case "perfil":
                    cargarFotoPerfil(request);
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
                Object cuenta = request.getSession().getAttribute("usuarioSesion");
                if (!(cuenta instanceof Usuario)) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Inicia sesión para editar tu perfil.");
                    return;
                }
                Usuario actual = (Usuario) cuenta;
                try {
                    String nombre = trim(request.getParameter("nombre"));
                    String apellido = trim(request.getParameter("apellido"));
                    String correo = trim(request.getParameter("correo"));
                    String nueva = request.getParameter("nuevaPassword") == null ? "" : request.getParameter("nuevaPassword");
                    if (nombre.isEmpty() || apellido.isEmpty() || nombre.length()>50 || apellido.length()>50)
                        throw new IllegalArgumentException("Nombre y apellido son obligatorios y admiten hasta 50 caracteres.");
                    if (correo.length()>50 || !correo.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+"))
                        throw new IllegalArgumentException("Ingresa un correo válido de hasta 50 caracteres.");
                    if (nueva.length()>256 || !nueva.equals(request.getParameter("confirmarPassword")))
                        throw new IllegalArgumentException("Las contraseñas nuevas deben coincidir y admitir hasta 256 caracteres.");
                    String claveActual = request.getParameter("claveActual");
                    if (claveActual == null || claveActual.isEmpty()) throw new IllegalArgumentException("Ingresa tu contraseña actual.");
                    byte[] foto = null;
                    jakarta.servlet.http.Part archivo = request.getPart("foto");
                    if (archivo != null && archivo.getSize()>0) {
                        if (!"image/jpeg".equals(archivo.getContentType()) && !"image/png".equals(archivo.getContentType()))
                            throw new IllegalArgumentException("La foto debe ser JPG o PNG.");
                        try (java.io.InputStream entrada = archivo.getInputStream()) { foto = entrada.readAllBytes(); }
                        if (javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(foto)) == null)
                            throw new IllegalArgumentException("El archivo no es una imagen válida.");
                    }
                    Usuario editado = new Usuario();
                    editado.setIdUsuario(actual.getIdUsuario());editado.setNombre(nombre);editado.setApellido(apellido);
                    editado.setCorreo(correo);editado.setPassword(nueva);
                    new UsuarioDAO().actualizarPerfil(editado, claveActual, foto, "true".equals(request.getParameter("quitarFoto")));
                    actual.setNombre(nombre);actual.setApellido(apellido);actual.setCorreo(correo);
                    response.sendRedirect(request.getContextPath()+"/NetworkOperatorServlet?action=perfil&guardado=1");
                } catch (IllegalArgumentException | java.sql.SQLException e) {
                    log("No se pudo actualizar el perfil", e);
                    request.setAttribute("error", e instanceof java.sql.SQLException
                            ? (((java.sql.SQLException)e).getErrorCode()==1062 ? "El correo ya está registrado." : "No se pudo guardar el perfil.") : e.getMessage());
                    cargarFotoPerfil(request);
                    forward(request, response, "/views/no-perfil.jsp");
                }
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
                String observacion = request.getParameter("observacion");

                try {
                    if (estado == null || estado.trim().isEmpty()) {
                        throw new IllegalArgumentException("El estado es obligatorio.");
                    }
                    incidenciaDAO.actualizarEstado(id, estado, observacion);
                } catch (IllegalArgumentException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    request.setAttribute("error", e.getMessage());
                    request.setAttribute("nuevoEstado", estado);
                    request.setAttribute("observacion", observacion);

                    cargarDetalle(request, id);

                    forward(request, response,
                            "/views/no-incidencia-actualizar.jsp");
                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=actualizacion&id=" + id);
                return;
            }

            if ("revisarRestauracion".equals(action) || "editarRestauracion".equals(action)
                    || "registrarRestauracion".equals(action)) {
                procesarRestauracion(request, response, action);
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

                    request.setAttribute(
                            "clientes", solicitudDAO.listarClientes());

                    request.setAttribute(
                            "rutas", solicitudDAO.listarRutas());

                    forward(request, response,
                            "/views/no-solicitud-form.jsp");
                    return;
                }

                SolicitudCapacidad solicitud =
                        new SolicitudCapacidad();

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
                solicitud.setIdUsuario(3);

                solicitudDAO.crear(solicitud);

                response.sendRedirect(
                        request.getContextPath()
                                + "/NetworkOperatorServlet?action=exito"
                                + "&tipo=solicitud");
                return;
            }

            response.sendRedirect(
                    request.getContextPath()
                            + "/NetworkOperatorServlet?action=panel");

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,e.getMessage());
        } catch (Exception e) {
            throw new ServletException(
                    "No se pudo guardar la operación. "
                            + "Verifica los datos y la conexión a MySQL.", e);
        }
    }

    private void procesarRestauracion(HttpServletRequest request, HttpServletResponse response,
                                     String action) throws ServletException, IOException, java.sql.SQLException {
        int id = parseId(request.getParameter("id"));
        HttpSession sesion = request.getSession();
        String vistaFormulario = "/views/no-incidencia-restauracion.jsp";
        cargarDetalle(request, id);

        String resultado = request.getParameter("resultado");
        String observaciones = trim(request.getParameter("observaciones"));

        try {
            if (!"revisarRestauracion".equals(action)) {
                String codigo = request.getParameter("codigoConfirmacion");
                BorradorRestauracion borrador;
                synchronized (sesion) {
                    borrador = (BorradorRestauracion) sesion.getAttribute(BORRADOR_RESTAURACION);
                    if (borrador == null || borrador.id != id || !borrador.codigo.equals(codigo)) {
                        throw new IllegalArgumentException("Vuelve a ingresar los datos para confirmar la restauración.");
                    }
                    sesion.removeAttribute(BORRADOR_RESTAURACION);
                }
                resultado = borrador.resultado;
                observaciones = borrador.observaciones;
            }

            if ("editarRestauracion".equals(action)) {
                request.setAttribute("resultado", resultado);
                request.setAttribute("observaciones", observaciones);
                forward(request, response, vistaFormulario);
                return;
            }

            String motivoRestauracion = (String) request.getAttribute("motivoRestauracion");
            if (motivoRestauracion != null) {
                throw new IllegalArgumentException(motivoRestauracion);
            }
            if ("revisarRestauracion".equals(action)) {
                if (!"Servicio restablecido".equals(resultado) && !"Restauración parcial".equals(resultado)) {
                    throw new IllegalArgumentException("Selecciona un resultado de restauración válido.");
                }
                if (observaciones.isEmpty()) {
                    throw new IllegalArgumentException("Completa las observaciones de la restauración.");
                }

                BorradorRestauracion borrador = new BorradorRestauracion(id, resultado, observaciones);
                synchronized (sesion) {
                    sesion.setAttribute(BORRADOR_RESTAURACION, borrador);
                }
                request.setAttribute("resultado", resultado);
                request.setAttribute("observaciones", observaciones);
                request.setAttribute("codigoConfirmacion", borrador.codigo);
                forward(request, response, "/views/no-incidencia-restauracion-confirmar.jsp");
                return;
            }

            incidenciaDAO.registrarRestauracion(id, resultado, observaciones);
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            request.setAttribute("error", e.getMessage());
            request.setAttribute("resultado", resultado);
            request.setAttribute("observaciones", observaciones);
            forward(request, response, vistaFormulario);
            return;
        }

        response.sendRedirect(request.getContextPath()
                + "/NetworkOperatorServlet?action=exito&tipo=restauracion&id=" + id);
    }

    private void cargarDetalle(HttpServletRequest request, int id) throws java.sql.SQLException {
        Incidencia incidencia = incidenciaDAO.obtener(id);
        String motivoRestauracion = null;
        if (incidencia == null) {
            motivoRestauracion = "Incidencia no encontrada.";
        } else if ("Cerrada".equals(incidencia.getEstado())) {
            motivoRestauracion = "La incidencia está cerrada.";
        } else if ("Servicio restaurado".equals(incidencia.getEstado())) {
            motivoRestauracion = "La incidencia ya figura como servicio restaurado.";
        } else if (!incidenciaDAO.puedeRestaurar(id)) {
            motivoRestauracion = "Para registrar la restauración, deben finalizar los mantenimientos correctivos de todos los segmentos afectados y registrar sus resultados.";
        }
        request.setAttribute("motivoRestauracion", motivoRestauracion);
        request.setAttribute("incidencia", incidencia);
        request.setAttribute(
                "eventos", eventoDAO.listarPorIncidencia(id));
        request.setAttribute("serviciosAfectados", incidenciaDAO.listarServiciosAfectados(id));
        request.setAttribute("responsableIncidencia", incidenciaDAO.obtenerResponsable(id));
    }

    private void cargarFotoPerfil(HttpServletRequest request) throws java.sql.SQLException {
        Object cuenta = request.getSession().getAttribute("usuarioSesion");
        if (cuenta instanceof Usuario) {
            byte[] foto = new UsuarioDAO().obtenerFoto(((Usuario)cuenta).getIdUsuario());
            if (foto != null) request.setAttribute("fotoPerfil", "data:image/"
                    + (foto.length>0 && foto[0]==(byte)0x89 ? "png" : "jpeg")
                    + ";base64,"+java.util.Base64.getEncoder().encodeToString(foto));
        }
    }

    private void forward(HttpServletRequest request,
                         HttpServletResponse response,
                         String ruta)
            throws ServletException, IOException {

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(ruta);

        dispatcher.forward(request, response);
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
