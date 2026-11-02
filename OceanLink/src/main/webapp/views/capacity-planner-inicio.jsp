<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
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
    String seccionPlanner = request.getAttribute("seccion") == null ? "rutas" : request.getAttribute("seccion").toString();
    Object usuarioSesionPlanner = session.getAttribute("usuarioSesion");
    Usuario perfilPlanner = usuarioSesionPlanner instanceof Usuario ? (Usuario) usuarioSesionPlanner : null;
    // Perfil de la maqueta mientras el equipo integra el inicio de sesión.
    String nombrePlanner = perfilPlanner == null ? "Gerson García" :
            ((perfilPlanner.getNombre() == null ? "" : perfilPlanner.getNombre()) + " " +
             (perfilPlanner.getApellido() == null ? "" : perfilPlanner.getApellido())).trim();
    String inicialesPlanner = "";
    for (String partePlanner : nombrePlanner.split("\\s+")) {
        if (!partePlanner.isEmpty() && inicialesPlanner.length() < 2) inicialesPlanner += partePlanner.substring(0, 1).toUpperCase(java.util.Locale.ROOT);
    }
    // Los datos compartidos viajan en request, como en los ejemplos de jsp:include.
    request.setAttribute("nombrePlanner", nombrePlanner);
    request.setAttribute("inicialesPlanner", inicialesPlanner);
    request.setAttribute("perfilPlanner", perfilPlanner);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= h(request.getAttribute("titulo")) %> · OceanLink</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body>
<div class="shell rutas-shell">
    <aside class="side">
        <div class="brand brand-side"><img class="brand-img" src="<%= request.getContextPath() %>/assets/logo.png" alt="OceanLink"></div>
        <nav class="nav-sec" aria-label="Módulos">
            <div class="nav-label">Módulos</div>
            <a class="nav-item <%= "panel".equals(seccionPlanner) ? "active" : "" %>" <%= "panel".equals(seccionPlanner) ? "aria-current=\"page\"" : "" %> href="<%= request.getContextPath() %>/capacity-planner/panel">
                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg><span>Panel General</span>
            </a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/servicios"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg><span>Servicios por cliente</span></a>
            <a class="nav-item <%= "rutas".equals(seccionPlanner) ? "active" : "" %>" <%= "rutas".equals(seccionPlanner) ? "aria-current=\"page\"" : "" %> href="<%= request.getContextPath() %>/capacity-planner/rutas">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="5" cy="5" r="2"/><circle cx="19" cy="19" r="2"/><path d="M7 5h8a4 4 0 0 1 0 8H9a4 4 0 0 0 0 8h8"/></svg>
                <span>Rutas</span>
            </a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/capacidad"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 15a9 9 0 0 1 18 0M12 15l4-6"/></svg><span>Capacidad</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/solicitudes"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6M8 13h8M8 17h8"/></svg><span>Solicitudes</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/alertas"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3 2 21h20zM12 9v5M12 17v1"/></svg><span>Alertas de Red</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/historico"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12h4l3 8 4-16 3 8h4"/></svg><span>Histórico</span></a>
        </nav>
        <div class="side-foot"><div class="role-badge"><div class="rl">Rol activo</div><div class="rn"><span class="dot"></span>Capacity Planner</div></div></div>
    </aside>
    <main class="main">
        <div class="topbar">
            <div class="crumb">OceanLink / Capacity Planner<%= "rutas".equals(seccionPlanner) ? " / Rutas" : "perfil".equals(seccionPlanner) ? " / Mi perfil" : "" %></div>
            <div class="grow"></div>
            <% if (!"sesion".equals(seccionPlanner)) { %>
            <div class="userpill" tabindex="0" aria-label="Perfil de <%= h(nombrePlanner) %>">
                <div class="avatar"><%= h(inicialesPlanner) %></div>
                <div class="uinfo"><div class="un"><%= h(nombrePlanner) %></div><div class="ur">Capacity Planner</div></div>
                <span class="ucaret" aria-hidden="true">▾</span>
                <div class="usermenu">
                    <a href="<%= request.getContextPath() %>/capacity-planner/panel?action=perfil">Mi perfil</a>
                    <form method="post" action="<%= request.getContextPath() %>/capacity-planner/panel"><input type="hidden" name="action" value="cerrarSesion"><button type="submit">Cerrar sesión</button></form>
                </div>
            </div>
            <% } %>
        </div>
        <div class="content">
