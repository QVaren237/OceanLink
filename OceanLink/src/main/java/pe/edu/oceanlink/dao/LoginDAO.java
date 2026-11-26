package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Usuario;
import pe.edu.oceanlink.util.Seguridad;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LoginDAO extends BaseDAO {

    public Usuario validarConHashEnJava(String correo, String password) {
        Usuario usuario = null;
        String passHash = Seguridad.sha256(password);
        String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.estado, u.idRol, "
                + "u.cuentaActivada, r.nombre AS nombreRol "
                + "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol "
                + "WHERE u.correo = ? AND u.password = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, correo);
            ps.setString(2, passHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) usuario = mapear(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    public Usuario validarConHashEnSQL(String correo, String password) {
        Usuario usuario = null;
        String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.estado, u.idRol, "
                + "u.cuentaActivada, r.nombre AS nombreRol "
                + "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol "
                + "WHERE u.correo = ? AND u.password = SHA2(?, 256)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, correo);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) usuario = mapear(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("idUsuario"));
        u.setNombre(rs.getString("nombre"));
        u.setApellido(rs.getString("apellido"));
        u.setCorreo(rs.getString("correo"));
        u.setEstado(rs.getString("estado"));
        u.setCuentaActivada(rs.getBoolean("cuentaActivada"));
        u.setIdRol(rs.getInt("idRol"));
        u.setNombreRol(rs.getString("nombreRol"));
        return u;
    }
}
