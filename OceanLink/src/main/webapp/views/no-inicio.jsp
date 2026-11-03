<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.*" %>
<%!
 private String h(Object v) { return v==null?"—":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String pill(String v) {
   if (v==null) return "pill-neutral";
   if (Arrays.asList("Crítica","Detectada","Fuera de servicio","Rechazada").contains(v)) return "pill-crit";
   if (Arrays.asList("Operativo","Servicio restaurado","Aprobada","Baja").contains(v)) return "pill-ok";
   if (Arrays.asList("Media","En mantenimiento").contains(v)) return "pill-info";
   return "Cerrada".equals(v)?"pill-neutral":"pill-warn";
 }
%>
<% String ctx=request.getContextPath(); %>
<%
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
  <title><%=h(request.getAttribute("tituloNO"))%> · OceanLink</title>
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
      <a class="nav-item <%= "panel".equals(request.getAttribute("seccionNO")) ? "active" : "" %>" href="<%=ctx%>/NetworkOperatorServlet?action=panel">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
        <span>Panel</span>
      </a>
      <a class="nav-item <%= "redes".equals(request.getAttribute("seccionNO")) ? "active" : "" %>" href="<%=ctx%>/NetworkOperatorServlet?action=redes">
        <svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg>
        <span>Estado de la red</span>
      </a>
      <a class="nav-item <%= "incidencias".equals(request.getAttribute("seccionNO")) ? "active" : "" %>" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">
        <svg viewBox="0 0 24 24"><path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17v.5"/></svg>
        <span>Incidencias</span>
      </a>
      <a class="nav-item <%= "solicitudes".equals(request.getAttribute("seccionNO")) ? "active" : "" %>" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes"><svg viewBox="0 0 24 24"><path d="M6 3h12a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z"/><path d="M8 8h8M8 12h8M8 16h5"/></svg><span>Solicitudes de capacidad</span></a><a class="nav-item <%= "historial".equals(request.getAttribute("seccionNO")) ? "active" : "" %>" href="<%=ctx%>/NetworkOperatorServlet?action=historial">
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
