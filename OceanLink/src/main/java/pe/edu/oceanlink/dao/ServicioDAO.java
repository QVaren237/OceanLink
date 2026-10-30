package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Servicio;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

/** DAO de servicios, con el estilo JDBC utilizado en LandingStationDAO. */
public class ServicioDAO {

    // READ: listar los servicios contratados por un cliente.
    public ArrayList<Servicio> obtenerServiciosPorCliente(int idCliente)
            throws SQLException, ClassNotFoundException {
        ArrayList<Servicio> lista = new ArrayList<>();
        String user = "root";
        String pass = "root"; // Cambiar por la contraseña local de MySQL
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            String sql = "SELECT s.*, c.razonSocial AS razonSocialCliente, r.nombre AS nombreRuta " +
                    "FROM servicio s INNER JOIN cliente c ON s.idCliente = c.idCliente " +
                    "INNER JOIN ruta r ON s.idRuta = r.idRuta " +
                    "WHERE s.idCliente = ? ORDER BY s.idServicio DESC";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idCliente);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Servicio servicio = new Servicio();
                        llenarServicio(servicio, rs);
                        lista.add(servicio);
                    }
                }
            }
        }
        return lista;
    }

    // READ: obtener un servicio por su ID.
    public Servicio obtenerServicio(int idServicio) throws SQLException, ClassNotFoundException {
        Servicio servicio = null;
        String user = "root";
        String pass = "root"; // Cambiar por la contraseña local de MySQL
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            String sql = "SELECT s.*, c.razonSocial AS razonSocialCliente, r.nombre AS nombreRuta " +
                    "FROM servicio s INNER JOIN cliente c ON s.idCliente = c.idCliente " +
                    "INNER JOIN ruta r ON s.idRuta = r.idRuta WHERE s.idServicio = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, idServicio);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        servicio = new Servicio();
                        llenarServicio(servicio, rs);
                    }
                }
            }
        }
        return servicio;
    }

    // CREATE: registrar servicio y devolver el ID autogenerado.
    public int crearServicio(Servicio servicio) throws SQLException, ClassNotFoundException {
        String user = "root";
        String pass = "root"; // Cambiar por la contraseña local de MySQL
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            String sql = "INSERT INTO servicio " +
                    "(codigo, idCliente, idRuta, origen, destino, capacidadContratada, fechaActivacion, estado) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, servicio.getCodigo());
                pstmt.setInt(2, servicio.getIdCliente());
                pstmt.setInt(3, servicio.getIdRuta());
                pstmt.setString(4, servicio.getOrigen());
                pstmt.setString(5, servicio.getDestino());
                if (servicio.getCapacidadContratada() == null) {
                    pstmt.setNull(6, java.sql.Types.DECIMAL);
                } else {
                    pstmt.setBigDecimal(6, servicio.getCapacidadContratada());
                }
                pstmt.setDate(7, java.sql.Date.valueOf(servicio.getFechaActivacion()));
                pstmt.setString(8, servicio.getEstado());
                if (pstmt.executeUpdate() != 1) throw new SQLException("No se registró el servicio");
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
                throw new SQLException("No se obtuvo el ID del servicio");
            }
        }
    }

    // UPDATE: cambiar el estado en vez de eliminar físicamente el servicio.
    public boolean cambiarEstado(int idServicio, String estado)
            throws SQLException, ClassNotFoundException {
        if (!("Activo".equals(estado) || "Suspendido".equals(estado) || "Cancelado".equals(estado))) {
            throw new IllegalArgumentException("Estado inválido");
        }
        String user = "root";
        String pass = "root"; // Cambiar por la contraseña local de MySQL
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            String sql = "UPDATE servicio SET estado = ? WHERE idServicio = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, estado);
                pstmt.setInt(2, idServicio);
                return pstmt.executeUpdate() == 1;
            }
        }
    }

    // Convierte la fila del ResultSet en un Bean Servicio.
    private void llenarServicio(Servicio servicio, ResultSet rs) throws SQLException {
        servicio.setIdServicio(rs.getInt("idServicio"));
        servicio.setCodigo(rs.getString("codigo"));
        servicio.setIdCliente(rs.getInt("idCliente"));
        servicio.setIdRuta(rs.getInt("idRuta"));
        servicio.setOrigen(rs.getString("origen"));
        servicio.setDestino(rs.getString("destino"));
        servicio.setCapacidadContratada(rs.getBigDecimal("capacidadContratada"));
        java.sql.Date fecha = rs.getDate("fechaActivacion");
        if (fecha != null) servicio.setFechaActivacion(fecha.toLocalDate());
        servicio.setEstado(rs.getString("estado"));
        servicio.setRazonSocialCliente(rs.getString("razonSocialCliente"));
        servicio.setNombreRuta(rs.getString("nombreRuta"));
    }
}
