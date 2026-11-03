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
<% request.setAttribute("tituloNO","Registrar incidencia");request.setAttribute("seccionNO","incidencias");
ArrayList<Segmento> segmentos=(ArrayList<Segmento>)request.getAttribute("segmentos");if(segmentos==null)segmentos=new ArrayList<>();Set<String> seleccionados=new HashSet<>();if(request.getParameterValues("segmentos")!=null)seleccionados.addAll(Arrays.asList(request.getParameterValues("segmentos")));
%>
<jsp:include page="/views/no-inicio.jsp"/>
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %><div class="page-head"><div><h1>Registrar incidencia</h1><div class="psub">Reporta una nueva incidencia y clasifícala.</div></div><div class="grow"></div></div><div class="card card-pad"><form method="post" action="<%=ctx%>/NetworkOperatorServlet" data-confirm-form class="form-grid" style="max-width:700px"><input type="hidden" name="action" value="crearIncidencia"><div id="noFormView"><div class="field"><label for="no-field-1">Título de la incidencia <span class="required-mark">*</span></label><input id="no-field-1" name="titulo" maxlength="150" value="<%=request.getParameter("titulo")==null?"":h(request.getParameter("titulo"))%>" class="input" placeholder="Ej. Corte total en enlace CLL–ATF" required><span class="validation-message">Este campo es obligatorio.</span></div><div class="field"><label for="no-field-2">Descripción <span class="required-mark">*</span></label><textarea id="no-field-2" name="descripcion" class="input" rows="3" placeholder="Describe lo que se observó…" required><%=request.getParameter("descripcion")==null?"":h(request.getParameter("descripcion"))%></textarea><span class="validation-message">Este campo es obligatorio.</span></div><div class="field"><label for="no-field-3">Severidad <span class="required-mark">*</span></label><select id="no-field-3" name="severidad" class="input" required><option value="">Seleccionar severidad</option><option>Crítica</option><option>Alta</option><option>Media</option><option>Baja</option></select><span class="validation-message">Este campo es obligatorio.</span><div class="hint">Clasifica la incidencia por su nivel de severidad.</div></div><div class="field"><label>Redes afectadas <span class="required-mark">*</span></label>
<details class="segment-dropdown">
  <summary>Seleccionar redes</summary>
  <div class="segment-options"><% for(Segmento red:segmentos){ %><label><input type="checkbox" aria-label="<%=h(red.getCodigo())%>" name="segmentos" value="<%=red.getIdSegmento()%>" <%=seleccionados.contains(String.valueOf(red.getIdSegmento()))?"checked":""%>><span><%=h(red.getCodigo())%> — <%=h(red.getNombreOrigen())%> ↔ <%=h(red.getNombreDestino())%></span></label><% } %></div>
</details>
<span id="noSegmentError" class="no-error" hidden>Selecciona al menos una red.</span>
<div class="hint">Puedes asociar uno o varios redes.</div></div><div class="field"><label>Fecha y hora de registro</label><div class="ro-field"><%=java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))%> — se registra automáticamente</div></div><div class="form-actions"><a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Cancelar</a><button class="btn btn-primary" type="submit">Registrar incidencia</button></div></div><div id="noConfirmView" hidden><div class="page-head"><div><h1>Confirmar registro</h1><div class="psub">Revisa la información antes de confirmar.</div></div></div><div class="card card-pad" style="max-width:720px"><div class="info-strip"><div class="ii">!</div><div><div class="it">CONFIRMAR OPERACIÓN</div><div class="id">La información se guardará al confirmar.</div></div></div><div id="noConfirmFields"></div><div class="form-actions"><button type="button" class="btn btn-outline" id="noBack">Volver a editar</button><button type="button" class="btn btn-primary" id="noSave">Confirmar</button></div></div></div></form></div><script>
(function(){const form=document.querySelector('[data-confirm-form]');if(!form)return;let confirmed=false;
const original=document.getElementById('noFormView'),review=document.getElementById('noConfirmView'),fields=document.getElementById('noConfirmFields');
form.addEventListener('submit',function(e){if(confirmed)return;e.preventDefault();if(!form.reportValidity())return;
 const checks=Array.from(form.querySelectorAll('input[name="segmentos"]'));if(checks.length&&!checks.some(c=>c.checked)){const error=document.getElementById('noSegmentError');error.hidden=false;return;}
 fields.replaceChildren();form.querySelectorAll('.field, .data-list > div').forEach(function(field){
 const controls=Array.from(field.querySelectorAll('input:not([type="hidden"]),textarea,select')),readonly=field.querySelector('.ro-field');if(!controls.length&&!readonly)return;
 const label=field.querySelector('label');let title=label?label.textContent.replace('*','').trim():field.previousElementSibling?field.previousElementSibling.textContent.trim():'';
 let values=controls.filter(c=>c.type!=='checkbox'||c.checked).map(c=>c.type==='checkbox'?c.parentElement.textContent.trim():c.tagName==='SELECT'?(c.selectedOptions[0]?c.selectedOptions[0].textContent:''):c.value).filter(Boolean);
 if(!values.length&&readonly)values=[readonly.textContent.trim()];if(!values.length)return;const item=document.createElement('div');item.className='field';const l=document.createElement('label');l.textContent=title;const v=document.createElement('div');v.className='ro-field';v.textContent=values.join(' · ');item.append(l,v);fields.append(item);
 });original.hidden=true;review.hidden=false;const heading=document.querySelector('.content>.page-head');if(heading)heading.hidden=true;const card=form.closest('.card')||form;if(card)card.style.maxWidth='760px';window.scrollTo(0,0);});
 document.getElementById('noBack').onclick=()=>{review.hidden=true;original.hidden=false;const heading=document.querySelector('.content>.page-head');if(heading)heading.hidden=false;const card=form.closest('.card')||form;if(card)card.style.maxWidth='';};document.getElementById('noSave').onclick=()=>{confirmed=true;form.requestSubmit();};
})();
</script>
<jsp:include page="/views/no-fin.jsp"/>
