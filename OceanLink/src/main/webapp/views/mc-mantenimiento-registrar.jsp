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
<% ArrayList<String[]> infraestructura=(ArrayList<String[]>)request.getAttribute("infraestructuraMC"),incidencias=(ArrayList<String[]>)request.getAttribute("incidenciasMC");if(infraestructura==null)infraestructura=new ArrayList<>();if(incidencias==null)incidencias=new ArrayList<>(); %>

      <div class="page-head">
        <div>
          <h1>Registrar Mantenimiento (RF24)</h1>
          <div class="psub">Planifica una intervención y vincúlala a incidencias si es necesario.</div>
        </div>
      </div>

      <div class="card card-pad mc-ref-4">
        <form method="post" action="<%=base%>"><input type="hidden" name="action" value="crear"><input type="hidden" name="token" value="<%=h(request.getAttribute("mcToken"))%>">
          <div class="field">
            <label>Tipo de Mantenimiento (*)</label>
            <select class="input" id="tipoMantenimiento" name="tipo" required>
              <option value="Preventivo" <%=!"Correctivo".equals(request.getParameter("tipo"))?"selected":""%>>Preventivo (Rutina Programada)</option>
              <option value="Correctivo" <%= "Correctivo".equals(request.getParameter("tipo"))?"selected":""%>>Correctivo (Resolución de Incidencia N.O.)</option>
            </select>
          </div>

          <!-- Este campo se muestra solo si es Correctivo -->
          <div class="field mc-ref-5" id="campoIncidencia" hidden>
            <label>Vincular a Incidencia del Network Operator (*)</label>
            <select class="input" id="mcIncidencia" name="idIncidencia"><option value="">Seleccione el ticket reportado...</option><% for(String[] i:incidencias){ %><option value="<%=h(i[0])%>" <%=i[0].equals(request.getParameter("idIncidencia"))?"selected":""%>><%=h(i[1])%></option><% } %></select>
            <div class="hint">Al registrar la finalización (RF30), se habilitará la restauración en el panel del N.O.</div>
          </div>

          <div class="field">
            <label>Título de la intervención (*)</label>
            <input type="text" name="titulo" aria-label="Título de la intervención" maxlength="150" value="<%=dato(request,"titulo")%>" class="input" placeholder="Ej. Cambio de amplificador óptico" required>
          </div>

          <div class="field">
            <label>Seleccionar Infraestructura (RF25) (*)</label>
            <select class="input" name="infraestructura" aria-label="Infraestructura" required><option value="">Selecciona el cable o estación...</option><% for(String[] i:infraestructura){ %><option value="<%=h(i[0])%>" <%=i[0].equals(request.getParameter("infraestructura"))?"selected":""%>><%=h(i[1])%></option><% } %></select>
          </div>

          <div class="form-grid mc-ref-6">
            <div class="field">
              <label>Fecha y Hora de Inicio (RF26) (*)</label>
              <input type="datetime-local" name="fechaInicio" aria-label="Fecha y hora de inicio" value="<%=dato(request,"fechaInicio")%>" min="<%=java.time.LocalDateTime.now(java.time.ZoneId.of("America/Lima")).withSecond(0).withNano(0)%>" class="input" required>
            </div>
            <div class="field">
              <label>Duración Estimada (RF26) (*)</label>
              <select class="input" name="duracion" aria-label="Duración estimada" required><% for(String d:new String[]{"1","2","4","8","24"}){ %><option value="<%=d%>" <%=d.equals(request.getParameter("duracion"))?"selected":""%>><%=d%> <%= "1".equals(d)?"hora":"horas" %></option><% } %></select>
            </div>
          </div>

          <div class="field">
            <label>Descripción técnica</label>
            <textarea name="descripcion" aria-label="Descripción técnica" maxlength="2000" class="input" rows="3" placeholder="Detalla los trabajos a realizar..."><%=dato(request,"descripcion")%></textarea>
          </div>

          <jsp:include page="/views/mc-responsable.jsp"/><div class="form-actions">
            <a class="btn btn-outline" href="<%=base%>">Cancelar</a>
            <button class="btn btn-primary" type="submit">Guardar Mantenimiento</button>
          </div>
        </form>
      </div>
    <script>(function(){const tipo=document.getElementById('tipoMantenimiento'),grupo=document.getElementById('campoIncidencia'),incidencia=document.getElementById('mcIncidencia');function cambiar(){const correctivo=tipo.value==='Correctivo';grupo.hidden=!correctivo;incidencia.required=correctivo;incidencia.disabled=!correctivo;}tipo.addEventListener('change',cambiar);cambiar();})();</script>
<jsp:include page="/views/mc-fin.jsp"/>
