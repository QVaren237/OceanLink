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
<% request.setAttribute("tituloNO","Detalle de incidencia");request.setAttribute("seccionNO","incidencias");
Incidencia incidencia=(Incidencia)request.getAttribute("incidencia");ArrayList<ObservacionIncidencia> eventos=(ArrayList<ObservacionIncidencia>)request.getAttribute("eventos");if(eventos==null)eventos=new ArrayList<>();ArrayList<String[]> servicios=(ArrayList<String[]>)request.getAttribute("serviciosAfectados");if(servicios==null)servicios=new ArrayList<>();
%>
<jsp:include page="/views/no-inicio.jsp"/>
<% if(incidencia==null){ %><div class="card center-state"><h2>Incidencia no encontrada</h2></div><% }else{ %><div class="back-row"><a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Volver</a></div>
<div class="detail-grid">
<div style="display:flex;flex-direction:column;gap:18px">
<div class="detail-card"><div class="dc-head"><div><div class="dc-sub">Información</div><h3>Datos de la incidencia</h3></div><a class="btn btn-primary btn-sm" href="<%=ctx%>/NetworkOperatorServlet?action=actualizarIncidencia&amp;id=<%=incidencia.getIdIncidencia()%>">Actualizar estado</a></div><div class="data-list"><div class="data-label">Título</div><div class="data-value"><%=h(incidencia.getTitulo())%></div><div class="data-label">Descripción</div><div><%=h(incidencia.getDescripcion())%></div><div class="data-label">Severidad</div><div><span class="pill <%=pill(incidencia.getSeveridad())%>"><span class="dot"></span><%=h(incidencia.getSeveridad())%></span></div><div class="data-label">Red afectada</div><div><%=h(incidencia.getRedes())%></div><div class="data-label">Network Operator asignado</div><div class="data-value"><%=h(request.getAttribute("responsableIncidencia"))%></div><div class="data-label">Supervisor responsable</div><div class="data-value">Sin asignación registrada</div></div></div>
<div class="detail-card"><div class="dc-head"><div><h3>Seguimiento del estado</h3></div></div><div class="state-flow"><% String[] estados={"Detectada","En análisis","Reparación programada","En reparación","Servicio restaurado","Cerrada"};int actual=Arrays.asList(estados).indexOf(incidencia.getEstado());for(int n=0;n<estados.length;n++){if(n>0){ %><div class="state-line"></div><% } %><div class="state-step <%=n<actual?"done":n==actual?"current":""%>"><div class="state-dot"><%=n<actual?"✓":String.valueOf(n+1)%></div><span><%=h(estados[n])%></span></div><% } %></div></div>
<div class="detail-card"><div class="dc-head"><div><h3>Observaciones</h3></div><a class="btn btn-outline btn-sm" href="<%=ctx%>/NetworkOperatorServlet?action=observacion&amp;id=<%=incidencia.getIdIncidencia()%>">+ Registrar observación</a></div><div class="obs-list"><% for(ObservacionIncidencia evento:eventos){ %><div class="obs-item"><div class="obs-date"><%=h(evento.getFechaRegistro())%> · <%=h(evento.getTipo())%></div><div class="obs-text"><%=h(evento.getDetalle())%></div></div><% } if(eventos.isEmpty()){ %><div class="obs-item">No hay observaciones registradas.</div><% } %></div></div>
</div>
<div style="display:flex;flex-direction:column;gap:18px">
<div class="detail-card"><div class="dc-head"><div><h3>Servicios y clientes afectados</h3></div></div><table class="mini-table"><thead><tr><th>Servicio</th><th>Cliente</th><th>Estado</th></tr></thead><tbody><% for(String[] servicio:servicios){ %><tr><td class="strong"><%=h(servicio[0])%></td><td><%=h(servicio[1])%></td><td><%=h(servicio[2])%></td></tr><% } if(servicios.isEmpty()){ %><tr><td colspan="3">No hay servicios asociados a los segmentos de esta incidencia.</td></tr><% } %></tbody></table></div>
<div class="detail-card"><div class="dc-head"><div><h3>Restauración del servicio</h3></div></div><div class="notice-soft">La restauración se registra cuando el servicio ha sido restablecido y verificado.</div><div class="action-row"><% if(Boolean.TRUE.equals(request.getAttribute("restauracionHabilitada"))){ %><a class="btn btn-primary" href="<%=ctx%>/NetworkOperatorServlet?action=restauracion&amp;id=<%=incidencia.getIdIncidencia()%>">Registrar restauración</a><% }else{ %><button class="btn btn-primary" type="button" disabled title="Se requiere finalizar los mantenimientos correctivos y registrar su resultado">Registrar restauración</button><% } %></div></div>
</div></div><% } %>
<jsp:include page="/views/no-fin.jsp"/>
