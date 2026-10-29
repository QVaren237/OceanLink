
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String tipo = request.getParameter("tipo");
    if (tipo == null) {
        tipo = (String) request.getAttribute("tipo");
    }

    String mensaje = "La operación se completó correctamente.";

    if ("incidencia".equals(tipo)) {
        mensaje = "La incidencia se registró correctamente.";
    } else if ("actualizacion".equals(tipo)) {
        mensaje = "El estado de la incidencia se actualizó correctamente.";
    } else if ("restauracion".equals(tipo)) {
        mensaje = "La restauración se registró correctamente.";
    } else if ("observacion".equals(tipo)) {
        mensaje = "La observación se registró correctamente.";
    } else if ("solicitud".equals(tipo)) {
        mensaje = "La solicitud de capacidad se registró correctamente.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Operación completada - OceanLink</title>
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
        <section class="content">
            <h1>¡Operación completada!</h1>
            <p><%=mensaje%></p>
            <p>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=panel">Volver al panel</a>
            </p>
            <p>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Ir a incidencias</a>
            </p>
            <p>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Ir a solicitudes</a>
            </p>
        </section>
    </main>
</div>
</body>
</html>
