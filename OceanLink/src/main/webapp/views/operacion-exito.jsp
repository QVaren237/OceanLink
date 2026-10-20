<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String modulo = request.getParameter("mod");
    String operacion = request.getParameter("op");
    
    String titulo = "Operación exitosa";
    String mensaje = "La operación se completó correctamente.";
    String link = request.getContextPath() + "/PanelServlet";
    String nombreModulo = "panel";
    
    if ("usuario".equals(modulo)) {
        link = request.getContextPath() + "/UsuarioServlet?action=lista";
        nombreModulo = "usuarios";
        if ("crear".equals(operacion)) { titulo = "Usuario registrado"; mensaje = "El usuario quedó registrado con éxito."; }
        else if ("editar".equals(operacion)) { titulo = "Usuario actualizado"; mensaje = "Los datos del usuario fueron actualizados con éxito."; }
    } else if ("cliente".equals(modulo)) {
        link = request.getContextPath() + "/ClienteServlet?action=lista";
        nombreModulo = "clientes";
        if ("crear".equals(operacion)) { titulo = "Cliente registrado"; mensaje = "El cliente corporativo quedó registrado con éxito."; }
        else if ("editar".equals(operacion)) { titulo = "Cliente actualizado"; mensaje = "Los datos del cliente corporativo fueron actualizados con éxito."; }
    } else if ("landing".equals(modulo)) {
        link = request.getContextPath() + "/LandingStationServlet?action=lista";
        nombreModulo = "landing stations";
        if ("crear".equals(operacion)) { titulo = "Estación registrada"; mensaje = "La landing station quedó registrada con éxito."; }
        else if ("editar".equals(operacion)) { titulo = "Estación actualizada"; mensaje = "Los datos de la landing station fueron actualizados con éxito."; }
    } else if ("redes".equals(modulo)) {
        link = request.getContextPath() + "/RedesSubmarinasServlet?action=lista";
        nombreModulo = "redes submarinas";
        if ("crear".equals(operacion)) { titulo = "Segmento registrado"; mensaje = "El segmento submarino quedó registrado con éxito."; }
        else if ("editar".equals(operacion)) { titulo = "Segmento actualizado"; mensaje = "Los datos del segmento submarino fueron actualizados con éxito."; }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= titulo %> · OceanLink</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css">
</head>
<body>
<div class="shell">
  <aside class="side">
    <div class="brand brand-side">
      <img class="brand-img" src="<%= request.getContextPath() %>/assets/logo.png" alt="Ocean Link Logistics">
    </div>
    <nav class="nav-sec">
      <div class="nav-label">Módulos</div>
      <a class="nav-item" href="<%= request.getContextPath() %>/PanelServlet"><svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg><span>Panel</span></a>
      <a class="nav-item <%= "usuario".equals(modulo) ? "active" : "" %>" href="<%= request.getContextPath() %>/UsuarioServlet?action=lista"><svg viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.2"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><path d="M16 6.2a3 3 0 0 1 0 5.6M17.5 19a5 5 0 0 0-2.5-4.3"/></svg><span>Usuarios</span></a>
      <a class="nav-item <%= "cliente".equals(modulo) ? "active" : "" %>" href="<%= request.getContextPath() %>/ClienteServlet?action=lista"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 12h18"/></svg><span>Clientes</span></a>
      <a class="nav-item <%= "landing".equals(modulo) ? "active" : "" %>" href="<%= request.getContextPath() %>/LandingStationServlet"><svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg><span>Landing Stations</span></a>
      <a class="nav-item <%= "redes".equals(modulo) ? "active" : "" %>" href="<%= request.getContextPath() %>/RedesSubmarinasServlet"><svg viewBox="0 0 24 24"><path d="M3 12h4l3-7 4 14 3-7h4"/></svg><span>Redes submarinas</span></a>
    </nav>
    <div class="side-foot">
      <div class="role-badge">
        <div class="rl">Rol activo</div>
        <div class="rn"><span class="dot"></span>Administrador</div>
      </div>
    </div>
  </aside>

  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Administrador</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0">
        <div class="avatar">AA</div>
        <div class="uinfo">
          <div class="un">Adrian Angles</div>
          <div class="ur">Administrador</div>
        </div>
        <span class="ucaret">▾</span>
        <div class="usermenu">
          <a href="#">Editar perfil</a>
          <a href="#">Cerrar sesión</a>
        </div>
      </div>
    </div>

    <div class="content">
      <div class="page-head">
        <div>
          <h1></h1>
          <div class="psub"></div>
        </div>
        <div class="grow"></div>
      </div>

      <div class="card center-state">
        <div class="cs-ic" style="background:var(--teal-soft);border-color:#64b7ac;color:var(--teal-dd)">✓</div>
        <h2><%= titulo %></h2>
        <p><%= mensaje %></p>
        <a class="btn btn-primary" style="margin-top:12px" href="<%= link %>">Volver a <%= nombreModulo %></a>
      </div>
    </div>
    
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>
</body>
</html>
