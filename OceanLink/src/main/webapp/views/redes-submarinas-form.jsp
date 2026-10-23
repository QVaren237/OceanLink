<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Segmento" %>
<%@ page import="pe.edu.oceanlink.bean.LandingStation" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Segmento s = (Segmento) request.getAttribute("segmento");
    ArrayList<LandingStation> estaciones = (ArrayList<LandingStation>) request.getAttribute("estaciones");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= s != null ? "Editar" : "Registrar" %> segmento · OceanLink</title>
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
      <a class="nav-item" href="<%= request.getContextPath() %>/ClienteServlet?action=lista"><svg viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M3 12h18"/></svg><span>Clientes</span></a>
      <a class="nav-item" href="<%= request.getContextPath() %>/LandingStationServlet"><svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg><span>Landing Stations</span></a>
      <a class="nav-item active" href="<%= request.getContextPath() %>/RedesSubmarinasServlet"><svg viewBox="0 0 24 24"><path d="M3 12h4l3-7 4 14 3-7h4"/></svg><span>Redes submarinas</span></a>
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
          <h1 id="pageTitle"><%= s != null ? "Editar segmento" : "Registrar nuevo segmento" %></h1>
          <div class="psub" id="pageSub"><%= s != null ? "Modifica los datos del segmento submarino." : "Añade un nuevo segmento entre dos estaciones." %></div>
        </div>
        <div class="grow"></div>
      </div>

      <div class="card card-pad" style="max-width:720px">
        <form id="mainForm" action="<%= request.getContextPath() %>/RedesSubmarinasServlet?action=crear" method="post">

          <% if (s != null) { %>
            <input type="hidden" name="idSegmento" value="<%= s.getIdSegmento() %>">
          <% } %>

          <div class="form-grid" id="formGrid" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
            <div class="field" style="grid-column: span 2;">
              <label>Código (*)</label>
              <input class="input" name="codigo" id="fCodigo" value="<%= s != null ? s.getCodigo() : "" %>"><div class="err" id="eCodigo" style="display:none;">Este campo es obligatorio.</div>
            </div>
            <div class="field">
              <label>Estación de origen (*)</label>
              <select class="input" name="idEstacionOrigen" id="fOrigen" required>
                <% if (estaciones != null) {
                     for (LandingStation ls : estaciones) {
                       boolean sel = (s != null && s.getIdEstacionOrigen() == ls.getIdLandingStation()); %>
                  <option value="<%= ls.getIdLandingStation() %>" <%= sel ? "selected" : "" %>><%= ls.getNombre() %> (<%= ls.getCodigo() %>)</option>
                <%   }
                   } %>
              </select>
            </div>
            <div class="field">
              <label>Estación de destino (*)</label>
              <select class="input" name="idEstacionDestino" id="fDestino" required>
                <% if (estaciones != null) {
                     for (LandingStation ls : estaciones) {
                       boolean sel = (s != null && s.getIdEstacionDestino() == ls.getIdLandingStation()); %>
                  <option value="<%= ls.getIdLandingStation() %>" <%= sel ? "selected" : "" %>><%= ls.getNombre() %> (<%= ls.getCodigo() %>)</option>
                <%   }
                   } %>
              </select>
              <div class="err" id="eDestino" style="display:none;">El destino debe ser distinto del origen.</div>
            </div>
            <div class="field">
              <label>Capacidad total (Gbps) (*)</label>
              <input class="input" type="number" step="0.01" min="0" name="capacidadTotal" id="fCapTotal" value="<%= s != null ? s.getCapacidadTotal() : "" %>"><div class="err" id="eCapTotal" style="display:none;">Ingrese un número válido.</div>
            </div>
            <div class="field">
              <label>Longitud (Km) (*)</label>
              <input class="input" type="number" step="0.01" min="0" name="longitudKm" id="fLongitud" value="<%= s != null ? s.getLongitudKm() : "" %>"><div class="err" id="eLongitud" style="display:none;">Ingrese un número válido.</div>
            </div>
            <div class="field">
              <label>Capacidad utilizada (Gbps) (*)</label>
              <input class="input" type="number" step="0.01" min="0" name="capacidadUtilizada" id="fCapUtil" value="<%= s != null ? s.getCapacidadUtilizada() : "" %>"><div class="err" id="eCapUtil" style="display:none;">Ingrese un número válido.</div>
            </div>
            <div class="field">
              <label>Capacidad reservada (Gbps) (*)</label>
              <input class="input" type="number" step="0.01" min="0" name="capacidadReservada" id="fCapRes" value="<%= s != null ? s.getCapacidadReservada() : "" %>"><div class="err" id="eCapRes" style="display:none;">Ingrese un número válido.</div>
            </div>
            <div class="field">
              <label>Estado (*)</label>
              <select class="input" name="estado" required>
                <option value="Operativo" <%= (s != null && "Operativo".equals(s.getEstado())) ? "selected" : "" %>>Operativo</option>
                <option value="Degradado" <%= (s != null && "Degradado".equals(s.getEstado())) ? "selected" : "" %>>Degradado</option>
                <option value="En mantenimiento" <%= (s != null && "En mantenimiento".equals(s.getEstado())) ? "selected" : "" %>>En mantenimiento</option>
                <option value="Fuera de servicio" <%= (s != null && "Fuera de servicio".equals(s.getEstado())) ? "selected" : "" %>>Fuera de servicio</option>
              </select>
            </div>
            <div class="field" style="grid-column: span 2;">
              <label>Descripción</label>
              <input class="input" name="descripcion" id="fDescripcion" value="<%= s != null && s.getDescripcion() != null ? s.getDescripcion() : "" %>">
            </div>
          </div>

          <div class="hint" style="margin-top:10px">(*) Campos obligatorios</div>

          <div class="form-actions" id="formActions">
            <div class="grow"></div>
            <a class="btn btn-outline" href="<%= request.getContextPath() %>/RedesSubmarinasServlet?action=lista">Cancelar</a>
            <button type="button" class="btn btn-primary" onclick="showConfirm()">Continuar</button>
          </div>

          <!-- SECCIÓN DE CONFIRMACIÓN (Oculta por defecto) -->
          <div id="confirmView" style="display:none;">
            <div class="info-strip">
              <div class="ii">i</div>
              <div>
                <div class="it" id="confName"></div>
                <div class="id" id="confRuta"></div>
              </div>
            </div>
            <div class="data-list">
              <div class="data-label">Código</div>
              <div class="data-value" id="cvCodigo"></div>
              <div class="data-label">Ruta</div>
              <div class="data-value" id="cvRuta"></div>
              <div class="data-label">Capacidad total</div>
              <div class="data-value" id="cvCapTotal"></div>
              <div class="data-label">Estado</div>
              <div class="data-value" id="cvEstado"></div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn btn-outline" onclick="hideConfirm()">Volver a editar</button>
              <button type="submit" class="btn btn-primary">Confirmar <%= s != null ? "cambios" : "registro" %></button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<script>
var esEdicion = <%= s != null ? "true" : "false" %>;

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

    checkField("fCodigo", "eCodigo", document.getElementById("fCodigo").value.trim() === "");

    var capTotal = document.getElementById("fCapTotal").value.trim();
    checkField("fCapTotal", "eCapTotal", capTotal === "" || isNaN(capTotal) || Number(capTotal) < 0);

    var longitud = document.getElementById("fLongitud").value.trim();
    checkField("fLongitud", "eLongitud", longitud === "" || isNaN(longitud) || Number(longitud) < 0);

    var capUtil = document.getElementById("fCapUtil").value.trim();
    checkField("fCapUtil", "eCapUtil", capUtil === "" || isNaN(capUtil) || Number(capUtil) < 0);

    var capRes = document.getElementById("fCapRes").value.trim();
    checkField("fCapRes", "eCapRes", capRes === "" || isNaN(capRes) || Number(capRes) < 0);

    // El destino no puede ser igual al origen
    var origen = document.getElementById("fOrigen").value;
    var destino = document.getElementById("fDestino").value;
    checkField("fDestino", "eDestino", origen === destino);

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

    var selOrigen = document.getElementById("fOrigen");
    var selDestino = document.getElementById("fDestino");
    var textoRuta = selOrigen.options[selOrigen.selectedIndex].text + " → " + selDestino.options[selDestino.selectedIndex].text;

    document.getElementById("cvCodigo").innerText = document.getElementsByName("codigo")[0].value;
    document.getElementById("cvRuta").innerText = textoRuta;
    document.getElementById("cvCapTotal").innerText = document.getElementsByName("capacidadTotal")[0].value + " Gbps";

    var estadoSelect = document.getElementsByName("estado")[0];
    document.getElementById("cvEstado").innerText = estadoSelect.options[estadoSelect.selectedIndex].text;

    document.getElementById("confName").innerText = document.getElementsByName("codigo")[0].value;
    document.getElementById("confRuta").innerText = textoRuta;

    document.getElementById("pageTitle").innerText = esEdicion ? "Confirmar cambios" : "Confirmar registro";
    document.getElementById("pageSub").innerText = esEdicion ? "Revisa los datos del segmento antes de guardarlos." : "Revisa la información antes de confirmar el registro.";

    document.getElementById("confirmView").style.display = "block";
}

function hideConfirm() {
    document.getElementById("confirmView").style.display = "none";
    document.getElementById("formGrid").style.display = "grid";
    document.getElementById("formActions").style.display = "flex";
    document.querySelector(".hint").style.display = "block";

    document.getElementById("pageTitle").innerText = esEdicion ? "Editar segmento" : "Registrar nuevo segmento";
    document.getElementById("pageSub").innerText = esEdicion ? "Modifica los datos del segmento submarino." : "Añade un nuevo segmento entre dos estaciones.";
}
</script>
</body>
</html>
