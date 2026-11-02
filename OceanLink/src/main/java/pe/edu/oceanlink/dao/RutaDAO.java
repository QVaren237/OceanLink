package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.LandingStation;
import pe.edu.oceanlink.bean.Ruta;
import pe.edu.oceanlink.bean.RutaSegmento;
import pe.edu.oceanlink.bean.PanelCapacityPlanner;
import pe.edu.oceanlink.bean.ServicioResumen;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;

public class RutaDAO {
    // Mismo acceso JDBC de las clases 6.5, 7.2 y 7.3. Ajustar a MySQL local.
    protected Connection abrirConexion() throws SQLException, ClassNotFoundException {
        String user = "root";
        String pass = "070501";
        String url = "jdbc:mysql://127.0.0.1:3306/oceanlink?useSSL=false&serverTimezone=America/Lima&characterEncoding=UTF-8";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, pass);
    }

    private static final String CONSULTA_RUTA =
            "SELECT r.*, lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino, " +
            "(SELECT COUNT(*) FROM ruta_segmento rs WHERE rs.idRuta = r.idRuta) AS cantidadSegmentos, " +
            "(SELECT COUNT(*) FROM servicio s WHERE s.idRuta = r.idRuta) AS cantidadServicios, " +
            "(SELECT COUNT(*) FROM solicitud s WHERE s.idRuta = r.idRuta) AS cantidadSolicitudes " +
            "FROM ruta r INNER JOIN landing_station lo ON lo.idLandingStation = r.idEstacionOrigen " +
            "INNER JOIN landing_station ld ON ld.idLandingStation = r.idEstacionDestino ";

    private static final String CONSULTA_SEGMENTO =
            "SELECT s.*, lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino " +
            "FROM segmento s INNER JOIN landing_station lo ON lo.idLandingStation = s.idEstacionOrigen " +
            "INNER JOIN landing_station ld ON ld.idLandingStation = s.idEstacionDestino ";

    public ArrayList<Ruta> obtenerListaRutas() throws SQLException, ClassNotFoundException {
        ArrayList<Ruta> lista = new ArrayList<>();
        try (Connection conn = abrirConexion();
             PreparedStatement pstmt = conn.prepareStatement(CONSULTA_RUTA + "ORDER BY r.idRuta");
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) lista.add(mapearRuta(rs));
        }
        return lista;
    }

    public Ruta obtenerRuta(int id) throws SQLException, ClassNotFoundException {
        try (Connection conn = abrirConexion();
             PreparedStatement pstmt = conn.prepareStatement(CONSULTA_RUTA + "WHERE r.idRuta = ?")) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) return null;
                Ruta ruta = mapearRuta(rs);
                ruta.setSegmentos(obtenerTramos(conn, id));
                return ruta;
            }
        }
    }

    // Catálogos para los selectores: los errores se propagan al Servlet.
    public ArrayList<LandingStation> obtenerEstaciones() throws SQLException, ClassNotFoundException {
        ArrayList<LandingStation> lista = new ArrayList<>();
        try (Connection conn = abrirConexion();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM landing_station ORDER BY nombre");
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                LandingStation estacion = new LandingStation();
                estacion.setIdLandingStation(rs.getInt("idLandingStation"));
                estacion.setNombre(rs.getString("nombre"));
                estacion.setCodigo(rs.getString("codigo"));
                estacion.setEstado(rs.getString("estado"));
                lista.add(estacion);
            }
        }
        return lista;
    }

    public ArrayList<RutaSegmento> obtenerSegmentos() throws SQLException, ClassNotFoundException {
        ArrayList<RutaSegmento> lista = new ArrayList<>();
        try (Connection conn = abrirConexion();
             PreparedStatement pstmt = conn.prepareStatement(CONSULTA_SEGMENTO + "ORDER BY s.codigo");
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) lista.add(mapearSegmento(rs));
        }
        return lista;
    }

    public void crearRuta(Ruta ruta) throws SQLException, ClassNotFoundException {
        try (Connection conn = abrirConexion()) {
            // Ruta y sus tramos deben guardarse juntos o revertirse juntos.
            conn.setAutoCommit(false);
            try {
                cargarYValidarTramos(conn, ruta);
                String sql = "INSERT INTO ruta (codigo, nombre, idEstacionOrigen, idEstacionDestino, estado, descripcion) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    asignarDatos(pstmt, ruta);
                    pstmt.executeUpdate();
                    try (ResultSet rs = pstmt.getGeneratedKeys()) {
                        if (!rs.next()) throw new SQLException("No se obtuvo el identificador de la ruta.");
                        ruta.setIdRuta(rs.getInt(1));
                    }
                }
                insertarTramos(conn, ruta);
                conn.commit();
            } catch (SQLException | IllegalArgumentException e) {
                conn.rollback();
                ruta.setIdRuta(0);
                throw e;
            }
        }
    }

    public void actualizarRuta(Ruta ruta) throws SQLException, ClassNotFoundException {
        try (Connection conn = abrirConexion()) {
            conn.setAutoCommit(false);
            try {
                bloquearRuta(conn, ruta.getIdRuta());
                boolean enUso = estaEnUso(conn, ruta.getIdRuta());
                ArrayList<RutaSegmento> anteriores = obtenerTramos(conn, ruta.getIdRuta());
                if (enUso && cambioRecorrido(conn, ruta, anteriores)) {
                    throw new IllegalArgumentException("La ruta tiene servicios o solicitudes asociados. Conserva el origen, destino y orden de segmentos; crea otra ruta para un recorrido diferente.");
                }
                cargarYValidarTramos(conn, ruta);
                String sql = "UPDATE ruta SET codigo = ?, nombre = ?, idEstacionOrigen = ?, idEstacionDestino = ?, estado = ?, descripcion = ? WHERE idRuta = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    asignarDatos(pstmt, ruta);
                    pstmt.setInt(7, ruta.getIdRuta());
                    pstmt.executeUpdate();
                }
                if (!enUso) {
                    borrarTramos(conn, ruta.getIdRuta());
                    insertarTramos(conn, ruta);
                }
                conn.commit();
            } catch (SQLException | IllegalArgumentException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void desactivarRuta(int id) throws SQLException, ClassNotFoundException {
        try (Connection conn = abrirConexion()) {
            String sql = "UPDATE ruta SET estado = 'No operativa' WHERE idRuta = ? AND estado = 'Operativa'";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, id);
                if (pstmt.executeUpdate() != 1) {
                    throw new IllegalArgumentException("La ruta ya no existe o ya se encuentra No operativa. Actualiza el listado.");
                }
            }
        }
    }

    public PanelCapacityPlanner obtenerResumenPanel() throws SQLException, ClassNotFoundException {
        PanelCapacityPlanner panel = new PanelCapacityPlanner();
        try (Connection conn = abrirConexion()) {
            String indicadores = "SELECT " +
                    "(SELECT COUNT(*) FROM cliente WHERE estado = 'Activo') AS clientesActivos, " +
                    "(SELECT COUNT(*) FROM segmento) AS segmentosMonitoreados, " +
                    "(SELECT COUNT(*) FROM solicitud WHERE estado IN ('Registrada', 'En evaluación', 'Pendiente por capacidad')) AS solicitudesPendientes, " +
                    "(SELECT COUNT(*) FROM segmento WHERE capacidadTotal > 0 AND capacidadUtilizada / capacidadTotal > 0.95) AS segmentosCriticos";
            try (PreparedStatement pstmt = conn.prepareStatement(indicadores); ResultSet rs = pstmt.executeQuery()) {
                rs.next();
                panel.setClientesActivos(rs.getInt("clientesActivos"));
                panel.setSegmentosMonitoreados(rs.getInt("segmentosMonitoreados"));
                panel.setSolicitudesPendientes(rs.getInt("solicitudesPendientes"));
                panel.setSegmentosCriticos(rs.getInt("segmentosCriticos"));
            }
            String sql = "SELECT c.idCliente, c.razonSocial, s.codigo AS codigoServicio, s.capacidadContratada, s.estado, " +
                    "sg.codigo AS codigoSegmento, lo.nombre AS nombreOrigen, ld.nombre AS nombreDestino " +
                    "FROM servicio s INNER JOIN cliente c ON c.idCliente = s.idCliente " +
                    "LEFT JOIN ruta_segmento rs ON rs.idRuta = s.idRuta " +
                    "LEFT JOIN segmento sg ON sg.idSegmento = rs.idSegmento " +
                    "LEFT JOIN landing_station lo ON lo.idLandingStation = sg.idEstacionOrigen " +
                    "LEFT JOIN landing_station ld ON ld.idLandingStation = sg.idEstacionDestino " +
                    "ORDER BY s.idServicio DESC, rs.orden";
            try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ServicioResumen servicio = new ServicioResumen();
                    servicio.setIdCliente(rs.getInt("idCliente"));
                    servicio.setRazonSocial(rs.getString("razonSocial"));
                    servicio.setCodigoServicio(rs.getString("codigoServicio"));
                    servicio.setCodigoSegmento(rs.getString("codigoSegmento"));
                    servicio.setNombreOrigen(rs.getString("nombreOrigen"));
                    servicio.setNombreDestino(rs.getString("nombreDestino"));
                    servicio.setCapacidadContratada(rs.getBigDecimal("capacidadContratada"));
                    servicio.setEstado(rs.getString("estado"));
                    panel.getServicios().add(servicio);
                }
            }
        }
        return panel;
    }

    private void cargarYValidarTramos(Connection conn, Ruta ruta) throws SQLException {
        ArrayList<RutaSegmento> actuales = new ArrayList<>();
        // Orden de bloqueo estable para reducir conflictos entre dos formularios.
        ArrayList<Integer> ids = new ArrayList<>();
        for (RutaSegmento tramo : ruta.getSegmentos()) ids.add(tramo.getIdSegmento());
        ids.sort(Integer::compareTo);
        for (int id : ids) {
            try (PreparedStatement pstmt = conn.prepareStatement(CONSULTA_SEGMENTO + "WHERE s.idSegmento = ? FOR UPDATE")) {
                pstmt.setInt(1, id);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) throw new IllegalArgumentException("Uno de los segmentos seleccionados ya no existe.");
                    actuales.add(mapearSegmento(rs));
                }
            }
        }
        // Recuperar el orden elegido por el usuario, no el orden de los IDs.
        ArrayList<RutaSegmento> ordenados = new ArrayList<>();
        for (RutaSegmento elegido : ruta.getSegmentos()) {
            for (RutaSegmento actual : actuales) {
                if (elegido.getIdSegmento() == actual.getIdSegmento()) {
                    ordenados.add(actual);
                    break;
                }
            }
        }
        validarRecorrido(ruta, ordenados);
        ruta.setSegmentos(ordenados);
    }

    // Un cable físico se puede recorrer en ambos sentidos. No se permiten ciclos.
    public static void validarRecorrido(Ruta ruta, ArrayList<RutaSegmento> tramos) {
        if (ruta.getCodigo() == null || ruta.getCodigo().isBlank() || ruta.getCodigo().length() > 30)
            throw new IllegalArgumentException("Ingresa un código de hasta 30 caracteres.");
        if (ruta.getNombre() == null || ruta.getNombre().isBlank() || ruta.getNombre().length() > 100)
            throw new IllegalArgumentException("Ingresa un nombre de hasta 100 caracteres.");
        if (ruta.getDescripcion() != null && ruta.getDescripcion().length() > 255)
            throw new IllegalArgumentException("La descripción admite hasta 255 caracteres.");
        if (!"Operativa".equals(ruta.getEstado()) && !"No operativa".equals(ruta.getEstado()))
            throw new IllegalArgumentException("Selecciona un estado válido.");
        if (ruta.getIdEstacionOrigen() <= 0 || ruta.getIdEstacionDestino() <= 0 || ruta.getIdEstacionOrigen() == ruta.getIdEstacionDestino())
            throw new IllegalArgumentException("Selecciona estaciones de origen y destino diferentes.");
        if (tramos.isEmpty()) throw new IllegalArgumentException("Agrega por lo menos un segmento a la ruta.");
        HashSet<Integer> segmentos = new HashSet<>();
        HashSet<Integer> estaciones = new HashSet<>();
        int estacionActual = ruta.getIdEstacionOrigen();
        estaciones.add(estacionActual);
        for (RutaSegmento tramo : tramos) {
            if (!segmentos.add(tramo.getIdSegmento()))
                throw new IllegalArgumentException("Un segmento no puede aparecer dos veces en la ruta.");
            if (tramo.getIdEstacionOrigen() == estacionActual) estacionActual = tramo.getIdEstacionDestino();
            else if (tramo.getIdEstacionDestino() == estacionActual) estacionActual = tramo.getIdEstacionOrigen();
            else throw new IllegalArgumentException("El segmento " + tramo.getCodigo() + " no conecta con el anterior. Revisa el orden desde la estación de origen.");
            if (!estaciones.add(estacionActual))
                throw new IllegalArgumentException("El recorrido no puede volver a una estación ya visitada.");
            if ("Operativa".equals(ruta.getEstado()) && !"Operativo".equals(tramo.getEstado()) && !"Degradado".equals(tramo.getEstado()))
                throw new IllegalArgumentException("La ruta debe quedar No operativa: el segmento " + tramo.getCodigo() + " está en mantenimiento o fuera de servicio.");
        }
        if (estacionActual != ruta.getIdEstacionDestino())
            throw new IllegalArgumentException("El último segmento no termina en la estación de destino seleccionada.");
    }

    private ArrayList<RutaSegmento> obtenerTramos(Connection conn, int id) throws SQLException {
        ArrayList<RutaSegmento> lista = new ArrayList<>();
        String sql = CONSULTA_SEGMENTO + "INNER JOIN ruta_segmento rs ON rs.idSegmento = s.idSegmento WHERE rs.idRuta = ? ORDER BY rs.orden";
        // La consulta base selecciona s.*; añadir explícitamente las columnas de la relación.
        sql = sql.replace("SELECT s.*", "SELECT s.*, rs.idRuta, rs.orden, rs.capacidadRuta");
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    RutaSegmento tramo = mapearSegmento(rs);
                    tramo.setIdRuta(id);
                    tramo.setOrden(rs.getInt("orden"));
                    tramo.setCapacidadRuta(rs.getBigDecimal("capacidadRuta"));
                    lista.add(tramo);
                }
            }
        }
        return lista;
    }

    private void insertarTramos(Connection conn, Ruta ruta) throws SQLException {
        String sql = "INSERT INTO ruta_segmento (idRuta, idSegmento, orden, capacidadRuta) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int orden = 1;
            for (RutaSegmento tramo : ruta.getSegmentos()) {
                pstmt.setInt(1, ruta.getIdRuta());
                pstmt.setInt(2, tramo.getIdSegmento());
                pstmt.setInt(3, orden++);
                // Igual que los datos de prueba: capacidad física del tramo, no una reserva.
                pstmt.setBigDecimal(4, tramo.getCapacidadTotal());
                pstmt.executeUpdate();
            }
        }
    }

    private void borrarTramos(Connection conn, int id) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM ruta_segmento WHERE idRuta = ?")) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        }
    }

    private void bloquearRuta(Connection conn, int id) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement("SELECT idRuta FROM ruta WHERE idRuta = ? FOR UPDATE")) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("La ruta ya no existe. Actualiza el listado.");
            }
        }
    }

    private boolean estaEnUso(Connection conn, int id) throws SQLException {
        String sql = "SELECT EXISTS(SELECT 1 FROM servicio WHERE idRuta = ?) OR EXISTS(SELECT 1 FROM solicitud WHERE idRuta = ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.setInt(2, id);
            try (ResultSet rs = pstmt.executeQuery()) { rs.next(); return rs.getBoolean(1); }
        }
    }

    private boolean cambioRecorrido(Connection conn, Ruta ruta, ArrayList<RutaSegmento> anteriores) throws SQLException {
        try (PreparedStatement pstmt = conn.prepareStatement("SELECT idEstacionOrigen, idEstacionDestino FROM ruta WHERE idRuta = ?")) {
            pstmt.setInt(1, ruta.getIdRuta());
            try (ResultSet rs = pstmt.executeQuery()) {
                rs.next();
                if (rs.getInt(1) != ruta.getIdEstacionOrigen() || rs.getInt(2) != ruta.getIdEstacionDestino()) return true;
            }
        }
        if (anteriores.size() != ruta.getSegmentos().size()) return true;
        for (int i = 0; i < anteriores.size(); i++) {
            if (anteriores.get(i).getIdSegmento() != ruta.getSegmentos().get(i).getIdSegmento()) return true;
        }
        return false;
    }

    private void asignarDatos(PreparedStatement pstmt, Ruta ruta) throws SQLException {
        pstmt.setString(1, ruta.getCodigo());
        pstmt.setString(2, ruta.getNombre());
        pstmt.setInt(3, ruta.getIdEstacionOrigen());
        pstmt.setInt(4, ruta.getIdEstacionDestino());
        pstmt.setString(5, ruta.getEstado());
        pstmt.setString(6, ruta.getDescripcion());
    }

    private Ruta mapearRuta(ResultSet rs) throws SQLException {
        Ruta ruta = new Ruta();
        ruta.setIdRuta(rs.getInt("idRuta"));
        ruta.setCodigo(rs.getString("codigo"));
        ruta.setNombre(rs.getString("nombre"));
        ruta.setIdEstacionOrigen(rs.getInt("idEstacionOrigen"));
        ruta.setIdEstacionDestino(rs.getInt("idEstacionDestino"));
        ruta.setEstado(rs.getString("estado"));
        ruta.setDescripcion(rs.getString("descripcion"));
        ruta.setNombreOrigen(rs.getString("nombreOrigen"));
        ruta.setNombreDestino(rs.getString("nombreDestino"));
        ruta.setCantidadSegmentos(rs.getInt("cantidadSegmentos"));
        ruta.setCantidadServicios(rs.getInt("cantidadServicios"));
        ruta.setCantidadSolicitudes(rs.getInt("cantidadSolicitudes"));
        return ruta;
    }

    private RutaSegmento mapearSegmento(ResultSet rs) throws SQLException {
        RutaSegmento tramo = new RutaSegmento();
        tramo.setIdSegmento(rs.getInt("idSegmento"));
        tramo.setCodigo(rs.getString("codigo"));
        tramo.setIdEstacionOrigen(rs.getInt("idEstacionOrigen"));
        tramo.setIdEstacionDestino(rs.getInt("idEstacionDestino"));
        tramo.setNombreOrigen(rs.getString("nombreOrigen"));
        tramo.setNombreDestino(rs.getString("nombreDestino"));
        tramo.setEstado(rs.getString("estado"));
        tramo.setCapacidadTotal(rs.getBigDecimal("capacidadTotal"));
        tramo.setCapacidadUtilizada(rs.getBigDecimal("capacidadUtilizada"));
        tramo.setCapacidadReservada(rs.getBigDecimal("capacidadReservada"));
        return tramo;
    }
}
