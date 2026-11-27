<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="pe.edu.oceanlink.bean.SupervisorResumen,pe.edu.oceanlink.bean.SupervisorTramo,java.util.ArrayList" %>
<%!
  private String esc(String value) {
    if (value == null) return "—";
    return value.replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
  }
%>
<%
  SupervisorResumen resumen = (SupervisorResumen) request.getAttribute("resumen");
  @SuppressWarnings("unchecked")
  ArrayList<SupervisorTramo> tramos = (ArrayList<SupervisorTramo>) request.getAttribute("tramos");
  if (resumen == null || tramos == null) {
    response.sendRedirect(request.getContextPath() + "/supervisor/panel");
    return;
  }
%>
<!DOCTYPE html>
<html lang="es" class="tema-supervisor">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dashboard · OceanLink</title>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=supervisor">
</head>
<body>
<div class="shell">
  <jsp:include page="/views/supervisor-sidebar.jsp">
    <jsp:param name="moduloSupervisor" value="panel" />
  </jsp:include>
  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Supervisor</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0" aria-label="Perfil de usuario">
        <div class="avatar"<%= pe.edu.oceanlink.servlet.Vista.avatarAttr(session) %>><%= pe.edu.oceanlink.servlet.Vista.iniciales(session) %></div>
        <div class="uinfo"><div class="un"><%= pe.edu.oceanlink.servlet.Vista.nombre(session) %></div><div class="ur">Supervisor</div></div>
        <span class="ucaret" aria-hidden="true">▾</span>
        <div class="usermenu"><a href="<%= request.getContextPath() %>/PerfilServlet">Editar perfil</a><a href="<%= request.getContextPath() %>/sesion-cerrada.jsp">Cerrar sesión</a></div>
      </div>
    </div>
    <div class="content">
      <div class="page-head">
        <div>
          <h1>Control de Operaciones</h1>
          <div class="psub">Monitoreo global del uso de la fibra e incidentes en tiempo real.</div>
        </div>
      </div>

      <div class="kpis">
        <div class="kpi">
          <%
            java.math.BigDecimal promedio = resumen.getUtilizacionPromedio();
            boolean usoAlto = promedio != null && promedio.compareTo(new java.math.BigDecimal("80")) >= 0;
          %>
          <% if (promedio != null) { %>
          <span class="kbadge <%= usoAlto ? "warn" : "" %>"><%= promedio %>%</span>
          <% } %>
          <div class="kv"><%= promedio == null ? "Sin datos" : usoAlto ? "Uso Alto" : "Uso Normal" %></div>
          <div class="kl">Utilización prom. de red</div>
        </div>
        <div class="kpi">
          <span class="kbadge crit">ACTIVAS</span>
          <div class="kv"><%= resumen.getFallasActivas() %></div>
          <div class="kl">Fallas activas</div>
        </div>
        <div class="kpi">
          <span class="kbadge">ACTUAL</span>
          <div class="kv"><%= resumen.getMantenimientosSemana() %></div>
          <div class="kl">Mantenimientos semana</div>
        </div>
        <div class="kpi">
          <span class="kbadge crit">> 95%</span>
          <div class="kv"><%= resumen.getTramosCriticos() %></div>
          <div class="kl">Tramos críticos</div>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <h3>Tramos con Alta Utilización</h3>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
            <tr>
              <th>Segmento</th>
              <th>Origen</th>
              <th>Destino</th>
              <th>Capacidad Total</th>
              <th>Capacidad Disponible</th>
              <th>Utilización</th>
              <th>Estado</th>
            </tr>
            </thead>
            <tbody>
            <% if (tramos.isEmpty()) { %>
            <tr><td colspan="7" style="text-align:center;padding:28px;color:var(--muted)">No hay tramos con utilización igual o superior al 80 %.</td></tr>
            <% } else { for (SupervisorTramo tramo : tramos) {
              java.math.BigDecimal total = tramo.getCapacidadTotal();
              java.math.BigDecimal disponible = tramo.getCapacidadDisponible();
              java.math.BigDecimal porcentaje = tramo.getPorcentajeUtilizacion();
              boolean critico = tramo.isCritico();
              java.math.BigDecimal restante = (total != null && total.signum() > 0 && disponible != null)
                      ? disponible.multiply(new java.math.BigDecimal("100")).divide(total, 2, java.math.RoundingMode.HALF_UP)
                      : java.math.BigDecimal.ZERO;
            %>
            <tr>
              <td><strong><%= esc(tramo.getCodigo()) %></strong></td>
              <td><%= esc(tramo.getOrigen()) %></td>
              <td><%= esc(tramo.getDestino()) %></td>
              <td><%= total == null ? "—" : total.toPlainString() + " Gbps" %></td>
              <td><strong style="color:var(<%= critico ? "--danger" : "--warn" %>)"><%= disponible == null ? "—" : disponible.toPlainString() + " Gbps (" + restante.toPlainString() + "%)" %></strong></td>
              <td><span class="pill <%= critico ? "pill-crit" : "pill-warn" %>"><span class="dot"></span><%= porcentaje.toPlainString() %> % · <%= critico ? "Crítico" : "Alto" %></span></td>
              <td><%= esc(tramo.getEstado()) %></td>
            </tr>
            <% } } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>
</body>
</html>
