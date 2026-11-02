package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.bean.Cliente;
import pe.edu.oceanlink.bean.Ruta;
import pe.edu.oceanlink.bean.Servicio;
import pe.edu.oceanlink.dao.ClienteDAO;
import pe.edu.oceanlink.dao.RutaDAO;
import pe.edu.oceanlink.dao.ServicioDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.UUID;

/** Controlador MVC de servicios contratados del Capacity Planner. */
@WebServlet(name = "ServicioServlet", value = "/capacity-planner/servicios")
public class ServicioServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null || action.isBlank()) action = "lista";

        ServicioDAO servicioDAO = new ServicioDAO();
        ClienteDAO clienteDAO = new ClienteDAO();
        RutaDAO rutaDAO = new RutaDAO();
        RequestDispatcher view;
        try {
            switch (action) {
                case "lista":
                    request.setAttribute("clientes", clienteDAO.obtenerListaTrabajos());
                    view = request.getRequestDispatcher("/views/servicios.jsp");
                    view.forward(request, response);
                    break;
                case "detalle": {
                    int idCliente = idPositivo(request.getParameter("cliente"));
                    Cliente cliente = clienteDAO.obtenerTrabajo(String.valueOf(idCliente));
                    if (cliente == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Cliente inexistente");
                        return;
                    }
                    request.setAttribute("cliente", cliente);
                    request.setAttribute("lista", servicioDAO.obtenerServiciosPorCliente(idCliente));
                    view = request.getRequestDispatcher("/views/servicio-detalle.jsp");
                    view.forward(request, response);
                    break;
                }
                case "exito": {
                    int idCliente = idPositivo(request.getParameter("cliente"));
                    int idServicio = idPositivo(request.getParameter("servicio"));
                    Servicio guardado = servicioDAO.obtenerServicio(idServicio);
                    if (guardado == null || guardado.getIdCliente() != idCliente) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Servicio no encontrado para este cliente");
                        return;
                    }
                    request.setAttribute("servicioGuardado", guardado);
                    request.setAttribute("clienteId", idCliente);
                    view = request.getRequestDispatcher("/views/servicio-exito.jsp");
                    view.forward(request, response);
                    break;
                }
                case "formCrear": {
                    int idCliente = idPositivo(request.getParameter("cliente"));
                    Cliente cliente = clienteDAO.obtenerTrabajo(String.valueOf(idCliente));
                    if (cliente == null || !"Activo".equals(cliente.getEstado())) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "El cliente debe estar activo");
                        return;
                    }
                    request.setAttribute("cliente", cliente);
                    ArrayList<Ruta> rutas = rutaDAO.obtenerListaRutas();
                    // Cargar segmentos REALES ordenados, no los del HTML de demostración.
                    for (Ruta r : rutas) {
                        if ("Operativa".equals(r.getEstado())) {
                            Ruta completa = rutaDAO.obtenerRuta(r.getIdRuta());
                            if (completa != null) r.setSegmentos(completa.getSegmentos());
                        }
                    }
                    request.setAttribute("rutas", rutas);
                    view = request.getRequestDispatcher("/views/servicio-form.jsp");
                    view.forward(request, response);
                    break;
                }
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
            }
        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Identificador inválido");
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException("Error al consultar servicios", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ServicioDAO servicioDAO = new ServicioDAO();
        ClienteDAO clienteDAO = new ClienteDAO();
        RutaDAO rutaDAO = new RutaDAO();
        try {
            if ("confirmar".equals(action)) {
                Servicio servicio = construirServicio(request, clienteDAO, rutaDAO);
                request.setAttribute("servicio", servicio);
                request.setAttribute("cliente", clienteDAO.obtenerTrabajo(String.valueOf(servicio.getIdCliente())));
                request.setAttribute("ruta", rutaDAO.obtenerRuta(servicio.getIdRuta()));
                request.getRequestDispatcher("/views/servicio-confirm.jsp").forward(request, response);
            } else if ("guardar".equals(action)) {
                // Revalidar: nunca confiar en los campos hidden de la pantalla de confirmación.
                Servicio servicio = construirServicio(request, clienteDAO, rutaDAO);
                servicio.setCodigo("SRV-" + LocalDate.now().getYear() + "-" +
                        UUID.randomUUID().toString().substring(0, 8).toUpperCase());
                // Estado administrativo actual; no implica una reserva física de capacidad.
                servicio.setEstado("Activo");
                int nuevoId = servicioDAO.crearServicio(servicio);
                response.sendRedirect(request.getContextPath() + "/capacity-planner/servicios?action=exito&cliente=" +
                        servicio.getIdCliente() + "&servicio=" + nuevoId);
            } else if ("estado".equals(action)) {
                int idServicio = idPositivo(request.getParameter("idServicio"));
                int idCliente = idPositivo(request.getParameter("cliente"));
                String estado = request.getParameter("estado");
                if (!("Activo".equals(estado) || "Suspendido".equals(estado) || "Cancelado".equals(estado))) {
                    throw new IllegalArgumentException("Estado de servicio no válido");
                }
                Servicio existente = servicioDAO.obtenerServicio(idServicio);
                if (existente == null || existente.getIdCliente() != idCliente) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Servicio no encontrado para este cliente");
                    return;
                }
                servicioDAO.cambiarEstado(idServicio, estado);
                response.sendRedirect(request.getContextPath() + "/capacity-planner/servicios?action=detalle&cliente=" +
                        idCliente + "&actualizado=1");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
            }
        } catch (IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, ex.getMessage());
        } catch (SQLException | ClassNotFoundException ex) {
            throw new ServletException("Error al guardar o actualizar el servicio", ex);
        }
    }

    private int idPositivo(String valor) {
        int id = Integer.parseInt(valor);
        if (id <= 0) throw new IllegalArgumentException("El identificador debe ser positivo");
        return id;
    }

    private Servicio construirServicio(HttpServletRequest request, ClienteDAO clienteDAO, RutaDAO rutaDAO)
            throws SQLException, ClassNotFoundException {
        int idCliente = idPositivo(request.getParameter("cliente"));
        int idRuta = idPositivo(request.getParameter("ruta"));
        Cliente cliente = clienteDAO.obtenerTrabajo(String.valueOf(idCliente));
        if (cliente == null || !"Activo".equals(cliente.getEstado()))
            throw new IllegalArgumentException("El cliente no existe o está inactivo");
        Ruta ruta = rutaDAO.obtenerRuta(idRuta);
        if (ruta == null || !"Operativa".equals(ruta.getEstado()))
            throw new IllegalArgumentException("Selecciona una ruta operativa");

        LocalDate fecha;
        try {
            fecha = LocalDate.parse(request.getParameter("fechaActivacion"));
        } catch (RuntimeException ex) {
            throw new IllegalArgumentException("Fecha de activación inválida");
        }

        Servicio servicio = new Servicio();
        servicio.setIdCliente(idCliente);
        servicio.setIdRuta(idRuta);
        // Los nombres se obtienen de RutaDAO, no se aceptan del formulario.
        servicio.setOrigen(ruta.getNombreOrigen());
        servicio.setDestino(ruta.getNombreDestino());
        if (servicio.getOrigen() == null || servicio.getDestino() == null)
            throw new IllegalArgumentException("La ruta no tiene estaciones de origen y destino definidas");
        // La capacidad se asignará desde el módulo Capacidad, aún pendiente.
        servicio.setCapacidadContratada(null);
        servicio.setFechaActivacion(fecha);
        return servicio;
    }
}
