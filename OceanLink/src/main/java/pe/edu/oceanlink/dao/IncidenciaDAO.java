
package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Incidencia;
import java.sql.*;
import java.util.ArrayList;

public class IncidenciaDAO {

    public ArrayList<Incidencia> listar(String busqueda, String estado) {
        ArrayList<Incidencia> lista = new ArrayList<>();

        String sql = "SELECT i.*, GROUP_CONCAT(s.codigo SEPARATOR ', ') AS redes " +
                "FROM incidencia i " +
                "LEFT JOIN incidencia_segmento isg ON i.idIncidencia=isg.idIncidencia " +
                "LEFT JOIN segmento s ON isg.idSegmento=s.idSegmento " +
                "WHERE (i.codigo LIKE ? OR i.titulo LIKE ? OR s.codigo LIKE ?) " +
                "AND (?='' OR i.estado=?) " +
                "GROUP BY i.idIncidencia ORDER BY i.fechaDeteccion DESC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String filtro = "%" +
                    (busqueda == null ? "" : busqueda.trim()) + "%";

            ps.setString(1, filtro);
            ps.setString(2, filtro);
            ps.setString(3, filtro);
            ps.setString(4, estado == null ? "" : estado);
            ps.setString(5, estado == null ? "" : estado);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("No se pudo listar incidencias", e);
        }

        return lista;
    }

    public Incidencia obtener(int id) {
        String sql = "SELECT i.*, GROUP_CONCAT(s.codigo SEPARATOR ', ') AS redes " +
                "FROM incidencia i " +
                "LEFT JOIN incidencia_segmento isg ON i.idIncidencia=isg.idIncidencia " +
                "LEFT JOIN segmento s ON isg.idSegmento=s.idSegmento " +
                "WHERE i.idIncidencia=? GROUP BY i.idIncidencia";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException("No se pudo consultar la incidencia", e);
        }

        return null;
    }

    public int crear(Incidencia i, String[] segmentos) throws SQLException {
        String sql = "INSERT INTO incidencia " +
                "(idIncidencia, codigo, titulo, descripcion, severidad, estado, " +
                "fechaDeteccion, fechaCierre, idUsuario) " +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), NULL, ?)";

        try (Connection conn = Conexion.getConnection()) {
            conn.setAutoCommit(false);

            try {
                int id;

                // La tabla incidencia no tiene AUTO_INCREMENT en idIncidencia.
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COALESCE(MAX(idIncidencia),0)+1 FROM incidencia FOR UPDATE")) {
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        id = rs.getInt(1);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);
                    ps.setString(2, i.getCodigo());
                    ps.setString(3, i.getTitulo());
                    ps.setString(4, i.getDescripcion());
                    ps.setString(5, i.getSeveridad());
                    ps.setString(6, i.getEstado());
                    ps.setInt(7, i.getIdUsuario());
                    ps.executeUpdate();
                }

                if (segmentos != null) {
                    String sqlSegmento =
                            "INSERT INTO incidencia_segmento " +
                                    "(idIncidencia, idSegmento) VALUES (?, ?)";

                    try (PreparedStatement ps =
                                 conn.prepareStatement(sqlSegmento)) {
                        for (String segmento : segmentos) {
                            ps.setInt(1, id);
                            ps.setInt(2, Integer.parseInt(segmento));
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }

                insertarEvento(conn, id, "REGISTRO",
                        "Incidencia registrada");

                conn.commit();
                return id;

            } catch (Exception e) {
                conn.rollback();

                if (e instanceof SQLException) {
                    throw (SQLException) e;
                }

                throw new SQLException(e);

            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void actualizarEstado(int id, String nuevoEstado,
                                 String observacion) throws SQLException {

        try (Connection conn = Conexion.getConnection()) {
            conn.setAutoCommit(false);

            try {
                String sql = "UPDATE incidencia SET estado=?, " +
                        "fechaCierre=CASE WHEN ?='Cerrada' " +
                        "THEN NOW() ELSE fechaCierre END " +
                        "WHERE idIncidencia=?";

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, nuevoEstado);
                    ps.setString(2, nuevoEstado);
                    ps.setInt(3, id);
                    ps.executeUpdate();
                }

                String detalle = "Nuevo estado: " + nuevoEstado;

                if (observacion != null && !observacion.trim().isEmpty()) {
                    detalle += ". " + observacion.trim();
                }

                insertarEvento(conn, id, "ESTADO", detalle);
                conn.commit();

            } catch (SQLException e) {
                conn.rollback();
                throw e;

            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public ArrayList<Incidencia> listarAbiertas() {
        return listar("", "");
    }

    private Incidencia mapear(ResultSet rs) throws SQLException {
        Incidencia i = new Incidencia();

        i.setIdIncidencia(rs.getInt("idIncidencia"));
        i.setCodigo(rs.getString("codigo"));
        i.setTitulo(rs.getString("titulo"));
        i.setDescripcion(rs.getString("descripcion"));
        i.setSeveridad(rs.getString("severidad"));
        i.setEstado(rs.getString("estado"));
        i.setFechaDeteccion(rs.getTimestamp("fechaDeteccion"));
        i.setFechaCierre(rs.getTimestamp("fechaCierre"));
        i.setIdUsuario(rs.getInt("idUsuario"));
        i.setRedes(rs.getString("redes"));

        return i;
    }

    private void insertarEvento(Connection conn, int id, String tipo,
                                String detalle) throws SQLException {
        String sql = "INSERT INTO incidencia_evento " +
                "(idIncidencia, tipo, detalle, fechaRegistro) " +
                "VALUES (?, ?, ?, NOW())";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, tipo);
            ps.setString(3, detalle);
            ps.executeUpdate();
        }
    }
}
