<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>OceanLink · Bienvenido</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>

<header class="land-top">
  <img class="brand-img" src="${pageContext.request.contextPath}/assets/logo.png" alt="OceanLink">
  <div class="grow"></div>
  <a class="btn btn-primary" href="${pageContext.request.contextPath}/LoginServlet">Ingresar →</a>
</header>

<div class="land-wrap">

  <section class="hero-l">
    <div class="hleft">
      <div class="eyebrow">OceanLink · Network Operations</div>
      <h1>Gestión inteligente de redes de cable submarino</h1>
      <p>OceanLink es la plataforma que centraliza la operación de la red submarina: estaciones de aterrizaje, segmentos de fibra, capacidad y usuarios, con control de acceso por rol para cada equipo.</p>
          </div>
    <div class="hart"><div class="halo"></div></div>
  </section>

  <section>
    <div class="sec-title">¿Qué hacemos?</div>
    <div class="sec-sub">Damos soporte a la operación diaria de la infraestructura submarina de telecomunicaciones, de forma centralizada y segura.</div>
    <div class="feat-grid">
      <div class="feat"><div class="fic"><svg viewBox="0 0 24 24"><circle cx="5" cy="6" r="2"/><circle cx="19" cy="6" r="2"/><circle cx="12" cy="18" r="2"/><path d="M6.7 7.3 11 16m6.3-8.7L13 16"/></svg></div><h3>Infraestructura de red</h3><p>Consulta y administra estaciones de aterrizaje, segmentos y la capacidad contratada de la red submarina.</p></div>
      <div class="feat"><div class="fic"><svg viewBox="0 0 24 24"><path d="M12 3l7 3v5c0 4.4-3 7.5-7 9-4-1.5-7-4.6-7-9V6z"/><path d="M9.5 12l1.8 1.8L15 10"/></svg></div><h3>Acceso por rol</h3><p>Cada usuario ve solo lo que le corresponde: administrador, operador de red, capacidad, mantenimiento y supervisión.</p></div>
      <div class="feat"><div class="fic"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18"/></svg></div><h3>Operación centralizada</h3><p>Un solo lugar para monitorear el estado de la red, gestionar incidencias y coordinar el trabajo del equipo.</p></div>
    </div>
  </section>

  <section id="nosotros" class="about">
    <div class="aimg"></div>
    <div class="atxt">
      <h2>Quiénes somos</h2>
      <p>Somos el equipo detrás de OceanLink, enfocado en mantener conectados a los clientes a través de la red de cable submarino. Nuestro trabajo es que la información viaje bajo el océano de forma confiable, rápida y segura.</p>
      <p>Este espacio reúne a los distintos roles que operan la red para trabajar coordinados sobre una misma plataforma.</p>
    </div>
  </section>

</div>
<footer class="land-foot">OceanLink · Centro de operaciones</footer>

</body>
</html>
