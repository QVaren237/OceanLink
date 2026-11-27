package pe.edu.oceanlink.dao;

import java.sql.Connection;
import java.sql.SQLException;

public class Conexion {
    private static class Acceso extends BaseDAO {
    }

    public static Connection getConnection() throws SQLException {
        return new Acceso().getConnection();
    }
}
