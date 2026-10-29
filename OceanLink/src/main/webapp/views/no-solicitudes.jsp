
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.SolicitudCapacidad" %>
<%
    String ctx = request.getContextPath();
    ArrayList<SolicitudCapacidad> lista =
        (ArrayList<SolicitudCapacidad>) request.getAttribute("lista");
    if (lista == null) lista = new ArrayList<>();
    String buscar = request.getParameter("buscar") == null
        ? "" : request.getParameter("buscar");
    String estado = request.getParameter("estado") == null
        ? "" : request.getParameter("estado");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Solicitudes de capacidad - OceanLink</title>
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
        <header class="topbar"><h2>Solicitudes de capacidad</h2></header>
        <section class="content">
            <h1>Solicitudes de capacidad</h1>
            <p>Registra y consulta solicitudes de capacidad.</p>

            <a class="btn" href="<%=ctx%>/NetworkOperatorServlet?action=nuevaSolicitud">
                Nueva solicitud
            </a>

            <form method="get" action="<%=ctx%>/NetworkOperatorServlet">
                <input type="hidden" name="action" value="solicitudes">
                <input type="text" name="buscar" placeholder="Buscar código, ruta o motivo"
                       value="<%=buscar%>">

                <select name="estado">
                    <option value="">Todos los estados</option>
                    <option value="Registrada" <%= "Registrada".equals(estado) ? "selected" : "" %>>Registrada</option>
                    <option value="En revisión" <%= "En revisión".equals(estado) ? "selected" : "" %>>En revisión</option>
                    <option value="Aprobada" <%= "Aprobada".equals(estado) ? "selected" : "" %>>Aprobada</option>
                    <option value="Rechazada" <%= "Rechazada".equals(estado) ? "selected" : "" %>>Rechazada</option>
                </select>

                <button type="submit">Buscar</button>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Limpiar</a>
            </form>

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Código</th>
                        <th>Cliente</th>
                        <th>Ruta</th>
                        <th>Capacidad solicitada</th>
                        <th>Fecha de solicitud</th>
                        <th>Estado</th>
                        <th>Detalle</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (SolicitudCapacidad s : lista) { %>
                    <tr>
                        <td><%=s.getCodigo()%></td>
                        <td><%=s.getCliente()%></td>
                        <td><%=s.getRuta()%></td>
                        <td><%=s.getCapacidadSolicitada()%></td>
                        <td><%=s.getFechaSolicitud()%></td>
                        <td><%=s.getEstado()%></td>
                        <td>
                            <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleSolicitud&id=<%=s.getIdSolicitud()%>">Ver detalle</a>
                        </td>
                    </tr>
                    <% } %>
                    <% if (lista.isEmpty()) { %>
                    <tr><td colspan="7">No se encontraron solicitudes.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</body>
</html>
