<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%! private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");} %>
<% Object cuentaMC=session.getAttribute("usuarioSesion");Usuario usuarioMC=cuentaMC instanceof Usuario?(Usuario)cuentaMC:null;
String nombreMC=usuarioMC==null?"Maintenance Coordinator":usuarioMC.getNombre()+" "+usuarioMC.getApellido();String inicialesMC="MC";
if(usuarioMC!=null){inicialesMC="";for(String p:nombreMC.split("\\s+"))if(!p.isEmpty()&&inicialesMC.length()<2)inicialesMC+=p.substring(0,1).toUpperCase(java.util.Locale.ROOT);}
boolean historialMC="historial".equals(request.getAttribute("seccionMC")); %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%=h(request.getAttribute("tituloMC"))%> · OceanLink</title>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/styles.css?v=maintenance-menu-20261103">
</head>
<body>
<div class="shell mc-shell">
  <aside class="side">
    <div class="brand brand-side"><img class="brand-img" src="<%=request.getContextPath()%>/assets/logo.png" alt="OceanLink"></div>
    <nav class="nav-sec">
      <div class="nav-label">Módulos</div>
      <a class="nav-item <%=historialMC?"":"active"%>" href="<%=request.getContextPath()%>/maintenance-coordinator/mantenimientos">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg><span>Mantenimientos</span>
      </a>
      <a class="nav-item <%=historialMC?"active":""%>" href="<%=request.getContextPath()%>/maintenance-coordinator/historial">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg><span>Histórico (RF31)</span>
      </a>
    </nav>
    <div class="side-foot">
      <div class="role-badge"><div class="rl">Rol activo</div><div class="rn"><span class="dot mc-ref-1"></span>Maintenance Coord.</div></div>
    </div>
  </aside>

  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Maintenance Coordinator</div>
      <div class="grow"></div>
      
      <!-- Menú de usuario desplegable agregado -->
      <% if(!Boolean.TRUE.equals(request.getAttribute("ocultarPerfilMC"))){ %><div class="userpill" tabindex="0">
        <div class="avatar"><%=h(inicialesMC)%></div>
        <div class="uinfo">
            <div class="un"><%=h(nombreMC)%></div>
            <div class="ur">Maintenance Coord.</div>
        </div>
        <span class="ucaret">▾</span>
        <div class="usermenu">
            <a href="<%=request.getContextPath()%>/maintenance-coordinator/mantenimientos?action=perfil">Mi perfil</a>
            <form method="post" action="<%=request.getContextPath()%>/maintenance-coordinator/mantenimientos"><input type="hidden" name="action" value="cerrarSesion"><button type="submit">Cerrar sesión</button></form>
        </div>
      </div><% } %>
      
    </div>

    <div class="content <%=Boolean.TRUE.equals(request.getAttribute("centrarMC"))?"mc-centrado":""%>">
