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
<title>OceanLink · Editar mi usuario</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=ctx%>/css/styles.css">
</head>
<body class="no-shell profile-edit-page">
<main class="profile-edit-main">
  <header class="topbar profile-edit-topbar">
    <div class="crumb">OceanLink / Network Operator</div>
  </header>

  <section class="profile-edit-content">
    <div class="profile-edit-head">
      <div>
        <p class="eyebrow">CUENTA</p>
        <h1>Editar mi usuario</h1>
        <div class="psub">Actualiza los datos de tu cuenta.</div>
      </div>
    </div>

    <% if(cuenta==null){ %><div class="banner banner-err">Inicia sesión para editar tu cuenta. No hay un usuario autenticado en este navegador.</div><% } %>
    <% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
    <% if("1".equals(request.getParameter("guardado"))){ %><div class="info-strip" role="status">Perfil actualizado correctamente.</div><% } %>
    <section class="profile-edit-card">
      <form action="<%=ctx%>/NetworkOperatorServlet" method="post" enctype="multipart/form-data" class="profile-edit-form"><input type="hidden" name="action" value="guardarPerfil"><input type="hidden" name="quitarFoto" id="quitarFoto" value="false">
        <div class="profile-edit-left">
          <label class="field-label">Nombre <span class="required-mark">*</span>
            <input class="input" type="text" name="nombre" maxlength="50" value="<%=cuenta==null?"":h(cuenta.getNombre())%>" required><span class="validation-message">Este campo es obligatorio.</span>
          </label>

          <label class="field-label">Apellido <span class="required-mark">*</span><input class="input" name="apellido" maxlength="50" value="<%=cuenta==null?"":h(cuenta.getApellido())%>" required></label>
          <label class="field-label">Correo electrónico <span class="required-mark">*</span>
            <input class="input" type="email" name="correo" maxlength="50" value="<%=cuenta==null?"":h(cuenta.getCorreo())%>" required><span class="validation-message">Este campo es obligatorio.</span>
          </label>

          <div class="field-label">Mi contraseña actual <span class="required-mark">*</span>
            <div class="password-field">
              <input class="password-input input" id="current-password" type="password" name="claveActual" autocomplete="current-password" aria-label="Mi contraseña actual" required><span class="validation-message">Este campo es obligatorio.</span>
            </div>
          </div>

          <div class="field-label">Contraseña nueva
            <div class="password-field">
              <input class="password-input input" id="new-password" name="nuevaPassword" maxlength="256" autocomplete="new-password" type="password" placeholder="Ingresa una nueva contraseña" aria-label="Ingresa una nueva contraseña">
            </div>
          </div>

          <div class="field-label">Confirmar contraseña
            <div class="password-field">
              <input class="password-input input" id="confirm-password" name="confirmarPassword" maxlength="256" autocomplete="new-password" type="password" placeholder="Repite la nueva contraseña" aria-label="Repite la nueva contraseña">
            </div>
          </div>

          <label class="field-label">Cambio de rol
            <input class="input" type="text" value="Network Operator" disabled>
          </label>

          <div class="profile-edit-divider"></div>
          <div class="profile-edit-actions">
            <a class="btn btn-outline" href="<%=ctx%>/NetworkOperatorServlet?action=panel">Cancelar</a>
            <button class="btn btn-primary" type="submit" <%=cuenta==null?"disabled":""%>>Aceptar</button>
          </div>
        </div>

        <div class="profile-edit-image">
          <div class="profile-photo-placeholder" id="fotoIniciales" <%=request.getAttribute("fotoPerfil")!=null?"hidden":""%>><span><%=cuenta==null?"NO":h(cuenta.getNombre().substring(0,1)+cuenta.getApellido().substring(0,1))%></span></div><img class="no-profile-photo" id="fotoVista" alt="Foto de perfil" <%=request.getAttribute("fotoPerfil")==null?"hidden":"src=\""+h(request.getAttribute("fotoPerfil"))+"\""%>>
          <div class="profile-image-actions">
            <label class="btn btn-primary" for="fotoArchivo">Editar imagen</label><input id="fotoArchivo" name="foto" type="file" accept="image/png,image/jpeg" hidden>
            <button class="btn btn-outline" type="button" id="quitarImagen">Quitar</button>
          </div>
          <p>Foto de perfil del usuario. Formato JPG o<br>PNG, máximo 2 MB.</p>
        </div>
      </form>
    </section>
  </section>

  <footer class="appfoot profile-edit-footer"><span>OceanLink · Centro de operaciones</span></footer>
</main>

<script>
const archivo=document.getElementById('fotoArchivo'),vista=document.getElementById('fotoVista'),iniciales=document.getElementById('fotoIniciales');let preview;
archivo.onchange=()=>{const f=archivo.files[0];if(!f)return;if(f.size>2097152||!['image/jpeg','image/png'].includes(f.type)){archivo.value='';alert('Selecciona una imagen JPG o PNG de hasta 2 MB.');return;}if(preview)URL.revokeObjectURL(preview);preview=URL.createObjectURL(f);vista.src=preview;vista.hidden=false;iniciales.hidden=true;document.getElementById('quitarFoto').value='false';};
document.getElementById('quitarImagen').onclick=()=>{archivo.value='';vista.hidden=true;iniciales.hidden=false;document.getElementById('quitarFoto').value='true';};
document.querySelector('form').addEventListener('submit',e=>{if(document.getElementById('new-password').value!==document.getElementById('confirm-password').value){e.preventDefault();alert('Las contraseñas nuevas no coinciden.');}});
</script></body>
</html>
