
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="pe.edu.oceanlink.bean.Incidencia" %>
<%
    String ctx = request.getContextPath();
    Incidencia incidencia =
        (Incidencia) request.getAttribute("incidencia");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Agregar observación - OceanLink</title>
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
        <header class="topbar"><h2>Observación de incidencia</h2></header>
        <section class="content">
            <% if (incidencia == null) { %>
                <p>No se encontró la incidencia.</p>
            <% } else { %>
                <h1><%=incidencia.getCodigo()%> - <%=incidencia.getTitulo()%></h1>

                <% if (error != null) { %>
                    <p class="error"><%=error%></p>
                <% } %>

                <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
                    <input type="hidden" name="action" value="registrarObservacion">
                    <input type="hidden" name="id" value="<%=incidencia.getIdIncidencia()%>">

                    <label for="observacion">Detalle de la observación *</label>
                    <textarea id="observacion" name="observacion"
                              rows="5" required></textarea>

                    <button type="submit">Guardar observación</button>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=incidencia.getIdIncidencia()%>">Cancelar</a>
                </form>
            <% } %>
        </section>
    </main>
</div>
</body>
</html>
