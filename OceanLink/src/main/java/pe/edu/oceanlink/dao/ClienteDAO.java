package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Cliente;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class ClienteDAO {

    public void crearTrabajo(Cliente c) {
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "INSERT INTO cliente (razonSocial, ruc, telefono, correo, direccion, contacto, estado) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, c.getRazonSocial());
                    pstmt.setString(2, c.getRuc());
                    pstmt.setString(3, c.getTelefono());
                    pstmt.setString(4, c.getCorreo());
                    pstmt.setString(5, c.getDireccion());
                    pstmt.setString(6, c.getContacto());
                    pstmt.setString(7, c.getEstado());
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Cliente> obtenerListaTrabajos() {  //en las ppts se exige que en cada metodo se debe escribir la contraseña
        ArrayList<Cliente> listaTrabajos = new ArrayList<>();
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            java.sql.Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM cliente");
            
            while (rs.next()) {
                Cliente cliente = new Cliente();
                cliente.setIdCliente(rs.getInt(1));
                cliente.setRazonSocial(rs.getString(2));
                cliente.setRuc(rs.getString(3));
                cliente.setTelefono(rs.getString(4));
                cliente.setCorreo(rs.getString(5));
                cliente.setDireccion(rs.getString(6));
                cliente.setContacto(rs.getString(7));
                cliente.setEstado(rs.getString(8));
                listaTrabajos.add(cliente);
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return listaTrabajos;
    }

    public Cliente obtenerTrabajo(String idCliente) {
        Cliente cliente = null;
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT * FROM cliente WHERE idCliente = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(idCliente));
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        cliente = new Cliente();
                        cliente.setIdCliente(rs.getInt(1));
                        cliente.setRazonSocial(rs.getString(2));
                        cliente.setRuc(rs.getString(3));
                        cliente.setTelefono(rs.getString(4));
                        cliente.setCorreo(rs.getString(5));
                        cliente.setDireccion(rs.getString(6));
                        cliente.setContacto(rs.getString(7));
                        cliente.setEstado(rs.getString(8));
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return cliente;
    }

    public void actualizarTrabajo(Cliente c) {
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "UPDATE cliente SET razonSocial = ?, ruc = ?, telefono = ?, correo = ?, direccion = ?, contacto = ?, estado = ? WHERE idCliente = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, c.getRazonSocial());
                    pstmt.setString(2, c.getRuc());
                    pstmt.setString(3, c.getTelefono());
                    pstmt.setString(4, c.getCorreo());
                    pstmt.setString(5, c.getDireccion());
                    pstmt.setString(6, c.getContacto());
                    pstmt.setString(7, c.getEstado());
                    pstmt.setInt(8, c.getIdCliente());
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
        String sql = "UPDATE cliente SET estado = ? WHERE idCliente = ?";
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