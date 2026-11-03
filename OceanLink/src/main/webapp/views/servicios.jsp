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
<%@ page import="java.util.ArrayList,pe.edu.oceanlink.bean.Cliente" %>
<% ArrayList<Cliente> clientes=(ArrayList<Cliente>)request.getAttribute("clientes"); %>
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
<div class="page-head"><div><h1>Clientes</h1><div class="psub">Cartera de clientes y servicios contratados.</div></div></div>
<div class="card"><div class="card-pad" style="border-bottom:1px solid var(--line)"><div class="usearch-box" style="max-width:50%; min-width:340px"><span class="usearch-ic">⌕</span><input id="searchInput" placeholder="Buscar por RUC o razón social..."></div></div>
<div class="table-wrap"><table id="utable"><thead><tr><th class="sortable" data-col="0">ID <span class="sarrow">⇅</span></th><th class="sortable" data-col="1">Razón social <span class="sarrow">⇅</span></th><th class="sortable" data-col="2">RUC <span class="sarrow">⇅</span></th><th class="sortable" data-col="3">Teléfono <span class="sarrow">⇅</span></th><th class="sortable" data-col="4">Correo <span class="sarrow">⇅</span></th><th class="sortable" data-col="5">Estado <span class="sarrow">⇅</span></th><th>Acciones</th></tr></thead><tbody>
<% if(clientes!=null) for(Cliente c:clientes){ %>
<tr><td><strong><%=c.getIdCliente()%></strong></td><td><strong><%=esc(c.getRazonSocial())%></strong></td><td><%=esc(c.getRuc())%></td><td><%=esc(c.getTelefono())%></td><td><%=esc(c.getCorreo())%></td><td><span class="pill <%= "Activo".equals(c.getEstado())?"pill-ok":"pill-crit" %>"><span class="dot"></span><%=esc(c.getEstado())%></span></td><td>
  <div class="actions">
    <a href="<%=request.getContextPath()%>/capacity-planner/servicios?action=detalle&amp;cliente=<%=c.getIdCliente()%>"
       class="btn-icon" style="border: 1px solid var(--line-strong); color: var(--muted); background: #fff; border-radius: 9px;"
       title="Ver detalle" aria-label="Ver servicios de <%=esc(c.getRazonSocial())%>">
      <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
    </a>
  </div>
</td></tr>
<% } %>
<% if(clientes==null||clientes.isEmpty()){ %><tr><td colspan="7">No hay clientes disponibles.</td></tr><% } %>
</tbody></table></div>
<div class="pagination" id="clientesPagination" aria-label="Páginas de clientes"></div>
</div>
      </div>
      <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
    </div>
  </div>
<script>
// Paginación, búsqueda y ordenamiento de los clientes ya recibidos desde MySQL.
(function () {
  const table = document.getElementById('utable');
  const search = document.getElementById('searchInput');
  const pagination = document.getElementById('clientesPagination');
  if (!table || !search || !pagination) return;
  const body = table.tBodies[0];
  const allRows = Array.from(body.rows).filter(row => row.cells.length === 7);
  const rowsPerPage = 2; // Misma cantidad por página que index.html original.
  let page = 1;
  let sortColumn = -1;
  let ascending = true;

  function sortedFilteredRows() {
    const query = search.value.trim().toLocaleLowerCase('es');
    const result = allRows.filter(row =>
      [0, 1, 2, 3, 4, 5].some(col =>
        row.cells[col].textContent.toLocaleLowerCase('es').includes(query))
    );
    if (sortColumn !== -1) {
      result.sort((a, b) => {
        const va = a.cells[sortColumn].textContent.trim();
        const vb = b.cells[sortColumn].textContent.trim();
        const cmp = va.localeCompare(vb, 'es', {numeric: true, sensitivity: 'base'});
        return ascending ? cmp : -cmp;
      });
    }
    return result;
  }

  function addButton(text, destination, active, disabled, label) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'page-btn' + (active ? ' active' : '');
    button.textContent = text;
    button.disabled = disabled;
    if (label) button.setAttribute('aria-label', label);
    if (active) button.setAttribute('aria-current', 'page');
    button.addEventListener('click', () => {page = destination; render();});
    pagination.appendChild(button);
  }

  function renderPagination(totalPages) {
    pagination.replaceChildren();
    if (totalPages === 0) return;
    addButton('‹', page - 1, false, page === 1, 'Página anterior');
    const numbers = new Set([1, 2, 3, totalPages, page - 1, page, page + 1]);
    const visible = [...numbers].filter(n => n >= 1 && n <= totalPages).sort((a,b) => a-b);
    let last = 0;
    for (const n of visible) {
      if (n > last + 1) {
        const dots = document.createElement('span');
        dots.className = 'page-ellipsis';
        dots.textContent = '...';
        pagination.appendChild(dots);
      }
      addButton(String(n), n, n === page, false, 'Página ' + n);
      last = n;
    }
    addButton('›', page + 1, false, page === totalPages, 'Página siguiente');
  }

  function render() {
    const filtered = sortedFilteredRows();
    const totalPages = Math.ceil(filtered.length / rowsPerPage);
    page = Math.max(1, Math.min(page, totalPages || 1));
    allRows.forEach(row => {row.style.display = 'none';});
    filtered.slice((page - 1) * rowsPerPage, page * rowsPerPage)
      .forEach(row => {row.style.display = ''; body.appendChild(row);});
    const placeholder = body.querySelector('tr[data-empty-clientes]');
    if (placeholder) placeholder.remove();
    if (allRows.length > 0 && filtered.length === 0) {
      const tr = document.createElement('tr');
      tr.setAttribute('data-empty-clientes','');
      const td = document.createElement('td');
      td.colSpan = 7;
      td.textContent = 'No se encontraron clientes.';
      tr.appendChild(td);
      body.appendChild(tr);
    }
    renderPagination(totalPages);
  }

  search.addEventListener('input', () => {page = 1; render();});
  table.querySelectorAll('thead th.sortable').forEach(th => {
    th.style.cursor = 'pointer';
    th.addEventListener('click', () => {
      const col = Number(th.dataset.col);
      ascending = (sortColumn === col) ? !ascending : true;
      sortColumn = col;
      page = 1;
      table.querySelectorAll('thead th.sortable').forEach(other => {
        other.querySelector('.sarrow').textContent = (other === th) ? (ascending ? '▲' : '▼') : '⇅';
      });
      render();
    });
  });
  render();
})();
</script>
</body></html>
