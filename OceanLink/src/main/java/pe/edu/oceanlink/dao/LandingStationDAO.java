package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.LandingStation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class LandingStationDAO {

    public void crearLandingStation(LandingStation ls) {
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "INSERT INTO landing_station (codigo, nombre, ubicacion, estado, descripcion) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, ls.getCodigo());
                    pstmt.setString(2, ls.getNombre());
                    pstmt.setString(3, ls.getUbicacion());
                    pstmt.setString(4, ls.getEstado());
                    pstmt.setString(5, ls.getDescripcion());
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<LandingStation> obtenerListaLandingStations() {
        ArrayList<LandingStation> lista = new ArrayList<>();
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM landing_station ORDER BY idLandingStation");
            while (rs.next()) {
                LandingStation ls = new LandingStation();
                ls.setIdLandingStation(rs.getInt(1));
                ls.setCodigo(rs.getString(2));
                ls.setNombre(rs.getString(3));
                ls.setUbicacion(rs.getString(4));
                ls.setEstado(rs.getString(5));
                ls.setDescripcion(rs.getString(6));
                lista.add(ls);
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public LandingStation obtenerLandingStation(String id) {
        LandingStation ls = null;
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT * FROM landing_station WHERE idLandingStation = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(id));
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        ls = new LandingStation();
                        ls.setIdLandingStation(rs.getInt(1));
                        ls.setCodigo(rs.getString(2));
                        ls.setNombre(rs.getString(3));
                        ls.setUbicacion(rs.getString(4));
                        ls.setEstado(rs.getString(5));
                        ls.setDescripcion(rs.getString(6));
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return ls;
    }

    public void actualizarLandingStation(LandingStation ls) {
        try {
            String user = "root";
            String pass = "070501";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "UPDATE landing_station SET codigo = ?, nombre = ?, ubicacion = ?, estado = ?, descripcion = ? WHERE idLandingStation = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, ls.getCodigo());
                    pstmt.setString(2, ls.getNombre());
                    pstmt.setString(3, ls.getUbicacion());
                    pstmt.setString(4, ls.getEstado());
                    pstmt.setString(5, ls.getDescripcion());
                    pstmt.setInt(6, ls.getIdLandingStation());
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
        String pass = "070501";
        String sql = "UPDATE landing_station SET estado = ? WHERE idLandingStation = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, Integer.parseInt(id));
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
