
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.ObservacionIncidencia" %>
<%
    String ctx = request.getContextPath();
    ArrayList<ObservacionIncidencia> lista =
        (ArrayList<ObservacionIncidencia>) request.getAttribute("lista");
    if (lista == null) lista = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Historial - OceanLink</title>
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
        <header class="topbar"><h2>Historial de incidencias</h2></header>
        <section class="content">
            <h1>Historial de eventos</h1>
            <p>Consulta los registros, cambios de estado, observaciones y restauraciones.</p>

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Fecha y hora</th>
                        <th>Incidencia</th>
                        <th>Título</th>
                        <th>Tipo de evento</th>
                        <th>Detalle</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (ObservacionIncidencia evento : lista) { %>
                    <tr>
                        <td><%=evento.getFechaRegistro()%></td>
                        <td>
                            <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=evento.getIdIncidencia()%>">
                                <%=evento.getCodigoIncidencia()%>
                            </a>
                        </td>
                        <td><%=evento.getTituloIncidencia()%></td>
                        <td><%=evento.getTipo()%></td>
                        <td><%=evento.getDetalle()%></td>
                    </tr>
                    <% } %>
                    <% if (lista.isEmpty()) { %>
                    <tr><td colspan="5">No hay eventos en el historial.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</body>
</html>
