package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Incidencia;
import java.sql.*;
import java.util.*;

public class IncidenciaDAO {
    private static final String URL = System.getenv().getOrDefault("OCEANLINK_DB_URL",
        "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8");
    private static final String USER = System.getenv().getOrDefault("OCEANLINK_DB_USER", "root");
    private static final String PASS = System.getenv().getOrDefault("OCEANLINK_DB_PASSWORD", "root");

    private Connection conectar() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    private static final String SELECT =
        "SELECT i.*, CONCAT(u.nombre,' ',u.apellido) AS usuarioNombre, " +
        "(SELECT GROUP_CONCAT(s.codigo ORDER BY s.codigo SEPARATOR ', ') " +
        " FROM incidencia_segmento ix JOIN segmento s ON s.idSegmento=ix.idSegmento " +
        " WHERE ix.idIncidencia=i.idIncidencia) AS segmentos " +
        "FROM incidencia i JOIN usuario u ON u.idUsuario=i.idUsuario ";

    private Incidencia mapear(ResultSet rs) throws SQLException {
        Incidencia i = new Incidencia();
        i.setIdIncidencia(rs.getInt("idIncidencia"));
        i.setCodigo(rs.getString("codigo"));
        i.setTitulo(rs.getString("titulo"));
        i.setDescripcion(rs.getString("descripcion"));
        i.setSeveridad(rs.getString("severidad"));
        i.setEstado(rs.getString("estado"));
        Timestamp deteccion = rs.getTimestamp("fechaDeteccion");
        Timestamp cierre = rs.getTimestamp("fechaCierre");
        i.setFechaDeteccion(deteccion == null ? null : deteccion.toLocalDateTime());
        i.setFechaCierre(cierre == null ? null : cierre.toLocalDateTime());
        i.setIdUsuario(rs.getInt("idUsuario"));
        i.setUsuarioNombre(rs.getString("usuarioNombre"));
        i.setSegmentos(rs.getString("segmentos"));
        return i;
    }

    public List<Incidencia> listar(String buscar, String estado) throws SQLException {
        List<Incidencia> lista = new ArrayList<>();
        String sql = SELECT +
            "WHERE (?='' OR i.codigo LIKE ? OR i.titulo LIKE ? OR i.descripcion LIKE ?) " +
            "AND (?='' OR i.estado=?) ORDER BY i.fechaDeteccion DESC";
        try (Connection c=conectar(); PreparedStatement ps=c.prepareStatement(sql)) {
            String texto = buscar == null ? "" : buscar.trim();
            String filtro = "%" + texto + "%";
            ps.setString(1,texto); ps.setString(2,filtro); ps.setString(3,filtro); ps.setString(4,filtro);
            ps.setString(5,estado == null ? "" : estado); ps.setString(6,estado == null ? "" : estado);
            try(ResultSet rs=ps.executeQuery()){ while(rs.next()) lista.add(mapear(rs)); }
        }
        return lista;
    }

    public Incidencia obtener(int id) throws SQLException {
        try(Connection c=conectar(); PreparedStatement ps=c.prepareStatement(SELECT+"WHERE i.idIncidencia=?")){
            ps.setInt(1,id);
            try(ResultSet rs=ps.executeQuery()){ return rs.next()?mapear(rs):null; }
        }
    }

    public List<Map<String,Object>> listarSegmentos() throws SQLException {
        List<Map<String,Object>> lista=new ArrayList<>();
        String sql="SELECT idSegmento,codigo FROM segmento ORDER BY codigo";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()){
                Map<String,Object> m=new HashMap<>();
                m.put("id",rs.getInt("idSegmento")); m.put("codigo",rs.getString("codigo")); lista.add(m);
            }
        }
        return lista;
    }

    public String proximoCodigo() {
        return "INC-"+java.time.Year.now().getValue()+"-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT);
    }

    public int crear(Incidencia i, List<Integer> segmentos) throws SQLException {
        String sql="INSERT INTO incidencia(codigo,titulo,descripcion,severidad,estado,fechaDeteccion,idUsuario) VALUES(?,?,?,?,?,NOW(),?)";
        try(Connection c=conectar()){
            c.setAutoCommit(false);
            try(PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
                ps.setString(1,i.getCodigo()); ps.setString(2,i.getTitulo()); ps.setString(3,i.getDescripcion());
                ps.setString(4,i.getSeveridad()); ps.setString(5,i.getEstado()); ps.setInt(6,i.getIdUsuario());
                ps.executeUpdate();
                int id;
                try(ResultSet keys=ps.getGeneratedKeys()){ if(!keys.next()) throw new SQLException("No se obtuvo el ID"); id=keys.getInt(1); }
                guardarSegmentos(c,id,segmentos);
                c.commit(); return id;
            } catch(SQLException e){ c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    public boolean actualizar(Incidencia i, List<Integer> segmentos) throws SQLException {
        String sql="UPDATE incidencia SET titulo=?,descripcion=?,severidad=?,estado=?,fechaCierre=? WHERE idIncidencia=?";
        try(Connection c=conectar()){
            c.setAutoCommit(false);
            try(PreparedStatement ps=c.prepareStatement(sql)){
                ps.setString(1,i.getTitulo()); ps.setString(2,i.getDescripcion()); ps.setString(3,i.getSeveridad());
                ps.setString(4,i.getEstado());
                if("Resuelta".equals(i.getEstado()) || "Cerrada".equals(i.getEstado())) ps.setTimestamp(5,Timestamp.valueOf(java.time.LocalDateTime.now()));
                else ps.setNull(5,Types.TIMESTAMP);
                ps.setInt(6,i.getIdIncidencia());
                if(ps.executeUpdate()!=1){ c.rollback(); return false; }
                try(PreparedStatement del=c.prepareStatement("DELETE FROM incidencia_segmento WHERE idIncidencia=?")){del.setInt(1,i.getIdIncidencia());del.executeUpdate();}
                guardarSegmentos(c,i.getIdIncidencia(),segmentos);
                c.commit(); return true;
            } catch(SQLException e){ c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    private void guardarSegmentos(Connection c,int id,List<Integer> segmentos) throws SQLException {
        if(segmentos==null) return;
        try(PreparedStatement ps=c.prepareStatement("INSERT INTO incidencia_segmento(idIncidencia,idSegmento) VALUES(?,?)")){
            for(Integer segmento:segmentos){ ps.setInt(1,id); ps.setInt(2,segmento); ps.addBatch(); }
            ps.executeBatch();
        }
    }

    public boolean eliminar(int id) throws SQLException {
        try(Connection c=conectar()){
            c.setAutoCommit(false);
            try(PreparedStatement obs=c.prepareStatement("DELETE FROM incidencia_observacion WHERE idIncidencia=?")){
                obs.setInt(1,id); obs.executeUpdate();
            }
            try(PreparedStatement seg=c.prepareStatement("DELETE FROM incidencia_segmento WHERE idIncidencia=?")){
                seg.setInt(1,id); seg.executeUpdate();
            }
            try(PreparedStatement ps=c.prepareStatement("DELETE FROM incidencia WHERE idIncidencia=?")){
                ps.setInt(1,id); boolean ok=ps.executeUpdate()==1; c.commit(); return ok;
            } catch(SQLException e){ c.rollback(); throw e; }
            finally { c.setAutoCommit(true); }
        }
    }

    public void agregarObservacion(int idIncidencia,int idUsuario,String tipo,String observacion) throws SQLException {
        String sql="INSERT INTO incidencia_observacion(idIncidencia,idUsuario,tipo,observacion) VALUES(?,?,?,?)";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setInt(1,idIncidencia);ps.setInt(2,idUsuario);ps.setString(3,tipo);ps.setString(4,observacion);ps.executeUpdate();
        }
    }

    public List<Map<String,Object>> listarObservaciones(int id) throws SQLException {
        List<Map<String,Object>> lista=new ArrayList<>();
        String sql="SELECT o.*,CONCAT(u.nombre,' ',u.apellido) AS usuarioNombre FROM incidencia_observacion o JOIN usuario u ON u.idUsuario=o.idUsuario WHERE o.idIncidencia=? ORDER BY o.fechaRegistro DESC";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){while(rs.next()){
                Map<String,Object> m=new HashMap<>();m.put("tipo",rs.getString("tipo"));m.put("observacion",rs.getString("observacion"));
                m.put("fechaRegistro",rs.getTimestamp("fechaRegistro"));m.put("usuarioNombre",rs.getString("usuarioNombre"));lista.add(m);
            }}
        }
        return lista;
    }
}
