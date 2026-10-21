<%@ page import="pe.edu.oceanlink.bean.Cliente" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% Cliente c = (Cliente) request.getAttribute("cliente"); %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= c != null ? "Editar" : "Registrar" %> cliente · OceanLink</title>
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
      <a class="nav-item" href="<%= request.getContextPath() %>/UsuarioServlet?action=lista"><svg viewBox="0 0 24 24"><circle cx="9" cy="8" r="3.2"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><path d="M16 6.2a3 3 0 0 1 0 5.6M17.5 19a5 5 0 0 0-2.5-4.3"/></svg><span>Usuarios</span></a>
      <a class="nav-item active" href="<%= request.getContextPath() %>/ClienteServlet?action=lista"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 12h18"/></svg><span>Clientes</span></a>
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
          <h1 id="pageTitle"><%= c != null ? "Editar cliente" : "Registrar nuevo cliente" %></h1>
          <div class="psub" id="pageSub"><%= c != null ? "Modifica los datos del cliente corporativo." : "Añade un nuevo cliente corporativo a la red." %></div>
        </div>
        <div class="grow"></div>
      </div>

      <div class="card card-pad" style="max-width:720px">
        <form id="mainForm" action="<%= request.getContextPath() %>/ClienteServlet?action=crear" method="post">
          
          <% if (c != null) { %>
            <input type="hidden" name="idCliente" value="<%= c.getIdCliente() %>">
          <% } %>

          <div class="form-grid" id="formGrid" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
          <% if (request.getParameter("error") != null) { %>
            <div class="banner banner-err" style="grid-column: span 2; margin-bottom: 16px; padding: 12px; background-color: #ffeaea; border: 1px solid #ffcaca; color: #d00000; border-radius: 6px;">No se pudo guardar. Revisa los campos obligatorios o el RUC ya está registrado.</div>
          <% } %>
            <div class="field" style="grid-column: span 2;">
              <label>Razón Social (*)</label>
              <input class="input" name="razonSocial" id="fRazon" value="<%= c != null ? c.getRazonSocial() : "" %>"><div class="err" id="eRazon" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>RUC (*)</label>
              <input class="input" name="ruc" id="fRuc" value="<%= c != null ? c.getRuc() : "" %>"><div class="err" id="eRuc" style="display:none;">Debe tener 11 dígitos.</div>
            </div>
            <div class="field">
              <label>Teléfono de contacto (*)</label>
              <input class="input" type="tel" name="telefono" id="fTelefono" value="<%= c != null ? c.getTelefono() : "" %>"><div class="err" id="eTelefono" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field" style="grid-column: span 2;">
              <label>Correo corporativo (*)</label>
              <input class="input" type="email" name="correo" id="fCorreo" value="<%= c != null ? c.getCorreo() : "" %>"><div class="err" id="eCorreo" style="display:none;">Ingrese un correo válido.</div>
            </div>
            <div class="field" style="grid-column: span 2;">
              <label>Dirección principal (*)</label>
              <input class="input" name="direccion" id="fDireccion" value="<%= c != null ? c.getDireccion() : "" %>"><div class="err" id="eDireccion" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>Nombre del contacto clave (*)</label>
              <input class="input" name="contacto" id="fContacto" value="<%= c != null ? c.getContacto() : "" %>"><div class="err" id="eContacto" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>Estado (*)</label>
              <select class="input" name="estado" required>
                <option value="Activo" <%= (c != null && "Activo".equals(c.getEstado())) ? "selected" : "" %>>Activo</option>
                <option value="Inactivo" <%= (c != null && "Inactivo".equals(c.getEstado())) ? "selected" : "" %>>Inactivo</option>
              </select>
            </div>
          </div>
          
          <div class="hint" style="margin-top:10px">(*) Campos obligatorios</div>
          
                    <div class="form-actions" id="formActions">
            <div class="grow"></div>
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/ClienteServlet?action=lista">Cancelar</a>
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
              <div class="data-label">Razón Social</div>
              <div class="data-value" id="cvRazon"></div>
              <div class="data-label">RUC</div>
              <div class="data-value" id="cvRuc"></div>
              <div class="data-label">Teléfono</div>
              <div class="data-value" id="cvTelefono"></div>
              <div class="data-label">Correo</div>
              <div class="data-value" id="cvCorreo"></div>
              <div class="data-label">Estado</div>
              <div class="data-value" id="cvEstado"></div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn btn-outline" onclick="hideConfirm()">Volver a editar</button>
              <button type="submit" class="btn btn-primary">Confirmar <%= c != null ? "cambios" : "registro" %></button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<script>
function showConfirm() {
    var isValid = true;
    
    // Función auxiliar para mostrar error
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

    var valRazon = document.getElementById("fRazon").value.trim();
    checkField("fRazon", "eRazon", valRazon === "");

    var valRuc = document.getElementById("fRuc").value.trim();
    checkField("fRuc", "eRuc", valRuc.length !== 11 || isNaN(valRuc));

    var valTel = document.getElementById("fTelefono").value.trim();
    checkField("fTelefono", "eTelefono", valTel === "");

    var valCorreo = document.getElementById("fCorreo").value.trim();
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    checkField("fCorreo", "eCorreo", !emailRegex.test(valCorreo));

    var valDir = document.getElementById("fDireccion").value.trim();
    checkField("fDireccion", "eDireccion", valDir === "");

    var valCont = document.getElementById("fContacto").value.trim();
    checkField("fContacto", "eContacto", valCont === "");

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
    
    document.getElementById("cvRazon").innerText = document.getElementsByName("razonSocial")[0].value;
    document.getElementById("cvRuc").innerText = document.getElementsByName("ruc")[0].value;
    document.getElementById("cvTelefono").innerText = document.getElementsByName("telefono")[0].value;
    document.getElementById("cvCorreo").innerText = document.getElementsByName("correo")[0].value;
    
    var estadoSelect = document.getElementsByName("estado")[0];
    document.getElementById("cvEstado").innerText = estadoSelect.options[estadoSelect.selectedIndex].text;
    
    document.getElementById("confName").innerText = document.getElementsByName("razonSocial")[0].value;
    document.getElementById("confEmail").innerText = document.getElementsByName("ruc")[0].value;
    
    document.getElementById("pageTitle").innerText = "<%= c != null ? "Confirmar cambios" : "Confirmar registro" %>";
    document.getElementById("pageSub").innerText = "<%= c != null ? "Revisa los datos del cliente antes de guardarlos." : "Revisa la información antes de confirmar el registro." %>";
    
    document.getElementById("confirmView").style.display = "block";
}

function hideConfirm() {
    document.getElementById("confirmView").style.display = "none";
    document.getElementById("formGrid").style.display = "grid";
    document.getElementById("formActions").style.display = "flex";
    document.querySelector(".hint").style.display = "block";
    
    document.getElementById("pageTitle").innerText = "<%= c != null ? "Editar cliente" : "Registrar nuevo cliente" %>";
    document.getElementById("pageSub").innerText = "<%= c != null ? "Modifica los datos del cliente corporativo." : "Añade un nuevo cliente corporativo a la red." %>";
}
</script>
</body>
</html>