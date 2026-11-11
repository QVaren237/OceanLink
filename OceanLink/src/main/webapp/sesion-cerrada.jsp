<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session != null) { session.invalidate(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sesión cerrada · OceanLink</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
<div class="auth"><div class="auth-card" style="border:2px solid #14b8a6">
  <div class="brand brand-auth"><img class="brand-img" src="${pageContext.request.contextPath}/assets/logo.png" alt="OceanLink"></div>
  <div class="center-icon">&#10003;</div>
  <h1>Sesión cerrada</h1>
  <p class="sub">Cerraste sesión correctamente.</p>
  <a class="btn btn-primary" style="width:100%;justify-content:center" href="${pageContext.request.contextPath}/LoginServlet">Volver a iniciar sesión</a>
</div></div>
</body>
</html>
