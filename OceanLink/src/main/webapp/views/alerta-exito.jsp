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

    <div class="card center-state alertas-estilo-24">
      <!-- Ícono de éxito con el color estándar (teal) -->
      <div class="cs-ic alertas-estilo-25">✓</div>
      
      <!-- Título con el color por defecto (var(--ink)) -->
      <h2>Planificación Registrada</h2>
      
      <p>Se ha generado un ticket interno de ampliación (Upgrade) para el segmento crítico. El área de Ingeniería de Redes evaluará la factibilidad física de la expansión.</p>
      
      <!-- Botón principal en lugar de outline -->
      <a class="btn btn-primary alertas-estilo-26" href="<%=ctx%>/capacity-planner/alertas">Volver a Alertas de Red</a>
    </div>
  
</div>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
