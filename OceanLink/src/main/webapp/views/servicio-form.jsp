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
<%@ page import="java.util.ArrayList,pe.edu.oceanlink.bean.Cliente,pe.edu.oceanlink.bean.Ruta" %>
<% Cliente cliente=(Cliente)request.getAttribute("cliente"); ArrayList<Ruta> rutas=(ArrayList<Ruta>)request.getAttribute("rutas"); %>
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
<div class="page-head"><div><h1>Registrar nuevo servicio</h1><div class="psub">Asigna una ruta comercial al cliente. Los datos se obtienen de MySQL.</div></div></div>
<div class="card card-pad" style="max-width:780px"><form method="post" action="<%=request.getContextPath()%>/capacity-planner/servicios?action=confirmar">
<input type="hidden" name="cliente" value="<%=cliente.getIdCliente()%>">
<div class="field"><label>Cliente titular (*)</label><input class="input" value="<%=esc(cliente.getRazonSocial())%>" readonly></div>
<div class="form-grid" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
<div class="field"><label for="ruta">Ruta extremo a extremo (*)</label><select class="input" id="ruta" name="ruta" required><option value="">Selecciona la ruta solicitada...</option>
<% if(rutas!=null)for(Ruta r:rutas){ if("Operativa".equals(r.getEstado())){ %><option value="<%=r.getIdRuta()%>"><%=esc(r.getNombre())%></option><% }} %></select></div>
<div class="field"><label for="fechaActivacion">Fecha de activación programada (*)</label><input class="input" type="date" name="fechaActivacion" id="fechaActivacion" required></div></div>
<div class="field"><label for="capacidad">Capacidad contratada (Gbps) (*)</label><input class="input" type="number" name="capacidad" id="capacidad" step="0.01" min="0.01" max="9999999999.99" placeholder="Ej.: 100.00" required></div>
<div class="slabel" style="margin-top:20px">Topología física involucrada</div>
<div class="hint">La visualización y validación de los segmentos de la ruta requiere integrar RutaSegmentoDAO y comprobar capacidad disponible. No se muestra una reserva ficticia.</div>
<div class="form-actions"><a class="btn btn-outline" href="<%=request.getContextPath()%>/capacity-planner/servicios?action=detalle&amp;cliente=<%=cliente.getIdCliente()%>">Cancelar</a><button type="submit" class="btn btn-primary">Validar y continuar</button></div></form></div>
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
