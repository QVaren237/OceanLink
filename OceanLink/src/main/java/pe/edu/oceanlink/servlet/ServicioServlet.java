package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.bean.Servicio;
import pe.edu.oceanlink.dao.ServicioDAO;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet(name="ServicioServlet", urlPatterns="/ServicioServlet")
public class ServicioServlet extends HttpServlet {
    private final ServicioDAO dao = new ServicioDAO();

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action") == null ? "lista" : req.getParameter("action");
        try {
            switch(action) {
                case "lista":
                    req.setAttribute("clientes", dao.listarClientes());
                    req.getRequestDispatcher("/views/servicios.jsp").forward(req,resp);
                    break;
                case "detalle":
                    int cliente = entero(req.getParameter("cliente"));
                    String nombre = dao.nombreCliente(cliente);
                    if(nombre == null) { resp.sendError(404,"Cliente no encontrado"); return; }
                    req.setAttribute("clienteId",cliente);
                    req.setAttribute("clienteNombre",nombre);
                    req.setAttribute("lista",dao.listar(cliente));
                    req.getRequestDispatcher("/views/servicios.jsp").forward(req,resp);
                    break;
                case "formCrear":
                    int id = entero(req.getParameter("cliente"));
                    if(!dao.clienteActivo(id)) { resp.sendError(400,"Selecciona un cliente activo"); return; }
                    req.setAttribute("clienteId",id);
                    req.setAttribute("clienteNombre",dao.nombreCliente(id));
                    req.setAttribute("rutas",dao.listarRutas());
                    req.getRequestDispatcher("/views/servicio-form.jsp").forward(req,resp);
                    break;
                default: resp.sendError(400,"Acción desconocida");
            }
        } catch(IllegalArgumentException e) { resp.sendError(400,e.getMessage()); }
          catch(SQLException e) { throw new ServletException("Error consultando servicios",e); }
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        try {
            if("confirmar".equals(action)) {
                Servicio s = validar(req);
                req.setAttribute("servicio",s);
                req.setAttribute("clienteNombre",dao.nombreCliente(s.getIdCliente()));
                req.setAttribute("rutaNombre",dao.nombreRuta(s.getIdRuta()));
                req.getRequestDispatcher("/views/servicio-confirm.jsp").forward(req,resp);
            } else if("guardar".equals(action)) {
                Servicio s = validar(req); // Revalidar todos los campos, sin confiar en los ocultos.
                s.setCodigo(dao.proximoCodigo());
                s.setEstado("Activo");
                int nuevoId = dao.crear(s);
                resp.sendRedirect(req.getContextPath()+"/ServicioServlet?action=detalle&cliente="+s.getIdCliente()+"&creado="+nuevoId);
            } else if("estado".equals(action)) {
                int id = entero(req.getParameter("idServicio"));
                int idCliente = entero(req.getParameter("cliente"));
                String estado = req.getParameter("estado");
                if(!("Activo".equals(estado)||"Suspendido".equals(estado)||"Cancelado".equals(estado)))
                    throw new IllegalArgumentException("Estado inválido");
                Servicio anterior = dao.obtener(id);
                if(anterior == null || anterior.getIdCliente()!=idCliente) {
                    resp.sendError(404,"Servicio no encontrado para ese cliente"); return;
                }
                if(!dao.cambiarEstado(id,estado)) throw new SQLException("No se actualizó el estado");
                resp.sendRedirect(req.getContextPath()+"/ServicioServlet?action=detalle&cliente="+idCliente+"&actualizado=1");
            } else resp.sendError(400,"Acción desconocida");
        } catch(IllegalArgumentException e) {
            resp.sendError(400,"Datos inválidos: "+e.getMessage());
        } catch(SQLException e) { throw new ServletException("Error al guardar el servicio",e); }
    }

    private int entero(String v) {
        if(v == null || !v.matches("[0-9]{1,9}")) throw new IllegalArgumentException("Identificador inválido");
        int n = Integer.parseInt(v);
        if(n<=0) throw new IllegalArgumentException("Identificador inválido");
        return n;
    }
    private Servicio validar(HttpServletRequest req) throws SQLException {
        int cliente = entero(req.getParameter("cliente"));
        int ruta = entero(req.getParameter("ruta"));
        if(!dao.clienteActivo(cliente)) throw new IllegalArgumentException("El cliente no está activo");
        String[] extremos = dao.extremosRuta(ruta);
        if(extremos == null) throw new IllegalArgumentException("La ruta no existe o no está operativa");
        String cap = req.getParameter("capacidad");
        BigDecimal capacidad;
        try { capacidad = new BigDecimal(cap); }
        catch(RuntimeException e) { throw new IllegalArgumentException("Capacidad inválida"); }
        if(capacidad.compareTo(BigDecimal.ZERO)<=0 || capacidad.scale()>2 ||
                capacidad.compareTo(new BigDecimal("9999999999.99"))>0)
            throw new IllegalArgumentException("La capacidad debe ser positiva y tener máximo dos decimales");
        LocalDate fecha;
        try { fecha=LocalDate.parse(req.getParameter("fechaActivacion")); }
        catch(RuntimeException e) { throw new IllegalArgumentException("Fecha inválida"); }
        Servicio s = new Servicio();
        s.setIdCliente(cliente); s.setIdRuta(ruta); s.setOrigen(extremos[0]);
        s.setDestino(extremos[1]); s.setCapacidadContratada(capacidad);
        s.setFechaActivacion(fecha);
        return s;
    }
}
