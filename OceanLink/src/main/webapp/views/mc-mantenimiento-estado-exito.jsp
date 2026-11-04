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
<% Map<?,?> exito=(Map<?,?>)request.getAttribute("exitoMC"); %>

    <div class="card center-state mc-ref-24">
      <div class="cs-ic mc-ref-25">✓</div>
      <h2>Estado Modificado Correctamente</h2>
      <p>El estado del mantenimiento <%=h(exito.get("codigo"))%> ha sido actualizado a "<%=h(exito.get("estado"))%>" y la justificación técnica fue registrada en la bitácora exitosamente.</p>
      
      <!-- Este botón retorna a la vista de detalles enviando un parámetro en la URL para simular la actualización visual del estado -->
      <a class="btn btn-primary mc-ref-26" href="<%=base%>?action=detalle&amp;id=<%=h(exito.get("id"))%>">Volver a los Detalles</a>
    </div>
  
<jsp:include page="/views/mc-fin.jsp"/>
