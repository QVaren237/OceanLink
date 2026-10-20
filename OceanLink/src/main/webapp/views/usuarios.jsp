<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("lista"); %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Usuarios · OceanLink</title>
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
      <a class="nav-item active" href="<%= request.getContextPath() %>/UsuarioServlet?action=lista"><svg viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.2"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><path d="M16 6.2a3 3 0 0 1 0 5.6M17.5 19a5 5 0 0 0-2.5-4.3"/></svg><span>Usuarios</span></a>
      <a class="nav-item" href="<%= request.getContextPath() %>/ClienteServlet?action=lista"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 12h18"/></svg><span>Clientes</span></a>
      <a class="nav-item" href="<%= request.getContextPath() %>/LandingStationServlet"><svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg><span>Landing Stations</span></a>
      <a class="nav-item" href="<%= request.getContextPath() %>/RedesSubmarinasServlet"><svg viewBox="0 0 24 24"><path d="M3 12h4l3-7 4 14 3-7h4"/></svg><span>Redes submarinas</span></a>
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
          <h1>Gestión de usuarios</h1>
          <div class="psub">Cuentas y accesos del sistema.</div>
        </div>
        <div class="grow"></div>
        <a class="btn btn-primary" href="<%= request.getContextPath() %>/UsuarioServlet?action=formCrear">+ Nuevo usuario</a>
      </div>

      <div class="card">
        <div class="card-pad table-toolbar">
          <div class="usearch-box table-search">
            <span class="usearch-ic">
              <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
            </span>
            <input id="usearch" placeholder="Buscar por nombre, correo o rol…">
          </div>
        </div>

        <div class="table-wrap">
          <table id="utable">
            <thead>
              <tr>
                <th class="sortable" data-col="0">ID <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="1">Nombre <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="2">Apellido <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="3">Correo <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="4">Rol <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="5">Estado <span class="sarrow">⇅</span></th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody id="ubody">
              <% if (listaUsuarios != null) {
                   for (Usuario u : listaUsuarios) { %>
                <tr class="data-row">
                  <td data-sort="<%= u.getIdUsuario() %>"><strong><%= u.getIdUsuario() %></strong></td>
                  <td data-sort="<%= u.getNombre() %>"><div class="u-name"><%= u.getNombre() %></div></td>
                  <td data-sort="<%= u.getApellido() %>"><%= u.getApellido() %></td>
                  <td data-sort="<%= u.getCorreo() %>"><%= u.getCorreo() %></td>
                  <td data-sort="<%= u.getNombreRol() %>"><%= u.getNombreRol() %></td>
                  <td data-sort="<%= u.getEstado() %>">
                    <% if ("Activo".equals(u.getEstado())) { %>
                        <span class="pill pill-ok"><span class="dot"></span>Activo</span>
                    <% } else { %>
                        <span class="pill pill-warn"><span class="dot"></span>Inactivo</span>
                    <% } %>
                  </td>
                  <td>
                    <div class="actions">
                      <a class="btn btn-outline btn-icon" title="Editar usuario" href="<%= request.getContextPath() %>/UsuarioServlet?action=editar&id=<%= u.getIdUsuario() %>">
                        <svg viewBox="0 0 24 24"><path d="M4 20h4L19 9a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16z"/><path d="M13.5 6.5l4 4"/></svg>
                      </a>
                      <% boolean isActive = "Activo".equals(u.getEstado()); %>
                      <a class="btn <%= isActive ? "btn-danger" : "btn-primary" %> btn-icon"
                         title="<%= isActive ? "Desactivar" : "Activar" %> usuario"
                         href="<%= request.getContextPath() %>/UsuarioServlet?action=cambiarEstado&id=<%= u.getIdUsuario() %>&estado=<%= isActive ? "Inactivo" : "Activo" %>"
                         onclick="event.preventDefault(); openStateModal('<%= u.getNombre() %> <%= u.getApellido() %>', this.href, <%= isActive ? "false" : "true" %>);">
                        <% if(isActive) { %>
                          <svg viewBox="0 0 24 24"><path d="M18.36 6.64a9 9 0 1 1-12.73 0M12 2v10"/></svg>
                        <% } else { %>
                          <svg viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5"/></svg>
                        <% } %>
                      </a>
                    </div>
                  </td>
                </tr>
              <%   }
                 } %>
            </tbody>
          </table>
        </div>

        <div class="pagination" id="pagination-container"></div>
      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<script>
(function(){
  var tb = document.getElementById("utable");
  if(!tb) return;
  var body = document.getElementById("ubody");

  var allRows = Array.prototype.slice.call(body.querySelectorAll("tr.data-row"));

  var keys = [];
  var currentPage = 1;
  var rowsPerPage = 5;
  var filteredRows = allRows;

  function val(r, i) {
      return r.cells[i].getAttribute("data-sort") || r.cells[i].innerText;
  }

  function paintArrows() {
      document.querySelectorAll("th.sortable").forEach(function(th) {
          var i = +th.dataset.col, f = null;
          for(var k=0; k<keys.length; k++){ if(keys[k].col===i){ f=keys[k]; break; } }
          th.querySelector(".sarrow").textContent = f ? (f.asc ? "▲" : "▼") : "⇅";
      });
  }

  function applySort() {
      filteredRows.sort(function(a, b) {
          for(var k=0; k<keys.length; k++) {
              var i = keys[k].col;
              var c = val(a,i).localeCompare(val(b,i), "es", {numeric:true});
              if(c !== 0) return keys[k].asc ? c : -c;
          }
          return 0;
      });
      paintArrows();
      renderPage();
  }

  document.querySelectorAll("th.sortable").forEach(function(th) {
      th.addEventListener("click", function() {
          var i = +th.dataset.col;
          if(keys.length && keys[0].col === i) {
              keys[0].asc = !keys[0].asc;
          } else {
              keys = keys.filter(function(k){ return k.col!==i; });
              keys.unshift({col:i, asc:true});
          }
          currentPage = 1;
          applySort();
      });
  });

  var searchInput = document.getElementById("usearch");
  if(searchInput) {
      searchInput.addEventListener("input", function() {
          var q = searchInput.value.toLowerCase();
          filteredRows = allRows.filter(function(r) {
              return r.innerText.toLowerCase().indexOf(q) >= 0;
          });
          currentPage = 1;
          applySort();
      });
  }

  function renderPage() {
      body.innerHTML = "";
      var totalPages = Math.ceil(filteredRows.length / rowsPerPage);
      if(totalPages === 0) totalPages = 1;

      var start = (currentPage - 1) * rowsPerPage;
      var end = start + rowsPerPage;
      var pageRows = filteredRows.slice(start, end);

      pageRows.forEach(function(r) { body.appendChild(r); });

      var pagCont = document.getElementById("pagination-container");
      pagCont.innerHTML = "";

      var btnPrev = document.createElement("button");
      btnPrev.className = "page-btn";
      btnPrev.innerText = "‹";
      btnPrev.disabled = (currentPage === 1);
      btnPrev.onclick = function() { currentPage--; renderPage(); };
      pagCont.appendChild(btnPrev);

      for(var i=1; i<=totalPages; i++) {
          var btn = document.createElement("button");
          btn.className = "page-btn" + (i === currentPage ? " active" : "");
          btn.innerText = i;
          (function(pageIndex){
              btn.onclick = function() { currentPage = pageIndex; renderPage(); };
          })(i);
          pagCont.appendChild(btn);
      }

      var btnNext = document.createElement("button");
      btnNext.className = "page-btn";
      btnNext.innerText = "›";
      btnNext.disabled = (currentPage === totalPages);
      btnNext.onclick = function() { currentPage++; renderPage(); };
      pagCont.appendChild(btnNext);
  }

  renderPage();
})();
</script>
<!-- MODAL DE CONFIRMACIÓN DE ESTADO -->
<div id="stateModal" class="modal-back" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9999; justify-content:center; align-items:center;">
  <div class="modal" style="background:#fff; padding:24px; border-radius:12px; max-width:400px; width:100%; box-shadow:0 4px 12px rgba(0,0,0,0.15);">
    <h3 id="modalTitle" style="margin-top:0; font-size:18px; color:var(--text-main);">Cambiar estado</h3>
    <p id="modalDesc" style="color:var(--text-light); margin-bottom:24px;"></p>
    <div class="form-actions" style="display:flex; justify-content:flex-end; gap:12px;">
      <button type="button" class="btn btn-outline" onclick="closeStateModal()">Cancelar</button>
      <a id="btnConfirmState" class="btn" href="#">Confirmar</a>
    </div>
  </div>
</div>
<script>
function openStateModal(name, url, isActivating) {
    var actionTitle = isActivating ? "Activar usuario" : "Desactivar usuario";
    var actionDesc = isActivating ? "¿Deseas reactivar la cuenta de <b>" + name + "</b>? Volverá a tener acceso al sistema." : "¿Deseas desactivar la cuenta de <b>" + name + "</b>? Dejará de tener acceso temporalmente.";
    var btnClass = isActivating ? "btn-primary" : "btn-danger";
    var actionBtn = isActivating ? "Activar" : "Desactivar";

    document.getElementById('modalTitle').innerText = actionTitle;
    document.getElementById('modalDesc').innerHTML = actionDesc;

    var btn = document.getElementById('btnConfirmState');
    btn.className = "btn " + btnClass;
    btn.innerText = actionBtn;
    btn.href = url;

    document.getElementById('stateModal').style.display = 'flex';
}
function closeStateModal() {
    document.getElementById('stateModal').style.display = 'none';
}
</script>
</body>
</html>
