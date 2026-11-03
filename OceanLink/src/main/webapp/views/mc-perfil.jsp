<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.sql.Timestamp,java.math.BigDecimal,pe.edu.oceanlink.bean.Mantenimiento" %>
<%!
 private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
 private String fecha(Object v){return v==null?"Sin registrar":v instanceof Timestamp?((Timestamp)v).toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")):h(v);}
 private String pill(String v){return "Finalizado".equals(v)?"pill-neutral":"En ejecución".equals(v)?"pill-ok":"pill-warn";}
 private String dato(jakarta.servlet.http.HttpServletRequest r,String n){String v=r.getParameter(n);Object b=r.getAttribute("borradorMC");if(v==null&&b instanceof Map){Object valor=((Map<?,?>)b).get(n);if(valor!=null)v=valor.toString();}return h(v);}
%>
<% String ctx=request.getContextPath(),base=ctx+"/maintenance-coordinator/mantenimientos";
if(request.getAttribute("tituloMC")==null){response.sendRedirect(base);return;}
Mantenimiento m=(Mantenimiento)request.getAttribute("mantenimiento"); %>
<jsp:include page="/views/mc-inicio.jsp"/>
<% if(request.getAttribute("errorMC")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("errorMC"))%></div><% } %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %><div class="page-head"><div><h1>Mi perfil</h1><div class="psub">Maintenance Coordinator</div></div></div><div class="card card-pad mc-formulario"><% Object cuenta=session.getAttribute("usuarioSesion");if(cuenta instanceof Usuario){Usuario u=(Usuario)cuenta; %><div class="data-list"><div class="data-label">Nombre</div><div><%=h(u.getNombre())%> <%=h(u.getApellido())%></div><div class="data-label">Correo</div><div><%=h(u.getCorreo())%></div><div class="data-label">Rol</div><div>Maintenance Coordinator</div></div><% }else{ %><p>No hay un usuario autenticado. En los formularios puedes seleccionar al coordinador responsable de la operación.</p><% } %><div class="form-actions"><a class="btn btn-outline" href="<%=base%>">Volver a Mantenimientos</a></div></div>
<jsp:include page="/views/mc-fin.jsp"/>
