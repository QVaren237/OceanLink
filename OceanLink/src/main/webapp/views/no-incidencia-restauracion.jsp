<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="pe.edu.oceanlink.bean.Incidencia" %>
<%!
 private String h(Object v) { return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
%>
<%
 String ctx = request.getContextPath();
 request.setAttribute("tituloNO", "Registrar restauración");
 request.setAttribute("seccionNO", "incidencias");
 Incidencia incidencia = (Incidencia) request.getAttribute("incidencia");
 String resultado = (String) request.getAttribute("resultado");
 String motivoRestauracion = (String) request.getAttribute("motivoRestauracion");
 String urlDetalle = incidencia == null ? "" :
         ctx + "/NetworkOperatorServlet?action=detalleIncidencia&amp;id=" + incidencia.getIdIncidencia();
%>
<jsp:include page="/views/no-inicio.jsp"/>

<% if (incidencia == null) { %>
  <div class="card center-state">
    <h2>Incidencia no encontrada</h2>
    <a class="btn btn-outline" href="<%= ctx %>/NetworkOperatorServlet?action=incidencias">Volver</a>
  </div>
<% } else { %>
  <div class="back-row"><a class="btn btn-outline" href="<%= urlDetalle %>">Volver</a></div>
  <div class="page-head">
    <div>
      <h1>Registrar restauración</h1>
      <div class="psub">Documenta la recuperación del servicio afectado.</div>
    </div>
  </div>
  <div class="card card-pad">
    <% if (request.getAttribute("error") != null) { %>
      <div class="banner banner-err" role="alert"><%= h(request.getAttribute("error")) %></div>
    <% } %>
    <% if (motivoRestauracion == null) { %>
      <form method="post" action="<%= ctx %>/NetworkOperatorServlet" class="form-grid" style="max-width:700px">
        <input type="hidden" name="action" value="revisarRestauracion">
        <input type="hidden" name="id" value="<%= incidencia.getIdIncidencia() %>">
        <div class="field">
          <label>Incidencia</label>
          <div class="ro-field"><%= h(incidencia.getCodigo()) %> — <%= h(incidencia.getTitulo()) %></div>
        </div>
        <div class="field">
          <label>Estado previo</label>
          <div class="ro-field"><%= h(incidencia.getEstado()) %></div>
        </div>
        <div class="field">
          <label>Fecha y hora de restauración</label>
          <div class="ro-field">Se registrarán al confirmar.</div>
        </div>
        <div class="field">
          <label for="no-restauracion-resultado">Resultado <span class="required-mark">*</span></label>
          <select id="no-restauracion-resultado" name="resultado" class="input" required>
            <option>Servicio restablecido</option>
            <option<%= "Restauración parcial".equals(resultado) ? " selected" : "" %>>Restauración parcial</option>
          </select>
        </div>
        <div class="field">
          <label for="no-restauracion-observaciones">Observaciones <span class="required-mark">*</span></label>
          <textarea id="no-restauracion-observaciones" name="observaciones" class="input" rows="5"
                    placeholder="Describe las acciones realizadas y la verificación del servicio..." required><%= h(request.getAttribute("observaciones")) %></textarea>
        </div>
        <div class="form-actions">
          <a class="btn btn-outline" href="<%= urlDetalle %>">Cancelar</a>
          <button class="btn btn-primary" type="submit">Registrar restauración</button>
        </div>
      </form>
    <% } else { %>
      <% if (!motivoRestauracion.equals(request.getAttribute("error"))) { %>
        <div class="notice-soft"><%= h(motivoRestauracion) %></div>
      <% } %>
      <div class="form-actions"><a class="btn btn-outline" href="<%= urlDetalle %>">Cancelar</a></div>
    <% } %>
  </div>
<% } %>
<jsp:include page="/views/no-fin.jsp"/>
