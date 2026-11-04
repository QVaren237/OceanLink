package pe.edu.oceanlink.dao;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.bean.*;
import pe.edu.oceanlink.servlet.*;
import java.lang.reflect.*;
import java.sql.SQLException;
import java.util.*;

/** Regresiones de controladores sin servidor, sin datos reales y sin dependencias adicionales. */
public class IntegracionRolesCheck {
    private static int checks;
    private static void ok(boolean valor,String mensaje){if(!valor)throw new AssertionError(mensaje);checks++;}
    private static Object vacio(Class<?> t){if(t==boolean.class)return false;if(t==int.class)return 0;if(t==long.class)return 0L;return null;}
    private static class Sesion implements InvocationHandler {
        final Map<String,Object> datos=new HashMap<>();
        final HttpSession proxy=(HttpSession)Proxy.newProxyInstance(HttpSession.class.getClassLoader(),new Class[]{HttpSession.class},this);
        public Object invoke(Object p,Method m,Object[] a){switch(m.getName()){case "getAttribute":return datos.get(a[0]);case "setAttribute":datos.put((String)a[0],a[1]);return null;case "removeAttribute":datos.remove(a[0]);return null;case "getId":return "sesion-prueba";default:return vacio(m.getReturnType());}}
    }
    private static class Peticion implements InvocationHandler {
        final Map<String,String> parametros=new HashMap<>();final Map<String,Object> atributos=new HashMap<>();final Sesion sesion;String vista;
        final HttpServletRequest proxy=(HttpServletRequest)Proxy.newProxyInstance(HttpServletRequest.class.getClassLoader(),new Class[]{HttpServletRequest.class},this);
        Peticion(Sesion s,String... pares){sesion=s;for(int i=0;i<pares.length;i+=2)parametros.put(pares[i],pares[i+1]);}
        public Object invoke(Object p,Method m,Object[] a){switch(m.getName()){
            case "getParameter":return parametros.get(a[0]);case "getSession":return sesion.proxy;
            case "setAttribute":atributos.put((String)a[0],a[1]);return null;case "getAttribute":return atributos.get(a[0]);
            case "getContextPath":return "/OceanLink";case "getServletPath":return "/maintenance-coordinator/mantenimientos";
            case "getRequestDispatcher":String destino=(String)a[0];return new RequestDispatcher(){public void forward(ServletRequest r,ServletResponse s){vista=destino;}public void include(ServletRequest r,ServletResponse s){}};
            default:return vacio(m.getReturnType());
        }}
    }
    private static class Respuesta implements InvocationHandler {
        int estado=200;String redireccion;
        final HttpServletResponse proxy=(HttpServletResponse)Proxy.newProxyInstance(HttpServletResponse.class.getClassLoader(),new Class[]{HttpServletResponse.class},this);
        public Object invoke(Object p,Method m,Object[] a){if(m.getName().equals("setStatus")||m.getName().equals("sendError"))estado=(int)a[0];if(m.getName().equals("sendRedirect"))redireccion=(String)a[0];return vacio(m.getReturnType());}
    }
    private static class Datos extends MantenimientoDAO {
        final Map<Integer,Mantenimiento> mantenimientos=new HashMap<>();boolean fallar;
        Datos(){for(int id=1;id<=3;id++){Mantenimiento m=new Mantenimiento();m.setIdMantenimiento(id);m.setCodigo("MNT-"+id);m.setEstado("Programado");mantenimientos.put(id,m);}}
        @Override public Mantenimiento obtener(int id){return mantenimientos.get(id);}
        @Override public ArrayList<String[]> listarResponsables(){ArrayList<String[]> l=new ArrayList<>();l.add(new String[]{"4","Coordinador Prueba"});return l;}
        @Override public void validarResponsable(int id){if(id!=4)throw new IllegalArgumentException("Responsable no valido");}
        @Override public void cambiarEstado(int id,String anterior,String nuevo,String motivo,int usuario)throws SQLException{
            if(fallar){fallar=false;throw new SQLException("Fallo de prueba antes de guardar");}
            if(!mantenimientos.get(id).getEstado().equals(anterior))throw new IllegalArgumentException("Estado obsoleto");mantenimientos.get(id).setEstado(nuevo);
        }
    }
    private static class Controlador extends MaintenanceCoordinatorServlet {
        void get(Peticion r,Respuesta s)throws Exception{super.doGet(r.proxy,s.proxy);}
        void post(Peticion r,Respuesta s)throws Exception{super.doPost(r.proxy,s.proxy);}
    }
    private static void inyectar(Object objeto,Class<?> clase,String nombre,Object valor)throws Exception{Field campo=clase.getDeclaredField(nombre);campo.setAccessible(true);campo.set(objeto,valor);}
    private static String preparar(Controlador c,Sesion sesion,int id)throws Exception{
        Peticion formulario=new Peticion(sesion,"action","estado","id",String.valueOf(id));c.get(formulario,new Respuesta());
        String token=(String)formulario.atributos.get("mcToken");Peticion post=new Peticion(sesion,"action","preparar","id",String.valueOf(id),"nuevoEstado","En ejecución","justificacion","Justificacion "+id,"idResponsable","4","token",token);Respuesta salida=new Respuesta();c.post(post,salida);
        ok(salida.redireccion.endsWith("?action=confirmar&id="+id),"Preparar confirmacion "+id);
        return ((Map<?,?>)sesion.datos.get("mcBorrador."+id)).get("token").toString();
    }
    private static Respuesta confirmar(Controlador c,Sesion sesion,int id,String token)throws Exception{Respuesta s=new Respuesta();c.post(new Peticion(sesion,"action","confirmar","id",String.valueOf(id),"token",token),s);return s;}
    public static void main(String[] args)throws Exception{
        Sesion sesion=new Sesion();Datos datos=new Datos();Controlador controlador=new Controlador();inyectar(controlador,MaintenanceCoordinatorServlet.class,"dao",datos);
        ServletContext contexto=(ServletContext)Proxy.newProxyInstance(ServletContext.class.getClassLoader(),new Class[]{ServletContext.class},(p,m,a)->vacio(m.getReturnType()));
        controlador.init(new ServletConfig(){public String getServletName(){return "Prueba";}public ServletContext getServletContext(){return contexto;}public String getInitParameter(String n){return null;}public Enumeration<String> getInitParameterNames(){return Collections.emptyEnumeration();}});
        String uno=preparar(controlador,sesion,1),dos=preparar(controlador,sesion,2);
        Peticion vistaUno=new Peticion(sesion,"action","confirmar","id","1");controlador.get(vistaUno,new Respuesta());
        ok(((Map<?,?>)vistaUno.atributos.get("borradorMC")).get("id").equals("1"),"La segunda pestana no reemplaza la primera");
        ok(confirmar(controlador,sesion,1,uno).redireccion.endsWith("?action=exito&id=1"),"Confirmar primera pestana");
        ok(sesion.datos.containsKey("mcBorrador.2"),"Conservar segunda confirmacion pendiente");
        ok(confirmar(controlador,sesion,2,dos).redireccion.endsWith("?action=exito&id=2"),"Confirmar segunda pestana");
        ok(datos.obtener(1).getEstado().equals("En ejecución")&&datos.obtener(2).getEstado().equals("En ejecución"),"Guardar ambos mantenimientos");
        Peticion exitoUno=new Peticion(sesion,"action","exito","id","1");controlador.get(exitoUno,new Respuesta());ok(((Map<?,?>)exitoUno.atributos.get("exitoMC")).get("id").equals("1"),"Exito de la primera pestana");
        ok(sesion.datos.containsKey("mcExito.2"),"Conservar mensaje de segunda pestana");
        Peticion exitoDos=new Peticion(sesion,"action","exito","id","2");controlador.get(exitoDos,new Respuesta());ok(((Map<?,?>)exitoDos.atributos.get("exitoMC")).get("id").equals("2"),"Exito de segunda pestana");
        ok(confirmar(controlador,sesion,1,uno).estado==400,"No repetir una confirmacion consumida");
        String tres=preparar(controlador,sesion,3);datos.fallar=true;ok(confirmar(controlador,sesion,3,tres).estado==500,"Reportar fallo de guardado");
        ok(sesion.datos.containsKey("mcBorrador.3"),"Conservar justificacion para reintento");
        ok(confirmar(controlador,sesion,3,tres).redireccion.endsWith("?action=exito&id=3"),"Reintentar sin perder borrador");
        NetworkOperatorServlet no=new NetworkOperatorServlet();final String[] estado={"En análisis"};final boolean[] listo={false};
        IncidenciaDAO incidencias=new IncidenciaDAO(){
            @Override public Incidencia obtener(int id){Incidencia i=new Incidencia();i.setIdIncidencia(id);i.setEstado(estado[0]);return i;}
            @Override public boolean puedeRestaurar(int id){return listo[0];}
            @Override public ArrayList<String[]> listarServiciosAfectados(int id){return new ArrayList<>();}
            @Override public String obtenerResponsable(int id){return "Operador Prueba";}
        };
        ObservacionIncidenciaDAO eventos=new ObservacionIncidenciaDAO(){@Override public ArrayList<ObservacionIncidencia> listarPorIncidencia(int id){return new ArrayList<>();}};
        inyectar(no,NetworkOperatorServlet.class,"incidenciaDAO",incidencias);inyectar(no,NetworkOperatorServlet.class,"eventoDAO",eventos);
        Method cargar=NetworkOperatorServlet.class.getDeclaredMethod("cargarDetalle",HttpServletRequest.class,int.class);cargar.setAccessible(true);
        Peticion detalle=new Peticion(sesion);cargar.invoke(no,detalle.proxy,1);ok(Boolean.FALSE.equals(detalle.atributos.get("restauracionHabilitada")),"Restauracion bloqueada antes de finalizar");
        listo[0]=true;cargar.invoke(no,detalle.proxy,1);ok(Boolean.TRUE.equals(detalle.atributos.get("restauracionHabilitada")),"Restauracion habilitada despues de finalizar");
        estado[0]="Cerrada";cargar.invoke(no,detalle.proxy,1);ok(Boolean.FALSE.equals(detalle.atributos.get("restauracionHabilitada")),"No restaurar incidencia cerrada");
        estado[0]="Servicio restaurado";cargar.invoke(no,detalle.proxy,1);ok(Boolean.FALSE.equals(detalle.atributos.get("restauracionHabilitada")),"No repetir restauracion");
        System.out.println(checks+" comprobaciones de integracion de controladores correctas, sin acceso a MySQL.");
    }
}
