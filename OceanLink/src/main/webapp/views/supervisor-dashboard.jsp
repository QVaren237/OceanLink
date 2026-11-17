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
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dashboard · OceanLink</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/supervisor.css">
</head>
<body>
<div class="shell">
  <aside class="side">
    <div class="brand brand-side"><img class="brand-img" src="<%= request.getContextPath() %>/assets/logo.png" alt="Ocean Link Logistics"></div>
    <nav class="nav-sec">
      <div class="nav-label">Módulos</div>
      <a class="nav-item active" href="<%= request.getContextPath() %>/supervisor/panel">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
        <span>Panel</span>
      </a>
      <a class="nav-item" href="<%=request.getContextPath()%>/supervisor/incidencias">
        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <span>Fallas y Mantenimientos</span>
      </a>
      <a class="nav-item" href="<%=request.getContextPath()%>/supervisor/reportes">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        <span>Reportes Históricos</span>
      </a>
    </nav>
    <div class="side-foot">
      <div class="role-badge">
        <div class="rl">Rol activo</div>
        <div class="rn"><span class="dot"></span>Supervisor</div>
      </div>
    </div>
  </aside>
  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Supervisor</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0" aria-label="Perfil de usuario">
        <div class="avatar"><%= pe.edu.oceanlink.util.Vista.iniciales(session) %></div>
        <div class="uinfo"><div class="un"><%= pe.edu.oceanlink.util.Vista.nombre(session) %></div><div class="ur">Supervisor</div></div>
        <span class="ucaret" aria-hidden="true">▾</span>
        <div class="usermenu"><a href="#">Editar perfil</a><a href="<%= request.getContextPath() %>/sesion-cerrada.jsp">Cerrar sesión</a></div>
      </div>
    </div>
    <div class="content">
      <div class="page-head">
        <div>
          <h1>Control de Operaciones</h1>
          <div class="psub">Monitoreo global del uso de la fibra e incidentes en tiempo real.</div>
        </div>
      </div>
      
      <!-- KPIs con colores de alerta según utilización -->
      <div class="kpis">
        <div class="kpi">
          <span class="kbadge <%= resumen.getUtilizacionPromedio().compareTo(new java.math.BigDecimal("80")) >= 0 ? "warn" : "" %>"><%= resumen.getUtilizacionPromedio() %>%</span>
          <div class="kv"><%= resumen.getUtilizacionPromedio().compareTo(new java.math.BigDecimal("80")) >= 0 ? "Uso Alto" : "Uso Normal" %></div>
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
          <div class="kv"><%= resumen.getTramosSaturados() %></div>
          <div class="kl">Tramos saturados</div>
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
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
            <% if (tramos.isEmpty()) { %>
              <tr><td colspan="6" style="text-align:center;padding:28px;color:var(--muted)">No hay tramos con utilización igual o superior al 80 %.</td></tr>
            <% } else { for (SupervisorTramo tramo : tramos) {
                 java.math.BigDecimal total = tramo.getCapacidadTotal();
                 java.math.BigDecimal disponible = tramo.getCapacidadDisponible();
                 java.math.BigDecimal porcentaje = tramo.getPorcentajeUtilizacion();
                 boolean critico = porcentaje != null && porcentaje.compareTo(new java.math.BigDecimal("95")) >= 0;
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
                <td><span class="pill <%= critico ? "pill-crit" : "pill-warn" %>"><span class="dot"></span><%= esc(tramo.getEstado()) %></span></td>
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