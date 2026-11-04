package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.oceanlink.dao.RutaDAO;
import pe.edu.oceanlink.dao.CapacidadDAO;
import pe.edu.oceanlink.bean.CapacidadEnlace;
import pe.edu.oceanlink.bean.CapacidadServicio;
import pe.edu.oceanlink.bean.EvaluacionCapacidad;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.bean.HistoricoCapacidad;
import java.util.*;
import java.math.BigDecimal;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CapacityPlannerServlet", value = {"/CapacityPlannerServlet", "/capacity-planner", "/capacity-planner/panel", "/capacity-planner/capacidad", "/capacity-planner/solicitudes", "/capacity-planner/alertas", "/capacity-planner/historico"})
public class CapacityPlannerServlet extends HttpServlet {
    private static final String VISTAS = "/views/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        if ("/capacity-planner/capacidad".equals(request.getServletPath())) {
            mostrarCapacidad(request, response);
            return;
        }
        if ("/capacity-planner/solicitudes".equals(request.getServletPath())) {
            mostrarSolicitudes(request,response);
            return;
        }
        if ("/capacity-planner/alertas".equals(request.getServletPath())) {
            mostrarAlertas(request,response);return;
        }
        if ("/capacity-planner/historico".equals(request.getServletPath())) {
            mostrarHistorico(request,response);return;
        }
        String action = request.getParameter("action");
        if (action == null || "panel".equals(action)) {
            request.setAttribute("titulo", "Panel General");
            request.setAttribute("seccion", "panel");
            try {
                request.setAttribute("panel", new RutaDAO().obtenerResumenPanel());
            } catch (SQLException | ClassNotFoundException e) {
                log("No se pudo cargar el panel de Capacity Planner", e);
                response.setStatus(500);
                request.setAttribute("error", "No se pudo cargar el resumen. Verifica la conexión con MySQL e inténtalo nuevamente.");
            }
            request.getRequestDispatcher(VISTAS + "capacity-planner-panel.jsp").forward(request, response);
        } else if ("perfil".equals(action)) {
            request.setAttribute("titulo", "Mi perfil");
            request.setAttribute("seccion", "perfil");
            request.getRequestDispatcher(VISTAS + "capacity-planner-perfil.jsp").forward(request, response);
        } else if ("sesionCerrada".equals(action)) {
            request.setAttribute("titulo", "Sesión cerrada");
            request.setAttribute("seccion", "sesion");
            request.getRequestDispatcher(VISTAS + "capacity-planner-sesion-cerrada.jsp").forward(request, response);
        } else {
            response.sendError(400, "Acción no válida.");
        }
    }

    private void mostrarCapacidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("reserva".equals(action)) {
            mostrarReserva(request,response);
            return;
        }
        if ("reservaExito".equals(action)) {
            Object mensaje=request.getSession().getAttribute("reservaConfirmada");
            request.getSession().removeAttribute("reservaConfirmada");
            if(mensaje==null){response.sendRedirect(request.getContextPath()+"/capacity-planner/capacidad");return;}
            request.setAttribute("titulo","Reserva registrada");request.setAttribute("seccion","capacidad");request.setAttribute("mensajeReserva",mensaje);
            request.getRequestDispatcher(VISTAS+"capacidad-reserva-exito.jsp").forward(request,response);return;
        }
        boolean detalle = "detalle".equals(action);
        if (action != null && !"lista".equals(action) && !detalle) {
            response.sendError(400, "Acción de capacidad no válida.");
            return;
        }
        request.setAttribute("titulo", detalle ? "Detalle de enlace" : "Capacidad");
        request.setAttribute("seccion", "capacidad");
        CapacidadDAO dao = new CapacidadDAO();
        try {
            if (detalle) {
                int id;
                try {
                    id = Integer.parseInt(request.getParameter("id"));
                    if (id <= 0) throw new NumberFormatException();
                } catch (NumberFormatException e) {
                    response.sendError(400, "El identificador del segmento debe ser un entero positivo.");
                    return;
                }
                CapacidadEnlace enlace = dao.obtener(id);
                if (enlace == null) {
                    response.sendError(404, "No se encontró el segmento solicitado.");
                    return;
                }
                request.setAttribute("enlace", enlace);
                request.setAttribute("servicios", dao.listarServicios(id));
            } else {
                request.setAttribute("enlaces", dao.listar());
            }
        } catch (SQLException e) {
            log("No se pudo consultar la capacidad de la red", e);
            response.setStatus(500);
            request.setAttribute("error", "No se pudo consultar la capacidad. Verifica la conexión con MySQL e inténtalo nuevamente.");
        }
        request.getRequestDispatcher(VISTAS + (detalle ? "capacidad-detalle.jsp" : "capacidad.jsp"))
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        if("/capacity-planner/alertas".equals(request.getServletPath())&&"planificar".equals(request.getParameter("action"))){
            guardarAmpliacion(request,response);return;
        }
        if("/capacity-planner/capacidad".equals(request.getServletPath())&&"reservar".equals(request.getParameter("action"))){
            guardarReserva(request,response);return;
        }
        if("/capacity-planner/solicitudes".equals(request.getServletPath())&&"evaluar".equals(request.getParameter("action"))){
            evaluarSolicitud(request,response);return;
        }
        if (!"cerrarSesion".equals(request.getParameter("action"))) {
            response.sendError(400, "Acción no válida.");
            return;
        }
        HttpSession sesion = request.getSession(false);
        if (sesion != null) sesion.invalidate();
        response.sendRedirect(request.getContextPath() + "/capacity-planner/panel?action=sesionCerrada");
    }

    private int id(String texto){
        try{int id=Integer.parseInt(texto);if(id>0)return id;}catch(NumberFormatException e){ }
        throw new IllegalArgumentException("Selecciona un identificador válido.");
    }
    private Integer solicitudOpcional(HttpServletRequest request){
        String valor=request.getParameter("idSolicitud");return valor==null||valor.isBlank()?null:id(valor);
    }
    private int responsable(HttpServletRequest request){
        Object cuenta=request.getSession().getAttribute("usuarioSesion");
        return cuenta instanceof Usuario?((Usuario)cuenta).getIdUsuario():id(request.getParameter("idResponsable"));
    }
    private void cargarResponsables(HttpServletRequest request,CapacidadDAO dao) throws SQLException {
        request.setAttribute("responsables",dao.listarResponsables());
        request.setAttribute("responsableSesion",request.getSession().getAttribute("usuarioSesion"));
    }
    private void mostrarReserva(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        request.setAttribute("titulo","Reservar capacidad");request.setAttribute("seccion","capacidad");
        CapacidadDAO dao=new CapacidadDAO();
        try{
            Integer idSolicitud=solicitudOpcional(request);
            int base;
            if(idSolicitud!=null){
                EvaluacionCapacidad evaluacion=dao.obtenerEvaluacion(idSolicitud);
                if(evaluacion==null){response.sendError(404,"La solicitud no existe.");return;}
                if(!"Aprobada".equals(evaluacion.getSolicitud().getEstado())||evaluacion.getSegmentos().isEmpty())
                    throw new IllegalArgumentException("La solicitud debe estar aprobada y tener una ruta con segmentos.");
                request.setAttribute("evaluacion",evaluacion);base=evaluacion.getSegmentos().get(0).getIdSegmento();
            }else{base=id(request.getParameter("id"));}
            CapacidadEnlace enlace=dao.obtener(base);
            if(enlace==null){response.sendError(404,"El segmento no existe.");return;}
            request.setAttribute("enlace",enlace);
            ArrayList<CapacidadServicio> servicios=dao.serviciosReservables(base,idSolicitud);
            request.setAttribute("servicios",servicios);
            Map<Integer,ArrayList<CapacidadEnlace>> tramos=new LinkedHashMap<>();
            for(CapacidadServicio servicio:servicios)tramos.put(servicio.getIdServicio(),dao.segmentosRuta(dao.obtenerRutaServicio(servicio.getIdServicio())));
            request.setAttribute("tramosServicios",tramos);cargarResponsables(request,dao);
            String token=UUID.randomUUID().toString();request.getSession().setAttribute("tokenReserva",token);request.setAttribute("tokenReserva",token);
        }catch(IllegalArgumentException e){response.setStatus(400);request.setAttribute("error",e.getMessage());}
        catch(SQLException e){log("No se pudo cargar la reserva",e);response.setStatus(500);request.setAttribute("error","No se pudo cargar la reserva. Verifica la conexión y la actualización del SQL.");}
        request.getRequestDispatcher(VISTAS+"capacidad-reserva.jsp").forward(request,response);
    }
    private void guardarReserva(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        try{
            int servicio=id(request.getParameter("idServicio")),base=id(request.getParameter("id"));
            BigDecimal cantidad=CapacidadDAO.validarCantidad(request.getParameter("cantidad"));
            ArrayList<Integer> segmentos=new ArrayList<>();String[] valores=request.getParameterValues("segmentos");
            if(valores!=null)for(String valor:valores)segmentos.add(id(valor));
            if(!segmentos.contains(base))throw new IllegalArgumentException("La reserva debe incluir el segmento seleccionado.");
            int usuario=responsable(request);
            HttpSession sesion=request.getSession();
            synchronized(sesion){
                String token=request.getParameter("tokenReserva");
                if(token==null||!token.equals(sesion.getAttribute("tokenReserva")))
                    throw new IllegalArgumentException("El formulario ya se envió o venció. Revisa los datos y confirma nuevamente.");
                sesion.removeAttribute("tokenReserva");
            }
            new CapacidadDAO().reservar(servicio,segmentos,cantidad,solicitudOpcional(request),usuario);
            sesion.setAttribute("reservaConfirmada","Se reservaron "+cantidad.stripTrailingZeros().toPlainString()+" Gbps en "+segmentos.size()+" segmento(s)."
                    +(solicitudOpcional(request)==null?" Reserva directa, sin solicitud previa.":" La solicitud quedó en estado Reservada."));
            response.sendRedirect(request.getContextPath()+"/capacity-planner/capacidad?action=reservaExito");
        }catch(IllegalArgumentException e){request.setAttribute("error",e.getMessage());response.setStatus(400);mostrarReserva(request,response);}
        catch(SQLException e){log("No se pudo guardar la reserva",e);request.setAttribute("error","No se guardó la reserva. Verifica MySQL y que el SQL esté actualizado.");response.setStatus(500);mostrarReserva(request,response);}
    }
    private void mostrarSolicitudes(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        request.setAttribute("seccion","solicitudes");request.setAttribute("titulo","Solicitudes de capacidad");
        String action=request.getParameter("action");boolean detalle="evaluar".equals(action);
        if(action!=null&&!"lista".equals(action)&&!detalle){response.sendError(400,"Acción de solicitudes no válida. Solo Network Operator registra solicitudes.");return;}
        Object mensaje=request.getSession().getAttribute("solicitudEvaluada");
        request.getSession().removeAttribute("solicitudEvaluada");
        if(mensaje!=null)request.setAttribute("mensaje",mensaje);
        try{
            CapacidadDAO dao=new CapacidadDAO();
            if(detalle){
                EvaluacionCapacidad evaluacion=dao.obtenerEvaluacion(id(request.getParameter("id")));
                if(evaluacion==null){response.sendError(404,"No se encontró la solicitud.");return;}
                request.setAttribute("evaluacion",evaluacion);cargarResponsables(request,dao);
            }else{
                request.setAttribute("solicitudes",dao.listarSolicitudes());
            }
        }catch(IllegalArgumentException e){response.setStatus(400);request.setAttribute("error",e.getMessage());}
        catch(SQLException e){log("No se pudieron consultar las solicitudes",e);response.setStatus(500);request.setAttribute("error","No se pudieron cargar las solicitudes. Verifica MySQL y la actualización del SQL.");}
        request.getRequestDispatcher(VISTAS+(detalle?"capacidad-evaluar.jsp":"capacidad-solicitudes.jsp")).forward(request,response);
    }
    private void evaluarSolicitud(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        try{
            int id=id(request.getParameter("id"));
            String decision=request.getParameter("decision");
            new CapacidadDAO().evaluarSolicitud(id,decision,request.getParameter("comentario"),responsable(request));
            request.getSession().setAttribute("solicitudEvaluada","Solicitud "+decision.toLowerCase(java.util.Locale.ROOT)+" correctamente."
                    +("Aprobada".equals(decision)?" La aprobación no reserva capacidad automáticamente.":""));
            response.sendRedirect(request.getContextPath()+"/capacity-planner/solicitudes?action=evaluar&id="+id);
        }catch(IllegalArgumentException e){request.setAttribute("error",e.getMessage());response.setStatus(400);mostrarSolicitudes(request,response);}
        catch(SQLException e){log("No se pudo evaluar la solicitud",e);request.setAttribute("error","No se pudo guardar la evaluación. Verifica MySQL y la actualización del SQL.");response.setStatus(500);mostrarSolicitudes(request,response);}
    }
    private void mostrarAlertas(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        request.setAttribute("seccion","alertas");request.setAttribute("titulo","Alertas de Saturación");
        String accion=request.getParameter("action");String vista="alertas.jsp";
        if("exito".equals(accion)){
            Object codigo=request.getSession().getAttribute("ampliacionRegistrada");
            request.getSession().removeAttribute("ampliacionRegistrada");
            if(codigo==null){response.sendRedirect(request.getContextPath()+"/capacity-planner/alertas");return;}
            request.setAttribute("codigoAmpliacion",codigo);request.setAttribute("titulo","Ampliación Solicitada");vista="alerta-exito.jsp";
        }else if("ampliacion".equals(accion)||"planificar".equals(accion)){
            request.setAttribute("titulo","Planificar Ampliación");vista="alerta-ampliacion.jsp";
            try{
                CapacidadEnlace enlace=new CapacidadDAO().obtener(id(request.getParameter("id")));
                if(enlace==null){response.sendError(404,"No se encontró el segmento.");return;}
                request.setAttribute("enlace",enlace);
                if(!enlace.isAlertaSaturacion()){
                    response.setStatus(400);request.setAttribute("error","El segmento ya no presenta una alerta de saturación. Vuelve a consultar las alertas.");
                }else{
                    String token=UUID.randomUUID().toString();request.getSession().setAttribute("tokenAmpliacion."+enlace.getIdSegmento(),token);
                    request.setAttribute("tokenAmpliacion",token);
                }
            }catch(IllegalArgumentException e){response.setStatus(400);request.setAttribute("error",e.getMessage());}
            catch(SQLException e){log("No se pudo cargar el segmento para ampliación",e);response.setStatus(500);request.setAttribute("error","No se pudo consultar el segmento. Verifica la conexión con MySQL.");}
        }else if(accion==null||"lista".equals(accion)){
            try{request.setAttribute("alertas",new CapacidadDAO().listarAlertas());}
            catch(SQLException e){log("No se pudieron consultar las alertas",e);response.setStatus(500);request.setAttribute("error","No se pudieron consultar las alertas. Verifica la conexión con MySQL.");}
        }else{response.sendError(400,"Acción de alertas no válida.");return;}
        request.getRequestDispatcher(VISTAS+vista).forward(request,response);
    }

    private void guardarAmpliacion(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        try{
            int segmento=id(request.getParameter("id"));
            BigDecimal nueva=CapacidadDAO.validarCantidad(request.getParameter("capacidadNueva"));
            java.sql.Date fecha;
            try{fecha=java.sql.Date.valueOf(java.time.LocalDate.parse(request.getParameter("fechaLimite")));}
            catch(java.time.format.DateTimeParseException|NullPointerException e){throw new IllegalArgumentException("Selecciona una fecha límite válida.");}
            Object cuenta=request.getSession().getAttribute("usuarioSesion");
            Integer actor=cuenta instanceof Usuario?((Usuario)cuenta).getIdUsuario():null;
            HttpSession sesion=request.getSession();
            synchronized(sesion){
                String token=request.getParameter("tokenAmpliacion");
                if(token==null||!token.equals(sesion.getAttribute("tokenAmpliacion."+segmento)))
                    throw new IllegalArgumentException("El formulario ya se envió o venció. Revisa los datos antes de enviar nuevamente.");
                sesion.removeAttribute("tokenAmpliacion."+segmento);
            }
            String codigo=new CapacidadDAO().planificarAmpliacion(segmento,nueva,fecha,request.getParameter("justificacion"),actor);
            sesion.setAttribute("ampliacionRegistrada",codigo);
            response.sendRedirect(request.getContextPath()+"/capacity-planner/alertas?action=exito");
        }catch(IllegalArgumentException e){response.setStatus(400);request.setAttribute("error",e.getMessage());mostrarAlertas(request,response);}
        catch(SQLException e){log("No se pudo registrar la planificación de ampliación",e);response.setStatus(500);request.setAttribute("error","No se guardó la planificación. Verifica la conexión y la actualización del script SQL.");mostrarAlertas(request,response);}
    }

    private void mostrarHistorico(HttpServletRequest request,HttpServletResponse response) throws IOException,ServletException {
        request.setAttribute("seccion","historico");request.setAttribute("titulo","Histórico de Utilización");
        String rango=request.getParameter("rango");if(rango==null)rango="6meses";
        request.setAttribute("rango",rango);
        try{
            if(!Arrays.asList("6meses","actual","completo").contains(rango))throw new IllegalArgumentException("Selecciona un rango de tiempo válido.");
            String accion=request.getParameter("action");
            if(accion!=null&&!"lista".equals(accion)&&!"exportar".equals(accion))throw new IllegalArgumentException("Acción de histórico no válida.");
            CapacidadDAO dao=new CapacidadDAO();ArrayList<CapacidadEnlace> enlaces=dao.listar();request.setAttribute("enlaces",enlaces);
            if(!enlaces.isEmpty()){
                int segmento=request.getParameter("id")==null?enlaces.get(0).getIdSegmento():id(request.getParameter("id"));
                CapacidadEnlace enlace=dao.obtener(segmento);
                if(enlace==null){response.sendError(404,"El segmento no existe.");return;}
                request.setAttribute("enlace",enlace);
                java.time.LocalDate hoy=java.time.LocalDate.now(),desde="actual".equals(rango)?hoy.withDayOfYear(1):"completo".equals(rango)?java.time.LocalDate.of(1000,1,1):hoy.withDayOfMonth(1).minusMonths(5);
                ArrayList<HistoricoCapacidad> periodos=dao.consultarHistorico(segmento,java.sql.Date.valueOf(desde),java.sql.Date.valueOf(hoy.plusDays(1)));
                if("exportar".equals(accion)){exportarHistorico(response,segmento,periodos);return;}
                request.setAttribute("periodos",periodos);
                BigDecimal pico=null;
                for(HistoricoCapacidad periodo:periodos)if(periodo.getPico()!=null&&(pico==null||periodo.getPico().compareTo(pico)>0))pico=periodo.getPico();
                request.setAttribute("pico",pico);
                if(periodos.size()>1)request.setAttribute("crecimiento",HistoricoCapacidad.crecimiento(periodos.get(0).getPromedio(),periodos.get(periodos.size()-1).getPromedio()));
            }
        }catch(IllegalArgumentException e){response.setStatus(400);request.setAttribute("error",e.getMessage());}
        catch(SQLException e){log("No se pudo consultar el histórico",e);response.setStatus(500);request.setAttribute("error","No se pudo consultar el histórico. Verifica la conexión con MySQL.");}
        request.getRequestDispatcher(VISTAS+"historico.jsp").forward(request,response);
    }
    private void exportarHistorico(HttpServletResponse response,int segmento,ArrayList<HistoricoCapacidad> periodos) throws IOException {
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition","attachment; filename=historico-segmento-"+segmento+".csv");
        java.io.PrintWriter salida=response.getWriter();salida.write('\uFEFF');
        salida.println("Periodo;Capacidad instalada (Gbps);Trafico promedio (Gbps);Pico maximo (Gbps);Utilizacion maxima (%);Variacion (puntos porcentuales)");
        for(int i=periodos.size()-1;i>=0;i--){HistoricoCapacidad p=periodos.get(i);
            salida.println(p.getNombrePeriodo()+";"+csvNumero(p.getCapacidadInstalada())+";"+csvNumero(p.getPromedio())+";"+csvNumero(p.getPico())+";"+csvNumero(p.getUtilizacionMaxima())+";"+csvNumero(p.getTendencia()));
        }
    }
    private String csvNumero(BigDecimal valor){return valor==null?"":valor.setScale(2,java.math.RoundingMode.HALF_UP).toPlainString();}

}
