<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace,pe.edu.oceanlink.bean.CapacidadServicio,pe.edu.oceanlink.bean.EvaluacionCapacidad,pe.edu.oceanlink.bean.SolicitudCapacidad,pe.edu.oceanlink.bean.Usuario,java.util.*" %>
<%!
 private String h(Object v) { return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String numero(BigDecimal v) { return v==null?"Sin datos":v.stripTrailingZeros().toPlainString(); }
 private String capacidad(BigDecimal v) { return v==null?"Sin datos":numero(v)+" Gbps"; }
 private String porcentaje(BigDecimal v) { return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).toPlainString()+"%"; }
 private String estadoClase(String estado) {
  return "Operativo".equals(estado)||"Activo".equals(estado)?"pill-ok":"Fuera de servicio".equals(estado)||"Cancelado".equals(estado)?"pill-crit":"pill-warn";
 }
%>
<%
 String ctx=request.getContextPath();
 if(request.getAttribute("titulo")==null){response.sendRedirect(ctx+"/capacity-planner/capacidad");return;}
%>
<%
EvaluacionCapacidad evaluacion=(EvaluacionCapacidad)request.getAttribute("evaluacion");ArrayList<String[]> responsables=(ArrayList<String[]>)request.getAttribute("responsables");if(responsables==null)responsables=new ArrayList<>();
%>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="capacidad-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% if(evaluacion!=null){SolicitudCapacidad solicitud=evaluacion.getSolicitud(); %>
<a class="link" href="<%=ctx%>/capacity-planner/solicitudes">&lt;- Volver a bandeja</a>
<div class="page-head"><div><h1>Evaluación de Solicitud <%=h(solicitud.getCodigo())%></h1><div class="psub">Análisis de factibilidad técnica para provisión de nueva capacidad.</div></div></div>
<% if(request.getAttribute("mensaje")!=null){ %><div class="info-strip" role="status"><%=h(request.getAttribute("mensaje"))%></div><% } %>
<div class="card card-pad"><h3 class="reserva-titulo">DATOS DEL REQUERIMIENTO</h3><div class="evaluacion-datos">
<div>Cliente: <strong><%=h(solicitud.getCliente())%></strong></div><div>RUC: <strong><%=h(evaluacion.getRuc())%></strong></div><div>Fecha: <strong><%=h(solicitud.getFechaSolicitud())%></strong></div><div>Estado: <strong><%=h(solicitud.getEstado())%></strong></div>
<div>Ruta: <strong><%=h(solicitud.getRuta())%></strong></div><div>Motivo: <strong><%=h(solicitud.getMotivo())%></strong></div></div><p class="hint">Observación original: <%=h(solicitud.getObservacion())%></p></div>
<form class="card card-pad" method="post" action="<%=ctx%>/capacity-planner/solicitudes" id="evaluacionForm"><input type="hidden" name="action" value="evaluar"><input type="hidden" name="id" value="<%=solicitud.getIdSolicitud()%>"><input type="hidden" name="decision" id="decisionEvaluacion">
<h3 class="reserva-titulo">ANÁLISIS DE FACTIBILIDAD</h3><div class="evaluacion-datos"><div class="field"><label>Capacidad Requerida por el Cliente</label><input class="input" value="<%=capacidad(BigDecimal.valueOf(solicitud.getCapacidadSolicitada()))%>" readonly></div><div class="field"><label>Capacidad Disponible en la Ruta</label><input class="input" value="<%=capacidad(evaluacion.getDisponible())%>" readonly></div></div>
<div class="field"><label>Condición Técnica de la Red</label><div class="info-strip"><div class="ii"><%=evaluacion.isFactible()?"✓":"!"%></div><div><div class="it"><%=evaluacion.isFactible()?"Factibilidad Positiva":"Revisar condiciones de capacidad"%></div><div class="id">Se consideran la capacidad disponible, el estado de cada segmento y el estado del cliente y de la ruta.</div></div></div></div>
<div class="table-wrap"><table><thead><tr><th>Segmento</th><th>Disponible</th><th>Estado</th></tr></thead><tbody><% for(CapacidadEnlace tramo:evaluacion.getSegmentos()){ %><tr><td><%=h(tramo.getCodigo())%></td><td><%=capacidad(tramo.getCapacidadDisponible())%></td><td><%=h(tramo.getEstado())%></td></tr><% } %></tbody></table></div>
<% if(evaluacion.isEvaluable()){ %>
<div class="field reserva-comentario"><label for="comentario">Comentarios de Evaluación (obligatorio al rechazar)</label><textarea class="input" name="comentario" id="comentario" maxlength="255" rows="3"><%=h(request.getParameter("comentario"))%></textarea></div>
<div class="field reserva-responsable"><label for="idResponsable">Capacity Planner responsable *</label>
<% if(request.getAttribute("responsableSesion") instanceof Usuario){Usuario actor=(Usuario)request.getAttribute("responsableSesion"); %><div class="ro-field"><%=h(actor.getNombre())%> <%=h(actor.getApellido())%></div>
<% }else{ %><select class="input" id="idResponsable" name="idResponsable" required><option value="">Selecciona al responsable</option><% for(String[] actor:responsables){ %><option value="<%=actor[0]%>" <%=actor[0].equals(request.getParameter("idResponsable"))?"selected":""%>><%=h(actor[1])%></option><% } %></select><% } %></div>
<div class="form-actions"><a class="btn btn-outline" href="<%=ctx%>/capacity-planner/solicitudes">Cancelar</a><button type="button" class="btn btn-danger" data-decision="Rechazada">Rechazar Solicitud</button><button type="button" class="btn btn-primary" data-decision="Aprobada" <%=evaluacion.isFactible()?"":"disabled"%>>Aprobar solicitud</button></div>
<% }else{ %><div class="info-strip"><div><strong><%=evaluacion.getFechaEvaluacion()==null?"Estado actual de la solicitud":"Evaluación registrada"%></strong><p><%=h(evaluacion.getComentarioEvaluacion())%></p><p><%=h(evaluacion.getEvaluador())%> · <%=h(evaluacion.getFechaEvaluacion())%></p></div></div>
<% if("Aprobada".equals(solicitud.getEstado())){ %><a class="btn btn-primary" href="<%=ctx%>/capacity-planner/capacidad?action=reserva&amp;idSolicitud=<%=solicitud.getIdSolicitud()%>">Crear reserva vinculada</a><% } %>
<% } %></form><% } %>
<dialog class="ruta-dialog" id="confirmarEvaluacion"><h2>Confirmar evaluación</h2><p id="textoEvaluacion"></p><div class="form-actions"><button type="button" class="btn btn-outline" id="volverEvaluacion">Volver</button><button type="button" class="btn btn-primary" id="guardarEvaluacion">Confirmar</button></div></dialog>

</div>
<script>
(function(){const form=document.getElementById('evaluacionForm');if(!form)return;const comentario=document.getElementById('comentario'),dialog=document.getElementById('confirmarEvaluacion');
form.querySelectorAll('[data-decision]').forEach(b=>b.onclick=()=>{const rechazo=b.dataset.decision==='Rechazada';comentario.required=rechazo;comentario.setCustomValidity('');if(!form.reportValidity())return;if(rechazo&&!comentario.value.trim()){comentario.setCustomValidity('Indica el motivo del rechazo.');comentario.reportValidity();return;}document.getElementById('decisionEvaluacion').value=b.dataset.decision;document.getElementById('textoEvaluacion').textContent=rechazo?'¿Confirmas el rechazo de esta solicitud?':'¿Confirmas la aprobación? Esta acción no reserva capacidad automáticamente.';dialog.showModal();});
if(comentario)comentario.oninput=()=>comentario.setCustomValidity('');document.getElementById('volverEvaluacion').onclick=()=>dialog.close();document.getElementById('guardarEvaluacion').onclick=()=>{if(form.reportValidity()){document.getElementById('guardarEvaluacion').disabled=true;form.requestSubmit();}};
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
