<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace" %>
<%!
 private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
 private String numero(BigDecimal v){return v==null?"Sin datos":v.stripTrailingZeros().toPlainString();}
 private String porcentaje(BigDecimal v){return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).toPlainString()+"%";}
%>
<% String ctx=request.getContextPath();if(request.getAttribute("titulo")==null){response.sendRedirect(ctx+"/capacity-planner/alertas");return;} %>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="alertas-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% CapacidadEnlace enlace=(CapacidadEnlace)request.getAttribute("enlace");if(enlace!=null&&enlace.isAlertaSaturacion()){ %>
            <div class="alertas-estilo-10">
                <a href="<%=ctx%>/capacity-planner/alertas" class="link">&lt;- Volver a Alertas</a>
            </div>
            
            <div class="page-head">
                <div>
                    <h1>Planificar Ampliación de Capacidad (Upgrade)</h1>
                    <div class="psub">Inicia el requerimiento técnico para incrementar la capacidad física del segmento saturado.</div>
                </div>
            </div>

            <div class="card card-pad alertas-estilo-11">
                <!-- Datos del enlace pre-llenados e inmodificables -->
                <div class="alertas-estilo-12">
                    <div class="alertas-estilo-13">
                        <span class="alertas-estilo-14">Segmento Crítico:</span>
                        <strong class="alertas-estilo-15"><%=h(enlace.getCodigo())%> (<%=h(enlace.getNombre())%>)</strong>
                        
                        <span class="alertas-estilo-16">Estado Actual:</span>
                        <span><strong><%=porcentaje(enlace.getPorcentajeUtilizacion())%> Utilizado</strong> (<%=numero(enlace.getCapacidadAsignada())%> Gbps / <%=numero(enlace.getCapacidadTotal())%> Gbps)</span>
                    </div>
                </div>

                <form id="ampliacionForm" method="post" action="<%=ctx%>/capacity-planner/alertas" novalidate data-actual="<%=numero(enlace.getCapacidadTotal())%>">
<input type="hidden" name="action" value="planificar"><input type="hidden" name="id" value="<%=enlace.getIdSegmento()%>"><input type="hidden" name="tokenAmpliacion" value="<%=h(request.getAttribute("tokenAmpliacion"))%>">
                    <div class="form-grid alertas-estilo-17">
                        
                        <div class="field">
                            <label for="capacidadNueva">Nueva Capacidad Total Deseada (Gbps) (*)</label>
                            <div class="alertas-estilo-18">
                                <input type="number" id="capacidadNueva" name="capacidadNueva" value="<%=h(request.getParameter("capacidadNueva"))%>" aria-describedby="err-capacidad" class="input" placeholder="Ej: 200" min="<%=enlace.getCapacidadTotal().add(new BigDecimal("0.01")).toPlainString()%>" step="0.01" max="9999999999.99" required>
                                <div id="err-capacidad" class="err alertas-error" hidden>
                                    Error: La nueva capacidad debe ser mayor a la actual (<%=numero(enlace.getCapacidadTotal())%> Gbps).
                                </div>
                            </div>
                        </div>

                        <div class="field">
                            <label for="fechaLimite">Fecha Límite Sugerida (*)</label>
                            <div class="alertas-estilo-19">
                                <input type="date" id="fechaLimite" name="fechaLimite" value="<%=h(request.getParameter("fechaLimite"))%>" min="<%=java.time.LocalDate.now()%>" aria-describedby="err-fecha" class="input" required>
                                <div id="err-fecha" class="err alertas-error" hidden>
                                    Error: Debe seleccionar una fecha límite para la ejecución.
                                </div>
                            </div>
                        </div>

                        <div class="field alertas-estilo-20">
                            <label for="justificacion">Justificación Técnica (*)</label>
                            <div class="alertas-estilo-21">
                                <textarea id="justificacion" name="justificacion" maxlength="2000" aria-describedby="err-justificacion" class="input" rows="3" placeholder="Ej: El segmento ha superado el 95% de utilización, se requiere instalar nuevas tarjetas de red..." required><%=h(request.getParameter("justificacion"))%></textarea>
                                <div id="err-justificacion" class="err alertas-error" hidden>
                                    Error: Debe justificar la necesidad de la ampliación.
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="hint alertas-estilo-22">(*) Campos obligatorios</div>

                    <div class="form-actions alertas-estilo-23">
                        <a href="<%=ctx%>/capacity-planner/alertas" class="btn btn-outline">Cancelar</a>
                        <button type="submit" id="guardarAmpliacion" class="btn btn-danger">Solicitar Ampliación a Ingeniería</button>
                    </div>
                </form>
            </div>
        <% }else{ %><a class="link" href="<%=ctx%>/capacity-planner/alertas">&lt;- Volver a Alertas</a><% } %><script>
(function(){
 const form=document.getElementById('ampliacionForm');if(!form)return;
 const capacidad=document.getElementById('capacidadNueva'),fecha=document.getElementById('fechaLimite'),justificacion=document.getElementById('justificacion');
 const campos=[[capacidad,'err-capacidad'],[fecha,'err-fecha'],[justificacion,'err-justificacion']];
 form.addEventListener('submit',function(e){
  let valido=true;campos.forEach(([input,error])=>{input.classList.remove('bad');document.getElementById(error).hidden=true;input.removeAttribute('aria-invalid');});
  function fallo(input,error){valido=false;input.classList.add('bad');input.setAttribute('aria-invalid','true');document.getElementById(error).hidden=false;}
  if(!capacidad.value||!capacidad.validity.valid||Number(capacidad.value)<=Number(form.dataset.actual))fallo(capacidad,'err-capacidad');
  if(!fecha.value||!fecha.validity.valid)fallo(fecha,'err-fecha');
  if(!justificacion.value.trim()||!justificacion.validity.valid)fallo(justificacion,'err-justificacion');
  if(!valido){e.preventDefault();form.querySelector('.bad').focus();return;}
  document.getElementById('guardarAmpliacion').disabled=true;
 });
 campos.forEach(([input,error])=>input.addEventListener('input',()=>{input.classList.remove('bad');input.removeAttribute('aria-invalid');document.getElementById(error).hidden=true;}));
})();
</script>
</div>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
