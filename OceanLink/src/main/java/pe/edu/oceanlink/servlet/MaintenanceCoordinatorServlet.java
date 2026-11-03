package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.bean.Mantenimiento;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.dao.MantenimientoDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(name="MaintenanceCoordinatorServlet",value={"/MaintenanceCoordinatorServlet","/maintenance-coordinator","/maintenance-coordinator/mantenimientos","/maintenance-coordinator/historial"})
public class MaintenanceCoordinatorServlet extends HttpServlet {
    private static final String BASE="/maintenance-coordinator/mantenimientos";
    private final MantenimientoDAO dao=new MantenimientoDAO();
    private int id(String valor){try{int id=Integer.parseInt(valor);if(id>0)return id;}catch(NumberFormatException e){ }throw new IllegalArgumentException("Selecciona un identificador válido.");}
    private int actor(HttpServletRequest r){Object u=r.getSession().getAttribute("usuarioSesion");return u instanceof Usuario?((Usuario)u).getIdUsuario():id(r.getParameter("idResponsable"));}
    private String accion(HttpServletRequest r){return "/maintenance-coordinator/historial".equals(r.getServletPath())?"historial":r.getParameter("action")==null?"lista":r.getParameter("action");}
    private void redirigir(HttpServletRequest r,HttpServletResponse s,String sufijo)throws IOException{s.sendRedirect(r.getContextPath()+BASE+sufijo);}
    private void token(HttpServletRequest r,String operacion,int id){String t=UUID.randomUUID().toString();r.getSession().setAttribute("mcToken."+operacion+"."+id,t);r.setAttribute("mcToken",t);}
    private void consumir(HttpServletRequest r,String operacion,int id){HttpSession sesion=r.getSession();synchronized(sesion){String llave="mcToken."+operacion+"."+id,t=r.getParameter("token");if(t==null||!t.equals(sesion.getAttribute(llave)))throw new IllegalArgumentException("El formulario venció o ya fue enviado. Revisa los datos y vuelve a intentarlo.");sesion.removeAttribute(llave);}}
    @Override protected void doGet(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
        r.setCharacterEncoding("UTF-8");s.setCharacterEncoding("UTF-8");mostrar(r,s,accion(r));
    }
    private void mostrar(HttpServletRequest r,HttpServletResponse s,String accion)throws ServletException,IOException{
        r.setAttribute("seccionMC","historial".equals(accion)?"historial":"mantenimientos");r.setAttribute("tituloMC","Maintenance Coordinator");
        String vista="mc-mantenimientos.jsp";
        try{
            Object u=r.getSession().getAttribute("usuarioSesion");if(u instanceof Usuario)dao.validarResponsable(((Usuario)u).getIdUsuario());
            r.setAttribute("responsablesMC",dao.listarResponsables());
            if("lista".equals(accion)||"historial".equals(accion)){
                r.setAttribute("listaMC",dao.listar("historial".equals(accion)));r.setAttribute("esHistorial", "historial".equals(accion));r.setAttribute("tituloMC","historial".equals(accion)?"Historial de Mantenimientos":"Gestión de Mantenimientos");
            }else if("registro".equals(accion)){
                vista="mc-mantenimiento-registrar.jsp";r.setAttribute("tituloMC","Registrar Mantenimiento");r.setAttribute("infraestructuraMC",dao.listarInfraestructura());r.setAttribute("incidenciasMC",dao.listarIncidencias());token(r,"crear",0);
            }else if(Arrays.asList("detalle","estado","confirmar","finalizar").contains(accion)){
                Mantenimiento m=dao.obtener(id(r.getParameter("id")));if(m==null){s.sendError(404,"El mantenimiento no existe.");return;}r.setAttribute("mantenimiento",m);
                if("detalle".equals(accion)){
                    vista="mc-mantenimiento-detalle.jsp";r.setAttribute("tituloMC",m.getCodigo());r.setAttribute("eventosMC",dao.bitacora(m.getIdMantenimiento()));r.setAttribute("serviciosMC",dao.serviciosAfectados(m.getIdMantenimiento()));token(r,"actividad",m.getIdMantenimiento());
                    Object mensaje=r.getSession().getAttribute("mcMensaje");r.getSession().removeAttribute("mcMensaje");if(mensaje!=null)r.setAttribute("mensajeMC",mensaje);
                }else if("confirmar".equals(accion)){
                    Object b=r.getSession().getAttribute("mcBorrador");
                    if(!(b instanceof Map)||!String.valueOf(m.getIdMantenimiento()).equals(((Map<?,?>)b).get("id"))){redirigir(r,s,"?action=estado&id="+m.getIdMantenimiento());return;}
                    r.setAttribute("borradorMC",b);vista="mc-mantenimiento-estado-confirmar.jsp";r.setAttribute("tituloMC","Confirmar Cambio de Estado");r.setAttribute("centrarMC",true);
                }else{
                    if(m.isFinalizado())throw new IllegalArgumentException("El mantenimiento está finalizado y solo puede consultarse.");
                    if("finalizar".equals(accion)&&!"En ejecución".equals(m.getEstado()))throw new IllegalArgumentException("Solo se puede finalizar un mantenimiento en ejecución.");
                    vista="estado".equals(accion)?"mc-mantenimiento-estado.jsp":"mc-mantenimiento-finalizar.jsp";
                    r.setAttribute("tituloMC","estado".equals(accion)?"Modificar Estado de Mantenimiento":"Registrar Finalización");r.setAttribute("estadosMC",MantenimientoDAO.estadosPermitidos(m.getEstado()));
                    Object borrador=r.getSession().getAttribute("mcBorrador");if(borrador instanceof Map&&String.valueOf(m.getIdMantenimiento()).equals(((Map<?,?>)borrador).get("id")))r.setAttribute("borradorMC",borrador);
                    token(r,"estado".equals(accion)?"preparar":"finalizar",m.getIdMantenimiento());
                }
            }else if("exito".equals(accion)){
                Object resultado=r.getSession().getAttribute("mcExito");r.getSession().removeAttribute("mcExito");if(resultado==null){redirigir(r,s,"");return;}r.setAttribute("exitoMC",resultado);r.setAttribute("tituloMC","Estado Modificado Correctamente");r.setAttribute("centrarMC",true);vista="mc-mantenimiento-estado-exito.jsp";
            }else if("perfil".equals(accion)){
                vista="mc-perfil.jsp";r.setAttribute("tituloMC","Mi perfil");
            }else if("sesionCerrada".equals(accion)){
                vista="mc-sesion-cerrada.jsp";r.setAttribute("tituloMC","Sesión cerrada");r.setAttribute("centrarMC",true);r.setAttribute("ocultarPerfilMC",true);
            }else{s.sendError(400,"Acción de mantenimiento no válida.");return;}
        }catch(IllegalArgumentException e){s.setStatus(400);r.setAttribute("errorMC",e.getMessage());vista="mc-error.jsp";}
        catch(SQLException e){log("No se pudo consultar Maintenance Coordinator",e);s.setStatus(500);r.setAttribute("errorMC","No se pudieron cargar los datos. Verifica MySQL y la actualización del script SQL.");vista="mc-error.jsp";}
        r.getRequestDispatcher("/views/"+vista).forward(r,s);
    }
    @Override protected void doPost(HttpServletRequest r,HttpServletResponse s)throws ServletException,IOException{
        r.setCharacterEncoding("UTF-8");s.setCharacterEncoding("UTF-8");String accion=r.getParameter("action"),volver="lista";
        try{
            if("cerrarSesion".equals(accion)){r.getSession().invalidate();redirigir(r,s,"?action=sesionCerrada");return;}
            if("crear".equals(accion)){
                volver="registro";Mantenimiento m=new Mantenimiento();m.setTipo(r.getParameter("tipo"));m.setTitulo(r.getParameter("titulo"));m.setDescripcion(r.getParameter("descripcion"));
                String infra=r.getParameter("infraestructura");if(infra==null)throw new IllegalArgumentException("Selecciona la infraestructura.");
                if(infra.startsWith("SEG:"))m.setIdSegmento(id(infra.substring(4)));else if(infra.startsWith("LS:"))m.setIdLandingStation(id(infra.substring(3)));else throw new IllegalArgumentException("Infraestructura no válida.");
                String incidencia=r.getParameter("idIncidencia");if(incidencia!=null&&!incidencia.isBlank())m.setIdIncidencia(id(incidencia));
                try{m.setFechaInicio(Timestamp.valueOf(LocalDateTime.parse(r.getParameter("fechaInicio"))));m.setDuracionEstimada(new BigDecimal(r.getParameter("duracion")));}catch(Exception e){throw new IllegalArgumentException("Ingresa una fecha de inicio y una duración válidas.");}
                int responsable=actor(r);consumir(r,"crear",0);int nuevo=dao.crear(m,responsable);r.getSession().setAttribute("mcMensaje","Mantenimiento registrado correctamente.");redirigir(r,s,"?action=detalle&id="+nuevo);return;
            }
            int id=id(r.getParameter("id"));
            if("actividad".equals(accion)){
                volver="detalle";int responsable=actor(r);consumir(r,"actividad",id);dao.agregarActividad(id,r.getParameter("actividad"),responsable);r.getSession().setAttribute("mcMensaje","Actividad registrada correctamente.");redirigir(r,s,"?action=detalle&id="+id);return;
            }
            if("preparar".equals(accion)){
                volver="estado";Mantenimiento m=dao.obtener(id);if(m==null)throw new IllegalArgumentException("El mantenimiento no existe.");
                String nuevo=r.getParameter("nuevoEstado"),motivo=r.getParameter("justificacion");
                if(!MantenimientoDAO.estadosPermitidos(m.getEstado()).contains(nuevo))throw new IllegalArgumentException("Selecciona un nuevo estado permitido.");
                if(motivo==null||motivo.isBlank()||motivo.trim().length()>2000)throw new IllegalArgumentException("La justificación es obligatoria y admite hasta 2000 caracteres.");
                int responsable=actor(r);dao.validarResponsable(responsable);consumir(r,"preparar",id);
                Map<String,String> b=new HashMap<>();b.put("id",String.valueOf(id));b.put("anterior",m.getEstado());b.put("nuevoEstado",nuevo);b.put("justificacion",motivo.trim());b.put("idResponsable",String.valueOf(responsable));b.put("token",UUID.randomUUID().toString());r.getSession().setAttribute("mcBorrador",b);redirigir(r,s,"?action=confirmar&id="+id);return;
            }
            if("confirmar".equals(accion)){
                volver="estado";Map<?,?> b;
                synchronized(r.getSession()){
                    Object valor=r.getSession().getAttribute("mcBorrador");if(!(valor instanceof Map))throw new IllegalArgumentException("La confirmación venció o ya se registró.");b=(Map<?,?>)valor;
                    if(!String.valueOf(id).equals(b.get("id"))||!Objects.equals(r.getParameter("token"),b.get("token")))throw new IllegalArgumentException("Confirmación no válida.");r.getSession().removeAttribute("mcBorrador");
                }
                Object actual=r.getSession().getAttribute("usuarioSesion");int usuario=actual instanceof Usuario?((Usuario)actual).getIdUsuario():Integer.parseInt(b.get("idResponsable").toString());
                dao.cambiarEstado(id,b.get("anterior").toString(),b.get("nuevoEstado").toString(),b.get("justificacion").toString(),usuario);
                Mantenimiento m=dao.obtener(id);Map<String,String> exito=new HashMap<>();exito.put("id",String.valueOf(id));exito.put("codigo",m.getCodigo());exito.put("estado",m.getEstado());r.getSession().setAttribute("mcExito",exito);redirigir(r,s,"?action=exito");return;
            }
            if("finalizar".equals(accion)){
                volver="finalizar";int usuario=actor(r);consumir(r,"finalizar",id);dao.finalizar(id,r.getParameter("resultado"),usuario);r.getSession().setAttribute("mcMensaje","Mantenimiento finalizado. El resultado quedó registrado en la bitácora.");redirigir(r,s,"?action=detalle&id="+id);return;
            }
            s.sendError(400,"Acción de mantenimiento no válida.");
        }catch(IllegalArgumentException e){s.setStatus(400);r.setAttribute("errorMC",e instanceof NumberFormatException?"Selecciona un responsable válido.":e.getMessage());mostrar(r,s,volver);}
        catch(SQLException e){log("No se pudo guardar el mantenimiento",e);s.setStatus(500);r.setAttribute("errorMC","No se guardaron los cambios. Verifica la conexión con MySQL y el script SQL.");mostrar(r,s,volver);}
    }
}
