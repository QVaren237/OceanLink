package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Rol;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class RolDAO {

    public ArrayList<Rol> obtenerListaRoles() {
        ArrayList<Rol> listaRoles = new ArrayList<>();
        try {
            String user = "root";
            String pass = "1029";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT idRol, nombre FROM rol ORDER BY nombre")) {
                while (rs.next()) {
                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("idRol"));
                    rol.setNombre(rs.getString("nombre"));
                    listaRoles.add(rol);
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return listaRoles;
    }
}
