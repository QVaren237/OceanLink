package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Solicitud;
import java.sql.*;
import java.util.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public class SolicitudDAO {
    private static final String URL = System.getenv().getOrDefault("OCEANLINK_DB_URL",
        "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8");
    private static final String USER = System.getenv().getOrDefault("OCEANLINK_DB_USER", "root");
    private static final String PASS = System.getenv().getOrDefault("OCEANLINK_DB_PASSWORD", "root");
    private Connection conectar() throws SQLException { return DriverManager.getConnection(URL,USER,PASS); }

    private static final String SELECT="SELECT s.*,c.razonSocial AS clienteNombre,r.nombre AS rutaNombre FROM solicitud s JOIN cliente c ON c.idCliente=s.idCliente JOIN ruta r ON r.idRuta=s.idRuta ";

    private Solicitud mapear(ResultSet rs) throws SQLException {
        Solicitud s=new Solicitud(); s.setIdSolicitud(rs.getInt("idSolicitud"));s.setCodigo(rs.getString("codigo"));
        s.setIdCliente(rs.getInt("idCliente"));s.setClienteNombre(rs.getString("clienteNombre"));
        s.setIdRuta(rs.getInt("idRuta"));s.setRutaNombre(rs.getString("rutaNombre"));
        s.setCapacidadSolicitada(rs.getBigDecimal("capacidadSolicitada"));
        Date fs=rs.getDate("fechaSolicitud"),fl=rs.getDate("fechaLimite");
        s.setFechaSolicitud(fs==null?null:fs.toLocalDate());s.setFechaLimite(fl==null?null:fl.toLocalDate());
        s.setMotivo(rs.getString("motivo"));s.setEstado(rs.getString("estado"));s.setObservacion(rs.getString("observacion"));s.setIdUsuario(rs.getInt("idUsuario"));return s;
    }
    public List<Solicitud> listar(String buscar,String estado) throws SQLException {
        List<Solicitud> lista=new ArrayList<>();String texto=buscar==null?"":buscar.trim();String filtro="%"+texto+"%";
        String sql=SELECT+"WHERE (?='' OR s.codigo LIKE ? OR c.razonSocial LIKE ? OR r.nombre LIKE ?) AND (?='' OR s.estado=?) ORDER BY s.idSolicitud DESC";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,texto);ps.setString(2,filtro);ps.setString(3,filtro);ps.setString(4,filtro);ps.setString(5,estado==null?"":estado);ps.setString(6,estado==null?"":estado);
            try(ResultSet rs=ps.executeQuery()){while(rs.next())lista.add(mapear(rs));}
        }return lista;
    }
    public Solicitud obtener(int id) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(SELECT+"WHERE s.idSolicitud=?")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next()?mapear(rs):null;}
        }
    }
    public List<Map<String,Object>> listarClientes() throws SQLException {
        return opciones("SELECT idCliente AS id,razonSocial AS nombre FROM cliente ORDER BY razonSocial");
    }
    public List<Map<String,Object>> listarRutas() throws SQLException {
        return opciones("SELECT idRuta AS id,nombre FROM ruta ORDER BY nombre");
    }
    private List<Map<String,Object>> opciones(String sql) throws SQLException {
        List<Map<String,Object>> lista=new ArrayList<>();
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql);ResultSet rs=ps.executeQuery()){
            while(rs.next()){Map<String,Object> m=new HashMap<>();m.put("id",rs.getInt("id"));m.put("nombre",rs.getString("nombre"));lista.add(m);}
        }return lista;
    }
    public String proximoCodigo(){return "SOL-"+java.time.Year.now().getValue()+"-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT);}
    public int crear(Solicitud s) throws SQLException {
        String sql="INSERT INTO solicitud(codigo,idCliente,idRuta,capacidadSolicitada,fechaSolicitud,fechaLimite,motivo,estado,observacion,idUsuario) VALUES(?,?,?,?,?,?,?,?,?,?)";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1,s.getCodigo());ps.setInt(2,s.getIdCliente());ps.setInt(3,s.getIdRuta());ps.setBigDecimal(4,s.getCapacidadSolicitada());
            ps.setDate(5,Date.valueOf(s.getFechaSolicitud()));
            if(s.getFechaLimite()==null)ps.setNull(6,Types.DATE);else ps.setDate(6,Date.valueOf(s.getFechaLimite()));
            ps.setString(7,s.getMotivo());ps.setString(8,s.getEstado());ps.setString(9,s.getObservacion());ps.setInt(10,s.getIdUsuario());ps.executeUpdate();
            try(ResultSet keys=ps.getGeneratedKeys()){if(keys.next())return keys.getInt(1);}
        }throw new SQLException("No se pudo guardar la solicitud");
    }
    public boolean actualizar(Solicitud s) throws SQLException {
        String sql="UPDATE solicitud SET idCliente=?,idRuta=?,capacidadSolicitada=?,fechaLimite=?,motivo=?,estado=?,observacion=? WHERE idSolicitud=?";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setInt(1,s.getIdCliente());ps.setInt(2,s.getIdRuta());ps.setBigDecimal(3,s.getCapacidadSolicitada());
            if(s.getFechaLimite()==null)ps.setNull(4,Types.DATE);else ps.setDate(4,Date.valueOf(s.getFechaLimite()));
            ps.setString(5,s.getMotivo());ps.setString(6,s.getEstado());ps.setString(7,s.getObservacion());ps.setInt(8,s.getIdSolicitud());return ps.executeUpdate()==1;
        }
    }
    public boolean eliminar(int id) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement("DELETE FROM solicitud WHERE idSolicitud=?")){
            ps.setInt(1,id);return ps.executeUpdate()==1;
        }
    }
}
