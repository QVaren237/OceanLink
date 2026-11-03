package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.SupervisorResumen;
import pe.edu.oceanlink.bean.SupervisorTramo;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/** Consultas de solo lectura para el Panel General de Supervisor. */
public class SupervisorDAO extends BaseDAO {

    public SupervisorResumen obtenerResumen() throws SQLException {
        SupervisorResumen resumen = new SupervisorResumen();
        try (Connection conn = getConnection()) {
            // Promedio de uso porcentual por segmento, sin contar segmentos sin capacidad total.
            String sqlUso = "SELECT COALESCE(ROUND(AVG(LEAST(100, 100 * "
                + "(COALESCE(capacidadUtilizada,0) + COALESCE(capacidadReservada,0)) "
                + "/ NULLIF(capacidadTotal,0))), 2), 0) AS porcentaje "
                + "FROM segmento WHERE capacidadTotal > 0";
            try (PreparedStatement ps = conn.prepareStatement(sqlUso);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setUtilizacionPromedio(rs.getBigDecimal("porcentaje"));
            }

            // Incidencias sin fecha de cierre: criterio verificable en el esquema.
            String sqlFallas = "SELECT COUNT(*) AS total FROM incidencia WHERE fechaCierre IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(sqlFallas);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setFallasActivas(rs.getInt("total"));
            }

            // Semana calendario actual, de lunes a domingo (zona horaria de MySQL).
            String sqlMantenimientos = "SELECT COUNT(*) AS total FROM mantenimiento "
                + "WHERE fechaInicio >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) "
                + "AND fechaInicio < DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 7 DAY)";
            try (PreparedStatement ps = conn.prepareStatement(sqlMantenimientos);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setMantenimientosSemana(rs.getInt("total"));
            }

            // Saturación >= 95% de la capacidad total.
            String sqlSaturados = "SELECT COUNT(*) AS total FROM segmento "
                + "WHERE capacidadTotal > 0 AND "
                + "(COALESCE(capacidadUtilizada,0) + COALESCE(capacidadReservada,0)) / capacidadTotal >= 0.95";
            try (PreparedStatement ps = conn.prepareStatement(sqlSaturados);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) resumen.setTramosSaturados(rs.getInt("total"));
            }
        }
        return resumen;
    }

    public ArrayList<SupervisorTramo> listarTramosAltaUtilizacion() throws SQLException {
        ArrayList<SupervisorTramo> lista = new ArrayList<>();
        String sql = "SELECT s.codigo, eo.nombre AS origen, ed.nombre AS destino, s.estado, "
            + "s.capacidadTotal, GREATEST(0, s.capacidadTotal - COALESCE(s.capacidadUtilizada,0) "
            + "- COALESCE(s.capacidadReservada,0)) AS disponible, "
            + "ROUND(100 * (COALESCE(s.capacidadUtilizada,0) + COALESCE(s.capacidadReservada,0)) "
            + "/ NULLIF(s.capacidadTotal,0), 2) AS porcentaje "
            + "FROM segmento s "
            + "JOIN landing_station eo ON eo.idLandingStation = s.idEstacionOrigen "
            + "JOIN landing_station ed ON ed.idLandingStation = s.idEstacionDestino "
            + "WHERE s.capacidadTotal > 0 "
            + "AND (COALESCE(s.capacidadUtilizada,0) + COALESCE(s.capacidadReservada,0)) "
            + "/ s.capacidadTotal >= 0.80 "
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
                lista.add(tramo);
            }
        }
        return lista;
    }

    /** Eventos reales de incidencias y mantenimientos, sin duplicar sus segmentos. */
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

    /** Servicios cuyas rutas incluyen los segmentos asociados al evento. No modifica datos. */
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

    /** Reportes de solo consulta. Las fechas corresponden a cada evento/registro. */
    public ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> listarReporte(
            String tipo, java.time.LocalDate inicio, java.time.LocalDate fin) throws SQLException {
        ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> filas = new ArrayList<>();
        String sql;
        if ("capacidad".equals(tipo)) {
            // Historial real de capacidad (instantáneas registradas en historial_capacidad).
            sql = "SELECT s.codigo c1, DATE_FORMAT(h.fechaRegistro,'%d/%m/%Y') c2, "
                + "CONCAT(COALESCE(h.capacidadTotal,0),' Gbps') c3, "
                + "CONCAT(COALESCE(h.capacidadDisponible,0),' Gbps') c4, "
                + "CONCAT(COALESCE(h.porcentajeUtilizacion,0),' %') c5 "
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
            // Incidencias cerradas. Impacto = cantidad de clientes distintos cuyas rutas
            // usan uno de los segmentos vinculados a la incidencia (afectación potencial).
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
}
