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
<% if(m!=null){ %>
<div class="back-row"><a href="<%=base%>" class="btn btn-outline">Volver</a></div>
<div class="page-head"><div><h1><%=h(m.getCodigo())%>: <%=h(m.getTitulo())%></h1></div><div class="grow"></div>
<% if(!m.isFinalizado()){ %><a class="btn btn-outline" href="<%=base%>?action=estado&amp;id=<%=m.getIdMantenimiento()%>">Modificar Estado</a><% if("En ejecución".equals(m.getEstado())){ %><a class="btn btn-primary" href="<%=base%>?action=finalizar&amp;id=<%=m.getIdMantenimiento()%>">Registrar Finalización</a><% }else{ %><button class="btn btn-primary" disabled title="Primero cambia el mantenimiento a En ejecución">Registrar Finalización</button><% } } %></div>
<% if(request.getAttribute("mensajeMC")!=null){ %><div class="info-strip" role="status"><%=h(request.getAttribute("mensajeMC"))%></div><% } %>
<div class="info-strip mc-info"><div class="ii">!</div><div><div class="it">Mantenimiento <%=h(m.getTipo())%><%=m.getIncidenciaCodigo()==null?"":" — Origen: "+h(m.getIncidenciaCodigo())%></div><div class="id"><%=m.getIncidenciaCodigo()==null?"Intervención preventiva programada sobre la infraestructura seleccionada.":"Esta intervención física está diseñada para resolver la incidencia reportada por el Network Operator."%></div></div></div>
<div class="detail-grid"><div class="mc-columna"><div class="detail-card">
<div class="dc-head"><div><div class="dc-sub">Planificación</div><h3>Datos Generales</h3></div><span class="pill <%=pill(m.getEstado())%>"><span class="dot"></span><%=h(m.getEstado())%></span></div>
<div class="data-list"><div class="data-label">Infraestructura</div><div><span class="seg-tag"><%=h(m.getInfraestructuraCodigo())%></span> <%=h(m.getInfraestructuraNombre())%></div>
<div class="data-label">Fecha y Hora</div><div><%=fecha(m.getFechaInicio())%></div><div class="data-label">Duración Estimada</div><div><%=m.getDuracionEstimada()==null?"Sin registrar":h(m.getDuracionEstimada().stripTrailingZeros().toPlainString())+" horas"%></div>
<div class="data-label">Responsable</div><div><%=h(m.getResponsable())%></div>
<% if(m.getDescripcion()!=null&&!m.getDescripcion().isBlank()){ %><div class="data-label">Descripción técnica</div><div class="mc-multilinea"><%=h(m.getDescripcion())%></div><% } %>
<% if(m.isFinalizado()){ %><div class="data-label">Finalización</div><div><%=fecha(m.getFechaFin())%></div><div class="data-label">Resultado</div><div class="mc-multilinea"><%=h(m.getResultado())%></div><% } %></div></div>
<div class="detail-card"><div class="dc-head"><div><div class="dc-sub">Bitácora</div><h3><%=m.isFinalizado()?"Actividades Registradas":"Registrar Actividades"%></h3></div></div>
<% if(!m.isFinalizado()){ %><div class="card-pad mc-borde"><form method="post" action="<%=base%>"><input type="hidden" name="action" value="actividad"><input type="hidden" name="id" value="<%=m.getIdMantenimiento()%>"><input type="hidden" name="token" value="<%=h(request.getAttribute("mcToken"))%>"><div class="mc-actividad"><input type="text" class="input" name="actividad" aria-label="Nueva actividad" maxlength="2000" value="<%=dato(request,"actividad")%>" placeholder="Escribe una nueva actividad..." required><button class="btn btn-outline" type="submit">Agregar</button></div><jsp:include page="/views/mc-responsable.jsp"/></form></div><% } %>
<div class="obs-list"><% ArrayList<String[]> eventos=(ArrayList<String[]>)request.getAttribute("eventosMC");if(eventos==null)eventos=new ArrayList<>();for(String[] e:eventos){ %><div class="obs-item"><div class="obs-date"><%=h(e[0])%> · <%=h(e[3])%> · <%=h(e[1])%></div><div class="obs-text mc-multilinea"><% if(e[5]!=null){ %><strong><%=e[4]==null?"":h(e[4])+" → "%><%=h(e[5])%></strong><br><% } %><%=h(e[2])%></div></div><% } %>
<% if(m.getActividades()!=null&&!m.getActividades().isBlank()){ %><div class="obs-item"><div class="obs-date">Registro previo</div><div class="obs-text mc-multilinea"><%=h(m.getActividades())%></div></div><% }else if(eventos.isEmpty()){ %><div class="obs-item">Todavía no hay actividades registradas.</div><% } %></div></div></div>
<div class="mc-columna"><div class="detail-card"><div class="dc-head"><div><div class="dc-sub">Impacto Comercial</div><h3>Consultar Servicios Afectados</h3></div></div><div class="notice-soft">Estos servicios perderán conectividad temporal si no cuentan con una ruta de protección activa en el Network Operator.</div><div class="table-wrap"><table class="mini-table"><thead><tr><th>Servicio</th><th>Cliente</th><th>Capacidad</th></tr></thead><tbody>
<% ArrayList<String[]> servicios=(ArrayList<String[]>)request.getAttribute("serviciosMC");if(servicios==null)servicios=new ArrayList<>();for(String[] sv:servicios){ %><tr><td class="strong"><%=h(sv[0])%></td><td><%=h(sv[1])%></td><td><%=sv[2]==null?"Sin asignar":h(new BigDecimal(sv[2]).stripTrailingZeros().toPlainString())+" Gbps"%></td></tr><% }if(servicios.isEmpty()){ %><tr><td colspan="3">No se encontraron servicios activos o suspendidos asociados a esta infraestructura.</td></tr><% } %></tbody></table></div></div></div></div><% } %>

<jsp:include page="/views/mc-fin.jsp"/>
