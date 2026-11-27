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

      <div class="page-head">
        <div>
          <h1>Modificar Estado de Mantenimiento</h1>
          <div class="psub">Actualiza la fase de la intervención <%=h(m.getCodigo())%> y justifica el cambio.</div>
        </div>
      </div>

      <div class="card card-pad mc-ref-7">
        <form novalidate method="post" action="<%=base%>"><input type="hidden" name="action" value="preparar"><input type="hidden" name="id" value="<%=m.getIdMantenimiento()%>"><input type="hidden" name="token" value="<%=h(request.getAttribute("mcToken"))%>">

          <div class="info-strip mc-ref-8">
            <div class="ii">i</div>
            <div>
              <div class="it"><%=h(m.getCodigo())%>: <%=h(m.getTitulo())%></div>
              <div class="id">Estado actual: <strong class="mc-ref-9"><%=h(m.getEstado())%></strong></div>
            </div>
          </div>

          <div class="field">
            <label>Nuevo Estado (*)</label>
            <select class="input" name="nuevoEstado" aria-label="Nuevo estado" required><option value="">Selecciona el nuevo estado...</option><% ArrayList<String> estados=(ArrayList<String>)request.getAttribute("estadosMC");if(estados!=null)for(String estado:estados){ %><option value="<%=h(estado)%>" <%=estado.equals(request.getParameter("nuevoEstado"))||estado.equals(((Map<?,?>)(request.getAttribute("borradorMC")==null?new HashMap<>():request.getAttribute("borradorMC"))).get("nuevoEstado"))?"selected":""%>><%=h(estado)%><%= "En ejecución".equals(estado)?" (Iniciando trabajos)":" (Pausado por fuerza mayor)" %></option><% } %></select>
          </div>

          <div class="field">
            <label>Motivo o justificación técnica (*)</label>
            <textarea name="justificacion" aria-label="Justificación técnica" maxlength="2000" class="input" rows="4" placeholder="Ej. El equipo técnico ha llegado al sitio y se inician las maniobras de intervención..." required><%=dato(request,"justificacion")%></textarea>
            <div class="hint">Las modificaciones de estado requieren una justificación obligatoria para la bitácora de auditoría.</div>
          </div>

          <jsp:include page="/views/mc-responsable.jsp"/><div class="form-actions">
            <a class="btn btn-outline" href="<%=base%>?action=detalle&amp;id=<%=m.getIdMantenimiento()%>">Cancelar</a>
            <button class="btn btn-primary" type="submit">Continuar a Verificación</button>
          </div>
        </form>
      </div>

<script>function ocValida(f){var ok=true;var cs=f.querySelectorAll('input:not([type=hidden]),select,textarea');for(var i=0;i<cs.length;i++){(function(c){if(c.disabled)return;if(c._ocE){c._ocE.remove();c._ocE=null;}c.style.borderColor='';if(!c.checkValidity()){ok=false;var v=c.validity,m;if(v.valueMissing)m=(c.tagName==='SELECT')?'Selecciona una opción.':'Este campo es obligatorio.';else if(v.customError)m=c.validationMessage;else if(v.typeMismatch&&c.type==='email')m='Ingresa un correo válido.';else if(v.rangeUnderflow||v.rangeOverflow||v.stepMismatch||v.badInput)m='Ingresa un valor válido.';else m=c.validationMessage||'Revisa este campo.';var s=document.createElement('small');s.className='oc-err';s.style.cssText='display:block;color:#bd586d;font-size:10.5px;font-weight:600;margin-top:4px';s.textContent=m;c.insertAdjacentElement('afterend',s);c._ocE=s;c.style.borderColor='#c0334a';if(!c._ocB){c._ocB=1;var limpia=function(){if(c.checkValidity()&&c._ocE){c._ocE.remove();c._ocE=null;c.style.borderColor='';}};c.addEventListener('input',limpia);c.addEventListener('change',limpia);}}})(cs[i]);}return ok;}document.querySelectorAll('form').forEach(function(fm){if(fm.querySelector('[required]'))fm.addEventListener('submit',function(e){if(!ocValida(fm))e.preventDefault();});});</script>
<jsp:include page="/views/mc-fin.jsp"/>
