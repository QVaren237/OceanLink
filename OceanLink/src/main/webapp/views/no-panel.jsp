
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.*" %>
<%
    String ctx = request.getContextPath();
    ArrayList<Incidencia> incidencias =
        (ArrayList<Incidencia>) request.getAttribute("incidencias");
    ArrayList<Segmento> segmentos =
        (ArrayList<Segmento>) request.getAttribute("segmentos");
    if (incidencias == null) incidencias = new ArrayList<>();
    if (segmentos == null) segmentos = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>OceanLink - Network Operator</title>
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
        <div class="side-foot">Rol activo: Network Operator</div>
    </aside>

    <main class="main">
        <header class="topbar">
            <div class="crumb">OceanLink / Panel</div>
            <div class="userpill">Network Operator</div>
        </header>

        <section class="content">
            <h1>Panel de Network Operator</h1>
            <p>Resumen del estado de la red e incidencias registradas.</p>

            <div class="cards">
                <article class="card">
                    <h3>Segmentos de red</h3>
                    <p><strong><%= segmentos.size() %></strong></p>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=redes">Ver estado completo</a>
                </article>

                <article class="card">
                    <h3>Incidencias registradas</h3>
                    <p><strong><%= incidencias.size() %></strong></p>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Ver incidencias</a>
                </article>

                <article class="card">
                    <h3>Solicitudes de capacidad</h3>
                    <p>Consulta y registra solicitudes.</p>
                    <a href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Ver solicitudes</a>
                </article>
            </div>

            <h2>Incidencias recientes</h2>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Código</th>
                        <th>Título</th>
                        <th>Severidad</th>
                        <th>Estado</th>
                        <th>Acción</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Incidencia i : incidencias) { %>
                    <tr>
                        <td><%= i.getCodigo() %></td>
                        <td><%= i.getTitulo() %></td>
                        <td><%= i.getSeveridad() %></td>
                        <td><%= i.getEstado() %></td>
                        <td>
                            <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=i.getIdIncidencia()%>">
                                Ver detalle
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    <% if (incidencias.isEmpty()) { %>
                    <tr><td colspan="5">No hay incidencias registradas.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</body>
</html>
