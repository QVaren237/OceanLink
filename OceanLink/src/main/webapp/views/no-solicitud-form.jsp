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
<% request.setAttribute("tituloNO","Nueva solicitud de capacidad");request.setAttribute("seccionNO","solicitudes");
ArrayList<String[]> clientes=(ArrayList<String[]>)request.getAttribute("clientes"),rutas=(ArrayList<String[]>)request.getAttribute("rutas");if(clientes==null)clientes=new ArrayList<>();if(rutas==null)rutas=new ArrayList<>();
ArrayList<String> motivos=(ArrayList<String>)request.getAttribute("motivos");if(motivos==null)motivos=new ArrayList<>();
String motivoSeleccionado=request.getParameter("motivo")==null?"":request.getParameter("motivo");
boolean otroMotivo="__otro__".equals(motivoSeleccionado);

%>
<jsp:include page="/views/no-inicio.jsp"/>
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %><div class="back-row"><a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Volver</a></div><div class="page-head"><div><h1>Nueva solicitud de capacidad</h1><div class="psub">Solicita capacidad adicional al Capacity Planner.</div></div></div><form method="post" action="<%=ctx%>/NetworkOperatorServlet" data-confirm-form class="detail-card"><input type="hidden" name="action" value="crearSolicitud"><div id="noFormView"><div class="dc-head"><div><div class="dc-sub">Solicitud del Network Operator</div><h3>Datos del requerimiento</h3></div></div><div class="data-list"><div class="data-label">Cliente *</div><div><select class="input" aria-label="Cliente" name="idCliente" required><option value="">Selecciona un cliente</option><% for(String[] c:clientes){ %><option value="<%=h(c[0])%>" <%=c[0].equals(request.getParameter("idCliente"))?"selected":""%>><%=h(c[1])%></option><% } %></select></div><div class="data-label">Ruta *</div><div><select class="input" aria-label="Ruta" name="idRuta" required><option value="">Selecciona una ruta</option><% for(String[] r:rutas){ %><option value="<%=h(r[0])%>" <%=r[0].equals(request.getParameter("idRuta"))?"selected":""%>><%=h(r[1])%></option><% } %></select></div><div class="data-label">Capacidad solicitada</div><div><input class="input" name="capacidad" value="<%=request.getParameter("capacidad")==null?"":h(request.getParameter("capacidad"))%>" aria-label="Capacidad solicitada en Gbps" type="number" min="0.01" step="0.01" required><div class="hint">Capacidad en Gbps.</div></div><div class="data-label">Motivo</div><div><select class="input" aria-label="Motivo" id="motivoSolicitud" name="motivo" required>
<option value="">Selecciona un motivo</option>
<% for(String motivo:motivos){ %><option value="<%=h(motivo)%>" <%=motivo.equals(motivoSeleccionado)?"selected":""%>><%=h(motivo)%></option><% } %>
<option value="__otro__" <%=otroMotivo?"selected":""%>>Otro motivo</option>
</select>
<div id="motivoPersonalizadoGrupo" <%=otroMotivo?"":"hidden"%>>
<label for="motivoPersonalizado" class="hint">Especifica el motivo *</label>
<input class="input" id="motivoPersonalizado" name="motivoPersonalizado" maxlength="255" placeholder="Escribe el motivo de la solicitud" value="<%=request.getParameter("motivoPersonalizado")==null?"":h(request.getParameter("motivoPersonalizado"))%>" <%=otroMotivo?"required":"disabled"%>>
</div></div><div class="data-label">Observación</div><div><textarea class="input" name="observacion" maxlength="255" rows="4" placeholder="Explica la necesidad de capacidad adicional..."><%=request.getParameter("observacion")==null?"":h(request.getParameter("observacion"))%></textarea></div></div><div class="data-list"><div class="data-label">Fecha límite</div><div><input class="input" name="fechaLimite" value="<%=request.getParameter("fechaLimite")==null?"":h(request.getParameter("fechaLimite"))%>" aria-label="Fecha límite" type="date" min="<%=java.time.LocalDate.now()%>"></div></div><div class="action-row"><a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Cancelar</a><button class="btn btn-primary" type="submit">Enviar</button></div></div><div id="noConfirmView" hidden><div class="page-head"><div><h1>Confirmar solicitud</h1><div class="psub">Revisa la información antes de confirmar.</div></div></div><div class="card card-pad" style="max-width:720px"><div class="info-strip"><div class="ii">!</div><div><div class="it">CONFIRMAR OPERACIÓN</div><div class="id">La información se guardará al confirmar.</div></div></div><div id="noConfirmFields"></div><div class="form-actions"><button type="button" class="btn btn-outline" id="noBack">Volver a editar</button><button type="button" class="btn btn-primary" id="noSave">Confirmar</button></div></div></div></form><script>
(function(){const form=document.querySelector('[data-confirm-form]');if(!form)return;let confirmed=false;
const original=document.getElementById('noFormView'),review=document.getElementById('noConfirmView'),fields=document.getElementById('noConfirmFields');
const motivo=document.getElementById('motivoSolicitud'),personalizado=document.getElementById('motivoPersonalizado'),grupo=document.getElementById('motivoPersonalizadoGrupo');
function cambiarMotivo(){const otro=motivo.value==='__otro__';grupo.hidden=!otro;personalizado.disabled=!otro;personalizado.required=otro;personalizado.setCustomValidity('');}
motivo.addEventListener('change',cambiarMotivo);personalizado.addEventListener('input',()=>personalizado.setCustomValidity(personalizado.value.trim()?'':'Especifica el motivo.'));cambiarMotivo();
form.addEventListener('submit',function(e){if(confirmed)return;e.preventDefault();if(!form.reportValidity())return;
 const checks=Array.from(form.querySelectorAll('input[name="segmentos"]'));if(checks.length&&!checks.some(c=>c.checked)){const error=document.getElementById('noSegmentError');error.hidden=false;return;}
 fields.replaceChildren();form.querySelectorAll('.field, .data-list > div').forEach(function(field){
 const controls=Array.from(field.querySelectorAll('input:not([type="hidden"]),textarea,select')),readonly=field.querySelector('.ro-field');if(!controls.length&&!readonly)return;
 const label=field.querySelector('label');let title=label?label.textContent.replace('*','').trim():field.previousElementSibling?field.previousElementSibling.textContent.trim():'';
 let values=controls.filter(c=>!c.disabled&&(c.type!=='checkbox'||c.checked)).map(c=>c.type==='checkbox'?c.parentElement.textContent.trim():c.tagName==='SELECT'?(c.selectedOptions[0]?c.selectedOptions[0].textContent:''):c.value).filter(Boolean);
 if(controls.includes(motivo)){title='Motivo';values=[motivo.value==='__otro__'?personalizado.value.trim():motivo.selectedOptions[0].textContent];}if(!values.length&&readonly)values=[readonly.textContent.trim()];if(!values.length)return;const item=document.createElement('div');item.className='field';const l=document.createElement('label');l.textContent=title;const v=document.createElement('div');v.className='ro-field';v.textContent=values.join(' · ');item.append(l,v);fields.append(item);
 });original.hidden=true;review.hidden=false;const heading=document.querySelector('.content>.page-head');if(heading)heading.hidden=true;const card=form.closest('.card')||form;if(card)card.style.maxWidth='760px';window.scrollTo(0,0);});
 document.getElementById('noBack').onclick=()=>{review.hidden=true;original.hidden=false;const heading=document.querySelector('.content>.page-head');if(heading)heading.hidden=false;const card=form.closest('.card')||form;if(card)card.style.maxWidth='';};document.getElementById('noSave').onclick=()=>{confirmed=true;form.requestSubmit();};
})();
</script>
<jsp:include page="/views/no-fin.jsp"/>
