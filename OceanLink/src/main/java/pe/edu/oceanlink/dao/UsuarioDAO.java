package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Usuario;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UsuarioDAO {

    public void crearUsuario(Usuario u) {
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("cSom.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "INSERT INTO usuario (nombre, apellido, correo, password, estado, idRol) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, u.getNombre());
                    pstmt.setString(2, u.getApellido());
                    pstmt.setString(3, u.getCorreo());
                    pstmt.setString(4, u.getPassword());
                    pstmt.setString(5, u.getEstado());
                    pstmt.setInt(6, u.getIdRol());
                    pstmt.executeUpdate();
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Usuario> obtenerListaUsuarios() {
        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);
            java.sql.Statement stmt = conn.createStatement();
            // JOIN con rol para traer el nombre del rol y mostrarlo en la tabla
            String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.password, u.estado, u.idRol, r.nombre AS nombreRol " +
                    "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol ORDER BY u.idUsuario";
            ResultSet rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("idUsuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellido(rs.getString("apellido"));
                usuario.setCorreo(rs.getString("correo"));
                usuario.setPassword(rs.getString("password"));
                usuario.setEstado(rs.getString("estado"));
                usuario.setIdRol(rs.getInt("idRol"));
                usuario.setNombreRol(rs.getString("nombreRol"));
                listaUsuarios.add(usuario);
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return listaUsuarios;
    }

    public Usuario obtenerUsuario(String idUsuario) {
        Usuario usuario = null;
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.password, u.estado, u.idRol, r.nombre AS nombreRol " +
                        "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol WHERE u.idUsuario = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(idUsuario));
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        usuario = new Usuario();
                        usuario.setIdUsuario(rs.getInt("idUsuario"));
                        usuario.setNombre(rs.getString("nombre"));
                        usuario.setApellido(rs.getString("apellido"));
                        usuario.setCorreo(rs.getString("correo"));
                        usuario.setPassword(rs.getString("password"));
                        usuario.setEstado(rs.getString("estado"));
                        usuario.setIdRol(rs.getInt("idRol"));
                        usuario.setNombreRol(rs.getString("nombreRol"));
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    public void actualizarUsuario(Usuario u) {
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                // Si no se escribió una nueva contraseña, se conserva la actual (no se sobrescribe)
                boolean cambiaPassword = u.getPassword() != null && !u.getPassword().isEmpty();
                String sql = cambiaPassword
                        ? "UPDATE usuario SET nombre = ?, apellido = ?, correo = ?, password = ?, estado = ?, idRol = ? WHERE idUsuario = ?"
                        : "UPDATE usuario SET nombre = ?, apellido = ?, correo = ?, estado = ?, idRol = ? WHERE idUsuario = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    int i = 1;
                    pstmt.setString(i++, u.getNombre());
                    pstmt.setString(i++, u.getApellido());
                    pstmt.setString(i++, u.getCorreo());
                    if (cambiaPassword) {
                        pstmt.setString(i++, u.getPassword());
                    }
                    pstmt.setString(i++, u.getEstado());
                    pstmt.setInt(i++, u.getIdRol());
                    pstmt.setInt(i, u.getIdUsuario());
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
        String sql = "UPDATE usuario SET estado = ? WHERE idUsuario = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, Integer.parseInt(id));
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Cuenta el total de usuarios registrados
    public int contarUsuarios() {
        int total = 0;
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 java.sql.Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM usuario")) {
                if (rs.next()) total = rs.getInt(1);
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Cuenta solo los usuarios con estado Activo
    public int contarUsuariosActivos() {
        int total = 0;
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 java.sql.Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM usuario WHERE estado = 'Activo'")) {
                if (rs.next()) total = rs.getInt(1);
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Trae los ultimos usuarios registrados (para la tabla del panel)
    public ArrayList<Usuario> obtenerUsuariosRecientes(int limite) {
        ArrayList<Usuario> lista = new ArrayList<>();
        try {
            String user = "root";
            String pass = "root";
            String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {
                String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.password, u.estado, u.idRol, r.nombre AS nombreRol " +
                        "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol ORDER BY u.idUsuario DESC LIMIT ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, limite);
                    ResultSet rs = pstmt.executeQuery();
                    while (rs.next()) {
                        Usuario usuario = new Usuario();
                        usuario.setIdUsuario(rs.getInt("idUsuario"));
                        usuario.setNombre(rs.getString("nombre"));
                        usuario.setApellido(rs.getString("apellido"));
                        usuario.setCorreo(rs.getString("correo"));
                        usuario.setPassword(rs.getString("password"));
                        usuario.setEstado(rs.getString("estado"));
                        usuario.setIdRol(rs.getInt("idRol"));
                        usuario.setNombreRol(rs.getString("nombreRol"));
                        lista.add(usuario);
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}