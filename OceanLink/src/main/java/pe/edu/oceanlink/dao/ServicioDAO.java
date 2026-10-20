package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Servicio;
import java.sql.*;
import java.util.ArrayList;

public class ServicioDAO {

    // Asegúrate de poner el nombre de tu BD si no es oceanlink_db
    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://127.0.0.1:3306/oceanlink";

    public ArrayList<Servicio> obtenerListaServicios() {
        ArrayList<Servicio> listaServicios = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM servicios");
                while (rs.next()) {
                    Servicio servicio = new Servicio();
                    servicio.setIdServicio(rs.getInt("id_servicio"));
                    servicio.setNombre(rs.getString("nombre"));
                    servicio.setDescripcion(rs.getString("descripcion"));
                    servicio.setPrecio(rs.getDouble("precio"));
                    listaServicios.add(servicio);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return listaServicios;
    }

    public Servicio obtenerServicio(int idServicio) {
        Servicio servicio = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT * FROM servicios WHERE id_servicio = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idServicio);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            servicio = new Servicio();
                            servicio.setIdServicio(rs.getInt("id_servicio"));
                            servicio.setNombre(rs.getString("nombre"));
                            servicio.setDescripcion(rs.getString("descripcion"));
                            servicio.setPrecio(rs.getDouble("precio"));
                        }
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return servicio;
    }

    public void crearServicio(String nombre, String descripcion, double precio) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "INSERT INTO servicios (nombre, descripcion, precio) VALUES (?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, nombre);
                    pstmt.setString(2, descripcion);
                    pstmt.setDouble(3, precio);
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public void actualizarServicio(int idServicio, String nombre, String descripcion, double precio) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "UPDATE servicios SET nombre = ?, descripcion = ?, precio = ? WHERE id_servicio = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, nombre);
                    pstmt.setString(2, descripcion);
                    pstmt.setDouble(3, precio);
                    pstmt.setInt(4, idServicio);
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public void borrarServicio(int idServicio) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "DELETE FROM servicios WHERE id_servicio = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idServicio);
                    pstmt.executeUpdate();
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}