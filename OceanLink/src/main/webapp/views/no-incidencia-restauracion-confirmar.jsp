<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="pe.edu.oceanlink.bean.Incidencia" %>
<%!
 private String h(String valor) {
   return valor.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
           .replace("\"", "&quot;").replace("'", "&#39;");
 }
%>
<%
 Incidencia incidencia = (Incidencia) request.getAttribute("incidencia");
 String codigoConfirmacion = (String) request.getAttribute("codigoConfirmacion");
 if (incidencia == null || codigoConfirmacion == null) {
   response.sendRedirect(request.getContextPath() + "/NetworkOperatorServlet?action=incidencias");
   return;
 }
 request.setAttribute("tituloNO", "Confirmar restauración");
 request.setAttribute("seccionNO", "incidencias");
%>
<jsp:include page="/views/no-inicio.jsp"/>

<div class="page-head">
  <div>
    <h1>Confirmar restauración</h1>
    <div class="psub">Revisa el resultado y las observaciones antes de guardar.</div>
  </div>
</div>

<div class="card card-pad" style="max-width:720px">
  <div class="info-strip">
    <div class="ii" aria-hidden="true">i</div>
    <div>
      <div class="it"><%= h(incidencia.getCodigo()) %></div>
      <div class="id"><%= h(incidencia.getTitulo()) %></div>
    </div>
  </div>
  <div class="data-list">
    <div class="data-label">Fecha y hora</div><div>Se registrarán al confirmar.</div>
    <div class="data-label">Resultado</div><div><%= h((String) request.getAttribute("resultado")) %></div>
    <div class="data-label">Observaciones</div>
    <div style="white-space:pre-wrap;overflow-wrap:anywhere"><%= h((String) request.getAttribute("observaciones")) %></div>
  </div>
  <form class="form-actions" method="post" action="<%= request.getContextPath() %>/NetworkOperatorServlet">
    <input type="hidden" name="id" value="<%= incidencia.getIdIncidencia() %>">
    <input type="hidden" name="codigoConfirmacion" value="<%= h(codigoConfirmacion) %>">
    <button class="btn btn-outline" type="submit" name="action" value="editarRestauracion">Volver</button>
    <button class="btn btn-primary" type="submit" name="action" value="registrarRestauracion">Confirmar restauración</button>
  </form>
</div>
<jsp:include page="/views/no-fin.jsp"/>
