package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Servicio;
import java.sql.*;
import java.math.BigDecimal;
import java.util.*;

public class ServicioDAO {
    private static final String URL = System.getenv().getOrDefault("OCEANLINK_DB_URL",
        "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8");
    private static final String USER = System.getenv().getOrDefault("OCEANLINK_DB_USER", "root");
    private static final String PASS = System.getenv().getOrDefault("OCEANLINK_DB_PASSWORD", "root");

    private Connection conectar() throws SQLException { return DriverManager.getConnection(URL, USER, PASS); }

    private Servicio mapear(ResultSet rs) throws SQLException {
        Servicio s = new Servicio();
        s.setIdServicio(rs.getInt("idServicio"));
        s.setCodigo(rs.getString("codigo"));
        s.setIdCliente(rs.getInt("idCliente"));
        s.setIdRuta(rs.getInt("idRuta"));
        s.setOrigen(rs.getString("origen"));
        s.setDestino(rs.getString("destino"));
        s.setCapacidadContratada(rs.getBigDecimal("capacidadContratada"));
        java.sql.Date fecha = rs.getDate("fechaActivacion");
        s.setFechaActivacion(fecha == null ? null : fecha.toLocalDate());
        s.setEstado(rs.getString("estado"));
        s.setClienteNombre(rs.getString("clienteNombre"));
        s.setRutaNombre(rs.getString("rutaNombre"));
        return s;
    }
    private static final String SELECT =
        "SELECT s.*, c.razonSocial AS clienteNombre, r.nombre AS rutaNombre " +
        "FROM servicio s JOIN cliente c ON c.idCliente=s.idCliente " +
        "JOIN ruta r ON r.idRuta=s.idRuta ";

    public List<Servicio> listar(Integer idCliente) throws SQLException {
        List<Servicio> result = new ArrayList<>();
        String sql = SELECT + (idCliente == null ? "" : "WHERE s.idCliente=? ") + "ORDER BY s.idServicio DESC";
        try (Connection c = conectar(); PreparedStatement ps = c.prepareStatement(sql)) {
            if (idCliente != null) ps.setInt(1, idCliente);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.add(mapear(rs));
            }
        }
        return result;
    }
    public Servicio obtener(int id) throws SQLException {
        try (Connection c = conectar(); PreparedStatement ps = c.prepareStatement(SELECT+"WHERE s.idServicio=?")) {
            ps.setInt(1,id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? mapear(rs) : null; }
        }
    }
    public List<Map<String,Object>> listarClientes() throws SQLException {
        return opciones("SELECT idCliente AS id, razonSocial AS nombre FROM cliente WHERE estado='Activo' ORDER BY razonSocial");
    }
    public List<Map<String,Object>> listarRutas() throws SQLException {
        return opciones("SELECT r.idRuta AS id, r.nombre AS nombre FROM ruta r WHERE r.estado='Operativa' ORDER BY r.nombre");
    }
    private List<Map<String,Object>> opciones(String sql) throws SQLException {
        List<Map<String,Object>> out=new ArrayList<>();
        try(Connection c=conectar(); PreparedStatement ps=c.prepareStatement(sql); ResultSet rs=ps.executeQuery()){
            while(rs.next()){
                Map<String,Object> m=new HashMap<>(); m.put("id",rs.getInt("id"));m.put("nombre",rs.getString("nombre"));out.add(m);
            }
        }
        return out;
    }
    public String nombreCliente(int id) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement("SELECT razonSocial FROM cliente WHERE idCliente=?")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):null;}
        }
    }
    public String nombreRuta(int id) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement("SELECT nombre FROM ruta WHERE idRuta=?")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getString(1):null;}
        }
    }
    public String[] extremosRuta(int id) throws SQLException {
        String sql="SELECT eo.ubicacion, ed.ubicacion FROM ruta r "+
            "JOIN landing_station eo ON eo.idLandingStation=r.idEstacionOrigen "+
            "JOIN landing_station ed ON ed.idLandingStation=r.idEstacionDestino "+
            "WHERE r.idRuta=? AND r.estado='Operativa'";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){
                return rs.next()?new String[]{rs.getString(1),rs.getString(2)}:null;
            }
        }
    }
    public boolean clienteActivo(int id) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement("SELECT 1 FROM cliente WHERE idCliente=? AND estado='Activo'")){
            ps.setInt(1,id);try(ResultSet rs=ps.executeQuery()){return rs.next();}
        }
    }
    // La capacidad es dato obligatorio en la tabla: se recibe del formulario, nunca se inventa.
    public int crear(Servicio s) throws SQLException {
        String sql="INSERT INTO servicio(codigo,idCliente,idRuta,origen,destino,capacidadContratada,fechaActivacion,estado) VALUES(?,?,?,?,?,?,?,?)";
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1,s.getCodigo());ps.setInt(2,s.getIdCliente());ps.setInt(3,s.getIdRuta());
            ps.setString(4,s.getOrigen());ps.setString(5,s.getDestino());
            ps.setBigDecimal(6,s.getCapacidadContratada());ps.setDate(7,java.sql.Date.valueOf(s.getFechaActivacion()));
            ps.setString(8,s.getEstado());
            if(ps.executeUpdate()!=1)throw new SQLException("No se insertó el servicio");
            try(ResultSet keys=ps.getGeneratedKeys()){if(keys.next())return keys.getInt(1);}
            throw new SQLException("No se obtuvo el ID del servicio");
        }
    }
    public String proximoCodigo() throws SQLException {
        // El índice UNIQUE en codigo protege ante duplicados concurrentes; reintentar si ocurre.
        return "SRV-"+java.time.Year.now().getValue()+"-"+UUID.randomUUID().toString().substring(0,8).toUpperCase(Locale.ROOT);
    }
    public boolean cambiarEstado(int id, String estado) throws SQLException {
        try(Connection c=conectar();PreparedStatement ps=c.prepareStatement("UPDATE servicio SET estado=? WHERE idServicio=?")){
            ps.setString(1,estado);ps.setInt(2,id);return ps.executeUpdate()==1;
        }
    }
}
