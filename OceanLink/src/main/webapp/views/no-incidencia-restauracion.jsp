
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
    <title>Restauración de servicio - OceanLink</title>
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
        <header class="topbar"><h2>Restauración del servicio</h2></header>
        <section class="content">
            <% if (incidencia == null) { %>
                <p>No se encontró la incidencia.</p>
            <% } else { %>
                <h1><%=incidencia.getCodigo()%> - <%=incidencia.getTitulo()%></h1>

                <% if (error != null) { %>
                    <p class="error"><%=error%></p>
                <% } %>

                <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
                    <input type="hidden" name="action" value="registrarRestauracion">
                    <input type="hidden" name="id" value="<%=incidencia.getIdIncidencia()%>">

                    <label for="resultado">Resultado de la restauración *</label>
                    <select id="resultado" name="resultado" required>
                        <option value="">Selecciona el resultado</option>
                        <option value="Servicio restablecido">Servicio restablecido</option>
                        <option value="Restauración parcial">Restauración parcial</option>
                    </select>

                    <label for="observaciones">Observaciones *</label>
                    <textarea id="observaciones" name="observaciones" rows="5" required></textarea>

                    <button type="submit">Registrar restauración</button>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=incidencia.getIdIncidencia()%>">Cancelar</a>
                </form>
            <% } %>
        </section>
    </main>
</div>
</body>
</html>
