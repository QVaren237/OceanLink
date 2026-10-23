<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.Ruta" %>
<%@ page import="pe.edu.oceanlink.bean.RutaSegmento" %>
<%@ page import="pe.edu.oceanlink.bean.LandingStation" %>
<%!
    // Escape para texto y atributos HTML; nunca insertar datos en JavaScript inline.
    private String h(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    if (request.getAttribute("titulo") == null) {
        response.sendRedirect(request.getContextPath() + "/capacity-planner/rutas");
        return;
    }
%>
<%
    Ruta ruta = (Ruta) request.getAttribute("ruta");
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<div class="page-head"><div><a class="link" href="<%= request.getContextPath() %>/capacity-planner/rutas">← Volver a rutas</a><h1><%= h(ruta.getCodigo()) %> · <%= h(ruta.getNombre()) %></h1><p class="psub"><%= h(ruta.getNombreOrigen()) %> → <%= h(ruta.getNombreDestino()) %></p></div><div class="grow"></div><a class="btn btn-outline" href="<%= request.getContextPath() %>/capacity-planner/rutas?action=editar&amp;id=<%= ruta.getIdRuta() %>">Editar ruta</a></div>
<div class="kpis"><div class="kpi"><div class="kv"><%= ruta.getSegmentos().size() %></div><div class="kl">Segmentos del recorrido</div></div><div class="kpi"><div class="kv"><%= h(ruta.getCapacidadDisponible()) %></div><div class="kl">Capacidad disponible del recorrido (Gbps)</div></div><div class="kpi"><div class="kv"><%= ruta.getCantidadServicios() %></div><div class="kl">Servicios asociados</div></div><div class="kpi"><div class="kv"><%= ruta.getCantidadSolicitudes() %></div><div class="kl">Solicitudes asociadas</div></div></div>
<div class="card card-pad"><span class="pill <%= "Operativa".equals(ruta.getEstado()) ? "pill-ok" : "pill-warn" %>"><span class="dot"></span><%= h(ruta.getEstado()) %></span><p class="ruta-description"><%= ruta.getDescripcion() == null || ruta.getDescripcion().isBlank() ? "Sin descripción." : h(ruta.getDescripcion()) %></p><p class="hint">La capacidad disponible del recorrido corresponde al menor valor disponible entre sus segmentos. El estado operativo de cada tramo debe verificarse antes de activar un servicio.</p></div>
<section class="card"><div class="card-head"><h2>Recorrido físico</h2></div><div class="table-wrap"><table><thead><tr><th>Orden</th><th>Segmento</th><th>Desde</th><th>Hasta</th><th>Estado</th><th>Total (Gbps)</th><th>Disponible (Gbps)</th></tr></thead><tbody>
<% int actual = ruta.getIdEstacionOrigen();
   for (RutaSegmento tramo : ruta.getSegmentos()) {
       boolean directo = actual == tramo.getIdEstacionOrigen();
       actual = directo ? tramo.getIdEstacionDestino() : tramo.getIdEstacionOrigen();
%><tr><td><%= tramo.getOrden() %></td><td><%= h(tramo.getCodigo()) %></td><td><%= h(directo ? tramo.getNombreOrigen() : tramo.getNombreDestino()) %></td><td><%= h(directo ? tramo.getNombreDestino() : tramo.getNombreOrigen()) %></td><td><%= h(tramo.getEstado()) %></td><td><%= h(tramo.getCapacidadTotal()) %></td><td><%= h(tramo.getCapacidadDisponible()) %></td></tr><% } %>
<% if (ruta.getSegmentos().isEmpty()) { %><tr><td colspan="7" class="ruta-empty">Esta ruta no tiene segmentos registrados.</td></tr><% } %>
</tbody></table></div></section>
<jsp:include page="/views/capacity-planner-fin.jsp" />
