
package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.SolicitudCapacidad;
import java.sql.*;
import java.util.ArrayList;

public class SolicitudCapacidadDAO extends BaseDAO {

    public ArrayList<String> listarMotivos() {
        java.util.Set<String> motivos = new java.util.LinkedHashSet<>();
        motivos.add("Contingencia por incidencia");
        motivos.add("Refuerzo operativo");
        String sql = "SELECT DISTINCT TRIM(motivo) AS motivo FROM solicitud "
                + "WHERE motivo IS NOT NULL AND TRIM(motivo) <> '' ORDER BY motivo";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) motivos.add(rs.getString("motivo"));
        } catch (SQLException e) {
            throw new RuntimeException("No se pudieron consultar los motivos de solicitud", e);
        }
        ArrayList<String> lista = new ArrayList<>(motivos);
        lista.sort(java.text.Collator.getInstance(new java.util.Locale("es", "PE")));
        return lista;
    }

    public String[] obtenerResumenReserva(int id) {
        String sql = "SELECT s.codigo, SUM(rc.capacidadReservada) AS capacidad, "
                + "GROUP_CONCAT(DISTINCT CONCAT(u.nombre,' ',u.apellido) SEPARATOR ', ') AS responsables "
                + "FROM reserva_capacidad rc JOIN segmento s ON s.idSegmento=rc.idSegmento "
                + "JOIN usuario u ON u.idUsuario=rc.idUsuario WHERE rc.idSolicitud=? "
                + "AND COALESCE(rc.estado,'') NOT IN ('Liberada','Cancelada') GROUP BY s.idSegmento,s.codigo";
        ArrayList<String> capacidades = new ArrayList<>();
        java.util.Set<String> responsables = new java.util.LinkedHashSet<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    capacidades.add(rs.getString("codigo")+": "+rs.getBigDecimal("capacidad").stripTrailingZeros().toPlainString()+" Gbps");
                    responsables.add(rs.getString("responsables"));
                }
            }
        } catch (SQLException e) { throw new RuntimeException("No se pudo consultar la reserva de la solicitud", e); }
        return new String[]{capacidades.isEmpty()?"Sin reservas vigentes":String.join(" · ",capacidades),
                responsables.isEmpty()?"Sin asignación registrada":String.join(" · ",responsables)};
    }

    public ArrayList<SolicitudCapacidad> listar(String busqueda,
                                                String estado) {
        ArrayList<SolicitudCapacidad> lista = new ArrayList<>();

        String sql = "SELECT so.*, c.razonSocial AS cliente, " +
                "r.nombre AS ruta " +
                "FROM solicitud so " +
                "JOIN cliente c ON so.idCliente=c.idCliente " +
                "JOIN ruta r ON so.idRuta=r.idRuta " +
                "WHERE (so.codigo LIKE ? OR r.nombre LIKE ? OR so.motivo LIKE ?) " +
                "AND (?='' OR so.estado=?) " +
                "ORDER BY so.fechaSolicitud DESC, so.idSolicitud DESC";

        try (Connection conn = getConnection();
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
            throw new RuntimeException(
                    "No se pudo listar solicitudes", e);
        }

        return lista;
    }

    public SolicitudCapacidad obtener(int id) {
        String sql = "SELECT so.*, c.razonSocial AS cliente, " +
                "r.nombre AS ruta " +
                "FROM solicitud so " +
                "JOIN cliente c ON so.idCliente=c.idCliente " +
                "JOIN ruta r ON so.idRuta=r.idRuta " +
                "WHERE so.idSolicitud=?";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudo consultar solicitud", e);
        }

        return null;
    }

    public void crear(SolicitudCapacidad s) throws SQLException {
        String sql = "INSERT INTO solicitud " +
                "(codigo, idCliente, idRuta, capacidadSolicitada, " +
                "fechaSolicitud, fechaLimite, motivo, estado, observacion, idUsuario) " +
                "VALUES (?, ?, ?, ?, CURDATE(), ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, s.getCodigo());
            ps.setInt(2, s.getIdCliente());
            ps.setInt(3, s.getIdRuta());
            ps.setDouble(4, s.getCapacidadSolicitada());

            if (s.getFechaLimite() == null) {
                ps.setNull(5, Types.DATE);
            } else {
                ps.setDate(5, s.getFechaLimite());
            }

            ps.setString(6, s.getMotivo());
            ps.setString(7, "Registrada");
            ps.setString(8, s.getObservacion());
            ps.setInt(9, s.getIdUsuario());

            ps.executeUpdate();
        }
    }

    public ArrayList<String[]> listarClientes() {
        ArrayList<String[]> lista = new ArrayList<>();

        String sql = "SELECT idCliente, razonSocial " +
                "FROM cliente WHERE estado='Activo' " +
                "ORDER BY razonSocial";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(new String[]{
                        rs.getString("idCliente"),
                        rs.getString("razonSocial")
                });
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudieron consultar los clientes", e);
        }

        return lista;
    }

    public ArrayList<String[]> listarRutas() {
        ArrayList<String[]> lista = new ArrayList<>();

        String sql = "SELECT idRuta, nombre FROM ruta ORDER BY nombre";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(new String[]{
                        rs.getString("idRuta"),
                        rs.getString("nombre")
                });
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudieron consultar las rutas", e);
        }

        return lista;
    }

    private SolicitudCapacidad mapear(ResultSet rs)
            throws SQLException {

        SolicitudCapacidad s = new SolicitudCapacidad();

        s.setIdSolicitud(rs.getInt("idSolicitud"));
        s.setCodigo(rs.getString("codigo"));
        s.setIdCliente(rs.getInt("idCliente"));
        s.setIdRuta(rs.getInt("idRuta"));
        s.setCapacidadSolicitada(rs.getDouble("capacidadSolicitada"));
        s.setFechaSolicitud(rs.getDate("fechaSolicitud"));
        s.setFechaLimite(rs.getDate("fechaLimite"));
        s.setMotivo(rs.getString("motivo"));
        s.setEstado(rs.getString("estado"));
        s.setObservacion(rs.getString("observacion"));
        s.setIdUsuario(rs.getInt("idUsuario"));
        s.setCliente(rs.getString("cliente"));
        s.setRuta(rs.getString("ruta"));

        return s;
    }
}
