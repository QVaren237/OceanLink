package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.bean.Solicitud;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.dao.SolicitudDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet(name="SolicitudServlet",urlPatterns="/SolicitudServlet")
public class SolicitudServlet extends HttpServlet {
    private final SolicitudDAO dao=new SolicitudDAO();
    private int usuarioActual(HttpServletRequest req){
        HttpSession s=req.getSession(false);if(s==null)return 0;
        Object id=s.getAttribute("idUsuario");if(id instanceof Number)return ((Number)id).intValue();
        Object u=s.getAttribute("usuario");if(u instanceof Usuario){try{return Integer.parseInt(((Usuario)u).getIdUsuario());}catch(Exception ignored){}}
        return 0;
    }
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");String action=req.getParameter("action")==null?"lista":req.getParameter("action");
        try{
            if("lista".equals(action)){
                req.setAttribute("lista",dao.listar(req.getParameter("buscar"),req.getParameter("estado")));
                req.getRequestDispatcher("/views/network-solicitudes.jsp").forward(req,resp);
            }else if("nuevo".equals(action)||"editar".equals(action)){
                req.setAttribute("clientes",dao.listarClientes());req.setAttribute("rutas",dao.listarRutas());
                if("editar".equals(action)){Solicitud s=dao.obtener(entero(req.getParameter("id")));if(s==null){resp.sendError(404,"Solicitud no encontrada");return;}req.setAttribute("solicitud",s);}
                req.getRequestDispatcher("/views/network-solicitud-form.jsp").forward(req,resp);
            }else resp.sendError(400,"Acción no válida");
        }catch(IllegalArgumentException e){resp.sendError(400,e.getMessage());}
         catch(SQLException e){throw new ServletException("Error consultando solicitudes",e);}
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");String action=req.getParameter("action");
        try{
            if("crear".equals(action)||"actualizar".equals(action)){
                Solicitud s=validar(req);s.setEstado(opcion(req.getParameter("estado"),new String[]{"Pendiente","En revisión","Aprobada","Rechazada","Atendida"}));
                s.setObservacion(req.getParameter("observacion"));
                if("crear".equals(action)){
                    int usuario=usuarioActual(req);if(usuario<=0){resp.sendError(400,"No se encontró idUsuario en la sesión. Inicia sesión antes de registrar una solicitud.");return;}
                    s.setIdUsuario(usuario);s.setCodigo(dao.proximoCodigo());s.setFechaSolicitud(LocalDate.now());dao.crear(s);
                }else{s.setIdSolicitud(entero(req.getParameter("id")));if(!dao.actualizar(s)){resp.sendError(404,"Solicitud no encontrada");return;}}
                resp.sendRedirect(req.getContextPath()+"/SolicitudServlet?action=lista");
            }else if("eliminar".equals(action)){
                if(!dao.eliminar(entero(req.getParameter("id")))){resp.sendError(404,"Solicitud no encontrada");return;}
                resp.sendRedirect(req.getContextPath()+"/SolicitudServlet?action=lista");
            }else resp.sendError(400,"Acción no válida");
        }catch(IllegalArgumentException e){resp.sendError(400,e.getMessage());}
         catch(SQLException e){throw new ServletException("Error guardando solicitud",e);}
    }
    private Solicitud validar(HttpServletRequest req)throws SQLException{
        Solicitud s=new Solicitud();s.setIdCliente(entero(req.getParameter("idCliente")));s.setIdRuta(entero(req.getParameter("idRuta")));
        try{s.setCapacidadSolicitada(new BigDecimal(req.getParameter("capacidad")));}catch(Exception e){throw new IllegalArgumentException("Capacidad inválida");}
        if(s.getCapacidadSolicitada().compareTo(BigDecimal.ZERO)<=0||s.getCapacidadSolicitada().scale()>2)throw new IllegalArgumentException("La capacidad debe ser positiva y tener máximo dos decimales");
        try{s.setFechaLimite(req.getParameter("fechaLimite")==null||req.getParameter("fechaLimite").isBlank()?null:LocalDate.parse(req.getParameter("fechaLimite")));}catch(Exception e){throw new IllegalArgumentException("Fecha límite inválida");}
        if(s.getFechaLimite()!=null&&s.getFechaLimite().isBefore(LocalDate.now()))throw new IllegalArgumentException("La fecha límite no puede ser anterior a hoy");
        s.setMotivo(req.getParameter("motivo"));return s;
    }
    private int entero(String v){try{int n=Integer.parseInt(v);if(n<=0)throw new Exception();return n;}catch(Exception e){throw new IllegalArgumentException("Identificador inválido");}}
    private String opcion(String v,String[] ops){for(String op:ops)if(op.equals(v))return v;throw new IllegalArgumentException("Estado no válido");}
}
