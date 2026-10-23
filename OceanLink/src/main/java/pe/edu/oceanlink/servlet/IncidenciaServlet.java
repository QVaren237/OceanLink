package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.bean.Incidencia;
import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.dao.IncidenciaDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet(name="IncidenciaServlet",urlPatterns="/IncidenciaServlet")
public class IncidenciaServlet extends HttpServlet {
    private final IncidenciaDAO dao=new IncidenciaDAO();

    private int usuarioActual(HttpServletRequest req) {
        HttpSession sesion=req.getSession(false);
        if(sesion==null) return 0;
        Object id=sesion.getAttribute("idUsuario");
        if(id instanceof Number) return ((Number)id).intValue();
        Object usuario=sesion.getAttribute("usuario");
        if(usuario instanceof Usuario) {
            try { return Integer.parseInt(((Usuario)usuario).getIdUsuario()); }
            catch(Exception ignored) { }
        }
        return 0;
    }

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        String action=req.getParameter("action")==null?"lista":req.getParameter("action");
        try {
            if("lista".equals(action)) {
                req.setAttribute("lista",dao.listar(req.getParameter("buscar"),req.getParameter("estado")));
                req.getRequestDispatcher("/views/network-incidencias.jsp").forward(req,resp);
            } else if("nuevo".equals(action)||"editar".equals(action)) {
                req.setAttribute("segmentos",dao.listarSegmentos());
                if("editar".equals(action)) {
                    Incidencia i=dao.obtener(entero(req.getParameter("id")));
                    if(i==null){resp.sendError(404,"Incidencia no encontrada");return;}
                    req.setAttribute("incidencia",i);
                }
                req.getRequestDispatcher("/views/network-incidencia-form.jsp").forward(req,resp);
            } else if("observaciones".equals(action)) {
                int id=entero(req.getParameter("id"));
                req.setAttribute("incidencia",dao.obtener(id));
                req.setAttribute("observaciones",dao.listarObservaciones(id));
                req.getRequestDispatcher("/views/network-incidencia-observaciones.jsp").forward(req,resp);
            } else resp.sendError(400,"Acción no válida");
        } catch(IllegalArgumentException e){resp.sendError(400,e.getMessage());}
          catch(SQLException e){throw new ServletException("Error consultando incidencias",e);}
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        String action=req.getParameter("action");
        try {
            if("crear".equals(action)||"actualizar".equals(action)) {
                Incidencia i=new Incidencia();
                i.setTitulo(obligatorio(req.getParameter("titulo"),150,"Título"));
                i.setDescripcion(req.getParameter("descripcion"));
                i.setSeveridad(opcion(req.getParameter("severidad"),new String[]{"Baja","Media","Alta","Crítica"},"Severidad"));
                i.setEstado(opcion(req.getParameter("estado"),new String[]{"Abierta","En atención","Resuelta","Cerrada"},"Estado"));
                List<Integer> segmentos=new ArrayList<>();
                String[] seleccionados=req.getParameterValues("segmentos");
                if(seleccionados!=null) for(String s:seleccionados) segmentos.add(entero(s));
                if("crear".equals(action)) {
                    int usuario=usuarioActual(req);
                    if(usuario<=0) { resp.sendError(400,"No se encontró idUsuario en la sesión. Inicia sesión antes de registrar una incidencia.");return; }
                    i.setCodigo(dao.proximoCodigo());i.setIdUsuario(usuario);
                    dao.crear(i,segmentos);
                } else {
                    i.setIdIncidencia(entero(req.getParameter("id")));
                    if(!dao.actualizar(i,segmentos)){resp.sendError(404,"Incidencia no encontrada");return;}
                }
                resp.sendRedirect(req.getContextPath()+"/IncidenciaServlet?action=lista");
            } else if("eliminar".equals(action)) {
                if(!dao.eliminar(entero(req.getParameter("id")))){resp.sendError(404,"Incidencia no encontrada");return;}
                resp.sendRedirect(req.getContextPath()+"/IncidenciaServlet?action=lista");
            } else if("observar".equals(action)) {
                int usuario=usuarioActual(req);
                if(usuario<=0){resp.sendError(400,"No se encontró idUsuario en la sesión.");return;}
                int id=entero(req.getParameter("id"));
                String texto=obligatorio(req.getParameter("observacion"),2000,"Observación");
                String tipo=opcion(req.getParameter("tipo"),new String[]{"Observación","Restauración"},"Tipo");
                dao.agregarObservacion(id,usuario,tipo,texto);
                if("Restauración".equals(tipo)) registrarRestauracion(req,id,usuario,texto);
                resp.sendRedirect(req.getContextPath()+"/IncidenciaServlet?action=observaciones&id="+id);
            } else resp.sendError(400,"Acción no válida");
        } catch(IllegalArgumentException e){resp.sendError(400,e.getMessage());}
          catch(SQLException e){throw new ServletException("Error guardando la incidencia",e);}
    }

    private void registrarRestauracion(HttpServletRequest req,int idIncidencia,int usuario,String texto)throws SQLException {
        String sql="INSERT INTO mantenimiento(codigo,tipo,idIncidencia,fechaInicio,duracionEstimada,estado,actividades,resultado,idUsuario) VALUES(?, 'Correctivo', ?, NOW(), 0, 'Finalizado', ?, ?, ?)";
        String url=System.getenv().getOrDefault("OCEANLINK_DB_URL","jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8");
        String user=System.getenv().getOrDefault("OCEANLINK_DB_USER","root");
        String pass=System.getenv().getOrDefault("OCEANLINK_DB_PASSWORD","root");
        try(java.sql.Connection c=java.sql.DriverManager.getConnection(url,user,pass);java.sql.PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,"MNT-"+java.util.UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT));
            ps.setInt(2,idIncidencia);ps.setString(3,"Restauración del servicio");ps.setString(4,texto);ps.setInt(5,usuario);ps.executeUpdate();
        }
    }
    private int entero(String v){try{int n=Integer.parseInt(v);if(n<=0)throw new Exception();return n;}catch(Exception e){throw new IllegalArgumentException("Identificador inválido");}}
    private String obligatorio(String v,int max,String campo){if(v==null||v.trim().isEmpty()||v.trim().length()>max)throw new IllegalArgumentException(campo+" es obligatorio y admite hasta "+max+" caracteres");return v.trim();}
    private String opcion(String v,String[] opciones,String campo){for(String op:opciones)if(op.equals(v))return v;throw new IllegalArgumentException(campo+" no válido");}
}
