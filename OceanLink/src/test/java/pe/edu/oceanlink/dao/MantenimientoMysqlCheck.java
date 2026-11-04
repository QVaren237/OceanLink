package pe.edu.oceanlink.dao;
import pe.edu.oceanlink.bean.Mantenimiento;
import java.sql.*;
import java.math.BigDecimal;
import java.util.*;

/** Pruebas explícitas en esquema aislado; nunca inserta datos funcionales en oceanlink. */
public class MantenimientoMysqlCheck {
 private static String db;private static int checks;
 private static final String[] TABLAS={"rol","usuario","cliente","landing_station","segmento","ruta","ruta_segmento","servicio","incidencia","incidencia_segmento","incidencia_evento","mantenimiento","mantenimiento_segmento","mantenimiento_evento"};
 private static class DAO extends MantenimientoDAO {@Override protected Connection abrirConexion()throws SQLException{Connection c=super.abrirConexion();c.setCatalog(db);return c;}}
 private static final DAO dao=new DAO();
 private static void sql(String q)throws SQLException{try(Connection c=dao.abrirConexion();Statement st=c.createStatement()){st.executeUpdate(q);}}
 private static String valor(String q)throws SQLException{try(Connection c=dao.abrirConexion();Statement st=c.createStatement();ResultSet r=st.executeQuery(q)){r.next();return r.getString(1);}}
 private static void ok(boolean b,String mensaje){if(!b)throw new AssertionError(mensaje);checks++;}
 private interface Accion{void hacer()throws Exception;}
 private static void rechaza(Accion a,String mensaje)throws Exception{try{a.hacer();throw new AssertionError(mensaje);}catch(IllegalArgumentException e){checks++;}}
 private static Mantenimiento nuevo(String tipo,Integer incidencia,Integer segmento,Integer estacion){Mantenimiento m=new Mantenimiento();m.setTipo(tipo);m.setTitulo("Intervención de prueba");m.setDescripcion("Descripción técnica");m.setIdIncidencia(incidencia);m.setIdSegmento(segmento);m.setIdLandingStation(estacion);m.setFechaInicio(Timestamp.valueOf(java.time.LocalDateTime.now(java.time.ZoneId.of("America/Lima")).plusDays(1)));m.setDuracionEstimada(new BigDecimal("4"));return m;}
 private static void fixtures()throws SQLException{
  sql("INSERT INTO rol(idRol,nombre) VALUES(1,'Administrador'),(3,'Network Operator'),(4,'Maintenance Coordinator')");
  sql("INSERT INTO usuario(idUsuario,nombre,apellido,correo,password,estado,idRol) VALUES(3,'Operador','Prueba','no@test.local','x','Activo',3),(4,'Coordinador','Prueba','mc@test.local','x','Activo',4),(5,'Inactivo','Prueba','off@test.local','x','Inactivo',4)");
  sql("INSERT INTO cliente(idCliente,razonSocial,ruc,estado) VALUES(1,'Cliente Prueba','20000000001','Activo')");
  sql("INSERT INTO landing_station(idLandingStation,codigo,nombre,ubicacion,estado) VALUES(1,'LS-1','Uno','Perú','Operativa'),(2,'LS-2','Dos','Perú','Operativa'),(3,'LS-3','Tres','Perú','Operativa')");
  sql("INSERT INTO segmento(idSegmento,codigo,idEstacionOrigen,idEstacionDestino,capacidadTotal,capacidadUtilizada,capacidadReservada,estado) VALUES(1,'SEG-1',1,2,100,20,10,'Operativo'),(2,'SEG-2',2,3,100,30,10,'Operativo'),(3,'SEG-3',1,3,100,10,10,'Fuera de servicio')");
  sql("INSERT INTO ruta(idRuta,codigo,nombre,idEstacionOrigen,idEstacionDestino,estado) VALUES(1,'R-1','Uno-Tres',1,3,'Operativa')");
  sql("INSERT INTO ruta_segmento(idRuta,idSegmento,orden) VALUES(1,1,1),(1,2,2)");
  sql("INSERT INTO servicio(idServicio,codigo,idCliente,idRuta,origen,destino,capacidadContratada,fechaActivacion,estado) VALUES(1,'SRV-1',1,1,'Uno','Tres',25,CURDATE(),'Activo'),(2,'SRV-2',1,1,'Uno','Tres',NULL,CURDATE(),'Cancelado')");
  sql("INSERT INTO incidencia(idIncidencia,codigo,titulo,estado,idUsuario,fechaDeteccion) VALUES(1,'INC-1','Incidencia uno','En análisis',3,NOW()),(2,'INC-2','Incidencia dos','En análisis',3,NOW()),(3,'INC-3','Cerrada','Cerrada',3,NOW())");
  sql("INSERT INTO incidencia_segmento(idIncidencia,idSegmento) VALUES(1,1),(2,2),(3,1)");
 }
 public static void main(String[] args)throws Exception{
  if(args.length!=1||!"--mysql-aislado".equals(args[0])){System.out.println("Usar --mysql-aislado.");return;}
  db="oceanlink_mc_check_"+Long.toUnsignedString(System.nanoTime());
  try(Connection admin=new MantenimientoDAO().abrirConexion();Statement st=admin.createStatement()){
   String origen=admin.getCatalog();st.executeUpdate("CREATE DATABASE `"+db+"` CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci");
   try{
    for(String t:TABLAS)st.executeUpdate("CREATE TABLE `"+db+"`.`"+t+"` LIKE `"+origen+"`.`"+t+"`");fixtures();
    rechaza(()->dao.crear(nuevo("Correctivo",null,1,null),4),"Correctivo requiere incidencia");
    rechaza(()->dao.crear(nuevo("Preventivo",1,1,null),4),"Preventivo no recibe incidencia");
    rechaza(()->dao.crear(nuevo("Correctivo",3,1,null),4),"Incidencia cerrada");
    rechaza(()->dao.crear(nuevo("Correctivo",1,2,null),4),"Segmento ajeno a la incidencia");
    rechaza(()->dao.crear(nuevo("Correctivo",2,null,1),4),"Estacion ajena a la incidencia");
    rechaza(()->dao.crear(nuevo("Preventivo",null,999,null),4),"Infraestructura inexistente");
    rechaza(()->dao.crear(nuevo("Preventivo",null,1,2),4),"Infraestructura ambigua");
    rechaza(()->dao.crear(nuevo("Preventivo",null,1,null),3),"Rol incorrecto");
    rechaza(()->dao.crear(nuevo("Preventivo",null,1,null),5),"Responsable inactivo");
    Mantenimiento invalido=nuevo("Preventivo",null,1,null);invalido.setTitulo(" ");rechaza(()->dao.crear(invalido,4),"Titulo obligatorio");
    invalido.setTitulo("Prueba");invalido.setFechaInicio(Timestamp.valueOf(java.time.LocalDateTime.now().minusDays(1)));rechaza(()->dao.crear(invalido,4),"Inicio pasado");
    invalido.setFechaInicio(Timestamp.valueOf(java.time.LocalDateTime.now().plusDays(1)));invalido.setDuracionEstimada(BigDecimal.ZERO);rechaza(()->dao.crear(invalido,4),"Duracion positiva");
    ok("0".equals(valor("SELECT COUNT(*) FROM mantenimiento")),"No crear registros invalidos");
    int id=dao.crear(nuevo("Correctivo",1,1,null),4);Mantenimiento m=dao.obtener(id);
    ok("Programado".equals(m.getEstado()),"Estado inicial");ok(m.getTitulo().equals("Intervención de prueba"),"Titulo persistido");
    ok(dao.serviciosAfectados(id).size()==1,"Servicio afectado sin cancelados");ok(dao.bitacora(id).size()==1,"Evento de registro");
    ok("1".equals(valor("SELECT COUNT(*) FROM mantenimiento_segmento WHERE idMantenimiento="+id)),"Relacion segmento");
    ok(!dao.puedeRestaurar(1),"Restauracion bloqueada antes de finalizar");
    dao.agregarActividad(id,"Repuestos verificados",4);ok(dao.bitacora(id).size()==2,"Actividad conserva historial");
    rechaza(()->dao.agregarActividad(id," ",4),"Actividad vacia");
    rechaza(()->dao.finalizar(id,"Resultado",4),"No finalizar programado");
    rechaza(()->dao.cambiarEstado(id,"Programado","Finalizado","Atajo",4),"No saltar finalizacion");
    rechaza(()->dao.cambiarEstado(id,"Programado","En ejecución"," ",4),"Justificacion obligatoria");
    dao.cambiarEstado(id,"Programado","En ejecución","Inicio de trabajos",4);
    ok("En ejecución".equals(dao.obtener(id).getEstado()),"Estado En ejecución");
    int antes=dao.bitacora(id).size();rechaza(()->dao.cambiarEstado(id,"Programado","Suspendido","Confirmacion obsoleta",4),"Control de concurrencia");ok(dao.bitacora(id).size()==antes,"Sin eventos por confirmacion obsoleta");
    dao.cambiarEstado(id,"En ejecución","Suspendido","Pausa por clima",4);rechaza(()->dao.finalizar(id,"Resultado",4),"No finalizar suspendido");
    dao.cambiarEstado(id,"Suspendido","En ejecución","Reinicio",4);
    rechaza(()->dao.finalizar(id," ",4),"Resultado obligatorio");
    IncidenciaDAO incidencias=new IncidenciaDAO(){@Override protected Connection abrirConexion()throws SQLException{return dao.abrirConexion();}};
    rechaza(()->incidencias.actualizarEstado(1,"Servicio restaurado","Intento prematuro"),"Guardia de backend en NO");
    rechaza(()->incidencias.actualizarEstado(1,"Cerrada","Saltar mantenimiento"),"No cerrar sin restauracion");
    rechaza(()->incidencias.actualizarEstado(1,"Estado inventado","Parametro manipulado"),"Estado de incidencia validado en backend");
    dao.finalizar(id,"Equipo reparado y probado",4);m=dao.obtener(id);ok(m.isFinalizado()&&m.getFechaFin()!=null,"Finalizacion con fecha real");ok("Equipo reparado y probado".equals(m.getResultado()),"Resultado almacenado");
    ok("En análisis".equals(valor("SELECT estado FROM incidencia WHERE idIncidencia=1")),"Finalizar no restaura automaticamente");
    ok(dao.puedeRestaurar(1),"Restauracion habilitada");
    rechaza(()->dao.agregarActividad(id,"Modificar pasado",4),"Bitacora finalizada inmutable");
    rechaza(()->dao.finalizar(id,"Segundo cierre",4),"No finalizar dos veces");
    rechaza(()->dao.cambiarEstado(id,"Finalizado","En ejecución","Reabrir",4),"No reabrir finalizado");
    ok(dao.listar(true).size()==1&&dao.listar(false).isEmpty(),"Historial separado");
    ok("100.00".equals(valor("SELECT capacidadTotal FROM segmento WHERE idSegmento=1")),"Sin alterar capacidad");
    sql("INSERT INTO incidencia_segmento(idIncidencia,idSegmento) VALUES(1,2)");ok(!dao.puedeRestaurar(1),"Debe repararse toda la infraestructura");
    int segundo=dao.crear(nuevo("Correctivo",1,2,null),4);dao.cambiarEstado(segundo,"Programado","En ejecución","Inicio",4);dao.finalizar(segundo,"Segundo segmento reparado",4);ok(dao.puedeRestaurar(1),"Todos los segmentos cubiertos");
    incidencias.actualizarEstado(1,"Servicio restaurado","Verificado por NO");ok("Servicio restaurado".equals(valor("SELECT estado FROM incidencia WHERE idIncidencia=1")),"NO restaura despues de finalizar");

    incidencias.actualizarEstado(1,"Cerrada","Verificacion completada");
    ok("Cerrada".equals(valor("SELECT estado FROM incidencia WHERE idIncidencia=1")),"Cierre despues de restaurar");
    ok(valor("SELECT fechaCierre FROM incidencia WHERE idIncidencia=1")!=null,"Fecha de cierre registrada");
    rechaza(()->incidencias.actualizarEstado(1,"En análisis","Reabrir cerrada"),"Cerrada es terminal");
    UsuarioDAO perfiles=new UsuarioDAO(){@Override protected Connection abrirConexion()throws SQLException{return dao.abrirConexion();}};
    pe.edu.oceanlink.bean.Usuario perfil=new pe.edu.oceanlink.bean.Usuario();perfil.setIdUsuario(3);perfil.setNombre("Operador Actualizado");perfil.setApellido("Prueba");perfil.setCorreo("no@test.local");perfil.setPassword("");
    rechaza(()->perfiles.actualizarPerfil(perfil,"incorrecta",null,false),"Comprobar contraseña actual");
    ok("Operador".equals(valor("SELECT nombre FROM usuario WHERE idUsuario=3")),"Perfil no cambia con contraseña incorrecta");
    perfiles.actualizarPerfil(perfil,"x",null,false);
    ok("Operador Actualizado".equals(valor("SELECT nombre FROM usuario WHERE idUsuario=3")),"Datos del perfil guardados");
    ok("x".equals(valor("SELECT password FROM usuario WHERE idUsuario=3")),"Conservar contraseña si no se cambia");
    java.io.ByteArrayOutputStream imagen=new java.io.ByteArrayOutputStream();javax.imageio.ImageIO.write(new java.awt.image.BufferedImage(1,1,java.awt.image.BufferedImage.TYPE_INT_RGB),"png",imagen);byte[] png=imagen.toByteArray();
    perfiles.actualizarPerfil(perfil,"x",png,false);ok(java.util.Arrays.equals(png,perfiles.obtenerFoto(3)),"Guardar y obtener foto PNG");
    perfiles.actualizarPerfil(perfil,"x",null,false);ok(java.util.Arrays.equals(png,perfiles.obtenerFoto(3)),"Conservar foto al modificar datos");
    rechaza(()->perfiles.actualizarPerfil(perfil,"x",new byte[]{1,2,3},false),"Rechazar archivo que no es imagen");
    perfil.setCorreo("mc@test.local");perfil.setNombre("No debe guardarse");
    try{perfiles.actualizarPerfil(perfil,"x",null,false);throw new AssertionError("Correo duplicado");}catch(SQLException e){ok(e.getErrorCode()==1062,"Correo duplicado reportado");}
    ok("Operador Actualizado".equals(valor("SELECT nombre FROM usuario WHERE idUsuario=3")),"Rollback completo al duplicar correo");
    perfil.setCorreo("no@test.local");perfil.setNombre("Operador Actualizado");perfil.setPassword("claveNuevaPrueba");
    perfiles.actualizarPerfil(perfil,"x",null,true);ok(perfiles.obtenerFoto(3)==null,"Quitar foto");
    ok("claveNuevaPrueba".equals(valor("SELECT password FROM usuario WHERE idUsuario=3")),"Cambiar contraseña del usuario de prueba");
    ok("3".equals(valor("SELECT idRol FROM usuario WHERE idUsuario=3"))&&"Activo".equals(valor("SELECT estado FROM usuario WHERE idUsuario=3")),"Perfil conserva rol y estado");
    rechaza(()->perfiles.actualizarPerfil(perfil,"x",null,false),"Contraseña anterior ya no autoriza cambios");
    int estacion=dao.crear(nuevo("Preventivo",null,null,2),4);ok("2".equals(valor("SELECT COUNT(*) FROM mantenimiento_segmento WHERE idMantenimiento="+estacion)),"Derivar segmentos de estacion");ok(dao.serviciosAfectados(estacion).size()==1,"No duplicar servicio en estacion");
    System.out.println(checks+" comprobaciones de Maintenance Coordinator correctas.");
   }finally{if(!db.matches("oceanlink_mc_check_[0-9]+"))throw new Exception("Nombre de prueba no valido");st.executeUpdate("DROP DATABASE `"+db+"`");System.out.println("Base temporal eliminada; sin datos de prueba en oceanlink.");}
  }
 }
}
