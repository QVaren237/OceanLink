package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.SupervisorResumen;
import pe.edu.oceanlink.bean.SupervisorTramo;
import java.math.BigDecimal;
import pe.edu.oceanlink.bean.SupervisorDatoGrafico;
import pe.edu.oceanlink.bean.SupervisorEstadisticas;
import pe.edu.oceanlink.bean.SupervisorMes;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;

public class SupervisorDAO extends BaseDAO {

    public SupervisorResumen obtenerResumen() throws SQLException {
        SupervisorResumen resumen = new SupervisorResumen();
        try (Connection conn = getConnection()) {

            String sqlUso = "SELECT ROUND(AVG(100 * " + CapacidadDAO.USO_ACTUAL
                + " / NULLIF(s.capacidadTotal,0)), 2) AS porcentaje FROM segmento s WHERE s.capacidadTotal > 0";
            try (PreparedStatement ps = conn.prepareStatement(sqlUso);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setUtilizacionPromedio(rs.getBigDecimal("porcentaje"));
            }

            String sqlFallas = "SELECT COUNT(*) AS total FROM incidencia WHERE fechaCierre IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(sqlFallas);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setFallasActivas(rs.getInt("total"));
            }

            String sqlMantenimientos = "SELECT COUNT(*) AS total FROM mantenimiento "
                + "WHERE fechaInicio >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) "
                + "AND fechaInicio < DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 7 DAY)";
            try (PreparedStatement ps = conn.prepareStatement(sqlMantenimientos);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setMantenimientosSemana(rs.getInt("total"));
            }

            String sqlCriticos = "SELECT COUNT(*) AS total FROM segmento s "
                + "WHERE s.capacidadTotal > 0 AND " + CapacidadDAO.USO_ACTUAL + " > s.capacidadTotal * 0.95";
            try (PreparedStatement ps = conn.prepareStatement(sqlCriticos);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setTramosCriticos(rs.getInt("total"));
            }
        }
        return resumen;
    }

    public ArrayList<SupervisorTramo> listarTramosAltaUtilizacion() throws SQLException {
        ArrayList<SupervisorTramo> lista = new ArrayList<>();
        String sql = "SELECT s.codigo, eo.nombre AS origen, ed.nombre AS destino, s.estado, "
            + "s.capacidadTotal, s.capacidadTotal - " + CapacidadDAO.USO_ACTUAL + " AS disponible, "
            + "ROUND(100 * " + CapacidadDAO.USO_ACTUAL + " / NULLIF(s.capacidadTotal,0), 2) AS porcentaje, "
            + CapacidadDAO.USO_ACTUAL + " > s.capacidadTotal * 0.95 AS critico "
            + "FROM segmento s "
            + "JOIN landing_station eo ON eo.idLandingStation = s.idEstacionOrigen "
            + "JOIN landing_station ed ON ed.idLandingStation = s.idEstacionDestino "
            + "WHERE s.capacidadTotal > 0 "
            + "AND " + CapacidadDAO.USO_ACTUAL + " >= s.capacidadTotal * 0.80 "
            + "ORDER BY porcentaje DESC, s.codigo";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SupervisorTramo tramo = new SupervisorTramo();
                tramo.setCodigo(rs.getString("codigo"));
                tramo.setOrigen(rs.getString("origen"));
                tramo.setDestino(rs.getString("destino"));
                tramo.setEstado(rs.getString("estado"));
                tramo.setCapacidadTotal(rs.getBigDecimal("capacidadTotal"));
                tramo.setCapacidadDisponible(rs.getBigDecimal("disponible"));
                tramo.setPorcentajeUtilizacion(rs.getBigDecimal("porcentaje"));
                tramo.setCritico(rs.getBoolean("critico"));
                lista.add(tramo);
            }
        }
        return lista;
    }

    public ArrayList<pe.edu.oceanlink.bean.SupervisorEvento> listarEventos() throws SQLException {
        ArrayList<pe.edu.oceanlink.bean.SupervisorEvento> lista = new ArrayList<>();
        String sql = "SELECT CONCAT('I:', i.idIncidencia) clave, i.codigo, "
          + "COALESCE(NULLIF(i.titulo,''),'Incidencia') tipo, "
          + "COALESCE(GROUP_CONCAT(DISTINCT CONCAT(eo.nombre, ' → ', ed.nombre) SEPARATOR ', '),'Sin tramo vinculado') tramo, "
          + "i.severidad gravedad, i.estado, i.fechaDeteccion fecha "
          + "FROM incidencia i LEFT JOIN incidencia_segmento ix ON ix.idIncidencia=i.idIncidencia "
          + "LEFT JOIN segmento s ON s.idSegmento=ix.idSegmento "
          + "LEFT JOIN landing_station eo ON eo.idLandingStation=s.idEstacionOrigen "
          + "LEFT JOIN landing_station ed ON ed.idLandingStation=s.idEstacionDestino "
          + "GROUP BY i.idIncidencia, i.codigo, i.titulo, i.severidad, i.estado, i.fechaDeteccion "
          + "UNION ALL "
          + "SELECT CONCAT('M:',m.idMantenimiento) clave, m.codigo, "
          + "CONCAT('Mantenimiento ',COALESCE(m.tipo,'')) tipo, "
          + "COALESCE(GROUP_CONCAT(DISTINCT CONCAT(eo.nombre,' → ',ed.nombre) SEPARATOR ', '),'Sin tramo vinculado') tramo, "
          + "NULL gravedad, m.estado, m.fechaInicio fecha "
          + "FROM mantenimiento m "
          + "LEFT JOIN (SELECT idMantenimiento,idSegmento FROM mantenimiento_segmento "
          + "UNION SELECT idMantenimiento,idSegmento FROM mantenimiento WHERE idSegmento IS NOT NULL) mx "
          + "ON mx.idMantenimiento=m.idMantenimiento "
          + "LEFT JOIN segmento s ON s.idSegmento=mx.idSegmento "
          + "LEFT JOIN landing_station eo ON eo.idLandingStation=s.idEstacionOrigen "
          + "LEFT JOIN landing_station ed ON ed.idLandingStation=s.idEstacionDestino "
          + "GROUP BY m.idMantenimiento,m.codigo,m.tipo,m.estado,m.fechaInicio "
          + "ORDER BY fecha DESC";
        try(Connection conn=getConnection(); PreparedStatement ps=conn.prepareStatement(sql);
            ResultSet rs=ps.executeQuery()) {
            while(rs.next()) {
                pe.edu.oceanlink.bean.SupervisorEvento e=new pe.edu.oceanlink.bean.SupervisorEvento();
                e.setClave(rs.getString("clave")); e.setCodigo(rs.getString("codigo"));
                e.setTipo(rs.getString("tipo")); e.setTramo(rs.getString("tramo"));
                e.setGravedad(rs.getString("gravedad")); e.setEstado(rs.getString("estado"));
                lista.add(e);
            }
        }
        return lista;
    }

    public ArrayList<pe.edu.oceanlink.bean.SupervisorAfectado> listarAfectados(String clave) throws SQLException {
        ArrayList<pe.edu.oceanlink.bean.SupervisorAfectado> lista=new ArrayList<>();
        if(clave==null || !clave.matches("[IM]:[0-9]{1,10}")) return lista;
        boolean incidencia=clave.startsWith("I:");
        long id=Long.parseLong(clave.substring(2));
        if(id>Integer.MAX_VALUE) return lista;
        String sub=incidencia
           ? "SELECT idSegmento FROM incidencia_segmento WHERE idIncidencia=?"
           : "SELECT idSegmento FROM mantenimiento_segmento WHERE idMantenimiento=? "
             + "UNION SELECT idSegmento FROM mantenimiento WHERE idMantenimiento=? AND idSegmento IS NOT NULL";
        String sql="SELECT DISTINCT c.razonSocial empresa, sv.codigo servicio, sv.capacidadContratada capacidad, "
            + "COALESCE(NULLIF(c.telefono,''),NULLIF(c.correo,''),'—') contacto "
            + "FROM servicio sv JOIN cliente c ON c.idCliente=sv.idCliente "
            + "JOIN ruta_segmento rx ON rx.idRuta=sv.idRuta "
            + "WHERE rx.idSegmento IN (" + sub + ") AND sv.estado NOT IN ('Cancelado','Cancelada') "
            + "ORDER BY c.razonSocial,sv.codigo";
        try(Connection conn=getConnection(); PreparedStatement ps=conn.prepareStatement(sql)) {
            ps.setInt(1,(int)id);if(!incidencia) ps.setInt(2,(int)id);
            try(ResultSet rs=ps.executeQuery()) {
                while(rs.next()) {
                    pe.edu.oceanlink.bean.SupervisorAfectado a=new pe.edu.oceanlink.bean.SupervisorAfectado();
                    a.setEmpresa(rs.getString("empresa"));a.setServicio(rs.getString("servicio"));
                    a.setCapacidad(rs.getBigDecimal("capacidad"));a.setContacto(rs.getString("contacto"));lista.add(a);
                }
            }
        }
        return lista;
    }

    public ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> listarReporte(
            String tipo, java.time.LocalDate inicio, java.time.LocalDate fin) throws SQLException {
        ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> filas = new ArrayList<>();
        String sql;
        if ("capacidad".equals(tipo)) {

            sql = "SELECT s.codigo c1, DATE_FORMAT(h.fechaRegistro,'%d/%m/%Y') c2, "
                + "CONCAT(COALESCE(h.capacidadTotal,0),' Gbps') c3, "
                + "COALESCE(CONCAT(h.capacidadTotal - h.capacidadUtilizada,' Gbps'),'Sin datos') c4, "
                + "COALESCE(CONCAT(ROUND(100 * h.capacidadUtilizada / NULLIF(h.capacidadTotal,0), 2),' %'),'Sin datos') c5 "
                + "FROM historial_capacidad h JOIN segmento s ON s.idSegmento=h.idSegmento "
                + "WHERE h.fechaRegistro >= COALESCE(?, '1000-01-01') "
                + "AND h.fechaRegistro < DATE_ADD(COALESCE(?, '9998-12-30'),INTERVAL 1 DAY) "
                + "ORDER BY h.fechaRegistro DESC,h.idHistorial DESC";
        } else if ("servicios".equals(tipo)) {
            sql = "SELECT c.razonSocial c1, DATE_FORMAT(s.fechaActivacion,'%d/%m/%Y') c2, "
                + "s.codigo c3, COALESCE(r.nombre,r.codigo) c4, "
                + "COALESCE(CONCAT(s.capacidadContratada,' Gbps'),'Pendiente de asignación') c5 "
                + "FROM servicio s JOIN cliente c ON c.idCliente=s.idCliente "
                + "JOIN ruta r ON r.idRuta=s.idRuta "
                + "WHERE s.fechaActivacion >= COALESCE(?, '1000-01-01') "
                + "AND s.fechaActivacion <= COALESCE(?, '9999-12-31') "
                + "ORDER BY s.fechaActivacion DESC,s.codigo";
        } else {

            sql = "SELECT i.codigo c1, DATE_FORMAT(i.fechaCierre,'%d/%m/%Y') c2, "
                + "COALESCE(GROUP_CONCAT(DISTINCT CONCAT(eo.nombre,' → ',ed.nombre) SEPARATOR ', '),'Sin tramo vinculado') c3, "
                + "CONCAT(COUNT(DISTINCT sv.idCliente),' clientes relacionados') c4, "
                + "COALESCE(i.estado,'Cerrado') c5 "
                + "FROM incidencia i LEFT JOIN incidencia_segmento ix ON ix.idIncidencia=i.idIncidencia "
                + "LEFT JOIN segmento seg ON seg.idSegmento=ix.idSegmento "
                + "LEFT JOIN landing_station eo ON eo.idLandingStation=seg.idEstacionOrigen "
                + "LEFT JOIN landing_station ed ON ed.idLandingStation=seg.idEstacionDestino "
                + "LEFT JOIN ruta_segmento rx ON rx.idSegmento=ix.idSegmento "
                + "LEFT JOIN servicio sv ON sv.idRuta=rx.idRuta AND sv.estado NOT IN ('Cancelado','Cancelada') "
                + "WHERE i.fechaCierre IS NOT NULL "
                + "AND i.fechaCierre >= COALESCE(?, '1000-01-01') "
                + "AND i.fechaCierre < DATE_ADD(COALESCE(?, '9998-12-30'),INTERVAL 1 DAY) "
                + "GROUP BY i.idIncidencia,i.codigo,i.fechaCierre,i.estado "
                + "ORDER BY i.fechaCierre DESC,i.codigo";
        }
        try (Connection conn=getConnection(); PreparedStatement ps=conn.prepareStatement(sql)) {
            if (inicio == null) ps.setNull(1, java.sql.Types.DATE);
            else ps.setDate(1, java.sql.Date.valueOf(inicio));
            if (fin == null) ps.setNull(2, java.sql.Types.DATE);
            else ps.setDate(2, java.sql.Date.valueOf(fin));
            try (ResultSet rs=ps.executeQuery()) {
                while (rs.next()) {
                    pe.edu.oceanlink.bean.SupervisorReporteFila f=new pe.edu.oceanlink.bean.SupervisorReporteFila();
                    f.setC1(rs.getString("c1"));f.setC2(rs.getString("c2"));
                    f.setC3(rs.getString("c3"));f.setC4(rs.getString("c4"));
                    f.setC5(rs.getString("c5"));filas.add(f);
                }
            }
        }
        return filas;
    }

    public SupervisorEstadisticas obtenerEstadisticas(
            LocalDate inicio, LocalDate fin) throws SQLException {

        SupervisorEstadisticas estadisticas = new SupervisorEstadisticas();

        Date desde = Date.valueOf(inicio);
        Date hasta = Date.valueOf(fin);
        try (Connection conn = getConnection()) {

            String sqlIncidencias = """
                    SELECT COUNT(*) AS total,
                           SUM(CASE WHEN fechaCierre IS NULL THEN 1 ELSE 0 END) AS abiertas,
                           SUM(CASE WHEN fechaCierre IS NOT NULL THEN 1 ELSE 0 END) AS cerradas,
                           SUM(CASE WHEN severidad IN ('Crítica', 'Critica') THEN 1 ELSE 0 END) AS criticas,
                           SUM(CASE WHEN severidad = 'Alta' THEN 1 ELSE 0 END) AS altas,
                           SUM(CASE WHEN severidad = 'Media' THEN 1 ELSE 0 END) AS medias,
                           SUM(CASE WHEN severidad = 'Baja' THEN 1 ELSE 0 END) AS bajas
                    FROM incidencia
                    WHERE fechaDeteccion >= ? AND DATE(fechaDeteccion) <= ?
                    """;

            try (PreparedStatement ps = conn.prepareStatement(sqlIncidencias)) {

                ps.setDate(1, desde);
                ps.setDate(2, hasta);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        estadisticas.setTotalIncidencias(rs.getInt("total"));
                        estadisticas.setIncidenciasAbiertas(rs.getInt("abiertas"));
                        estadisticas.setIncidenciasCerradas(rs.getInt("cerradas"));
                        int criticas = rs.getInt("criticas");
                        int altas = rs.getInt("altas");
                        int medias = rs.getInt("medias");
                        int bajas = rs.getInt("bajas");
                        estadisticas.setIncidenciasGraves(criticas + altas);
                        agregarSeveridad(estadisticas, "Crítica", criticas);
                        agregarSeveridad(estadisticas, "Alta", altas);
                        agregarSeveridad(estadisticas, "Media", medias);
                        agregarSeveridad(estadisticas, "Baja", bajas);
                        agregarSeveridad(estadisticas, "Sin clasificar",
                                estadisticas.getTotalIncidencias() - criticas - altas - medias - bajas);
                    }
                }
            }

            String sqlMantenimientos =
                    "SELECT COUNT(*) AS total " +
                            "FROM mantenimiento " +
                            "WHERE fechaInicio >= ? " +
                            "AND DATE(fechaInicio) <= ?";

            try (PreparedStatement ps = conn.prepareStatement(sqlMantenimientos)) {

                ps.setDate(1, desde);
                ps.setDate(2, hasta);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        estadisticas.setTotalMantenimientos(rs.getInt("total"));
                    }
                }
            }

            String sqlSegmentos =
                    "SELECT COUNT(DISTINCT segmentos.idSegmento) AS total " +
                            "FROM ( " +
                            "    SELECT ix.idSegmento " +
                            "    FROM incidencia i " +
                            "    JOIN incidencia_segmento ix ON ix.idIncidencia = i.idIncidencia " +
                            "    WHERE i.fechaDeteccion >= ? " +
                            "    AND DATE(i.fechaDeteccion) <= ? " +
                            "    UNION " +
                            "    SELECT ms.idSegmento " +
                            "    FROM mantenimiento m " +
                            "    JOIN mantenimiento_segmento ms " +
                            "        ON ms.idMantenimiento = m.idMantenimiento " +
                            "    WHERE m.fechaInicio >= ? " +
                            "    AND DATE(m.fechaInicio) <= ? " +
                            "    UNION " +
                            "    SELECT m.idSegmento " +
                            "    FROM mantenimiento m " +
                            "    WHERE m.idSegmento IS NOT NULL " +
                            "    AND m.fechaInicio >= ? " +
                            "    AND DATE(m.fechaInicio) <= ? " +
                            ") AS segmentos";

            try (PreparedStatement ps = conn.prepareStatement(sqlSegmentos)) {

                ps.setDate(1, desde);
                ps.setDate(2, hasta);
                ps.setDate(3, desde);
                ps.setDate(4, hasta);
                ps.setDate(5, desde);
                ps.setDate(6, hasta);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        estadisticas.setSegmentosInvolucrados(
                                rs.getInt("total")
                        );
                    }
                }
            }

            String sqlClientes =
                    "SELECT COUNT(DISTINCT sv.idCliente) AS total " +
                            "FROM servicio sv " +
                            "JOIN ruta_segmento rx ON rx.idRuta = sv.idRuta " +
                            "WHERE rx.idSegmento IN ( " +
                            "    SELECT ix.idSegmento " +
                            "    FROM incidencia i " +
                            "    JOIN incidencia_segmento ix ON ix.idIncidencia = i.idIncidencia " +
                            "    WHERE i.fechaDeteccion >= ? " +
                            "    AND DATE(i.fechaDeteccion) <= ? " +
                            "    UNION " +
                            "    SELECT ms.idSegmento " +
                            "    FROM mantenimiento m " +
                            "    JOIN mantenimiento_segmento ms " +
                            "        ON ms.idMantenimiento = m.idMantenimiento " +
                            "    WHERE m.fechaInicio >= ? " +
                            "    AND DATE(m.fechaInicio) <= ? " +
                            "    UNION " +
                            "    SELECT m.idSegmento " +
                            "    FROM mantenimiento m " +
                            "    WHERE m.idSegmento IS NOT NULL " +
                            "    AND m.fechaInicio >= ? " +
                            "    AND DATE(m.fechaInicio) <= ? " +
                            ") " +
                            "AND sv.estado NOT IN ('Cancelado', 'Cancelada')";

            try (PreparedStatement ps = conn.prepareStatement(sqlClientes)) {

                ps.setDate(1, desde);
                ps.setDate(2, hasta);
                ps.setDate(3, desde);
                ps.setDate(4, hasta);
                ps.setDate(5, desde);
                ps.setDate(6, hasta);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        estadisticas.setClientesRelacionados(
                                rs.getInt("total")
                        );
                    }
                }
            }
            cargarTendencia(conn, desde, hasta, estadisticas);
        }
        return estadisticas;
    }

    private void agregarSeveridad(SupervisorEstadisticas estadisticas, String etiqueta, int cantidad) {
        SupervisorDatoGrafico dato = new SupervisorDatoGrafico();
        dato.setEtiqueta(etiqueta);
        dato.setCantidad(cantidad);
        estadisticas.getSeveridades().add(dato);
    }

    private void cargarTendencia(Connection conn, Date inicio, Date fin, SupervisorEstadisticas estadisticas)
            throws SQLException {
        String sql = """
                SELECT mes, SUM(incidencias) AS incidencias, SUM(mantenimientos) AS mantenimientos
                FROM (
                    SELECT DATE_FORMAT(fechaDeteccion, '%Y-%m') AS mes,
                           COUNT(*) AS incidencias, 0 AS mantenimientos
                    FROM incidencia
                    WHERE fechaDeteccion >= ? AND DATE(fechaDeteccion) <= ?
                    GROUP BY DATE_FORMAT(fechaDeteccion, '%Y-%m')
                    UNION ALL
                    SELECT DATE_FORMAT(fechaInicio, '%Y-%m') AS mes,
                           0 AS incidencias, COUNT(*) AS mantenimientos
                    FROM mantenimiento
                    WHERE fechaInicio >= ? AND DATE(fechaInicio) <= ?
                    GROUP BY DATE_FORMAT(fechaInicio, '%Y-%m')
                ) AS eventos
                GROUP BY mes
                ORDER BY mes
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, inicio);
            ps.setDate(2, fin);
            ps.setDate(3, inicio);
            ps.setDate(4, fin);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    estadisticas.getMeses().add(new SupervisorMes(rs.getString("mes"),
                            rs.getInt("incidencias"), rs.getInt("mantenimientos")));
                }
            }
        }
    }
}
