package pe.edu.oceanlink.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public abstract class BaseDAO {

    public Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontró el controlador JDBC de MySQL.", ex);
        }

        String user = "root";
        String pass = "070501";
        String url = "jdbc:mysql://localhost:3306/oceanlink?serverTimezone=America/Lima";

        return DriverManager.getConnection(url, user, pass);
    }

    protected Connection abrirConexion() throws SQLException {
        return getConnection();
    }
}
