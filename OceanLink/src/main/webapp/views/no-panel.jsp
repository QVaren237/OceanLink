<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList,pe.edu.oceanlink.bean.Incidencia,pe.edu.oceanlink.bean.Segmento,pe.edu.oceanlink.bean.Usuario" %>
<%!
    private String h(String valor) {
        return valor == null ? "" : valor.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    String ctx = request.getContextPath();
    boolean cerrada = Boolean.TRUE.equals(request.getAttribute("sesionCerrada"));
    if (!cerrada && request.getAttribute("segmentos") == null) {
        response.sendRedirect(ctx + "/NetworkOperatorServlet?action=panel");
        return;
    }
    ArrayList<Segmento> segmentos = (ArrayList<Segmento>) request.getAttribute("segmentos");
    ArrayList<Incidencia> incidencias = (ArrayList<Incidencia>) request.getAttribute("incidencias");
    if (segmentos == null) segmentos = new ArrayList<>();
    if (incidencias == null) incidencias = new ArrayList<>();
    ArrayList<Incidencia> activas = new ArrayList<>();
    for (Incidencia incidencia : incidencias) {
        if (!"Cerrada".equalsIgnoreCase(incidencia.getEstado())) activas.add(incidencia);
    }
    int estaciones = request.getAttribute("landingStations") instanceof Integer
            ? (Integer) request.getAttribute("landingStations") : 0;
    Object cuenta = session.getAttribute("usuarioSesion");
    Usuario operador = cuenta instanceof Usuario ? (Usuario) cuenta : null;
    String nombre = operador == null ? "Network Operator"
            : ((operador.getNombre() == null ? "" : operador.getNombre()) + " "
            + (operador.getApellido() == null ? "" : operador.getApellido())).trim();
    String iniciales = "NO";
    if (operador != null && !nombre.isEmpty()) {
        String[] partes = nombre.split("\\s+");
        iniciales = partes[0].substring(0, 1)
                + (partes.length > 1 ? partes[partes.length - 1].substring(0, 1) : "");
        iniciales = iniciales.toUpperCase(java.util.Locale.ROOT);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Panel · OceanLink</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%=ctx%>/css/styles.css">
</head>
<body>
<div class="shell no-shell">
  <aside class="side">
    <div class="brand brand-side"><img class="brand-img" src="<%=ctx%>/assets/logo.png" alt="OceanLink"></div>
    <nav class="nav-sec">
      <div class="nav-label">Módulos</div>
      <a class="nav-item active" href="<%=ctx%>/NetworkOperatorServlet?action=panel">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        <span>Panel</span>
      </a>
      <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=redes">
        <svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg>
        <span>Estado de la red</span>
      </a>
      <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">
        <svg viewBox="0 0 24 24"><path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17v.5"/></svg>
        <span>Incidencias</span>
      </a>
      <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes"><svg viewBox="0 0 24 24"><path d="M6 3h12a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"/><path d="M8 8h8M8 12h8M8 16h5"/></svg><span>Solicitudes de capacidad</span></a><a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=historial">
        <svg viewBox="0 0 24 24"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 4v4h4"/><path d="M12 8v4l3 2"/></svg>
        <span>Historial</span>
      </a>

    </nav>
    <div class="side-foot">
      <div class="role-badge"><div class="rl">Rol activo</div><div class="rn"><span class="dot"></span>Network Operator</div></div>
    </div>
  </aside>

  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Network Operator</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0">
        <div class="avatar"><%=h(iniciales)%></div>
        <div class="uinfo"><div class="un"><%=h(nombre)%></div><div class="ur">Network Operator</div></div>
        <span class="ucaret">▾</span>
        <div class="usermenu">
          <a href="<%=ctx%>/NetworkOperatorServlet?action=perfil">Mi perfil</a>
          <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
            <input type="hidden" name="action" value="cerrarSesion">
            <button type="submit">Cerrar sesión</button>
          </form>
        </div>
      </div>
    </div>

    <div class="content">
      <% if (cerrada) { %>
      <div class="card center-state"><h1>Sesión cerrada</h1><p>La sesión de este navegador ha finalizado.</p><a class="btn btn-primary" href="<%=ctx%>/NetworkOperatorServlet?action=panel">Volver al panel</a></div>
      <% } else { %>
      <div class="page-head">
        <div>
          <h1>Panel</h1>
          <div class="psub">Resumen general de la operación y de las incidencias de la red.</div>
        </div>
        <div class="grow"></div>
      </div>

      <div class="kpis">
        <div class="kpi"><span class="kbadge">RED</span><div class="kv"><%=segmentos.size()%></div><div class="kl">Redes</div></div>
        <div class="kpi"><span class="kbadge">ALERTA</span><div class="kv"><%=activas.size()%></div><div class="kl">Incidencias activas</div></div>
        <div class="kpi"><span class="kbadge">INFRA</span><div class="kv"><%=estaciones%></div><div class="kl">Landing stations</div></div>
      </div>

      <div class="grid-2">
        <div class="card">
          <div class="card-pad">
            <div class="section-title">Estado de la red</div>
            <div class="psub">Consulta rápida de las redes y su estado operativo.</div>
          </div>
          <div class="card-pad" style="padding-top:0">
            <div class="mini-list">
              <% for (Segmento segmento : segmentos.subList(0, Math.min(3, segmentos.size()))) {
                  String estado = segmento.getEstado();
                  String clase = "Operativo".equals(estado) ? "pill-ok"
                          : "Fuera de servicio".equals(estado) ? "pill-out" : "pill-warn";
              %>
              <div class="mini-row"><span><%=h(segmento.getCodigo())%></span><span class="pill <%=clase%>"><span class="dot"></span><%=h(estado)%></span></div>
              <% } %>
              <% if (segmentos.isEmpty()) { %><p class="psub">No hay redes registradas.</p><% } %>
            </div>
            <a class="btn btn-outline btn-sm" href="<%=ctx%>/NetworkOperatorServlet?action=redes" style="margin-top:14px">Ver estado completo</a>
          </div>
        </div>

        <div class="card">
          <div class="card-pad">
            <div class="section-title">Incidencias activas</div>
            <div class="psub">Incidencias que requieren seguimiento operativo.</div>
          </div>
          <div class="card-pad" style="padding-top:0">
            <div class="mini-list">
              <% for (Incidencia incidencia : activas.subList(0, Math.min(3, activas.size()))) {
                  String severidad = incidencia.getSeveridad();
                  String clase = "Crítica".equals(severidad) ? "pill-crit"
                          : "Alta".equals(severidad) ? "pill-warn" : "pill-ok";
              %>
              <div class="mini-row">
                <span><a class="no-incidencia-link" href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&amp;id=<%=incidencia.getIdIncidencia()%>"><strong><%=h(incidencia.getCodigo())%></strong></a><br><small><%=h(incidencia.getTitulo())%></small></span>
                <span class="pill <%=clase%>"><span class="dot"></span><%=h(severidad)%></span>
              </div>
              <% } %>
              <% if (activas.isEmpty()) { %><p class="psub">No hay incidencias activas.</p><% } %>
            </div>
            <a class="btn btn-outline btn-sm" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias" style="margin-top:14px">Ver incidencias</a>
          </div>
        </div>
      </div>


      <% } %>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>
<dialog id="perfilOperador" class="no-profile">
  <h2>Mi perfil</h2>
  <p><strong>Nombre:</strong> <%=h(nombre)%></p>
  <p><strong>Rol:</strong> Network Operator</p>
  <% if (operador != null) { %><p><strong>Correo:</strong> <%=h(operador.getCorreo())%></p><% } else { %><p>No hay un usuario autenticado en la sesión actual.</p><% } %>
  <form method="dialog"><button class="btn btn-outline">Cerrar</button></form>
</dialog>
</body>
</html>
