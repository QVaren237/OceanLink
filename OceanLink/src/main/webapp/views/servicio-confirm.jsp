<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%! private String esc(Object x){
 if(x==null)return "";
 return String.valueOf(x).replace("&","&amp;").replace("<","&lt;")
 .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
} %>
<%@ page import="pe.edu.oceanlink.bean.Cliente,pe.edu.oceanlink.bean.Ruta,pe.edu.oceanlink.bean.Servicio" %>
<% Cliente cliente=(Cliente)request.getAttribute("cliente"); Ruta ruta=(Ruta)request.getAttribute("ruta"); Servicio servicio=(Servicio)request.getAttribute("servicio"); %>
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
  <!-- Estilos exclusivos de la confirmación. No modifica el CSS compartido de OceanLink. -->
  <style>
    .confirm-view .confirm-wrap { width:100%; max-width:640px; margin-left:0; margin-right:auto; box-sizing:border-box; }
    .confirm-view .page-head.confirm-wrap { margin-bottom:20px; }
    .confirm-view .page-head.confirm-wrap h1 { margin-bottom:2px; }
    .confirm-view .card.confirm-wrap { padding:20px 22px; }
    .confirm-view .info-strip { display:flex; align-items:flex-start; gap:10px; background:#e4f2f0; border-radius:12px; padding:13px 15px; margin-bottom:15px; }
    .confirm-view .info-strip .ii { width:20px; height:20px; flex:none; border-radius:50%; background:#fff; color:#328f91; display:flex; align-items:center; justify-content:center; font-size:10px; font-weight:800; }
    .confirm-view .info-strip .it { font-size:11px; font-weight:800; margin-bottom:3px; }
    .confirm-view .info-strip .id { font-size:10px; color:#718a8b; line-height:1.55; }
    .confirm-view .summary-box { border:1px solid #d8e5e5; border-radius:16px; overflow:hidden; margin-top:4px; }
    .confirm-view .summary-row { display:flex; align-items:center; justify-content:space-between; gap:14px; min-height:47px; padding:13px 20px; border-bottom:1px solid #d8e5e5; box-sizing:border-box; }
    .confirm-view .summary-row:last-child { border-bottom:0; }
    .confirm-view .summary-row > span { font-family:inherit; font-size:11px; line-height:1.4; color:#70868b; font-weight:600; }
    .confirm-view .summary-row > strong { font-family:inherit; font-size:12.5px; line-height:1.4; font-weight:800; color:#16343e; text-align:right; overflow-wrap:anywhere; }
    .confirm-view .summary-row .confirm-segment { display:block; font-size:inherit; color:inherit; font-weight:inherit; }
    .confirm-view .confirm-note { margin:12px 0 0; font-size:10px; color:#8199a0; line-height:1.5; }
    .confirm-view .form-actions { display:flex; align-items:center; justify-content:flex-end; gap:9px; margin-top:22px; padding-top:18px; border-top:1px solid #d8e5e5; }
    @media(max-width:680px) {
      .confirm-view .card.confirm-wrap { padding:16px; }
      .confirm-view .summary-row { padding:12px; }
      .confirm-view .summary-row > span { max-width:48%; }
    }
  </style>
</head>
<body>
  <div class="shell">
    <aside class="side">
      <div class="brand brand-side"><img class="brand-img" src="<%=request.getContextPath()%>/assets/logo.png" alt="OceanLink Logistics"></div>
      <nav class="nav-sec">
        <div class="nav-label">Módulos</div>
        <a class="nav-item" href="<%=request.getContextPath()%>/CapacityPlannerServlet">
          <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
          <span>Panel General</span>
        </a>
        <a class="nav-item active" href="<%=request.getContextPath()%>/capacity-planner/servicios">
          <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
          <span>Servicios por cliente</span>
        </a>
        <a class="nav-item" href="<%=request.getContextPath()%>/capacity-planner/rutas">
          <svg viewBox="0 0 24 24"><path d="M3 15a9 9 0 0 1 18 0"/></svg>
          <span>Rutas</span>
        </a>
        <a class="nav-item" href="#">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          <span>Solicitudes</span>
        </a>
        <a class="nav-item" href="#">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
          <span>Alertas de Red</span>
        </a>
        <a class="nav-item" href="#">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
          <span>Histórico</span>
        </a>
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
        <div class="userpill" tabindex="0">
            <div class="avatar">GG</div>
            <div class="uinfo">
                <div class="un">Capacity Planner</div>
                <div class="ur">Capacity Planner</div>
            </div>
            <span class="ucaret">▾</span>
            <div class="usermenu">
                <a href="#">Editar perfil</a>
                <a href="#">Cerrar sesión</a>
            </div>
        </div>
      </div>

      <div class="content confirm-view" style="flex:1">
<div class="page-head confirm-wrap">
  <div>
    <h1>Confirmar asignación de servicio</h1>
    <div class="psub">Revisa la ruta y la capacidad antes de registrar el servicio para el cliente.</div>
  </div>
</div>
<div class="card card-pad confirm-wrap">
  <div class="info-strip">
    <div class="ii">i</div>
    <div>
      <div class="it"><%=esc(cliente.getRazonSocial())%></div>
      <div class="id"><%=esc(servicio.getOrigen())%> → <%=esc(servicio.getDestino())%></div>
    </div>
  </div>

  <div class="summary-box">
    <div class="summary-row"><span>Cliente titular (*)</span><strong><%=esc(cliente.getRazonSocial())%></strong></div>
    <div class="summary-row"><span>Ruta / Enlace (*)</span><strong><%=esc(ruta.getCodigo())%></strong></div>
    <div class="summary-row"><span>Estación Origen</span><strong><%=esc(servicio.getOrigen())%></strong></div>
    <div class="summary-row"><span>Estación Destino</span><strong><%=esc(servicio.getDestino())%></strong></div>
    <div class="summary-row"><span>Fecha de activación</span><strong><%=servicio.getFechaActivacion().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))%></strong></div>
    <div class="summary-row"><span>Segmentos de la ruta (*)</span><strong>
      <% if(ruta.getSegmentos()!=null && !ruta.getSegmentos().isEmpty()) {
           for(pe.edu.oceanlink.bean.RutaSegmento tramo : ruta.getSegmentos()) { %>
        <span class="confirm-segment"><%=esc(tramo.getCodigo())%></span>
      <%   }
         } else { %>—<% } %>
    </strong></div>
    <div class="summary-row"><span>Capacidad contratada</span><strong><%=servicio.getCapacidadContratada()%> Gbps</strong></div>
  </div>

  <p class="confirm-note">Este registro crea el servicio contratado; la reserva de capacidad en la tabla reserva_capacidad todavía no está implementada.</p>

  <form method="post" action="<%=request.getContextPath()%>/capacity-planner/servicios?action=guardar">
    <input type="hidden" name="cliente" value="<%=servicio.getIdCliente()%>">
    <input type="hidden" name="ruta" value="<%=servicio.getIdRuta()%>">
    <input type="hidden" name="capacidad" value="<%=servicio.getCapacidadContratada()%>">
    <input type="hidden" name="fechaActivacion" value="<%=servicio.getFechaActivacion()%>">
    <div class="form-actions">
      <a class="btn btn-outline" href="<%=request.getContextPath()%>/capacity-planner/servicios?action=formCrear&amp;cliente=<%=servicio.getIdCliente()%>">Volver a editar</a>
      <button class="btn btn-primary" type="submit">Confirmar y guardar</button>
    </div>
  </form>
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
