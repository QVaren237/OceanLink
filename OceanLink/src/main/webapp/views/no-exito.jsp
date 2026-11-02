<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.*" %>
<%!
 private String h(Object v) { return v==null?"—":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String pill(String v) {
   if (v==null) return "pill-neutral";
   if (Arrays.asList("Crítica","Detectada","Fuera de servicio","Rechazada").contains(v)) return "pill-crit";
   if (Arrays.asList("Operativo","Servicio restaurado","Aprobada","Baja").contains(v)) return "pill-ok";
   if (Arrays.asList("Media","En mantenimiento").contains(v)) return "pill-info";
   return "Cerrada".equals(v)?"pill-neutral":"pill-warn";
 }
%>
<% String ctx=request.getContextPath(); %>
<% request.setAttribute("tituloNO","Operación completada");request.setAttribute("seccionNO","incidencias");
String tipo=request.getParameter("tipo");String titulo="Operación completada",mensaje="La operación se completó correctamente.";String destino="incidencias";
if("incidencia".equals(tipo)){titulo="Incidencia registrada";mensaje="La incidencia se registró correctamente y quedó incorporada al seguimiento operativo de la red.";}
else if("actualizacion".equals(tipo)){titulo="Estado actualizado";mensaje="El estado de la incidencia se actualizó correctamente.";}
else if("restauracion".equals(tipo)){titulo="Restauración registrada";mensaje="La restauración del servicio se registró correctamente.";}
else if("observacion".equals(tipo)){titulo="Observación registrada";mensaje="La observación quedó incorporada al seguimiento de la incidencia.";}
else if("solicitud".equals(tipo)){titulo="Solicitud enviada";mensaje="La solicitud de capacidad se registró para su evaluación.";destino="solicitudes";request.setAttribute("seccionNO",destino);}
%>
<jsp:include page="/views/no-inicio.jsp"/>
<div class="card center-state"><div class="cs-ic" style="border-color:#8dcac3;color:var(--teal)">✓</div><h2><%=h(titulo)%></h2><p><%=h(mensaje)%></p><a class="btn btn-primary" href="<%=ctx%>/NetworkOperatorServlet?action=<%=destino%>">Volver a <%=destino%></a></div>
<jsp:include page="/views/no-fin.jsp"/>
