
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
    <title>Actualizar incidencia - OceanLink</title>
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
        <header class="topbar"><h2>Actualizar estado</h2></header>
        <section class="content">
            <% if (incidencia == null) { %>
                <p>No se encontró la incidencia.</p>
            <% } else { %>
                <h1><%=incidencia.getCodigo()%> - <%=incidencia.getTitulo()%></h1>
                <p>Estado actual: <strong><%=incidencia.getEstado()%></strong></p>

                <% if (error != null) { %>
                    <p class="error"><%=error%></p>
                <% } %>

                <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
                    <input type="hidden" name="action" value="actualizarEstado">
                    <input type="hidden" name="id" value="<%=incidencia.getIdIncidencia()%>">

                    <label for="nuevoEstado">Nuevo estado *</label>
                    <select id="nuevoEstado" name="nuevoEstado" required>
                        <option value="">Selecciona un estado</option>
                        <option value="Detectada">Detectada</option>
                        <option value="En análisis">En análisis</option>
                        <option value="Servicio restaurado">Servicio restaurado</option>
                        <option value="Cerrada">Cerrada</option>
                    </select>

                    <label for="observacion">Observación (opcional)</label>
                    <textarea id="observacion" name="observacion" rows="4"></textarea>

                    <button type="submit">Guardar cambios</button>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=incidencia.getIdIncidencia()%>">Cancelar</a>
                </form>
            <% } %>
        </section>
    </main>
</div>
</body>
</html>
