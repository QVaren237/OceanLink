
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="pe.edu.oceanlink.bean.SolicitudCapacidad" %>
<%
    String ctx = request.getContextPath();
    SolicitudCapacidad solicitud =
        (SolicitudCapacidad) request.getAttribute("solicitud");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detalle de solicitud - OceanLink</title>
    <link rel="stylesheet" href="<%=ctx%>/css/styles.css">
</head>
<body>
<div class="shell">
    <aside class="side">
        <div class="brand brand-side">
            <img class="brand-img" src="<%=ctx%>/assets/logo.png" alt="OceanLink">
        </div>
        <nav class="nav-sec">
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=panel">Panel</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=redes">Estado de la red</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Incidencias</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Solicitudes de capacidad</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=historial">Historial</a>
        </nav>
    </aside>

    <main class="main">
        <header class="topbar"><h2>Detalle de solicitud</h2></header>
        <section class="content">
            <% if (solicitud == null) { %>
                <h1>Solicitud no encontrada</h1>
                <p>No se encontró la solicitud solicitada.</p>
            <% } else { %>
                <h1><%=solicitud.getCodigo()%></h1>
                <p><strong>Cliente:</strong> <%=solicitud.getCliente()%></p>
                <p><strong>Ruta:</strong> <%=solicitud.getRuta()%></p>
                <p><strong>Capacidad solicitada:</strong>
                    <%=solicitud.getCapacidadSolicitada()%></p>
                <p><strong>Fecha de solicitud:</strong>
                    <%=solicitud.getFechaSolicitud()%></p>
                <p><strong>Fecha límite:</strong>
                    <%=solicitud.getFechaLimite() == null ? "-" : solicitud.getFechaLimite()%></p>
                <p><strong>Motivo:</strong> <%=solicitud.getMotivo()%></p>
                <p><strong>Estado:</strong> <%=solicitud.getEstado()%></p>
                <p><strong>Observación:</strong>
                    <%=solicitud.getObservacion() == null ? "-" : solicitud.getObservacion()%></p>
            <% } %>

            <p><a href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Volver a solicitudes</a></p>
        </section>
    </main>
</div>
</body>
</html>
