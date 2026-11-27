package pe.edu.oceanlink.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class RecuperacionPasswordDAO extends BaseDAO {

    public Integer obtenerIdUsuarioActivoPorCorreo(String correo)
            throws SQLException {

        String sql = "SELECT idUsuario FROM usuario "
                + "WHERE correo = ? AND estado = 'Activo'";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, correo);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("idUsuario");
                }
            }
        }

        return null;
    }

    public void guardarToken(int idUsuario, String tokenHash,
                             Timestamp fechaExpiracion)
            throws SQLException {

        String sqlDesactivar =
                "UPDATE recuperacion_password "
                        + "SET usado = TRUE "
                        + "WHERE idUsuario = ? AND usado = FALSE";

        String sqlInsertar =
                "INSERT INTO recuperacion_password "
                        + "(idUsuario, tokenHash, fechaExpiracion, usado) "
                        + "VALUES (?, ?, ?, FALSE)";

        try (Connection conn = getConnection()) {

            conn.setAutoCommit(false);

            try {
                try (PreparedStatement ps =
                             conn.prepareStatement(sqlDesactivar)) {

                    ps.setInt(1, idUsuario);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps =
                             conn.prepareStatement(sqlInsertar)) {

                    ps.setInt(1, idUsuario);
                    ps.setString(2, tokenHash);
                    ps.setTimestamp(3, fechaExpiracion);
                    ps.executeUpdate();
                }

                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public Integer obtenerUsuarioPorTokenValido(String tokenHash)
            throws SQLException {

        String sql =
                "SELECT idUsuario FROM recuperacion_password "
                        + "WHERE tokenHash = ? "
                        + "AND usado = FALSE "
                        + "AND fechaExpiracion > NOW()";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, tokenHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("idUsuario");
                }
            }
        }

        return null;
    }

    public boolean actualizarPasswordConToken(
            String tokenHash, String nuevaPassword)
            throws SQLException {

        String sqlUsuario =
                "UPDATE usuario u "
                        + "INNER JOIN recuperacion_password r "
                        + "ON u.idUsuario = r.idUsuario "
                        + "SET u.password = ? "
                        + "WHERE r.tokenHash = ? "
                        + "AND r.usado = FALSE "
                        + "AND r.fechaExpiracion > NOW() "
                        + "AND u.estado = 'Activo'";

        String sqlToken =
                "UPDATE recuperacion_password "
                        + "SET usado = TRUE "
                        + "WHERE tokenHash = ? AND usado = FALSE";

        try (Connection conn = getConnection()) {

            conn.setAutoCommit(false);

            try {
                String passwordHash =
                        pe.edu.oceanlink.dao.Seguridad.sha256(nuevaPassword);

                int filasActualizadas;

                try (PreparedStatement ps =
                             conn.prepareStatement(sqlUsuario)) {

                    ps.setString(1, passwordHash);
                    ps.setString(2, tokenHash);

                    filasActualizadas = ps.executeUpdate();
                }

                if (filasActualizadas != 1) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps =
                             conn.prepareStatement(sqlToken)) {

                    ps.setString(1, tokenHash);

                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                conn.commit();
                return true;

            } catch (SQLException | RuntimeException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }
        }
    }
}
