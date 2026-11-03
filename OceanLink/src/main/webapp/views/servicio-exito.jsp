<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%!
    private String escPerfilServicios(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    Object sesionServicios = session.getAttribute("usuarioSesion");
    Usuario perfilServicios = sesionServicios instanceof Usuario ? (Usuario) sesionServicios : null;
    String nombreServicios = perfilServicios == null ? "Gerson García" :
            ((perfilServicios.getNombre() == null ? "" : perfilServicios.getNombre()) + " " +
             (perfilServicios.getApellido() == null ? "" : perfilServicios.getApellido())).trim();
    String inicialesServicios = "";
    for (String parteServicios : nombreServicios.split("\\s+")) {
        if (!parteServicios.isEmpty() && inicialesServicios.length() < 2)
            inicialesServicios += parteServicios.substring(0, 1).toUpperCase(java.util.Locale.ROOT);
    }
%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%! private String esc(Object x){
 if(x==null)return "";
 return String.valueOf(x).replace("&","&amp;").replace("<","&lt;")
 .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
} %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestión de Clientes · OceanLink</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/styles.css">
  <style>
    /* Diseño equivalente a service-success.html original, sin cambiar styles.css. */
    .ocean-success-card { margin:auto; max-width:500px; }
    .ocean-success-card .cs-ic { border-color:#55b6a8; color:var(--teal); font-weight:bold; }
    .ocean-success-card .ocean-success-button { margin-top:10px; }
  </style>
</head>
<body>
  <div class="shell rutas-shell">
    <aside class="side">
      <div class="brand brand-side"><img class="brand-img" src="<%=request.getContextPath()%>/assets/logo.png" alt="OceanLink Logistics"></div>
      <nav class="nav-sec" aria-label="Módulos">
            <div class="nav-label">Módulos</div>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/panel">
                <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg><span>Panel General</span>
            </a>
            <a class="nav-item active" aria-current="page" href="<%= request.getContextPath() %>/capacity-planner/servicios"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg><span>Servicios por cliente</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/rutas">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="5" cy="5" r="2"/><circle cx="19" cy="19" r="2"/><path d="M7 5h8a4 4 0 0 1 0 8H9a4 4 0 0 0 0 8h8"/></svg>
                <span>Rutas</span>
            </a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/capacidad"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 15a9 9 0 0 1 18 0M12 15l4-6"/></svg><span>Capacidad</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/solicitudes"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8zM14 2v6h6M8 13h8M8 17h8"/></svg><span>Solicitudes</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/alertas"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 3 2 21h20zM12 9v5M12 17v1"/></svg><span>Alertas de Red</span></a>
            <a class="nav-item" href="<%= request.getContextPath() %>/capacity-planner/historico"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 12h4l3 8 4-16 3 8h4"/></svg><span>Histórico</span></a>
        </nav>
      <div class="side-foot">
        <div class="role-badge">
          <div class="rl">Rol activo</div>
          <div class="rn"><span class="dot"></span>Capacity Planner</div>
        </div>
      </div>
    </aside>

    <div class="main">
      <div class="topbar">
        <div class="crumb">OceanLink / Capacity Planner</div>
        <div class="grow"></div>
        <div class="userpill" tabindex="0" aria-label="Perfil de <%= escPerfilServicios(nombreServicios) %>">
            <div class="avatar"><%= escPerfilServicios(inicialesServicios) %></div>
            <div class="uinfo"><div class="un"><%= escPerfilServicios(nombreServicios) %></div><div class="ur">Capacity Planner</div></div>
            <span class="ucaret" aria-hidden="true">▾</span>
            <div class="usermenu">
                <a href="<%= request.getContextPath() %>/capacity-planner/panel?action=perfil">Mi perfil</a>
                <form method="post" action="<%= request.getContextPath() %>/capacity-planner/panel"><input type="hidden" name="action" value="cerrarSesion"><button type="submit">Cerrar sesión</button></form>
            </div>
        </div>
      </div>

      <div class="content" style="flex:1">
<div class="card center-state ocean-success-card">
          <div class="cs-ic" aria-hidden="true">✓</div>
          <h2>El servicio se guardó correctamente</h2>
          <p>El servicio contratado se registró exitosamente para el cliente.</p>
          <a href="<%=request.getContextPath()%>/capacity-planner/servicios?action=detalle&amp;cliente=<%=request.getAttribute("clienteId")%>"
             class="btn btn-primary ocean-success-button">Aceptar</a>
        </div>
      </div>
      <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
    </div>
  </div>
<script>
function filtrarFilas(inputId, tableId){
 const query=document.getElementById(inputId).value.toLocaleLowerCase();
 document.querySelectorAll('#'+tableId+' tbody tr').forEach(tr=>{
  tr.style.display=tr.textContent.toLocaleLowerCase().includes(query)?'':'none';
 });
}
</script>
</body></html>
