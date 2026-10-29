package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Segmento;
import java.sql.*;
import java.util.ArrayList;

public class SegmentoConsultaDAO {

    public ArrayList<Segmento> listar(String busqueda, String estado) {
        ArrayList<Segmento> lista = new ArrayList<>();

        String sql = "SELECT s.idSegmento, s.codigo, s.idEstacionOrigen, " +
                "s.idEstacionDestino, s.capacidadTotal, s.capacidadUtilizada, " +
                "s.capacidadReservada, s.longitudKm, s.estado, s.descripcion, " +
                "lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino " +
                "FROM segmento s " +
                "JOIN landing_station lo ON s.idEstacionOrigen=lo.idLandingStation " +
                "JOIN landing_station ld ON s.idEstacionDestino=ld.idLandingStation " +
                "WHERE (s.codigo LIKE ? OR lo.nombre LIKE ? OR ld.nombre LIKE ?) " +
                "AND (?='' OR s.estado=?) ORDER BY s.idSegmento";

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
                    Segmento s = new Segmento();

                    s.setIdSegmento(rs.getInt("idSegmento"));
                    s.setCodigo(rs.getString("codigo"));
                    s.setIdEstacionOrigen(rs.getInt("idEstacionOrigen"));
                    s.setIdEstacionDestino(rs.getInt("idEstacionDestino"));
                    s.setCapacidadTotal(rs.getDouble("capacidadTotal"));
                    s.setCapacidadUtilizada(rs.getDouble("capacidadUtilizada"));
                    s.setCapacidadReservada(rs.getDouble("capacidadReservada"));
                    s.setLongitudKm(rs.getDouble("longitudKm"));
                    s.setEstado(rs.getString("estado"));
                    s.setDescripcion(rs.getString("descripcion"));
                    s.setNombreOrigen(rs.getString("nombreOrigen"));
                    s.setNombreDestino(rs.getString("nombreDestino"));

                    lista.add(s);
                }
            }

        } catch (SQLException e) {
            throw new RuntimeException(
                    "No se pudo consultar el estado de red", e);
        }

        return lista;
    }
}
