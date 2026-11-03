package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Usuario;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UsuarioDAO extends BaseDAO {

    public byte[] obtenerFoto(int id) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT foto FROM usuario WHERE idUsuario=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getBytes(1) : null; }
        }
    }

    public void actualizarPerfil(Usuario usuario, String claveActual, byte[] foto, boolean quitarFoto)
            throws SQLException {
        String sql = "UPDATE usuario SET nombre=?, apellido=?, correo=?, "
                + "password=CASE WHEN ?='' THEN password ELSE ? END"
                + (foto != null || quitarFoto ? ", foto=?" : "")
                + " WHERE idUsuario=? AND password=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre()); ps.setString(2, usuario.getApellido());
            ps.setString(3, usuario.getCorreo());
            ps.setString(4, usuario.getPassword()); ps.setString(5, usuario.getPassword());
            int indice = 6;
            if (foto != null || quitarFoto) ps.setBytes(indice++, quitarFoto ? null : foto);
            ps.setInt(indice++, usuario.getIdUsuario()); ps.setString(indice, claveActual);
            if (ps.executeUpdate() != 1) throw new IllegalArgumentException("La contraseña actual no es correcta o la cuenta ya no existe.");
        }
    }

    public void crearUsuario(Usuario u) {
        try {

            try (Connection conn = getConnection()) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Usuario> obtenerListaUsuarios() {
        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        try {

            Connection conn = getConnection();
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaUsuarios;
    }

    public Usuario obtenerUsuario(String idUsuario) {
        Usuario usuario = null;
        try {

            try (Connection conn = getConnection()) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    public void actualizarUsuario(Usuario u) {
        try {

            try (Connection conn = getConnection()) {
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void cambiarEstado(String id, String nuevoEstado) {

        String sql = "UPDATE usuario SET estado = ? WHERE idUsuario = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, Integer.parseInt(id));
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
