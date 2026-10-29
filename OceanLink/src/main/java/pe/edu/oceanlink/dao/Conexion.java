
package pe.edu.oceanlink.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {

    private static final String URL = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";

    private static final String USUARIO = "root";
    private static final String CLAVE = "root";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USUARIO, CLAVE);
    }
}
