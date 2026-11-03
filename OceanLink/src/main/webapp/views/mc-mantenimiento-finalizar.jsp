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
<div class="page-head"><div><h1>Registrar Finalización del Mantenimiento</h1><div class="psub">Registra el resultado de la intervención <%=h(m.getCodigo())%>.</div></div></div><div class="card card-pad mc-formulario"><form method="post" action="<%=base%>"><input type="hidden" name="action" value="finalizar"><input type="hidden" name="id" value="<%=m.getIdMantenimiento()%>"><input type="hidden" name="token" value="<%=h(request.getAttribute("mcToken"))%>"><div class="info-strip"><div class="ii">i</div><div><div class="it"><%=h(m.getCodigo())%>: <%=h(m.getTitulo())%></div><div class="id">Estado actual: <strong>En ejecución</strong></div></div></div><div class="field"><label for="mcResultado">Resultado de la intervención (*)</label><textarea class="input" name="resultado" id="mcResultado" rows="4" maxlength="2000" placeholder="Describe los trabajos realizados y el resultado obtenido..." required><%=dato(request,"resultado")%></textarea><div class="hint">El resultado y la fecha de finalización quedarán registrados en la bitácora. Network Operator verificará la restauración de la incidencia vinculada.</div></div><jsp:include page="/views/mc-responsable.jsp"/><div class="form-actions"><a class="btn btn-outline" href="<%=base%>?action=detalle&amp;id=<%=m.getIdMantenimiento()%>">Cancelar</a><button type="submit" class="btn btn-primary">Registrar Finalización</button></div></form></div>
<jsp:include page="/views/mc-fin.jsp"/>
