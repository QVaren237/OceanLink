<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%
    String destino = request.getContextPath() + "/LoginServlet";
    Usuario __u = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
    if (__u != null) {
        switch (__u.getIdRol()) {
            case 1: destino = request.getContextPath() + "/PanelServlet"; break;
            case 2: destino = request.getContextPath() + "/CapacityPlannerServlet"; break;
            case 3: destino = request.getContextPath() + "/NetworkOperatorServlet"; break;
            case 4: destino = request.getContextPath() + "/MaintenanceCoordinatorServlet"; break;
            case 5: destino = request.getContextPath() + "/SupervisorServlet"; break;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Acceso denegado · OceanLink</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=3">
</head>
<body>
<div class="auth"><div class="auth-card" style="border:2px solid #d62839">
  <div class="brand brand-auth"><img class="brand-img" src="${pageContext.request.contextPath}/assets/logo.png" alt="OceanLink"></div>
  <div class="center-icon" style="background:#f3c3c8;color:#9e1b2b">&#128274;</div>
  <h1>Acceso denegado</h1>
  <p class="sub">No cuentas con los permisos para esta sección. Cada rol solo puede ingresar a sus propios módulos.</p>
  <a class="btn btn-primary" style="width:100%;justify-content:center" href="<%= destino %>">Volver a mi panel</a>
</div></div>
</body>
</html>
