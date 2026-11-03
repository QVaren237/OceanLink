
package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.ObservacionIncidencia;
import java.sql.*;
import java.util.ArrayList;

public class ObservacionIncidenciaDAO {

    public void registrar(int idIncidencia, String tipo,
                          String detalle) throws SQLException {

        String sql = "INSERT INTO incidencia_evento " +
                "(idIncidencia, tipo, detalle, fechaRegistro) " +
                "VALUES (?, ?, ?, NOW())";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, idIncidencia);
            ps.setString(2, tipo);
            ps.setString(3, detalle.trim());
            ps.executeUpdate();
        }
    }

    public ArrayList<ObservacionIncidencia> listarTodos() {
        ArrayList<ObservacionIncidencia> lista = new ArrayList<>();

        String sql = "SELECT e.*, i.codigo, i.titulo " +
                "FROM incidencia_evento e " +
                "JOIN incidencia i ON e.idIncidencia=i.idIncidencia " +
                "ORDER BY e.fechaRegistro DESC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ObservacionIncidencia o = mapear(rs);
                lista.add(o);
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudo consultar el historial", e);
        }

        return lista;
    }

    public ArrayList<ObservacionIncidencia> listarPorIncidencia(int id) {
        ArrayList<ObservacionIncidencia> lista = new ArrayList<>();

        String sql = "SELECT e.*, i.codigo, i.titulo " +
                "FROM incidencia_evento e " +
                "JOIN incidencia i ON e.idIncidencia=i.idIncidencia " +
                "WHERE e.idIncidencia=? " +
                "ORDER BY e.fechaRegistro DESC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudo consultar el historial", e);
        }

        return lista;
    }

    private ObservacionIncidencia mapear(ResultSet rs)
            throws SQLException {

        ObservacionIncidencia o = new ObservacionIncidencia();

        o.setIdObservacion(rs.getInt("idEvento"));
        o.setIdIncidencia(rs.getInt("idIncidencia"));
        o.setTipo(rs.getString("tipo"));
        o.setDetalle(rs.getString("detalle"));
        o.setFechaRegistro(rs.getTimestamp("fechaRegistro"));
        o.setCodigoIncidencia(rs.getString("codigo"));
        o.setTituloIncidencia(rs.getString("titulo"));

        return o;
    }
}
