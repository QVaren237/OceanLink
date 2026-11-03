package pe.edu.oceanlink.dao;

import java.sql.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.concurrent.*;

/** Ejecutar con --mysql-aislado. Crea y elimina un esquema temporal; no escribe datos en oceanlink. */
public class CapacidadReservaMysqlCheck {
    private static String esquema;
    private static int verificaciones;
    private static class DAO extends CapacidadDAO {
        @Override protected Connection abrirConexion() throws SQLException {
            Connection conn=super.abrirConexion();conn.setCatalog(esquema);return conn;
        }
    }
    private static final DAO dao=new DAO();
    private static void sql(String texto)throws SQLException{
        try(Connection c=dao.abrirConexion();Statement s=c.createStatement()){s.executeUpdate(texto);}
    }
    private static String valor(String texto)throws SQLException{
        try(Connection c=dao.abrirConexion();Statement s=c.createStatement();ResultSet r=s.executeQuery(texto)){
            r.next();return r.getString(1);
        }
    }
    private static void comprobar(boolean condicion,String mensaje){if(!condicion)throw new AssertionError(mensaje);verificaciones++;}
    private interface Accion {void ejecutar()throws Exception;}
    private static void rechaza(Accion accion,String mensaje)throws Exception{
        try{accion.ejecutar();throw new AssertionError(mensaje);}catch(IllegalArgumentException esperado){verificaciones++;}
    }
    private static void reservar(int servicio,List<Integer> segmentos,String cantidad,Integer solicitud,int actor)throws Exception{
        dao.reservar(servicio,segmentos,new BigDecimal(cantidad),solicitud,actor);
    }
    private static void preparar()throws SQLException{
        for(String t:new String[]{"ampliacion_capacidad","historial_capacidad","reserva_capacidad","ruta_segmento","solicitud","servicio","ruta","segmento","landing_station","cliente","usuario","rol"})sql("TRUNCATE TABLE "+t);
        sql("INSERT INTO rol(idRol,nombre) VALUES(1,'Capacity Planner'),(2,'Network Operator')");
        sql("INSERT INTO usuario(idUsuario,nombre,apellido,correo,password,estado,idRol) VALUES(1,'Planner','Prueba','planner@test.local','clave','Activo',1),(2,'Operador','Prueba','operador@test.local','clave','Activo',2)");
        sql("INSERT INTO cliente(idCliente,razonSocial,ruc,estado) VALUES(1,'Cliente Uno','20000000001','Activo'),(2,'Cliente Dos','20000000002','Activo')");
        sql("INSERT INTO landing_station(idLandingStation,codigo,nombre,ubicacion,estado) VALUES(1,'LS-1','Uno','Peru','Operativo'),(2,'LS-2','Dos','Peru','Operativo'),(3,'LS-3','Tres','Peru','Operativo')");
        sql("INSERT INTO segmento(idSegmento,codigo,idEstacionOrigen,idEstacionDestino,capacidadTotal,capacidadUtilizada,capacidadReservada,estado) VALUES(1,'SEG-1',1,2,100,10,20,'Operativo'),(2,'SEG-2',2,3,100,10,20,'Operativo'),(3,'SEG-3',1,3,100,10,20,'Operativo')");
        sql("INSERT INTO ruta(idRuta,codigo,nombre,idEstacionOrigen,idEstacionDestino,estado) VALUES(1,'R-1','Uno-Dos-Tres',1,3,'Operativa'),(2,'R-2','Uno-Tres',1,3,'Operativa')");
        sql("INSERT INTO ruta_segmento(idRuta,idSegmento,orden,capacidadRuta) VALUES(1,1,1,100),(1,2,2,100),(2,3,1,100)");
        sql("INSERT INTO servicio(idServicio,codigo,idCliente,idRuta,origen,destino,capacidadContratada,fechaActivacion,estado) VALUES(1,'S-1',1,1,'Uno','Tres',NULL,CURDATE(),'Activo'),(2,'S-2',1,1,'Uno','Tres',NULL,CURDATE(),'Activo'),(3,'S-3',2,1,'Uno','Tres',NULL,CURDATE(),'Activo'),(4,'S-4',1,2,'Uno','Tres',NULL,CURDATE(),'Activo'),(5,'S-5',1,1,'Uno','Tres',NULL,CURDATE(),'Cancelado')");
        sql("INSERT INTO solicitud(idSolicitud,codigo,idCliente,idRuta,capacidadSolicitada,estado,observacion,idUsuario) VALUES(1,'SOL-1',1,1,25,'Registrada','Observacion original',2),(2,'SOL-2',1,1,50,'Registrada','Original',2),(3,'SOL-3',1,1,25,'Registrada','Original',2)");
    }
    public static void main(String[] args)throws Exception{
        if(args.length!=1||!"--mysql-aislado".equals(args[0])){System.out.println("Usar --mysql-aislado para probar en un esquema temporal.");return;}
        esquema="oceanlink_reservas_check_"+Long.toUnsignedString(System.nanoTime());
        try(Connection admin=new CapacidadDAO().abrirConexion();Statement st=admin.createStatement()){
            String original=admin.getCatalog();
            st.executeUpdate("CREATE DATABASE `"+esquema+"` CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci");
            try{
                for(String t:new String[]{"rol","usuario","cliente","landing_station","segmento","ruta","servicio","solicitud","ruta_segmento","reserva_capacidad","historial_capacidad","ampliacion_capacidad"})
                    st.executeUpdate("CREATE TABLE `"+esquema+"`.`"+t+"` LIKE `"+original+"`.`"+t+"`");
                preparar();
                SolicitudCapacidadDAO solicitudes=new SolicitudCapacidadDAO(){
                    @Override protected Connection abrirConexion() throws SQLException{return dao.abrirConexion();}
                };
                pe.edu.oceanlink.bean.SolicitudCapacidad nueva=new pe.edu.oceanlink.bean.SolicitudCapacidad();
                nueva.setCodigo("SOL-INCREMENTO");nueva.setIdCliente(1);nueva.setIdRuta(1);nueva.setIdUsuario(2);nueva.setCapacidadSolicitada(10);
                nueva.setMotivo("Incremento de capacidad");
                rechaza(()->solicitudes.crear(nueva),"Incremento sin servicio");
                nueva.setMotivo(" Incremento por capacidad ");
                rechaza(()->solicitudes.crear(nueva),"Alias de incremento sin servicio");
                nueva.setIdServicio(3);rechaza(()->solicitudes.crear(nueva),"Servicio de otro cliente");
                nueva.setIdServicio(4);rechaza(()->solicitudes.crear(nueva),"Servicio de otra ruta");
                nueva.setIdServicio(5);rechaza(()->solicitudes.crear(nueva),"Servicio cancelado para incremento");
                nueva.setIdServicio(999);rechaza(()->solicitudes.crear(nueva),"Servicio inexistente");
                comprobar("3".equals(valor("SELECT COUNT(*) FROM solicitud")),"No insertar solicitudes invalidas");
                nueva.setIdServicio(1);solicitudes.crear(nueva);
                comprobar("1".equals(valor("SELECT idServicio FROM solicitud WHERE codigo='SOL-INCREMENTO'")),"Guardar servicio asociado");
                nueva.setCodigo("SOL-NUEVO");nueva.setIdServicio(null);nueva.setMotivo("Capacidad para nuevo servicio");solicitudes.crear(nueva);
                comprobar("1".equals(valor("SELECT COUNT(*) FROM solicitud WHERE codigo='SOL-NUEVO' AND idServicio IS NULL")),"Otros motivos sin servicio");
                sql("UPDATE solicitud SET estado='Aprobada' WHERE codigo='SOL-INCREMENTO'");
                int solicitudIncremento=Integer.parseInt(valor("SELECT idSolicitud FROM solicitud WHERE codigo='SOL-INCREMENTO'"));
                comprobar(dao.serviciosReservables(1,solicitudIncremento).size()==1,"Solo listar servicio de la solicitud");
                rechaza(()->reservar(2,Arrays.asList(1,2),"10",solicitudIncremento,1),"No cambiar servicio al reservar incremento");
                preparar();
                sql("UPDATE segmento SET capacidadUtilizada=70,capacidadReservada=20 WHERE idSegmento=1");
                java.sql.Date limite=java.sql.Date.valueOf(java.time.LocalDate.now().plusDays(1));
                rechaza(()->dao.planificarAmpliacion(1,new BigDecimal("100"),limite,"Plan",1),"Ampliacion debe aumentar capacidad");
                rechaza(()->dao.planificarAmpliacion(1,new BigDecimal("200"),null,"Plan",1),"Fecha requerida");
                rechaza(()->dao.planificarAmpliacion(1,new BigDecimal("200"),java.sql.Date.valueOf(java.time.LocalDate.now().minusDays(1)),"Plan",1),"Fecha pasada");
                rechaza(()->dao.planificarAmpliacion(1,new BigDecimal("200"),limite,"   ",1),"Justificacion requerida");
                rechaza(()->dao.planificarAmpliacion(1,new BigDecimal("200"),limite,"Plan",2),"Operador no planifica");
                rechaza(()->dao.planificarAmpliacion(2,new BigDecimal("200"),limite,"Plan",1),"Segmento sin alerta");
                String ticket=dao.planificarAmpliacion(1,new BigDecimal("200"),limite,"Justificacion de prueba",1);
                comprobar(ticket.startsWith("AMP-"),"Codigo de planificacion");
                comprobar("1".equals(valor("SELECT COUNT(*) FROM ampliacion_capacidad WHERE capacidadActual=100 AND capacidadNueva=200 AND estado='Registrada'")),"Persistir ampliacion");
                comprobar("100.00".equals(valor("SELECT capacidadTotal FROM segmento WHERE idSegmento=1")),"Planificar no amplia capacidad fisica");
                comprobar("20.00".equals(valor("SELECT capacidadReservada FROM segmento WHERE idSegmento=1")),"Planificar no reserva");
                comprobar("3".equals(valor("SELECT COUNT(*) FROM solicitud")),"Planificar no crea solicitud de NO");
                comprobar(dao.listarAlertas().size()==1,"Listar alertas reales");
                preparar();
                sql("INSERT INTO historial_capacidad(idSegmento,fechaRegistro,capacidadTotal,capacidadUtilizada,capacidadReservada) VALUES(1,'2025-01-01',100,20,10),(1,'2025-02-01',100,40,10),(1,'2025-02-15',200,60,20),(2,'2025-02-15',100,99,0),(1,'2025-03-01',100,80,10)");
                java.util.ArrayList<pe.edu.oceanlink.bean.HistoricoCapacidad> meses=dao.consultarHistorico(1,java.sql.Date.valueOf("2025-01-01"),java.sql.Date.valueOf("2025-03-01"));
                comprobar(meses.size()==2,"Filtro de segmento y limites de fechas");
                comprobar(meses.get(1).getPromedio().compareTo(new BigDecimal("50"))==0,"Promedio mensual real");
                comprobar(meses.get(1).getPico().compareTo(new BigDecimal("60"))==0,"Pico mensual real");
                comprobar(meses.get(1).getCapacidadInstalada().compareTo(new BigDecimal("200"))==0,"Ultima capacidad instalada del mes");
                comprobar(meses.get(1).getUtilizacionMaxima().compareTo(new BigDecimal("50"))==0,"Utilizacion calcula cada muestra e incluye reservas");
                comprobar(meses.get(1).getTendencia().compareTo(new BigDecimal("20"))==0,"Tendencia en puntos porcentuales");
                comprobar(pe.edu.oceanlink.bean.HistoricoCapacidad.crecimiento(meses.get(0).getPromedio(),meses.get(1).getPromedio()).compareTo(new BigDecimal("150"))==0,"Crecimiento relativo del promedio");
                comprobar(dao.consultarHistorico(1,java.sql.Date.valueOf("2024-01-01"),java.sql.Date.valueOf("2024-03-01")).isEmpty(),"Historico sin datos no inventa muestras");
                pe.edu.oceanlink.bean.CapacidadEnlace umbral=new pe.edu.oceanlink.bean.CapacidadEnlace();umbral.setCapacidadTotal(new BigDecimal("100"));umbral.setCapacidadReservada(BigDecimal.ZERO);
                umbral.setCapacidadUtilizada(new BigDecimal("84.99"));comprobar(!umbral.isAlertaSaturacion(),"Menor al 85 sin alerta");
                umbral.setCapacidadUtilizada(new BigDecimal("85"));comprobar(umbral.isAlertaSaturacion()&&!umbral.isAlertaCritica(),"85 preventivo");
                umbral.setCapacidadUtilizada(new BigDecimal("95"));comprobar(!umbral.isAlertaCritica(),"95 preventivo");
                umbral.setCapacidadUtilizada(new BigDecimal("95.01"));comprobar(umbral.isAlertaCritica(),"Mayor al 95 critico");
                umbral.setCapacidadTotal(BigDecimal.ZERO);comprobar(!umbral.isAlertaSaturacion(),"Sin dividir entre cero");
                preparar();reservar(1,Arrays.asList(1),"10",null,1);
                comprobar("1".equals(valor("SELECT COUNT(*) FROM reserva_capacidad WHERE idSolicitud IS NULL")),"Reserva directa con NULL");
                comprobar("30.00".equals(valor("SELECT capacidadReservada FROM segmento WHERE idSegmento=1")),"Incremento reservado");
                comprobar("10.00".equals(valor("SELECT capacidadUtilizada FROM segmento WHERE idSegmento=1")),"No alterar utilizada");
                comprobar("Registrada".equals(valor("SELECT estado FROM solicitud WHERE idSolicitud=1")),"Reserva directa no toca solicitudes");
                comprobar("1".equals(valor("SELECT COUNT(*) FROM historial_capacidad")),"Historial en misma transaccion");
                preparar();reservar(1,Arrays.asList(2,1),"15",null,1);
                comprobar("2".equals(valor("SELECT COUNT(*) FROM reserva_capacidad")),"Reserva multisegmento");
                comprobar("2".equals(valor("SELECT COUNT(*) FROM segmento WHERE capacidadReservada=35")),"Mismo incremento por segmento");
                preparar();rechaza(()->reservar(1,Arrays.asList(1),"85",null,1),"Exceso de disponibilidad");
                comprobar("0".equals(valor("SELECT COUNT(*) FROM reserva_capacidad")),"No guardar exceso");
                preparar();sql("UPDATE segmento SET estado='Fuera de servicio' WHERE idSegmento=2");
                rechaza(()->reservar(1,Arrays.asList(1,2),"10",null,1),"Fallo segundo segmento");
                comprobar("20.00".equals(valor("SELECT capacidadReservada FROM segmento WHERE idSegmento=1")),"Rollback primer segmento");
                comprobar("0".equals(valor("SELECT COUNT(*) FROM reserva_capacidad")),"Rollback inserciones");
                comprobar("0".equals(valor("SELECT COUNT(*) FROM historial_capacidad")),"Rollback historial");
                preparar();rechaza(()->reservar(1,Arrays.asList(3),"10",null,1),"Segmento ajeno");
                rechaza(()->reservar(1,Arrays.asList(1,1),"10",null,1),"Segmentos repetidos");
                for(String cantidad:new String[]{"0","-1","1.001","NaN","99999999999"})rechaza(()->CapacidadDAO.validarCantidad(cantidad),"Cantidad invalida");
                rechaza(()->reservar(1,Arrays.asList(1),"10",null,2),"Operador no puede reservar");
                rechaza(()->reservar(5,Arrays.asList(1),"10",null,1),"Servicio cancelado");
                sql("UPDATE cliente SET estado='Inactivo' WHERE idCliente=1");rechaza(()->reservar(1,Arrays.asList(1),"10",null,1),"Cliente inactivo");
                preparar();sql("UPDATE ruta SET estado='No operativa' WHERE idRuta=1");rechaza(()->reservar(1,Arrays.asList(1),"10",null,1),"Ruta no operativa");
                preparar();sql("UPDATE segmento SET capacidadReservada=NULL WHERE idSegmento=1");rechaza(()->reservar(1,Arrays.asList(1),"10",null,1),"Capacidad desconocida");
                preparar();dao.evaluarSolicitud(1,"Aprobada","Factible",1);
                comprobar("Aprobada".equals(valor("SELECT estado FROM solicitud WHERE idSolicitud=1")),"Aprobacion");
                comprobar("0".equals(valor("SELECT COUNT(*) FROM reserva_capacidad")),"Aprobar no reserva");
                comprobar("20.00".equals(valor("SELECT capacidadReservada FROM segmento WHERE idSegmento=1")),"Aprobar no modifica capacidad");
                comprobar("Observacion original".equals(valor("SELECT observacion FROM solicitud WHERE idSolicitud=1")),"Conservar observacion de NO");
                comprobar("1".equals(valor("SELECT idEvaluador FROM solicitud WHERE idSolicitud=1")),"Evaluador registrado");
                comprobar("Factible".equals(valor("SELECT comentarioEvaluacion FROM solicitud WHERE idSolicitud=1")),"Comentario de evaluacion");
                rechaza(()->dao.evaluarSolicitud(1,"Rechazada","Cambio",1),"No reevaluar estado final");
                preparar();rechaza(()->dao.evaluarSolicitud(1,"Rechazada","",1),"Motivo obligatorio al rechazar");dao.evaluarSolicitud(1,"Rechazada","No factible",1);
                comprobar("Rechazada".equals(valor("SELECT estado FROM solicitud WHERE idSolicitud=1")),"Rechazo");
                preparar();rechaza(()->reservar(1,Arrays.asList(1,2),"25",1,1),"Solicitud sin aprobar");dao.evaluarSolicitud(1,"Aprobada","",1);
                rechaza(()->reservar(1,Arrays.asList(1,2),"20",1,1),"Cantidad no coincide");
                rechaza(()->reservar(1,Arrays.asList(1),"25",1,1),"Reserva vinculada parcial");
                rechaza(()->reservar(3,Arrays.asList(1,2),"25",1,1),"Cliente distinto");
                reservar(1,Arrays.asList(1,2),"25",1,1);
                comprobar("2".equals(valor("SELECT COUNT(*) FROM reserva_capacidad WHERE idSolicitud=1")),"Solicitud vinculada en cada reserva");
                comprobar("Reservada".equals(valor("SELECT estado FROM solicitud WHERE idSolicitud=1")),"Estado reservado");
                rechaza(()->reservar(1,Arrays.asList(1,2),"25",1,1),"No repetir reserva de solicitud");
                preparar();sql("UPDATE ruta SET estado='No operativa' WHERE idRuta=1");dao.evaluarSolicitud(1,"Rechazada","Ruta no operativa",1);
                comprobar("Rechazada".equals(valor("SELECT estado FROM solicitud WHERE idSolicitud=1")),"Rechazar ruta no operativa");
                preparar();sql("UPDATE segmento SET capacidadReservada=80 WHERE idSegmento=2");rechaza(()->dao.evaluarSolicitud(1,"Aprobada","",1),"Sin factibilidad");
                preparar();sql("DELETE FROM solicitud");reservar(1,Arrays.asList(1),"10",null,1);
                comprobar("1".equals(valor("SELECT COUNT(*) FROM reserva_capacidad")),"Reservar sin solicitudes en el sistema");
                preparar();ExecutorService pool=Executors.newFixedThreadPool(2);CountDownLatch inicio=new CountDownLatch(1);
                try{
                    ArrayList<Future<Boolean>> resultados=new ArrayList<>();
                    for(int servicio:new int[]{1,2})resultados.add(pool.submit(()->{inicio.await();try{reservar(servicio,Arrays.asList(1),"50",null,1);return true;}catch(IllegalArgumentException esperado){return false;}}));
                    inicio.countDown();int exitos=0;for(Future<Boolean> r:resultados)if(r.get(15,TimeUnit.SECONDS))exitos++;
                    comprobar(exitos==1,"Concurrencia sin sobreasignar");
                    comprobar("70.00".equals(valor("SELECT capacidadReservada FROM segmento WHERE idSegmento=1")),"Saldo concurrente correcto");
                }finally{pool.shutdownNow();}
                System.out.println(verificaciones+" comprobaciones MySQL correctas en un esquema aislado.");
            }finally{
                if(!esquema.startsWith("oceanlink_reservas_check_"))throw new IllegalStateException("Esquema inesperado");
                st.executeUpdate("DROP DATABASE `"+esquema+"`");System.out.println("Esquema temporal eliminado.");
            }
        }
    }
}