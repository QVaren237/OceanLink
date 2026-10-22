package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Segmento;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class SegmentoDAO {

    public void crearSegmento(Segmento s) {
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "INSERT INTO segmento (codigo, idEstacionOrigen, idEstacionDestino, capacidadTotal, capacidadUtilizada, capacidadReservada, longitudKm, estado, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, s.getCodigo());
                    pstmt.setInt(2, s.getIdEstacionOrigen());
                    pstmt.setInt(3, s.getIdEstacionDestino());
                    pstmt.setDouble(4, s.getCapacidadTotal());
                    pstmt.setDouble(5, s.getCapacidadUtilizada());
                    pstmt.setDouble(6, s.getCapacidadReservada());
                    pstmt.setDouble(7, s.getLongitudKm());
                    pstmt.setString(8, s.getEstado());
                    pstmt.setString(9, s.getDescripcion());
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Segmento> obtenerListaSegmentos() {
        ArrayList<Segmento> lista = new ArrayList<>();
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            Statement stmt = conn.createStatement();
            // Dos JOIN a landing_station: uno para la estación de origen y otro para la de destino
            String sql = "SELECT s.idSegmento, s.codigo, s.idEstacionOrigen, s.idEstacionDestino, " +
                         "s.capacidadTotal, s.capacidadUtilizada, s.capacidadReservada, s.longitudKm, s.estado, s.descripcion, " +
                         "lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino " +
                         "FROM segmento s " +
                         "INNER JOIN landing_station lo ON s.idEstacionOrigen = lo.idLandingStation " +
                         "INNER JOIN landing_station ld ON s.idEstacionDestino = ld.idLandingStation " +
                         "ORDER BY s.idSegmento";
            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public Segmento obtenerSegmento(String id) {
        Segmento s = null;
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT s.idSegmento, s.codigo, s.idEstacionOrigen, s.idEstacionDestino, " +
                             "s.capacidadTotal, s.capacidadUtilizada, s.capacidadReservada, s.longitudKm, s.estado, s.descripcion, " +
                             "lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino " +
                             "FROM segmento s " +
                             "INNER JOIN landing_station lo ON s.idEstacionOrigen = lo.idLandingStation " +
                             "INNER JOIN landing_station ld ON s.idEstacionDestino = ld.idLandingStation " +
                             "WHERE s.idSegmento = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        s = mapear(rs);
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return s;
    }

    public void actualizarSegmento(Segmento s) {
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "UPDATE segmento SET codigo = ?, idEstacionOrigen = ?, idEstacionDestino = ?, capacidadTotal = ?, capacidadUtilizada = ?, capacidadReservada = ?, longitudKm = ?, estado = ?, descripcion = ? WHERE idSegmento = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, s.getCodigo());
                    pstmt.setInt(2, s.getIdEstacionOrigen());
                    pstmt.setInt(3, s.getIdEstacionDestino());
                    pstmt.setDouble(4, s.getCapacidadTotal());
                    pstmt.setDouble(5, s.getCapacidadUtilizada());
                    pstmt.setDouble(6, s.getCapacidadReservada());
                    pstmt.setDouble(7, s.getLongitudKm());
                    pstmt.setString(8, s.getEstado());
                    pstmt.setString(9, s.getDescripcion());
                    pstmt.setInt(10, s.getIdSegmento());
                    pstmt.executeUpdate();
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public void cambiarEstado(String id, String nuevoEstado) {
        String url = "jdbc:mysql://localhost:3306/oceanlink";
        String user = "root";
        String pass = "root";
        String sql = "UPDATE segmento SET estado = ? WHERE idSegmento = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, Integer.parseInt(id));
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Convierte una fila del ResultSet en un objeto Segmento (evita repetir código)
    private Segmento mapear(ResultSet rs) throws SQLException {
        Segmento s = new Segmento();
        s.setIdSegmento(rs.getInt("idSegmento"));
        s.setCodigo(rs.getString("codigo"));
        s.setIdEstacionOrigen(rs.getInt("idEstacionOrigen"));
        s.setIdEstacionDestino(rs.getInt("idEstacionDestino"));
        s.setCapacidadTotal(rs.getDouble("capacidadTotal"));
        s.setCapacidadUtilizada(rs.getDouble("capacidadUtilizada"));
        s.setCapacidadReservada(rs.getDouble("capacidadReservada"));
        s.setLongitudKm(rs.getDouble("longitudKm"));
        s.setEstado(rs.getString("estado"));
        s.setDescripcion(rs.getString("descripcion"));
        s.setNombreOrigen(rs.getString("nombreOrigen"));
        s.setNombreDestino(rs.getString("nombreDestino"));
        return s;
    }
}
