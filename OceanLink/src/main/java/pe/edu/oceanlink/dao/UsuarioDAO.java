package pe.edu.oceanlink.dao;

import pe.edu.oceanlink.bean.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UsuarioDAO extends BaseDAO {

    public void crearUsuario(Usuario u) throws SQLException, ClassNotFoundException {
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
            throw e;
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

    public void actualizarUsuario(Usuario u) throws SQLException, ClassNotFoundException {
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
                    if (pstmt.executeUpdate() != 1) {
                        throw new SQLException("El usuario ya no existe. Actualiza el listado.");
                    }
                }
            }
        } catch (SQLException e) {
            throw e;
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

    // Cuenta el total de usuarios registrados
    public int contarUsuarios() {
        int total = 0;
        try {

            try (Connection conn = getConnection();
                 java.sql.Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM usuario")) {
                if (rs.next()) total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Cuenta solo los usuarios con estado Activo
    public int contarUsuariosActivos() {
        int total = 0;
        try {

            try (Connection conn = getConnection();
                 java.sql.Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM usuario WHERE estado = 'Activo'")) {
                if (rs.next()) total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Trae los ultimos usuarios registrados (para la tabla del panel)
    public ArrayList<Usuario> obtenerUsuariosRecientes(int limite) {
        ArrayList<Usuario> lista = new ArrayList<>();
        try {

            try (Connection conn = getConnection()) {
                String sql = "SELECT u.idUsuario, u.nombre, u.apellido, u.correo, u.password, u.estado, u.idRol, r.nombre AS nombreRol " +
                        "FROM usuario u INNER JOIN rol r ON u.idRol = r.idRol ORDER BY u.idUsuario DESC LIMIT ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, limite);
                    ResultSet rs = pstmt.executeQuery();
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
                        lista.add(usuario);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
    // Compatibilidad con el formulario de perfil de Network Operator.
    public byte[] obtenerFoto(int idUsuario) throws SQLException {
        try(Connection conn=abrirConexion();PreparedStatement ps=conn.prepareStatement("SELECT foto FROM usuario WHERE idUsuario=?")){
            ps.setInt(1,idUsuario);try(ResultSet rs=ps.executeQuery()){return rs.next()?rs.getBytes("foto"):null;}
        }
    }

    public void actualizarPerfil(Usuario usuario,String claveActual,byte[] foto,boolean quitarFoto) throws SQLException {
        String nombre=usuario.getNombre()==null?"":usuario.getNombre().trim();
        String apellido=usuario.getApellido()==null?"":usuario.getApellido().trim();
        String correo=usuario.getCorreo()==null?"":usuario.getCorreo().trim();
        String nueva=usuario.getPassword()==null?"":usuario.getPassword();
        if(nombre.isEmpty()||apellido.isEmpty()||nombre.length()>50||apellido.length()>50)
            throw new IllegalArgumentException("Nombre y apellido son obligatorios y admiten hasta 50 caracteres.");
        if(correo.length()>50||!correo.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+"))throw new IllegalArgumentException("Ingresa un correo válido de hasta 50 caracteres.");
        if(nueva.length()>256||(!nueva.isEmpty()&&nueva.isBlank()))throw new IllegalArgumentException("Ingresa una nueva contraseña válida de hasta 256 caracteres.");
        if(claveActual==null||claveActual.isEmpty())throw new IllegalArgumentException("Ingresa tu contraseña actual.");
        if(foto!=null){
            if(foto.length==0||foto.length>2097152)throw new IllegalArgumentException("La foto debe ser JPG o PNG de hasta 2 MB.");
            boolean png=foto.length>=8&&foto[0]==(byte)0x89&&foto[1]==0x50&&foto[2]==0x4e&&foto[3]==0x47;
            boolean jpg=foto.length>=3&&foto[0]==(byte)0xff&&foto[1]==(byte)0xd8&&foto[2]==(byte)0xff;
            try{if((!png&&!jpg)||javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(foto))==null)throw new IllegalArgumentException("La foto debe ser una imagen JPG o PNG válida.");}
            catch(java.io.IOException e){throw new IllegalArgumentException("No se pudo leer la imagen.");}
        }
        try(Connection conn=abrirConexion()){
            conn.setAutoCommit(false);
            try{
                try(PreparedStatement ps=conn.prepareStatement("SELECT password,estado FROM usuario WHERE idUsuario=? FOR UPDATE")){
                    ps.setInt(1,usuario.getIdUsuario());try(ResultSet rs=ps.executeQuery()){
                        if(!rs.next()||!"Activo".equals(rs.getString("estado")))throw new IllegalArgumentException("El usuario no existe o está inactivo.");
                        // Se conserva el formato de contraseñas que utiliza el CRUD actual.
                        if(!java.util.Objects.equals(claveActual,rs.getString("password")))throw new IllegalArgumentException("La contraseña actual es incorrecta.");
                    }
                }
                String sql="UPDATE usuario SET nombre=?,apellido=?,correo=?"+(!nueva.isEmpty()?",password=?":"")+(quitarFoto?",foto=NULL":foto!=null?",foto=?":"")+" WHERE idUsuario=?";
                try(PreparedStatement ps=conn.prepareStatement(sql)){
                    int indice=1;ps.setString(indice++,nombre);ps.setString(indice++,apellido);ps.setString(indice++,correo);
                    if(!nueva.isEmpty())ps.setString(indice++,nueva);if(!quitarFoto&&foto!=null)ps.setBytes(indice++,foto);ps.setInt(indice,usuario.getIdUsuario());
                    if(ps.executeUpdate()!=1)throw new SQLException("No se pudo actualizar el usuario.");
                }
                conn.commit();
            }catch(SQLException|RuntimeException e){conn.rollback();throw e;}finally{conn.setAutoCommit(true);}
        }
    }

}
