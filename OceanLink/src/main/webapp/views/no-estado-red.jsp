
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.Segmento" %>
<%
    String ctx = request.getContextPath();
    ArrayList<Segmento> lista =
        (ArrayList<Segmento>) request.getAttribute("lista");
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
    <title>Estado de la red - OceanLink</title>
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
        <header class="topbar"><h2>Estado de la red</h2></header>
        <section class="content">
            <h1>Estado de los segmentos</h1>
            <p>Consulta los segmentos de red registrados por el administrador.</p>

            <form method="get" action="<%=ctx%>/NetworkOperatorServlet">
                <input type="hidden" name="action" value="redes">
                <input type="text" name="buscar" placeholder="Buscar código u origen/destino"
                       value="<%=buscar%>">

                <select name="estado">
                    <option value="">Todos los estados</option>
                    <option value="Operativo" <%= "Operativo".equals(estado) ? "selected" : "" %>>Operativo</option>
                    <option value="Degradado" <%= "Degradado".equals(estado) ? "selected" : "" %>>Degradado</option>
                    <option value="En mantenimiento" <%= "En mantenimiento".equals(estado) ? "selected" : "" %>>En mantenimiento</option>
                    <option value="Fuera de servicio" <%= "Fuera de servicio".equals(estado) ? "selected" : "" %>>Fuera de servicio</option>
                </select>
                <button type="submit">Buscar</button>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=redes">Limpiar</a>
            </form>

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Código</th>
                        <th>Origen</th>
                        <th>Destino</th>
                        <th>Capacidad total</th>
                        <th>Capacidad disponible</th>
                        <th>Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Segmento s : lista) { %>
                    <tr>
                        <td><%= s.getCodigo() %></td>
                        <td><%= s.getNombreOrigen() %></td>
                        <td><%= s.getNombreDestino() %></td>
                        <td><%= s.getCapacidadTotal() %></td>
                        <td><%= s.getCapacidadDisponible() %></td>
                        <td><%= s.getEstado() %></td>
                    </tr>
                    <% } %>
                    <% if (lista.isEmpty()) { %>
                    <tr><td colspan="6">No se encontraron segmentos.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</body>
</html>
