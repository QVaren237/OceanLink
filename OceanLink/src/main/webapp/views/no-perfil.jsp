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
<% Usuario cuenta=session.getAttribute("usuarioSesion") instanceof Usuario?(Usuario)session.getAttribute("usuarioSesion"):null; %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Mi perfil · OceanLink</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=ctx%>/css/styles.css">
</head>
<body class="no-shell profile-edit-page">
<main class="profile-edit-main">
  <header class="topbar profile-edit-topbar"><div class="crumb">OceanLink / Network Operator / Mi perfil</div></header>
  <section class="profile-edit-content">
    <div class="profile-edit-head"><p class="eyebrow">CUENTA</p><h1>Mi perfil</h1><div class="psub">Información de tu cuenta.</div></div>
    <% if(cuenta==null){ %>
      <div class="banner banner-err" role="status">No hay un usuario autenticado en este navegador.</div>
    <% } else { %>
      <section class="profile-edit-card">
        <div class="data-list">
          <div class="data-label">Nombre</div><div class="data-value"><%=h(cuenta.getNombre())%></div>
          <div class="data-label">Apellido</div><div class="data-value"><%=h(cuenta.getApellido())%></div>
          <div class="data-label">Correo electrónico</div><div class="data-value"><%=h(cuenta.getCorreo())%></div>
          <div class="data-label">Rol</div><div class="data-value">Network Operator</div>
        </div>
        <p class="hint">Los datos de la cuenta y la contraseña se administran desde Gestión de usuarios.</p>
      </section>
    <% } %>
    <div class="profile-edit-actions"><a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=panel">Volver al panel</a></div>
  </section>
  <footer class="appfoot profile-edit-footer"><span>OceanLink · Centro de operaciones</span></footer>
</main>
</body>
</html>
