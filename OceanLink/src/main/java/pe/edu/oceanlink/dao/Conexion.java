package pe.edu.oceanlink.dao;

import java.sql.Connection;
import java.sql.SQLException;

/** Compatibilidad con codigo existente que invoque Conexion.getConnection(). */
@Deprecated
public final class Conexion {
    private Conexion() { }
    private static final BaseDAO DAO = new BaseDAO() { };
    public static Connection getConnection() throws SQLException {
        return DAO.getConnection();
    }
}
