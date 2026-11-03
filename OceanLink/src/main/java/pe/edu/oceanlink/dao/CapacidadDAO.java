package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.HistoricoCapacidad;

import pe.edu.oceanlink.bean.CapacidadEnlace;
import pe.edu.oceanlink.bean.CapacidadServicio;
import pe.edu.oceanlink.bean.SolicitudCapacidad;
import pe.edu.oceanlink.bean.EvaluacionCapacidad;
import java.math.BigDecimal;
import java.util.*;
import java.sql.*;
import java.util.ArrayList;

/** JDBC de consulta para las vistas de Capacidad de Capacity Planner. */
public class CapacidadDAO {
    // Conexión JDBC directa, con el mismo patrón de UsuarioDAO.
    protected Connection abrirConexion() throws SQLException {
        String user = "root";
        String pass = "070501";
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el controlador JDBC de MySQL.", e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    private static final String ENLACES = "SELECT s.*, lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino, "
            + "lo.ubicacion AS ubicacionOrigen, ld.ubicacion AS ubicacionDestino FROM segmento s "
            + "JOIN landing_station lo ON lo.idLandingStation=s.idEstacionOrigen "
            + "JOIN landing_station ld ON ld.idLandingStation=s.idEstacionDestino ";

    public ArrayList<CapacidadEnlace> listar() throws SQLException {
        ArrayList<CapacidadEnlace> lista = new ArrayList<>();
        try (Connection conn = abrirConexion(); PreparedStatement ps = conn.prepareStatement(ENLACES+"ORDER BY s.codigo");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public ArrayList<HistoricoCapacidad> consultarHistorico(int idSegmento,java.sql.Date desde,java.sql.Date hasta) throws SQLException {
        ArrayList<HistoricoCapacidad> periodos=new ArrayList<>();
        String sql="SELECT fechaRegistro,capacidadTotal,capacidadUtilizada,capacidadReservada FROM historial_capacidad "
                +"WHERE idSegmento=? AND fechaRegistro>=? AND fechaRegistro<? ORDER BY fechaRegistro,idHistorial";
        try(Connection conn=abrirConexion();PreparedStatement ps=conn.prepareStatement(sql)){
            ps.setInt(1,idSegmento);ps.setDate(2,desde);ps.setDate(3,hasta);
            try(ResultSet rs=ps.executeQuery()){
                while(rs.next()){
                    String mes=rs.getTimestamp("fechaRegistro").toLocalDateTime().toLocalDate().toString().substring(0,7);
                    HistoricoCapacidad periodo;
                    if(periodos.isEmpty()||!mes.equals(periodos.get(periodos.size()-1).getPeriodo())){
                        periodo=new HistoricoCapacidad();periodo.setPeriodo(mes);periodos.add(periodo);
                    }else periodo=periodos.get(periodos.size()-1);
                    periodo.agregarMuestra(rs.getBigDecimal("capacidadTotal"),rs.getBigDecimal("capacidadUtilizada"),rs.getBigDecimal("capacidadReservada"));
                }
            }
        }
        for(int i=1;i<periodos.size();i++){
            BigDecimal actual=periodos.get(i).getUtilizacionMaxima(),anterior=periodos.get(i-1).getUtilizacionMaxima();
            if(actual!=null&&anterior!=null)periodos.get(i).setTendencia(actual.subtract(anterior));
        }
        return periodos;
    }

    public ArrayList<CapacidadEnlace> listarAlertas() throws SQLException {
        ArrayList<CapacidadEnlace> alertas=new ArrayList<>();
        for(CapacidadEnlace enlace:listar())if(enlace.isAlertaSaturacion())alertas.add(enlace);
        alertas.sort((a,b)->b.getPorcentajeUtilizacion().compareTo(a.getPorcentajeUtilizacion()));
        return alertas;
    }

    public String planificarAmpliacion(int idSegmento,BigDecimal capacidadNueva,java.sql.Date fechaLimite,
                                      String justificacion,Integer idUsuario) throws SQLException {
        validarCantidad(capacidadNueva==null?null:capacidadNueva.toPlainString());
        if(fechaLimite==null || fechaLimite.toLocalDate().isBefore(java.time.LocalDate.now()))
            throw new IllegalArgumentException("Selecciona una fecha límite de hoy o posterior.");
        justificacion=justificacion==null?"":justificacion.trim();
        if(justificacion.isEmpty()||justificacion.length()>2000)
            throw new IllegalArgumentException("La justificación técnica es obligatoria y admite hasta 2000 caracteres.");
        try(Connection conn=abrirConexion()){
            conn.setAutoCommit(false);
            try{
                CapacidadEnlace enlace=bloquearSegmento(conn,idSegmento);
                if(!enlace.isAlertaSaturacion())throw new IllegalArgumentException("El segmento ya no presenta una alerta de saturación. Actualiza el monitoreo.");
                if(capacidadNueva.compareTo(enlace.getCapacidadTotal())<=0)
                    throw new IllegalArgumentException("La nueva capacidad debe ser mayor a la capacidad total actual ("+enlace.getCapacidadTotal().stripTrailingZeros().toPlainString()+" Gbps).");
                if(idUsuario!=null)validarPlanner(conn,idUsuario);
                String codigo="AMP-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(java.util.Locale.ROOT);
                String sql="INSERT INTO ampliacion_capacidad(codigo,idSegmento,capacidadActual,capacidadNueva,fechaLimite,justificacion,estado,idUsuario) VALUES(?,?,?,?,?,?,'Registrada',?)";
                try(PreparedStatement ps=conn.prepareStatement(sql)){
                    ps.setString(1,codigo);ps.setInt(2,idSegmento);ps.setBigDecimal(3,enlace.getCapacidadTotal());
                    ps.setBigDecimal(4,capacidadNueva);ps.setDate(5,fechaLimite);ps.setString(6,justificacion);
                    if(idUsuario==null)ps.setNull(7,Types.INTEGER);else ps.setInt(7,idUsuario);
                    ps.executeUpdate();
                }
                conn.commit();return codigo;
            }catch(SQLException|RuntimeException e){conn.rollback();throw e;}
            finally{conn.setAutoCommit(true);}
        }
    }

    public CapacidadEnlace obtener(int id) throws SQLException {
        try (Connection conn = abrirConexion(); PreparedStatement ps = conn.prepareStatement(ENLACES+"WHERE s.idSegmento=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapear(rs) : null; }
        }
    }

    public ArrayList<CapacidadServicio> listarServicios(int idSegmento) throws SQLException {
        // EXISTS evita duplicar el servicio si hay más de una asociación con el mismo segmento.
        String sql = "SELECT sv.idServicio, sv.idCliente, sv.codigo, sv.capacidadContratada, sv.estado, "
                + "c.razonSocial, c.ruc, r.nombre AS ruta FROM servicio sv "
                + "JOIN cliente c ON c.idCliente=sv.idCliente JOIN ruta r ON r.idRuta=sv.idRuta "
                + "WHERE EXISTS (SELECT 1 FROM ruta_segmento rs WHERE rs.idRuta=sv.idRuta AND rs.idSegmento=?) "
                + "ORDER BY sv.codigo";
        ArrayList<CapacidadServicio> lista = new ArrayList<>();
        try (Connection conn = abrirConexion(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idSegmento);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CapacidadServicio servicio = new CapacidadServicio();
                    servicio.setIdServicio(rs.getInt("idServicio"));servicio.setIdCliente(rs.getInt("idCliente"));
                    servicio.setCodigo(rs.getString("codigo"));servicio.setCliente(rs.getString("razonSocial"));
                    servicio.setRuc(rs.getString("ruc"));servicio.setRuta(rs.getString("ruta"));
                    servicio.setEstado(rs.getString("estado"));servicio.setCapacidadContratada(rs.getBigDecimal("capacidadContratada"));
                    lista.add(servicio);
                }
            }
        }
        return lista;
    }

    private CapacidadEnlace mapear(ResultSet rs) throws SQLException {
        CapacidadEnlace enlace = new CapacidadEnlace();
        enlace.setIdSegmento(rs.getInt("idSegmento"));enlace.setCodigo(rs.getString("codigo"));
        enlace.setNombreOrigen(rs.getString("nombreOrigen"));enlace.setNombreDestino(rs.getString("nombreDestino"));
        enlace.setUbicacionOrigen(rs.getString("ubicacionOrigen"));enlace.setUbicacionDestino(rs.getString("ubicacionDestino"));
        enlace.setEstado(rs.getString("estado"));enlace.setDescripcion(rs.getString("descripcion"));
        enlace.setCapacidadTotal(rs.getBigDecimal("capacidadTotal"));enlace.setCapacidadUtilizada(rs.getBigDecimal("capacidadUtilizada"));
        enlace.setCapacidadReservada(rs.getBigDecimal("capacidadReservada"));enlace.setLongitudKm(rs.getBigDecimal("longitudKm"));
        return enlace;
    }

    public ArrayList<String[]> listarResponsables() throws SQLException {
        ArrayList<String[]> lista=new ArrayList<>();
        String sql="SELECT u.idUsuario,CONCAT(u.nombre,' ',u.apellido) AS nombre FROM usuario u "
                +"JOIN rol r ON r.idRol=u.idRol WHERE u.estado='Activo' AND r.nombre='Capacity Planner' ORDER BY nombre";
        try(Connection conn=abrirConexion();PreparedStatement ps=conn.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next())lista.add(new String[]{rs.getString(1),rs.getString(2)});
        }
        return lista;
    }

    public ArrayList<SolicitudCapacidad> listarSolicitudes() throws SQLException {
        ArrayList<SolicitudCapacidad> lista=new ArrayList<>();
        String sql="SELECT so.*,c.razonSocial AS cliente,r.nombre AS ruta FROM solicitud so "
                +"JOIN cliente c ON c.idCliente=so.idCliente JOIN ruta r ON r.idRuta=so.idRuta ORDER BY so.idSolicitud DESC";
        try(Connection conn=abrirConexion();PreparedStatement ps=conn.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next())lista.add(mapearSolicitud(rs));
        }
        return lista;
    }

    public EvaluacionCapacidad obtenerEvaluacion(int id) throws SQLException {
        String sql="SELECT so.*,c.razonSocial AS cliente,c.ruc,c.estado AS estadoCliente,r.nombre AS ruta,r.estado AS estadoRuta,"
                +"CONCAT(u.nombre,' ',u.apellido) AS evaluador FROM solicitud so JOIN cliente c ON c.idCliente=so.idCliente "
                +"JOIN ruta r ON r.idRuta=so.idRuta LEFT JOIN usuario u ON u.idUsuario=so.idEvaluador WHERE so.idSolicitud=?";
        try(Connection conn=abrirConexion();PreparedStatement ps=conn.prepareStatement(sql)){
            ps.setInt(1,id);
            try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())return null;
                EvaluacionCapacidad e=new EvaluacionCapacidad();e.setSolicitud(mapearSolicitud(rs));e.setRuc(rs.getString("ruc"));
                e.setEstadoCliente(rs.getString("estadoCliente"));e.setEstadoRuta(rs.getString("estadoRuta"));
                e.setComentarioEvaluacion(rs.getString("comentarioEvaluacion"));e.setEvaluador(rs.getString("evaluador"));
                e.setFechaEvaluacion(rs.getTimestamp("fechaEvaluacion"));
                e.setSegmentos(segmentosRuta(conn,e.getSolicitud().getIdRuta()));return e;
            }
        }
    }

    public ArrayList<CapacidadEnlace> segmentosRuta(int idRuta) throws SQLException {
        try(Connection conn=abrirConexion()){return segmentosRuta(conn,idRuta);}
    }

    private ArrayList<CapacidadEnlace> segmentosRuta(Connection conn,int idRuta) throws SQLException {
        String sql=ENLACES+"JOIN ruta_segmento rs ON rs.idSegmento=s.idSegmento WHERE rs.idRuta=? ORDER BY rs.orden";
        ArrayList<CapacidadEnlace> lista=new ArrayList<>();
        try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setInt(1,idRuta);
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}}
        return lista;
    }

    public ArrayList<CapacidadServicio> serviciosReservables(int idSegmento,Integer idSolicitud) throws SQLException {
        ArrayList<CapacidadServicio> servicios=listarServicios(idSegmento);
        // Los servicios cancelados o de clientes inactivos no pueden recibir nuevas reservas.
        try(Connection conn=abrirConexion()){
            for(Iterator<CapacidadServicio> it=servicios.iterator();it.hasNext();){
                CapacidadServicio sv=it.next();
                String sql="SELECT 1 FROM servicio sv JOIN cliente c ON c.idCliente=sv.idCliente WHERE sv.idServicio=? "
                        +"AND sv.estado<>'Cancelado' AND c.estado='Activo'"
                        +(idSolicitud==null?"":" AND EXISTS(SELECT 1 FROM solicitud so WHERE so.idSolicitud=? AND so.idCliente=sv.idCliente AND so.idRuta=sv.idRuta AND (so.idServicio IS NULL OR so.idServicio=sv.idServicio))");
                try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setInt(1,sv.getIdServicio());if(idSolicitud!=null)ps.setInt(2,idSolicitud);
                    try(ResultSet rs=ps.executeQuery()){if(!rs.next())it.remove();}}
            }
        }
        return servicios;
    }

    public int obtenerRutaServicio(int idServicio) throws SQLException {
        try(Connection conn=abrirConexion()){return rutaServicio(conn,idServicio);}
    }

    private int rutaServicio(Connection conn,int id) throws SQLException {
        try(PreparedStatement ps=conn.prepareStatement("SELECT idRuta FROM servicio WHERE idServicio=?")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("El servicio no existe.");return rs.getInt(1);}}
    }

    public static BigDecimal validarCantidad(String texto){
        try{
            BigDecimal cantidad=new BigDecimal(texto==null?"":texto.trim());
            if(cantidad.signum()>0 && cantidad.scale()<=2 && cantidad.compareTo(new BigDecimal("9999999999.99"))<=0)return cantidad;
        }catch(NumberFormatException e){ /* Se informa como error del formulario. */ }
        throw new IllegalArgumentException("Ingresa una capacidad positiva, de hasta dos decimales.");
    }

    /** Una única transacción para la reserva directa o vinculada y todos sus segmentos. */
    public void reservar(int idServicio,Collection<Integer> ids,BigDecimal cantidad,Integer idSolicitud,int idUsuario) throws SQLException {
        validarCantidad(cantidad==null?null:cantidad.toPlainString());
        TreeSet<Integer> seleccion=new TreeSet<>(ids);
        if(seleccion.isEmpty()||seleccion.size()!=ids.size()||seleccion.first()<=0)
            throw new IllegalArgumentException("Selecciona segmentos válidos sin repetirlos.");
        try(Connection conn=abrirConexion()){
            int idRuta=rutaServicio(conn,idServicio);
            conn.setAutoCommit(false);
            try{
                String estadoRuta=bloquearRuta(conn,idRuta);
                if(!"Operativa".equals(estadoRuta))throw new IllegalArgumentException("La ruta del servicio no está operativa.");
                validarPlanner(conn,idUsuario);
                Integer clienteSolicitud=null;
                if(idSolicitud!=null){
                    try(PreparedStatement ps=conn.prepareStatement("SELECT idCliente,idRuta,estado,capacidadSolicitada,idServicio FROM solicitud WHERE idSolicitud=? FOR UPDATE")){
                        ps.setInt(1,idSolicitud);try(ResultSet rs=ps.executeQuery()){
                            if(!rs.next()||!"Aprobada".equals(rs.getString("estado")))throw new IllegalArgumentException("La solicitud debe estar aprobada y sin reservar.");
                            if(rs.getInt("idRuta")!=idRuta||cantidad.compareTo(rs.getBigDecimal("capacidadSolicitada"))!=0)
                                throw new IllegalArgumentException("La ruta y la cantidad deben coincidir con la solicitud aprobada.");
                            clienteSolicitud=rs.getInt("idCliente");
                            int servicioSolicitud=rs.getInt("idServicio");
                            if(!rs.wasNull()&&servicioSolicitud!=idServicio)throw new IllegalArgumentException("La reserva debe utilizar el servicio asociado a la solicitud.");
                        }
                    }
                }
                try(PreparedStatement ps=conn.prepareStatement("SELECT sv.idRuta,sv.idCliente,sv.estado,c.estado AS estadoCliente FROM servicio sv JOIN cliente c ON c.idCliente=sv.idCliente WHERE sv.idServicio=? FOR UPDATE")){
                    ps.setInt(1,idServicio);try(ResultSet rs=ps.executeQuery()){
                        if(!rs.next()||rs.getInt("idRuta")!=idRuta||"Cancelado".equals(rs.getString("estado"))||!"Activo".equals(rs.getString("estadoCliente")))
                            throw new IllegalArgumentException("El servicio debe existir, no estar cancelado y pertenecer a un cliente activo.");
                        if(clienteSolicitud!=null&&clienteSolicitud!=rs.getInt("idCliente"))throw new IllegalArgumentException("El servicio no pertenece al cliente de la solicitud.");
                    }
                }
                TreeSet<Integer> ruta=idsRuta(conn,idRuta);
                if(!ruta.containsAll(seleccion))throw new IllegalArgumentException("Los segmentos seleccionados no pertenecen a la ruta del servicio.");
                if(idSolicitud!=null&&!seleccion.equals(ruta))throw new IllegalArgumentException("La reserva vinculada debe cubrir todos los segmentos de la solicitud.");
                for(int id:seleccion){
                    CapacidadEnlace enlace=bloquearSegmento(conn,id);
                    validarDisponible(enlace,cantidad);
                    try(PreparedStatement ps=conn.prepareStatement("UPDATE segmento SET capacidadReservada=capacidadReservada+? WHERE idSegmento=? AND capacidadTotal-capacidadUtilizada-capacidadReservada>=?")){
                        ps.setBigDecimal(1,cantidad);ps.setInt(2,id);ps.setBigDecimal(3,cantidad);
                        if(ps.executeUpdate()!=1)throw new IllegalArgumentException("La disponibilidad cambió. Actualiza el formulario.");
                    }
                    try(PreparedStatement ps=conn.prepareStatement("INSERT INTO reserva_capacidad(idSolicitud,idSegmento,idServicio,capacidadReservada,fechaReserva,estado,idUsuario) VALUES(?,?,?,?,CURDATE(),'Activa',?)")){
                        if(idSolicitud==null)ps.setNull(1,Types.INTEGER);else ps.setInt(1,idSolicitud);
                        ps.setInt(2,id);ps.setInt(3,idServicio);ps.setBigDecimal(4,cantidad);ps.setInt(5,idUsuario);ps.executeUpdate();
                    }
                    registrarHistorial(conn,id);
                }
                if(idSolicitud!=null){
                    try(PreparedStatement ps=conn.prepareStatement("UPDATE solicitud SET estado='Reservada' WHERE idSolicitud=?")){ps.setInt(1,idSolicitud);ps.executeUpdate();}
                }
                conn.commit();
            }catch(SQLException|RuntimeException e){conn.rollback();throw e;}
            finally{conn.setAutoCommit(true);}
        }
    }

    public void evaluarSolicitud(int id,String decision,String comentario,int idUsuario) throws SQLException {
        if(!"Aprobada".equals(decision)&&!"Rechazada".equals(decision))throw new IllegalArgumentException("Decisión no válida.");
        comentario=comentario==null?"":comentario.trim();
        if(comentario.length()>255||("Rechazada".equals(decision)&&comentario.isEmpty()))
            throw new IllegalArgumentException("Para rechazar debes indicar un motivo. El comentario admite hasta 255 caracteres.");
        try(Connection conn=abrirConexion()){
            int idRuta;
            try(PreparedStatement ps=conn.prepareStatement("SELECT idRuta FROM solicitud WHERE idSolicitud=?")){ps.setInt(1,id);
                try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La solicitud no existe.");idRuta=rs.getInt(1);}}
            conn.setAutoCommit(false);
            try{
                String estadoRuta=bloquearRuta(conn,idRuta);validarPlanner(conn,idUsuario);
                BigDecimal cantidad;
                try(PreparedStatement ps=conn.prepareStatement("SELECT so.estado,so.capacidadSolicitada,so.idRuta,c.estado AS estadoCliente FROM solicitud so JOIN cliente c ON c.idCliente=so.idCliente WHERE so.idSolicitud=? FOR UPDATE")){
                    ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){
                        if(!rs.next()||rs.getInt("idRuta")!=idRuta||!Arrays.asList("Registrada","En evaluación","Pendiente por capacidad").contains(rs.getString("estado")))
                            throw new IllegalArgumentException("La solicitud ya fue evaluada o cambió de estado. Actualiza la bandeja.");
                        cantidad=rs.getBigDecimal("capacidadSolicitada");
                        if("Aprobada".equals(decision)&&!"Activo".equals(rs.getString("estadoCliente")))throw new IllegalArgumentException("El cliente debe estar activo.");
                    }
                }
                if("Aprobada".equals(decision)){
                    validarCantidad(cantidad==null?null:cantidad.toPlainString());
                    if(!"Operativa".equals(estadoRuta))throw new IllegalArgumentException("La ruta no está operativa.");
                    TreeSet<Integer> ids=idsRuta(conn,idRuta);
                    if(ids.isEmpty())throw new IllegalArgumentException("La ruta no tiene segmentos.");
                    for(int segmento:ids)validarDisponible(bloquearSegmento(conn,segmento),cantidad);
                }
                try(PreparedStatement ps=conn.prepareStatement("UPDATE solicitud SET estado=?,comentarioEvaluacion=?,idEvaluador=?,fechaEvaluacion=NOW() WHERE idSolicitud=?")){
                    ps.setString(1,decision);ps.setString(2,comentario);ps.setInt(3,idUsuario);ps.setInt(4,id);ps.executeUpdate();
                }
                conn.commit();
            }catch(SQLException|RuntimeException e){conn.rollback();throw e;}
            finally{conn.setAutoCommit(true);}
        }
    }

    private void validarPlanner(Connection conn,int id) throws SQLException {
        try(PreparedStatement ps=conn.prepareStatement("SELECT 1 FROM usuario u JOIN rol r ON r.idRol=u.idRol WHERE u.idUsuario=? AND u.estado='Activo' AND r.nombre='Capacity Planner'")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("El responsable debe ser un Capacity Planner activo.");}}
    }
    private String bloquearRuta(Connection conn,int id) throws SQLException {
        try(PreparedStatement ps=conn.prepareStatement("SELECT estado FROM ruta WHERE idRuta=? FOR UPDATE")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){if(!rs.next())throw new IllegalArgumentException("La ruta no existe.");return rs.getString(1);}}
    }
    private TreeSet<Integer> idsRuta(Connection conn,int id) throws SQLException {
        TreeSet<Integer> ids=new TreeSet<>();try(PreparedStatement ps=conn.prepareStatement("SELECT idSegmento FROM ruta_segmento WHERE idRuta=? ORDER BY idSegmento")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){while(rs.next())ids.add(rs.getInt(1));}}return ids;
    }
    private CapacidadEnlace bloquearSegmento(Connection conn,int id) throws SQLException {
        try(PreparedStatement ps=conn.prepareStatement("SELECT codigo,estado,capacidadTotal,capacidadUtilizada,capacidadReservada FROM segmento WHERE idSegmento=? FOR UPDATE")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){
                if(!rs.next())throw new IllegalArgumentException("El segmento no existe.");
                CapacidadEnlace e=new CapacidadEnlace();e.setIdSegmento(id);e.setCodigo(rs.getString("codigo"));e.setEstado(rs.getString("estado"));
                e.setCapacidadTotal(rs.getBigDecimal("capacidadTotal"));e.setCapacidadUtilizada(rs.getBigDecimal("capacidadUtilizada"));e.setCapacidadReservada(rs.getBigDecimal("capacidadReservada"));return e;
            }}
    }
    private void validarDisponible(CapacidadEnlace e,BigDecimal cantidad){
        if(!"Operativo".equals(e.getEstado())&&!"Degradado".equals(e.getEstado()))throw new IllegalArgumentException("El segmento "+e.getCodigo()+" no está disponible para reservar.");
        if(e.getCapacidadDisponible()==null||e.getCapacidadDisponible().compareTo(cantidad)<0)
            throw new IllegalArgumentException("Capacidad insuficiente en "+e.getCodigo()+". Actualiza la cantidad o el segmento.");
    }
    private void registrarHistorial(Connection conn,int id) throws SQLException {
        String sql="INSERT INTO historial_capacidad(idSegmento,fechaRegistro,capacidadTotal,capacidadUtilizada,capacidadReservada,capacidadDisponible,porcentajeUtilizacion) "
                +"SELECT idSegmento,NOW(),capacidadTotal,capacidadUtilizada,capacidadReservada,capacidadTotal-capacidadUtilizada-capacidadReservada,"
                +"(capacidadUtilizada+capacidadReservada)*100/NULLIF(capacidadTotal,0) FROM segmento WHERE idSegmento=?";
        try(PreparedStatement ps=conn.prepareStatement(sql)){ps.setInt(1,id);ps.executeUpdate();}
    }
    private SolicitudCapacidad mapearSolicitud(ResultSet rs) throws SQLException {
        SolicitudCapacidad s=new SolicitudCapacidad();s.setIdSolicitud(rs.getInt("idSolicitud"));s.setCodigo(rs.getString("codigo"));
        int servicio=rs.getInt("idServicio");s.setIdServicio(rs.wasNull()?null:servicio);
        s.setIdCliente(rs.getInt("idCliente"));s.setCliente(rs.getString("cliente"));s.setIdRuta(rs.getInt("idRuta"));s.setRuta(rs.getString("ruta"));
        s.setCapacidadSolicitada(rs.getDouble("capacidadSolicitada"));s.setEstado(rs.getString("estado"));s.setMotivo(rs.getString("motivo"));
        s.setObservacion(rs.getString("observacion"));s.setFechaSolicitud(rs.getDate("fechaSolicitud"));s.setFechaLimite(rs.getDate("fechaLimite"));s.setIdUsuario(rs.getInt("idUsuario"));return s;
    }
}
