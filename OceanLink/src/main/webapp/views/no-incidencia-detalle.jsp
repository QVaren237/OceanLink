
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.*" %>
<%
    String ctx = request.getContextPath();
    Incidencia incidencia =
        (Incidencia) request.getAttribute("incidencia");
    ArrayList<ObservacionIncidencia> eventos =
        (ArrayList<ObservacionIncidencia>) request.getAttribute("eventos");
    if (eventos == null) eventos = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Detalle de incidencia - OceanLink</title>
    <link rel="stylesheet" href="<%=ctx%>/css/styles.css">
</head>
<body>
<div class="shell">
    <aside class="side">
        <div class="brand brand-side">
            <img class="brand-img" src="<%=ctx%>/assets/logo.png" alt="OceanLink">
        </div>
        <nav class="nav-sec">
            <div class="nav-label">Módulos</div>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=panel">Panel</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=redes">Estado de la red</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Incidencias</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Solicitudes de capacidad</a>
            <a class="nav-item" href="<%=ctx%>/NetworkOperatorServlet?action=historial">Historial</a>
        </nav>
    </aside>

    <main class="main">
        <header class="topbar"><h2>Detalle de incidencia</h2></header>
        <section class="content">
            <% if (incidencia == null) { %>
                <h1>Incidencia no encontrada</h1>
                <p>No se encontró la incidencia solicitada.</p>
            <% } else { %>
                <h1><%=incidencia.getTitulo()%></h1>

                <p><strong>Código:</strong> <%=incidencia.getCodigo()%></p>
                <p><strong>Descripción:</strong> <%=incidencia.getDescripcion()%></p>
                <p><strong>Severidad:</strong> <%=incidencia.getSeveridad()%></p>
                <p><strong>Estado:</strong> <%=incidencia.getEstado()%></p>
                <p><strong>Redes afectadas:</strong>
                    <%=incidencia.getRedes() == null ? "-" : incidencia.getRedes()%>
                </p>
                <p><strong>Fecha de detección:</strong>
                    <%=incidencia.getFechaDeteccion() == null ? "-" : incidencia.getFechaDeteccion()%>
                </p>
                <p><strong>Fecha de cierre:</strong>
                    <%=incidencia.getFechaCierre() == null ? "-" : incidencia.getFechaCierre()%>
                </p>

                <p>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=actualizarIncidencia&id=<%=incidencia.getIdIncidencia()%>">Actualizar estado</a>
                    |
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=restauracion&id=<%=incidencia.getIdIncidencia()%>">Registrar restauración</a>
                    |
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=observacion&id=<%=incidencia.getIdIncidencia()%>">Agregar observación</a>
                    |
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=historial&id=<%=incidencia.getIdIncidencia()%>">Ver historial</a>
                </p>

                <h2>Historial de eventos</h2>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr><th>Fecha</th><th>Tipo</th><th>Detalle</th></tr>
                        </thead>
                        <tbody>
                        <% for (ObservacionIncidencia evento : eventos) { %>
                        <tr>
                            <td><%=evento.getFechaRegistro()%></td>
                            <td><%=evento.getTipo()%></td>
                            <td><%=evento.getDetalle()%></td>
                        </tr>
                        <% } %>
                        <% if (eventos.isEmpty()) { %>
                        <tr><td colspan="3">No hay eventos registrados.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
            <p><a href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Volver a incidencias</a></p>
        </section>
    </main>
</div>
</body>
</html>
