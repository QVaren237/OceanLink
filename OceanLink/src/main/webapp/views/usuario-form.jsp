<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.Rol" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Usuario u = (Usuario) request.getAttribute("usuario");
    ArrayList<Rol> roles = (ArrayList<Rol>) request.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= u != null ? "Editar" : "Registrar" %> usuario · OceanLink</title>
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
      <a class="nav-item" href="<%= request.getContextPath() %>/acceso-por-rol.html"><svg viewBox="0 0 24 24"><rect x="4" y="10" width="16" height="10" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg><span>Acceso por rol</span></a>
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
          <h1 id="pageTitle"><%= u != null ? "Editar usuario" : "Registrar nuevo usuario" %></h1>
          <div class="psub" id="pageSub"><%= u != null ? "Modifica los datos de la cuenta." : "Añade una nueva cuenta al sistema." %></div>
        </div>
        <div class="grow"></div>
      </div>

      <div class="card card-pad" style="max-width:720px">
        <form id="mainForm" action="<%= request.getContextPath() %>/UsuarioServlet?action=crear" method="post">

          <% if (u != null) { %>
            <input type="hidden" name="idUsuario" value="<%= u.getIdUsuario() %>">
          <% } %>

          <div class="form-grid" id="formGrid" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
            <div class="field">
              <label>Nombre (*)</label>
              <input class="input" name="nombre" id="fNombre" value="<%= u != null ? u.getNombre() : "" %>"><div class="err" id="eNombre" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>Apellido (*)</label>
              <input class="input" name="apellido" id="fApellido" value="<%= u != null ? u.getApellido() : "" %>"><div class="err" id="eApellido" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field" style="grid-column: span 2;">
              <label>Correo corporativo (*)</label>
              <input class="input" type="email" name="correo" id="fCorreo" value="<%= u != null ? u.getCorreo() : "" %>"><div class="err" id="eCorreo" style="display:none;">Ingrese un correo válido.</div>
            </div>
            <div class="field" style="grid-column: span 2;">
              <label>Contraseña <%= u != null ? "(dejar en blanco para no cambiarla)" : "(*)" %></label>
              <input class="input" type="password" name="password" id="fPassword" placeholder="<%= u != null ? "••••••••" : "" %>"><div class="err" id="ePassword" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>Rol (*)</label>
              <select class="input" name="idRol" required>
                <% if (roles != null) {
                     for (Rol r : roles) {
                       boolean sel = (u != null && u.getIdRol() == r.getIdRol()); %>
                  <option value="<%= r.getIdRol() %>" <%= sel ? "selected" : "" %>><%= r.getNombre() %></option>
                <%   }
                   } %>
              </select>
            </div>
            <div class="field">
              <label>Estado (*)</label>
              <select class="input" name="estado" required>
                <option value="Activo" <%= (u != null && "Activo".equals(u.getEstado())) ? "selected" : "" %>>Activo</option>
                <option value="Inactivo" <%= (u != null && "Inactivo".equals(u.getEstado())) ? "selected" : "" %>>Inactivo</option>
              </select>
            </div>
          </div>

          <div class="hint" style="margin-top:10px">(*) Campos obligatorios</div>

          <div class="form-actions" id="formActions">
            <div class="grow"></div>
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/UsuarioServlet?action=lista">Cancelar</a>
            <button type="button" class="btn btn-primary" onclick="showConfirm()">Continuar</button>
          </div>

          <!-- SECCIÓN DE CONFIRMACIÓN (Oculta por defecto) -->
          <div id="confirmView" style="display:none;">
            <div class="info-strip">
              <div class="ii">i</div>
              <div>
                <div class="it" id="confName"></div>
                <div class="id" id="confEmail"></div>
              </div>
            </div>
            <div class="data-list">
              <div class="data-label">Nombre</div>
              <div class="data-value" id="cvNombre"></div>
              <div class="data-label">Apellido</div>
              <div class="data-value" id="cvApellido"></div>
              <div class="data-label">Correo</div>
              <div class="data-value" id="cvCorreo"></div>
              <div class="data-label">Rol</div>
              <div class="data-value" id="cvRol"></div>
              <div class="data-label">Estado</div>
              <div class="data-value" id="cvEstado"></div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn btn-outline" onclick="hideConfirm()">Volver a editar</button>
              <button type="submit" class="btn btn-primary">Confirmar <%= u != null ? "cambios" : "registro" %></button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<script>
var esEdicion = <%= u != null ? "true" : "false" %>;

function showConfirm() {
    var isValid = true;

    function checkField(id, errId, condition) {
        var el = document.getElementById(id);
        var err = document.getElementById(errId);
        if (condition) {
            el.classList.add("bad");
            err.style.display = "block";
            isValid = false;
        } else {
            el.classList.remove("bad");
            err.style.display = "none";
        }
    }

    var valNombre = document.getElementById("fNombre").value.trim();
    checkField("fNombre", "eNombre", valNombre === "");

    var valApellido = document.getElementById("fApellido").value.trim();
    checkField("fApellido", "eApellido", valApellido === "");

    var valCorreo = document.getElementById("fCorreo").value.trim();
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    checkField("fCorreo", "eCorreo", !emailRegex.test(valCorreo));

    // La contraseña solo es obligatoria al registrar un usuario nuevo
    var valPassword = document.getElementById("fPassword").value;
    checkField("fPassword", "ePassword", !esEdicion && valPassword === "");

    if (!isValid) {
        var banner = document.getElementById("errorBanner");
        if(banner) {
            banner.style.display = "block";
        } else {
            var fg = document.getElementById("formGrid");
            var b = document.createElement("div");
            b.id = "errorBanner";
            b.className = "banner banner-err";
            b.style = "grid-column: span 2; margin-bottom: 16px;";
            b.innerText = "No se pudo guardar. Revisa los campos marcados.";
            fg.insertBefore(b, fg.firstChild);
        }
        return;
    }

    document.getElementById("formGrid").style.display = "none";
    document.getElementById("formActions").style.display = "none";
    document.querySelector(".hint").style.display = "none";

    document.getElementById("cvNombre").innerText = document.getElementsByName("nombre")[0].value;
    document.getElementById("cvApellido").innerText = document.getElementsByName("apellido")[0].value;
    document.getElementById("cvCorreo").innerText = document.getElementsByName("correo")[0].value;

    var rolSelect = document.getElementsByName("idRol")[0];
    document.getElementById("cvRol").innerText = rolSelect.options[rolSelect.selectedIndex].text;

    var estadoSelect = document.getElementsByName("estado")[0];
    document.getElementById("cvEstado").innerText = estadoSelect.options[estadoSelect.selectedIndex].text;

    document.getElementById("confName").innerText = document.getElementsByName("nombre")[0].value + " " + document.getElementsByName("apellido")[0].value;
    document.getElementById("confEmail").innerText = document.getElementsByName("correo")[0].value;

    document.getElementById("pageTitle").innerText = esEdicion ? "Confirmar cambios" : "Confirmar registro";
    document.getElementById("pageSub").innerText = esEdicion ? "Revisa los datos del usuario antes de guardarlos." : "Revisa la información antes de confirmar el registro.";

    document.getElementById("confirmView").style.display = "block";
}

function hideConfirm() {
    document.getElementById("confirmView").style.display = "none";
    document.getElementById("formGrid").style.display = "grid";
    document.getElementById("formActions").style.display = "flex";
    document.querySelector(".hint").style.display = "block";

    document.getElementById("pageTitle").innerText = esEdicion ? "Editar usuario" : "Registrar nuevo usuario";
    document.getElementById("pageSub").innerText = esEdicion ? "Modifica los datos de la cuenta." : "Añade una nueva cuenta al sistema.";
}
</script>
</body>
</html>
