package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Mantenimiento;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

/** JDBC y PreparedStatement, siguiendo el patrón DAO de las clases 7.2 y 7.3. */
public class MantenimientoDAO extends BaseDAO {
    private static final String CONSULTA="SELECT m.*,COALESCE(NULLIF(m.titulo,''),NULLIF(LEFT(m.actividades,150),''),m.codigo) AS tituloVista,"
        +"COALESCE(s.codigo,ls.codigo) AS infraestructuraCodigo,CASE WHEN m.idSegmento IS NOT NULL THEN CONCAT(lo.nombre,' ↔ ',ld.nombre) ELSE CONCAT('Landing Station ',ls.nombre) END AS infraestructuraNombre,"
        +"i.codigo AS incidenciaCodigo,CONCAT(u.nombre,' ',u.apellido) AS responsable FROM mantenimiento m "
        +"LEFT JOIN segmento s ON s.idSegmento=m.idSegmento LEFT JOIN landing_station lo ON lo.idLandingStation=s.idEstacionOrigen "
        +"LEFT JOIN landing_station ld ON ld.idLandingStation=s.idEstacionDestino LEFT JOIN landing_station ls ON ls.idLandingStation=m.idLandingStation "
        +"LEFT JOIN incidencia i ON i.idIncidencia=m.idIncidencia JOIN usuario u ON u.idUsuario=m.idUsuario ";

    public ArrayList<Mantenimiento> listar(boolean historial)throws SQLException{
        ArrayList<Mantenimiento> lista=new ArrayList<>();
        String condicion=historial?"m.estado='Finalizado'":"COALESCE(m.estado,'')<>'Finalizado'";
        try(Connection c=abrirConexion();PreparedStatement p=c.prepareStatement(CONSULTA+"WHERE "+condicion+" ORDER BY "+(historial?"COALESCE(m.fechaFin,m.fechaInicio) DESC":"m.fechaInicio")+",m.idMantenimiento DESC");ResultSet r=p.executeQuery()){
            while(r.next())lista.add(mapear(r));
        }return lista;
    }
    public Mantenimiento obtener(int id)throws SQLException{
        try(Connection c=abrirConexion();PreparedStatement p=c.prepareStatement(CONSULTA+"WHERE m.idMantenimiento=?")){
            p.setInt(1,id);try(ResultSet r=p.executeQuery()){return r.next()?mapear(r):null;}
        }
    }
    private Mantenimiento mapear(ResultSet r)throws SQLException{
        Mantenimiento m=new Mantenimiento();m.setIdMantenimiento(r.getInt("idMantenimiento"));m.setCodigo(r.getString("codigo"));m.setTipo(r.getString("tipo"));m.setTitulo(r.getString("tituloVista"));
        m.setDescripcion(r.getString("descripcion"));m.setEstado(r.getString("estado"));m.setFechaInicio(r.getTimestamp("fechaInicio"));m.setFechaFin(r.getTimestamp("fechaFin"));m.setDuracionEstimada(r.getBigDecimal("duracionEstimada"));
        m.setResultado(r.getString("resultado"));m.setActividades(r.getString("actividades"));m.setIdUsuario(r.getInt("idUsuario"));m.setResponsable(r.getString("responsable"));
        m.setInfraestructuraCodigo(r.getString("infraestructuraCodigo"));m.setInfraestructuraNombre(r.getString("infraestructuraNombre"));m.setIncidenciaCodigo(r.getString("incidenciaCodigo"));
        int v=r.getInt("idIncidencia");m.setIdIncidencia(r.wasNull()?null:v);v=r.getInt("idSegmento");m.setIdSegmento(r.wasNull()?null:v);v=r.getInt("idLandingStation");m.setIdLandingStation(r.wasNull()?null:v);return m;
    }
    public ArrayList<String[]> listarResponsables()throws SQLException{
        return opciones("SELECT u.idUsuario,CONCAT(u.nombre,' ',u.apellido) FROM usuario u JOIN rol r ON r.idRol=u.idRol WHERE u.estado='Activo' AND r.nombre='Maintenance Coordinator' ORDER BY u.nombre");
    }
    public ArrayList<String[]> listarInfraestructura()throws SQLException{
        return opciones("SELECT CONCAT('SEG:',s.idSegmento),CONCAT(s.codigo,': Cable Submarino ',o.nombre,' ↔ ',d.nombre) FROM segmento s JOIN landing_station o ON o.idLandingStation=s.idEstacionOrigen JOIN landing_station d ON d.idLandingStation=s.idEstacionDestino UNION ALL SELECT CONCAT('LS:',idLandingStation),CONCAT(codigo,': Landing Station ',nombre) FROM landing_station ORDER BY 2");
    }
    public ArrayList<String[]> listarIncidencias()throws SQLException{
        return opciones("SELECT idIncidencia,CONCAT(codigo,' — ',titulo) FROM incidencia WHERE COALESCE(estado,'') NOT IN ('Cerrada','Servicio restaurado') ORDER BY fechaDeteccion DESC");
    }
    private ArrayList<String[]> opciones(String sql)throws SQLException{
        ArrayList<String[]> lista=new ArrayList<>();try(Connection c=abrirConexion();PreparedStatement p=c.prepareStatement(sql);ResultSet r=p.executeQuery()){while(r.next())lista.add(new String[]{r.getString(1),r.getString(2)});}return lista;
    }
    public ArrayList<String[]> bitacora(int id)throws SQLException{
        ArrayList<String[]> lista=new ArrayList<>();String sql="SELECT e.fechaRegistro,e.tipo,e.detalle,CONCAT(u.nombre,' ',u.apellido),e.estadoAnterior,e.estadoNuevo FROM mantenimiento_evento e JOIN usuario u ON u.idUsuario=e.idUsuario WHERE e.idMantenimiento=? ORDER BY e.fechaRegistro DESC,e.idEvento DESC";
        try(Connection c=abrirConexion();PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,id);try(ResultSet r=p.executeQuery()){while(r.next())lista.add(new String[]{r.getString(1),r.getString(2),r.getString(3),r.getString(4),r.getString(5),r.getString(6)});}}return lista;
    }
    public ArrayList<String[]> serviciosAfectados(int id)throws SQLException{
        ArrayList<String[]> lista=new ArrayList<>();String sql="SELECT DISTINCT sv.codigo,c.razonSocial,sv.capacidadContratada FROM servicio sv JOIN cliente c ON c.idCliente=sv.idCliente WHERE sv.estado<>'Cancelado' AND EXISTS(SELECT 1 FROM ruta_segmento rs JOIN mantenimiento_segmento ms ON ms.idSegmento=rs.idSegmento WHERE ms.idMantenimiento=? AND rs.idRuta=sv.idRuta) ORDER BY sv.codigo";
        try(Connection c=abrirConexion();PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,id);try(ResultSet r=p.executeQuery()){while(r.next())lista.add(new String[]{r.getString(1),r.getString(2),r.getString(3)});}}return lista;
    }
    public static ArrayList<String> estadosPermitidos(String anterior){
        ArrayList<String> estados=new ArrayList<>();
        if("Programado".equals(anterior)){estados.add("En ejecución");estados.add("Suspendido");}
        if("En ejecución".equals(anterior))estados.add("Suspendido");
        if("Suspendido".equals(anterior))estados.add("En ejecución");
        return estados;
    }
    public void validarResponsable(int id)throws SQLException{try(Connection c=abrirConexion()){validarResponsable(c,id);}}
    private void validarResponsable(Connection c,int id)throws SQLException{
        try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM usuario u JOIN rol r ON r.idRol=u.idRol WHERE u.idUsuario=? AND u.estado='Activo' AND r.nombre='Maintenance Coordinator'")){
            p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("Selecciona un Maintenance Coordinator activo como responsable.");}
        }
    }
    private String texto(String v,String campo,int max){v=v==null?"":v.trim();if(v.isEmpty()||v.length()>max)throw new IllegalArgumentException(campo+" es obligatorio y admite hasta "+max+" caracteres.");return v;}
    private void enteroOpcional(PreparedStatement p,int indice,Integer v)throws SQLException{if(v==null)p.setNull(indice,Types.INTEGER);else p.setInt(indice,v);}
    public int crear(Mantenimiento m,int usuario)throws SQLException{
        String titulo=texto(m.getTitulo(),"El título",150);String descripcion=m.getDescripcion()==null?"":m.getDescripcion().trim();
        if(descripcion.length()>2000)throw new IllegalArgumentException("La descripción admite hasta 2000 caracteres.");
        if(!Arrays.asList("Preventivo","Correctivo").contains(m.getTipo()))throw new IllegalArgumentException("Selecciona un tipo de mantenimiento válido.");
        if((m.getIdSegmento()==null)==(m.getIdLandingStation()==null))throw new IllegalArgumentException("Selecciona un segmento o una estación.");
        if("Correctivo".equals(m.getTipo())&&m.getIdIncidencia()==null)throw new IllegalArgumentException("El mantenimiento correctivo debe vincularse a una incidencia abierta.");
        if("Preventivo".equals(m.getTipo())&&m.getIdIncidencia()!=null)throw new IllegalArgumentException("Un mantenimiento preventivo no debe vincularse a una incidencia.");
        if(m.getFechaInicio()==null||m.getFechaInicio().toLocalDateTime().isBefore(java.time.LocalDateTime.now(java.time.ZoneId.of("America/Lima"))))throw new IllegalArgumentException("La fecha y hora de inicio no pueden estar en el pasado.");
        BigDecimal duracion=m.getDuracionEstimada();if(duracion==null||duracion.signum()<=0||duracion.scale()>2||duracion.compareTo(new BigDecimal("999.99"))>0)throw new IllegalArgumentException("La duración debe ser positiva, hasta 999.99 horas y dos decimales.");
        try(Connection c=abrirConexion()){
            c.setAutoCommit(false);try{
                validarResponsable(c,usuario);
                if(m.getIdIncidencia()!=null)bloquearIncidencia(c,m.getIdIncidencia(),true);
                ArrayList<Integer> segmentos=new ArrayList<>();
                if(m.getIdSegmento()!=null){
                    try(PreparedStatement p=c.prepareStatement("SELECT idSegmento FROM segmento WHERE idSegmento=? FOR UPDATE")){p.setInt(1,m.getIdSegmento());try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("El segmento no existe.");segmentos.add(r.getInt(1));}}
                }else{
                    try(PreparedStatement p=c.prepareStatement("SELECT idLandingStation FROM landing_station WHERE idLandingStation=? FOR UPDATE")){p.setInt(1,m.getIdLandingStation());try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("La estación no existe.");}}
                    try(PreparedStatement p=c.prepareStatement("SELECT idSegmento FROM segmento WHERE idEstacionOrigen=? OR idEstacionDestino=? ORDER BY idSegmento")){p.setInt(1,m.getIdLandingStation());p.setInt(2,m.getIdLandingStation());try(ResultSet r=p.executeQuery()){while(r.next())segmentos.add(r.getInt(1));}}
                }
                if(m.getIdIncidencia()!=null){
                    boolean coincide=false;try(PreparedStatement p=c.prepareStatement("SELECT idSegmento FROM incidencia_segmento WHERE idIncidencia=?")){p.setInt(1,m.getIdIncidencia());try(ResultSet r=p.executeQuery()){while(r.next())if(segmentos.contains(r.getInt(1)))coincide=true;}}
                    if(!coincide)throw new IllegalArgumentException("La infraestructura debe incluir un segmento afectado por la incidencia seleccionada.");
                }
                String codigo="MNT-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT);int id;
                try(PreparedStatement p=c.prepareStatement("INSERT INTO mantenimiento(codigo,tipo,titulo,descripcion,idIncidencia,idSegmento,idLandingStation,fechaInicio,duracionEstimada,estado,idUsuario) VALUES(?,?,?,?,?,?,?,?,?,'Programado',?)",Statement.RETURN_GENERATED_KEYS)){
                    p.setString(1,codigo);p.setString(2,m.getTipo());p.setString(3,titulo);p.setString(4,descripcion);enteroOpcional(p,5,m.getIdIncidencia());enteroOpcional(p,6,m.getIdSegmento());enteroOpcional(p,7,m.getIdLandingStation());p.setTimestamp(8,m.getFechaInicio());p.setBigDecimal(9,duracion);p.setInt(10,usuario);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){if(!r.next())throw new SQLException("No se obtuvo el mantenimiento creado.");id=r.getInt(1);}
                }
                try(PreparedStatement p=c.prepareStatement("INSERT INTO mantenimiento_segmento(idMantenimiento,idSegmento) VALUES(?,?)")){for(int segmento:segmentos){p.setInt(1,id);p.setInt(2,segmento);p.executeUpdate();}}
                evento(c,id,usuario,"REGISTRO",null,"Programado","Mantenimiento programado: "+titulo);
                eventoIncidencia(c,m.getIdIncidencia(),"MANTENIMIENTO_PROGRAMADO",codigo+": "+titulo);
                c.commit();return id;
            }catch(SQLException|RuntimeException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}
        }
    }
    private void bloquearIncidencia(Connection c,int id,boolean abierta)throws SQLException{
        try(PreparedStatement p=c.prepareStatement("SELECT estado FROM incidencia WHERE idIncidencia=? FOR UPDATE")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next()||(abierta&&Arrays.asList("Cerrada","Servicio restaurado").contains(r.getString(1))))throw new IllegalArgumentException("La incidencia no existe o ya fue restaurada/cerrada.");}}
    }
    private Mantenimiento bloquear(Connection c,int id)throws SQLException{
        Integer incidencia=null;try(PreparedStatement p=c.prepareStatement("SELECT idIncidencia FROM mantenimiento WHERE idMantenimiento=?")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("El mantenimiento no existe.");int valor=r.getInt(1);if(!r.wasNull())incidencia=valor;}}
        if(incidencia!=null)bloquearIncidencia(c,incidencia,false);
        try(PreparedStatement p=c.prepareStatement("SELECT estado,codigo,idIncidencia FROM mantenimiento WHERE idMantenimiento=? FOR UPDATE")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){
            if(!r.next())throw new IllegalArgumentException("El mantenimiento no existe.");Mantenimiento m=new Mantenimiento();m.setIdMantenimiento(id);m.setEstado(r.getString(1));m.setCodigo(r.getString(2));m.setIdIncidencia(incidencia);return m;
        }}
    }
    public void agregarActividad(int id,String detalle,int usuario)throws SQLException{
        detalle=texto(detalle,"La actividad",2000);
        try(Connection c=abrirConexion()){c.setAutoCommit(false);try{
            Mantenimiento m=bloquear(c,id);validarResponsable(c,usuario);if(m.isFinalizado())throw new IllegalArgumentException("El mantenimiento está finalizado; su bitácora es de solo lectura.");
            evento(c,id,usuario,"ACTIVIDAD",null,null,detalle);c.commit();
        }catch(SQLException|RuntimeException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}}
    }
    public void cambiarEstado(int id,String anterior,String nuevo,String motivo,int usuario)throws SQLException{
        motivo=texto(motivo,"La justificación",2000);
        try(Connection c=abrirConexion()){c.setAutoCommit(false);try{
            Mantenimiento m=bloquear(c,id);validarResponsable(c,usuario);
            if(!Objects.equals(anterior,m.getEstado()))throw new IllegalArgumentException("El estado cambió mientras confirmabas. Revisa el detalle nuevamente.");
            if(!estadosPermitidos(anterior).contains(nuevo))throw new IllegalArgumentException("La transición de estado no está permitida.");
            try(PreparedStatement p=c.prepareStatement("UPDATE mantenimiento SET estado=? WHERE idMantenimiento=?")){p.setString(1,nuevo);p.setInt(2,id);p.executeUpdate();}
            evento(c,id,usuario,"ESTADO",anterior,nuevo,motivo);eventoIncidencia(c,m.getIdIncidencia(),"MANTENIMIENTO_ESTADO",m.getCodigo()+": "+anterior+" → "+nuevo+". "+motivo);c.commit();
        }catch(SQLException|RuntimeException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}}
    }
    public void finalizar(int id,String resultado,int usuario)throws SQLException{
        resultado=texto(resultado,"El resultado",2000);
        try(Connection c=abrirConexion()){c.setAutoCommit(false);try{
            Mantenimiento m=bloquear(c,id);validarResponsable(c,usuario);
            if(!"En ejecución".equals(m.getEstado()))throw new IllegalArgumentException("Solo puedes finalizar un mantenimiento en ejecución.");
            try(PreparedStatement p=c.prepareStatement("UPDATE mantenimiento SET estado='Finalizado',resultado=?,fechaFin=NOW() WHERE idMantenimiento=?")){p.setString(1,resultado);p.setInt(2,id);p.executeUpdate();}
            evento(c,id,usuario,"FINALIZACION",m.getEstado(),"Finalizado",resultado);eventoIncidencia(c,m.getIdIncidencia(),"MANTENIMIENTO_FINALIZADO",m.getCodigo()+": "+resultado+". Pendiente de verificación de restauración por Network Operator.");c.commit();
        }catch(SQLException|RuntimeException e){c.rollback();throw e;}finally{c.setAutoCommit(true);}}
    }
    private void evento(Connection c,int id,int usuario,String tipo,String anterior,String nuevo,String detalle)throws SQLException{
        try(PreparedStatement p=c.prepareStatement("INSERT INTO mantenimiento_evento(idMantenimiento,idUsuario,tipo,estadoAnterior,estadoNuevo,detalle) VALUES(?,?,?,?,?,?)")){p.setInt(1,id);p.setInt(2,usuario);p.setString(3,tipo);p.setString(4,anterior);p.setString(5,nuevo);p.setString(6,detalle);p.executeUpdate();}
    }
    private void eventoIncidencia(Connection c,Integer id,String tipo,String detalle)throws SQLException{
        if(id==null)return;try(PreparedStatement p=c.prepareStatement("INSERT INTO incidencia_evento(idIncidencia,tipo,detalle) VALUES(?,?,?)")){p.setInt(1,id);p.setString(2,tipo);p.setString(3,detalle);p.executeUpdate();}
    }
    public boolean puedeRestaurar(int id)throws SQLException{try(Connection c=abrirConexion()){return puedeRestaurar(c,id);}}
    public static boolean puedeRestaurar(Connection c,int id)throws SQLException{
        String sql="SELECT 1 FROM mantenimiento m WHERE m.idIncidencia=? AND m.tipo='Correctivo' AND m.estado='Finalizado' AND NULLIF(TRIM(m.resultado),'') IS NOT NULL "
            +"AND NOT EXISTS(SELECT 1 FROM mantenimiento activo WHERE activo.idIncidencia=m.idIncidencia AND COALESCE(activo.estado,'')<>'Finalizado') "
            +"AND NOT EXISTS(SELECT 1 FROM incidencia_segmento isg WHERE isg.idIncidencia=m.idIncidencia AND NOT EXISTS(SELECT 1 FROM mantenimiento terminado JOIN mantenimiento_segmento ms ON ms.idMantenimiento=terminado.idMantenimiento WHERE terminado.idIncidencia=m.idIncidencia AND terminado.estado='Finalizado' AND NULLIF(TRIM(terminado.resultado),'') IS NOT NULL AND ms.idSegmento=isg.idSegmento)) LIMIT 1";
        try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,id);try(ResultSet r=p.executeQuery()){return r.next();}}
    }
}
