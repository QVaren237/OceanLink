<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Iniciar sesión · OceanLink</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=3">
<style>

  input[type=password]::-ms-reveal,
  input[type=password]::-ms-clear { display:none; }

  .err-msg{display:none;color:#c0334a;font-size:12.5px;margin-top:6px}
  .field.invalid .input{border-color:#c0334a}
  .field.invalid .err-msg{display:block}
</style>
</head>
<body>
<a class="btn btn-primary" href="${pageContext.request.contextPath}/" style="position:absolute;top:20px;left:24px">&larr; Regresar</a>
<div class="auth"><div class="auth-card" style="border:2px solid #14b8a6">
  <div class="brand brand-auth"><img class="brand-img" src="${pageContext.request.contextPath}/assets/logo.png" alt="Ocean Link Logistics"></div>
  <h1>Iniciar sesión</h1>
  <p class="sub">Ingresa con tu cuenta para acceder a los módulos de tu rol.</p>
  <% if (request.getAttribute("error") != null) { %>
    <div style="margin:0 0 14px;background:#f3c3c8;color:#9e1b2b;padding:10px 12px;border-radius:8px;font-size:14px"><%= request.getAttribute("error") %></div>
  <% } %>
  <form id="loginForm" action="${pageContext.request.contextPath}/LoginServlet" method="post" novalidate onsubmit="return validarLogin()">
    <input type="hidden" name="accion" value="login">
    <div class="field" id="f-correo"><label>Correo electrónico</label>
      <input class="input" type="email" name="correo" id="li-correo" placeholder="correo@oceanlink.test" autofocus>
      <small class="err-msg" id="err-correo"></small>
    </div>
    <div class="field" id="f-pass"><label>Contraseña</label>
      <div class="pass-wrap">
        <input class="input" id="li-pass" type="password" name="password" placeholder="Contraseña">
        <button class="eye" type="button" onclick="tp('li-pass',this)"><svg viewBox="0 0 24 24"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg></button>
      </div>
      <small class="err-msg" id="err-pass"></small>
    </div>
    <div class="row-between"><span></span><a class="link" href="${pageContext.request.contextPath}/RecuperarPasswordServlet">¿Olvidaste tu contraseña?</a></div>
    <button class="btn btn-primary" type="submit" style="width:100%;justify-content:center">Iniciar sesión</button>
    <p class="foot-note">El acceso y los módulos visibles dependen del rol asignado por el administrador.</p>
  </form>
</div></div>
<script>
var EYE='<svg viewBox="0 0 24 24"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>';
var EYEOFF='<svg viewBox="0 0 24 24"><path d="M3 3l18 18"/><path d="M10.6 6.2A9.9 9.9 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-3.3 4.1M6.2 6.7A17 17 0 0 0 2 12s3.5 7 10 7a9.8 9.8 0 0 0 4-.8"/><path d="M9.5 9.6a3 3 0 0 0 4.2 4.2"/></svg>';
function tp(id,b){var i=document.getElementById(id);var s=i.type==="password";i.type=s?"text":"password";b.innerHTML=s?EYEOFF:EYE;}

function validarLogin(){
  var ok=true;
  var correo=document.getElementById('li-correo');
  var pass=document.getElementById('li-pass');
  var fc=document.getElementById('f-correo'), ec=document.getElementById('err-correo');
  var fp=document.getElementById('f-pass'), ep=document.getElementById('err-pass');

  var v=correo.value.trim();
  if(v===''){ ec.textContent='Este campo es obligatorio.'; fc.classList.add('invalid'); ok=false; }
  else if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)){ ec.textContent='Ingrese un correo válido. Ejemplo: usuario@dominio.com'; fc.classList.add('invalid'); ok=false; }
  else { fc.classList.remove('invalid'); }

  if(pass.value.trim()===''){ ep.textContent='Este campo es obligatorio.'; fp.classList.add('invalid'); ok=false; }
  else { fp.classList.remove('invalid'); }

  return ok;
}
</script>
</body>
</html>
