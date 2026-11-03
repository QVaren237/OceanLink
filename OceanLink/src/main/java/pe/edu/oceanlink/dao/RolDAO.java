package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Rol;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class RolDAO extends BaseDAO {

    public ArrayList<Rol> obtenerListaRoles() {
        ArrayList<Rol> listaRoles = new ArrayList<>();
        try {

            try (Connection conn = getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT idRol, nombre FROM rol ORDER BY nombre")) {
                while (rs.next()) {
                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("idRol"));
                    rol.setNombre(rs.getString("nombre"));
                    listaRoles.add(rol);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaRoles;
    }
}
