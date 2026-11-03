<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,pe.edu.oceanlink.bean.SupervisorAfectado" %>
<%!
 private String esc(String s) {if(s==null)return "—";return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
 @SuppressWarnings("unchecked")
 ArrayList<SupervisorAfectado> afectados=(ArrayList<SupervisorAfectado>)request.getAttribute("afectados");
%>
<table><thead><tr><th>Empresa</th><th>Servicio</th><th>Capacidad</th><th>Contacto</th></tr></thead><tbody>
<% if(afectados==null||afectados.isEmpty()){ %><tr><td colspan="4" style="text-align:center;padding:20px">No se encontraron servicios asociados a los segmentos de este evento.</td></tr>
<% } else {for(SupervisorAfectado a:afectados){ %>
<tr><td><strong><%=esc(a.getEmpresa())%></strong></td><td><%=esc(a.getServicio())%></td><td><%=a.getCapacidad()==null?"Pendiente de asignación":a.getCapacidad().toPlainString()+" Gbps"%></td><td><%=esc(a.getContacto())%></td></tr>
<% }} %></tbody></table>
