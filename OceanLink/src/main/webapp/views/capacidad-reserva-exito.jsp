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

%>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="capacidad-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<div class="card center-state"><div class="cs-ic" style="border-color:#8dcac3;color:var(--teal)">✓</div><h2>Reserva registrada</h2><p><%=h(request.getAttribute("mensajeReserva"))%></p><a class="btn btn-primary" href="<%=ctx%>/capacity-planner/capacidad">Volver a Capacidad</a><a class="btn btn-outline" href="<%=ctx%>/capacity-planner/solicitudes">Ver solicitudes</a></div>
</div>

<jsp:include page="/views/capacity-planner-fin.jsp"/>
