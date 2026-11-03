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
<%@ page import="java.util.ArrayList,pe.edu.oceanlink.bean.Cliente,pe.edu.oceanlink.bean.Servicio" %>
<% Cliente cliente=(Cliente)request.getAttribute("cliente"); ArrayList<Servicio> lista=(ArrayList<Servicio>)request.getAttribute("lista"); %>
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
/* Solo afecta a la vista de información del cliente. */
/* Botones idénticos en tamaño y trazo a client-detail.html. */
.detalle-action-group{display:flex;gap:6px;flex-wrap:wrap}
.detalle-icon-btn{width:36px;height:36px;padding:0;display:inline-flex;align-items:center;justify-content:center;border-radius:9px;border:1px solid var(--line-strong,#d5e2e5);background:#fff;color:var(--muted,#5a8894);cursor:pointer}
.detalle-icon-btn:hover{border-color:var(--teal,#479ba4);color:var(--teal-d,#317d88);background:var(--aqua,#e9f5f5)}
.detalle-icon-btn svg{width:17px;height:17px;stroke:currentColor;fill:none;stroke-width:1.9;stroke-linecap:round;stroke-linejoin:round}
/* Ventanas basadas en el HTML original; solo afectan a esta página. */
.detalle-modal-back[hidden]{display:none!important}
.detalle-modal-back{position:fixed;inset:0;background:rgba(32,60,62,.34);z-index:1000;display:flex;align-items:center;justify-content:center;padding:24px}
.detalle-modal{width:min(430px,100%);background:var(--surface,#fff);border-radius:var(--radius,18px);box-shadow:0 24px 60px rgba(42,91,94,.28);padding:26px 28px}
.detalle-modal.route-modal{width:min(580px,100%)}
.detalle-modal h3{font-size:18px;font-weight:800;margin:0 0 9px;font-family:var(--head,inherit)}
.detalle-modal p{font-size:12px;color:var(--muted,#82959b);line-height:1.6;margin:0 0 20px}
.detalle-modal .route-title{border-bottom:1px solid var(--line,#d5e2e5);padding-bottom:12px;margin-bottom:12px;font-size:15px}
.detalle-route-summary{font-size:12px;border-bottom:1px solid var(--line,#d5e2e5);padding-bottom:12px;margin-bottom:15px;line-height:1.6}
.detalle-route-tramos{font-size:12px;line-height:1.7}
.detalle-modal .field{margin-top:15px}
.detalle-modal .field label{display:block;font-size:12px;font-weight:700;margin:0 0 6px}
.detalle-modal select.input{width:100%}
.detalle-modal-actions{display:flex;justify-content:flex-end;gap:9px;margin-top:20px;padding:0;border:0}
#utable th.sortable{cursor:pointer;user-select:none}
#utable th .sarrow{margin-left:9px;color:#92a5ac;font-size:12px}
/* Paginación con el mismo estilo de client-detail.html */
#detallePagination{display:flex;align-items:center;gap:5px;padding:13px 22px;justify-content:flex-end;flex-wrap:wrap;border-top:1px solid var(--line,#dce7e8)}
#detallePagination .page-btn{min-width:27px;height:27px;padding:0 7px;display:inline-flex;align-items:center;justify-content:center;border:1px solid var(--line-strong,#d5e2e5);background:#fff;border-radius:7px;font-size:11px;font-weight:700;color:var(--ink,#183640);cursor:pointer}
#detallePagination .page-btn.active{background:var(--teal,#479ba4);border-color:var(--teal,#479ba4);color:#fff}
#detallePagination .page-btn:disabled{opacity:.45;cursor:default}
#detallePagination .page-ellipsis{color:var(--faint,#a0adb2);font-size:12px;padding:0 2px}
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
<div style="margin-bottom:15px"><a href="<%=request.getContextPath()%>/capacity-planner/servicios" class="btn btn-outline">Volver</a></div>
<div class="card card-pad" style="margin-bottom:28px">
  <h3 style="margin-bottom:16px;font-family:var(--head);font-weight:800">INFORMACIÓN DEL CLIENTE: <%=esc(cliente.getRazonSocial())%></h3>
  <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px;font-size:11.5px">
    <div><span style="color:var(--muted)">ID Cliente:</span> <strong><%=cliente.getIdCliente()%></strong></div>
    <div><span style="color:var(--muted)">Estado:</span> <span class="pill <%= "Activo".equalsIgnoreCase(cliente.getEstado())?"pill-ok":"pill-crit" %>"><span class="dot"></span><%=esc(cliente.getEstado())%></span></div>
    <div><span style="color:var(--muted)">RUC:</span> <strong><%=esc(cliente.getRuc())%></strong></div>
    <div><span style="color:var(--muted)">Teléfono:</span> <strong><%=esc(cliente.getTelefono())%></strong></div>
    <div><span style="color:var(--muted)">Razón Soc:</span> <strong><%=esc(cliente.getRazonSocial())%></strong></div>
    <div><span style="color:var(--muted)">Correo:</span> <strong><%=esc(cliente.getCorreo())%></strong></div>
    <div><span style="color:var(--muted)">Dirección:</span> <strong><%=esc(cliente.getDireccion())%></strong></div>
    <div><span style="color:var(--muted)">Persona Contacto:</span> <strong><%=esc(cliente.getContacto())%></strong></div>
  </div>
</div>
<div style="display:flex;justify-content:space-between;align-items:center;gap:16px;margin:10px 0 24px">
  <h3 style="font-family:var(--head);font-weight:800;font-size:18px;margin:0">Servicios Contratados</h3>
  <a class="btn btn-primary" href="<%=request.getContextPath()%>/capacity-planner/servicios?action=formCrear&amp;cliente=<%=cliente.getIdCliente()%>">+ Asignar nuevo servicio</a>
</div>
<% if(request.getParameter("creado")!=null){ %><div class="card card-pad" style="color:var(--teal);margin-bottom:12px">Servicio registrado correctamente.</div><% } %>
<% if(request.getParameter("actualizado")!=null){ %><div class="card card-pad" style="color:var(--teal);margin-bottom:12px">Estado actualizado correctamente.</div><% } %>
<div class="card">
  <div class="card-pad" style="border-bottom:1px solid var(--line)">
    <div class="usearch-box" style="max-width:50%;min-width:min(420px,100%)">
      <span class="usearch-ic"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span>
      <input id="searchInput" placeholder="Buscar por ID o capacidad..." oninput="filtrarFilas('searchInput','utable')" aria-label="Buscar servicios">
    </div>
  </div>
  <div class="table-wrap">
    <table id="utable">
      <thead><tr>
        <th>ID Servicio</th><th>Origen</th><th>Destino</th><th>Capacidad</th><th>Fecha de Activación</th><th>Estado</th><th>Acciones</th>
      </tr></thead>
      <tbody>
      <% if(lista!=null)for(Servicio servicio:lista){ %>
        <tr>
          <td><strong><%=esc(servicio.getCodigo())%></strong></td>
          <td><%=esc(servicio.getOrigen())%></td>
          <td><%=esc(servicio.getDestino())%></td>
          <td><strong><%=servicio.getCapacidadContratada()==null ? "Pendiente de asignación" : servicio.getCapacidadContratada()+" Gbps"%></strong></td>
          <td data-sort="<%=servicio.getFechaActivacion()%>"><%=servicio.getFechaActivacion()==null?"":servicio.getFechaActivacion().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))%></td>
          <td><span class="pill <%= "Activo".equals(servicio.getEstado())?"pill-ok": "Suspendido".equals(servicio.getEstado())?"pill-warn":"pill-crit" %>"><span class="dot"></span><%=esc(servicio.getEstado())%></span></td>
          <td>
            <div class="detalle-action-group">
              <button type="button" class="detalle-icon-btn" title="Ver información del servicio" aria-label="Ver servicio" data-codigo="<%=esc(servicio.getCodigo())%>" data-ruta="<%=esc(servicio.getNombreRuta())%>" data-cliente="<%=esc(cliente.getRazonSocial())%>" data-origen="<%=esc(servicio.getOrigen())%>" data-destino="<%=esc(servicio.getDestino())%>" data-capacidad="<%=servicio.getCapacidadContratada()==null ? "" : servicio.getCapacidadContratada()%>" data-fecha="<%=servicio.getFechaActivacion()%>" data-estado="<%=esc(servicio.getEstado())%>" onclick="verServicio(this)">
                <svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
              </button>
              <button type="button" class="detalle-icon-btn" title="Cambiar estado" aria-label="Cambiar estado" data-id="<%=servicio.getIdServicio()%>" data-codigo="<%=esc(servicio.getCodigo())%>" data-estado="<%=esc(servicio.getEstado())%>" onclick="abrirEstado(this)">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
              </button>
            </div>
          </td>
        </tr>
      <% } %>
      <% if(lista==null||lista.isEmpty()){ %><tr><td colspan="7">Este cliente todavía no tiene servicios contratados.</td></tr><% } %>
      </tbody>
    </table>
  </div>
  <div class="pagination" id="detallePagination" aria-label="Paginación de servicios"></div>
</div>
<div class="detalle-modal-back" id="detalleInfoModal" hidden>
  <div class="detalle-modal route-modal" role="dialog" aria-modal="true" aria-labelledby="detalleInfoTitulo">
    <h3 class="route-title" id="detalleInfoTitulo">DETALLE DE RUTA — SERVICIO <span id="detalleRutaCodigo"></span></h3>
    <div class="detalle-route-summary">
      <strong>Cliente:</strong> <span id="detalleRutaCliente"></span> |
      <strong>Capacidad:</strong> <span id="detalleRutaCapacidad"></span> |
      <strong>Estado:</strong> <span id="detalleRutaEstado"></span>
    </div>
    <div class="detalle-route-tramos">
      <strong style="display:block;margin-bottom:12px">Tramos asignados a la ruta:</strong>
      <div id="detalleRutaTramos"></div>
    </div>
    <div class="detalle-modal-actions" style="margin-top:25px">
      <button type="button" class="btn btn-primary" onclick="cerrarModales()">Cerrar Ventana</button>
    </div>
  </div>
</div>
<div class="detalle-modal-back" id="detalleEstadoModal" hidden>
  <div class="detalle-modal" role="dialog" aria-modal="true" aria-labelledby="detalleEstadoTitulo">
    <h3 id="detalleEstadoTitulo">Cambiar estado del servicio</h3>
    <p>Selecciona el nuevo estado para el servicio <strong id="detalleEstadoCodigo"></strong>.</p>
    <form method="post" action="<%=request.getContextPath()%>/capacity-planner/servicios?action=estado">
      <input type="hidden" name="cliente" value="<%=cliente.getIdCliente()%>">
      <input type="hidden" id="detalleEstadoId" name="idServicio">
      <div class="field">
        <label for="detalleEstadoSelect">Nuevo Estado</label>
        <select class="input" id="detalleEstadoSelect" name="estado" required>
          <option value="Activo">Activo</option>
          <option value="Suspendido">Suspendido</option>
          <option value="Cancelado">Cancelado</option>
        </select>
      </div>
      <div class="detalle-modal-actions">
        <button type="button" class="btn btn-outline" onclick="cerrarModales()">Cancelar</button>
        <button type="submit" class="btn btn-primary">Guardar cambios</button>
      </div>
    </form>
  </div>
</div>
      </div>
      <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
    </div>
  </div>
<script>
function cerrarModales(){document.getElementById('detalleInfoModal').hidden=true;document.getElementById('detalleEstadoModal').hidden=true;}
function verServicio(btn){
 const d=btn.dataset;
 document.getElementById('detalleRutaCodigo').textContent=d.codigo||'';
 document.getElementById('detalleRutaCliente').textContent=d.cliente||'';
 document.getElementById('detalleRutaCapacidad').textContent=d.capacidad ? d.capacidad+' Gbps' : 'Pendiente de asignación';
 document.getElementById('detalleRutaEstado').textContent=d.estado||'';
 const tramos=document.getElementById('detalleRutaTramos');
 tramos.replaceChildren();
 // Los segmentos reales NO se cargan en ServicioDAO.obtenerServiciosPorCliente().
 // Presentar los extremos de la ruta, sin inventar tramos ni su consumo.
 const fila=document.createElement('div');
 const fuerte=document.createElement('strong');
 fuerte.textContent=(d.origen||'Origen no disponible')+' ↔ '+(d.destino||'Destino no disponible');
 fila.append(fuerte,document.createTextNode(d.ruta?' — '+d.ruta:''));
 tramos.append(fila);
 const nota=document.createElement('p');
 nota.style.marginTop='10px';
 nota.textContent='El detalle de segmentos y su capacidad consumida no está disponible en esta consulta.';
 tramos.append(nota);
 document.getElementById('detalleInfoModal').hidden=false;
}
function abrirEstado(btn){
 document.getElementById('detalleEstadoId').value=btn.dataset.id;
 document.getElementById('detalleEstadoCodigo').textContent=btn.dataset.codigo;
 document.getElementById('detalleEstadoSelect').value=btn.dataset.estado;
 document.getElementById('detalleEstadoModal').hidden=false;
}
document.addEventListener('keydown',function(e){if(e.key==='Escape')cerrarModales()});
for(const modal of document.querySelectorAll('.detalle-modal-back'))modal.addEventListener('click',function(e){if(e.target===modal)cerrarModales()});
</script>
<script>
// El buscador actualiza la paginación sin modificar los registros de MySQL.
function filtrarFilas(inputId, tableId){
    if (window.actualizarPaginacionDetalle) window.actualizarPaginacionDetalle(true);
}
(function () {
    'use strict';
    var registrosPorPagina = 5;
    var pagina = 1;
    var cuerpo = document.querySelector('#utable tbody');
    var contenedor = document.getElementById('detallePagination');
    var buscador = document.getElementById('searchInput');
    if (!cuerpo || !contenedor) return;
    function filasReales() {
        return Array.prototype.filter.call(cuerpo.rows, function(tr) { return tr.cells.length === 7; });
    }
    function boton(texto, destino, activo, deshabilitado, etiqueta) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'page-btn' + (activo ? ' active' : '');
        b.textContent = texto;
        b.disabled = !!deshabilitado;
        b.setAttribute('aria-label', etiqueta || ('Página ' + destino));
        if (activo) b.setAttribute('aria-current', 'page');
        b.addEventListener('click', function() { pagina = destino; mostrar(); });
        contenedor.appendChild(b);
    }
    function puntos() {
        var span = document.createElement('span');
        span.className = 'page-ellipsis';
        span.textContent = '…';
        span.setAttribute('aria-hidden', 'true');
        contenedor.appendChild(span);
    }
    function mostrar(reset) {
        if (reset) pagina = 1;
        var busqueda = buscador ? buscador.value.trim().toLocaleLowerCase('es') : '';
        var filas = filasReales();
        var filtradas = filas.filter(function(tr) {
            return tr.textContent.toLocaleLowerCase('es').includes(busqueda);
        });
        var total = Math.max(1, Math.ceil(filtradas.length / registrosPorPagina));
        pagina = Math.min(Math.max(1, pagina), total);
        var desde = (pagina - 1) * registrosPorPagina;
        filas.forEach(function(tr) { tr.style.display = 'none'; });
        filtradas.slice(desde, desde + registrosPorPagina).forEach(function(tr) { tr.style.display = ''; });
        contenedor.replaceChildren();
        boton('‹', pagina - 1, false, pagina === 1, 'Página anterior');
        var numeros = [];
        for (var n = 1; n <= total; n++) {
            if (n === 1 || n === total || Math.abs(n - pagina) <= 1 || (pagina === 1 && n <= 3) || (pagina === total && n >= total - 2)) numeros.push(n);
        }
        var ultimo = 0;
        numeros.forEach(function(n) {
            if (n - ultimo > 1) puntos();
            boton(String(n), n, n === pagina, false, 'Ir a página ' + n);
            ultimo = n;
        });
        boton('›', pagina + 1, false, pagina === total, 'Página siguiente');
    }
    window.actualizarPaginacionDetalle = mostrar;
    mostrar();
})();
(function () {
    'use strict';
    function iniciar() {
        var tabla = document.getElementById('utable');
        if (!tabla || !tabla.tHead || !tabla.tBodies.length) return;
        var cuerpo = tabla.tBodies[0];
        var encabezados = Array.prototype.slice.call(tabla.tHead.rows[0].cells);
        var columnaActual = -1;
        var ascendente = true;
        var collation = new Intl.Collator('es', {numeric: true, sensitivity: 'base'});
        // Las 6 columnas de datos; ACCIONES no se ordena.
        encabezados.slice(0, 6).forEach(function (th, indice) {
            th.classList.add('sortable');
            th.dataset.col = String(indice);
            th.setAttribute('role', 'button');
            th.setAttribute('tabindex', '0');
            th.setAttribute('aria-label', th.textContent.trim() + ': ordenar columna');
            th.setAttribute('aria-sort', 'none');
            th.style.cursor = 'pointer';
            th.style.userSelect = 'none';
            var flecha = th.querySelector('.sarrow');
            if (!flecha) {
                flecha = document.createElement('span');
                flecha.className = 'sarrow';
                flecha.setAttribute('aria-hidden', 'true');
                th.appendChild(document.createTextNode('  '));
                th.appendChild(flecha);
            }
            flecha.textContent = '⇅';
            flecha.style.marginLeft = '6px';
            flecha.style.opacity = '0.8';
            function ordenar() {
                if (columnaActual === indice) ascendente = !ascendente;
                else { columnaActual = indice; ascendente = true; }
                var filas = Array.prototype.slice.call(cuerpo.rows);
                // Ignorar el mensaje vacío de colspan=7.
                if (!filas.length || (filas.length === 1 && filas[0].cells.length < 2)) return;
                function valor(tr) {
                    var td = tr.cells[indice];
                    return td ? (td.getAttribute('data-sort') || td.textContent || '').trim() : '';
                }
                function fecha(v) {
                    var m = v.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
                    if (m) return m[3] + m[2] + m[1];
                    m = v.match(/^(\d{4})-(\d{2})-(\d{2})$/);
                    if (m) return m[1] + m[2] + m[3];
                    return v;
                }
                filas.sort(function (a, b) {
                    var av = valor(a), bv = valor(b), cmp;
                    if (indice === 3) {
                        // Capacidad: 15.00 Gbps, 100 Gbps, etc.
                        var na = Number(av.replace(/[^\d.,-]/g, '').replace(',', '.'));
                        var nb = Number(bv.replace(/[^\d.,-]/g, '').replace(',', '.'));
                        cmp = Number.isFinite(na) && Number.isFinite(nb) ? na - nb : collation.compare(av, bv);
                    } else if (indice === 4) {
                        cmp = collation.compare(fecha(av), fecha(bv));
                    } else {
                        cmp = collation.compare(av, bv);
                    }
                    return ascendente ? cmp : -cmp;
                });
                filas.forEach(function (tr) { cuerpo.appendChild(tr); });
                if (window.actualizarPaginacionDetalle) window.actualizarPaginacionDetalle(true);
                encabezados.slice(0, 6).forEach(function (h, i) {
                    h.querySelector('.sarrow').textContent = i === columnaActual ? (ascendente ? '▲' : '▼') : '⇅';
                    h.setAttribute('aria-sort', i === columnaActual ? (ascendente ? 'ascending' : 'descending') : 'none');
                });
            }
            th.addEventListener('click', ordenar);
            th.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); ordenar(); }
            });
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', iniciar);
    else iniciar();
})();
</script>
</body></html>
