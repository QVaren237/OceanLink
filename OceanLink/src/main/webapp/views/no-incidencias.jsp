
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.Incidencia" %>
<%
    String ctx = request.getContextPath();
    ArrayList<Incidencia> lista =
        (ArrayList<Incidencia>) request.getAttribute("lista");
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
    <title>Incidencias - OceanLink</title>
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
        <header class="topbar"><h2>Gestión de incidencias</h2></header>
        <section class="content">
            <h1>Incidencias</h1>
            <p>Registra incidencias y consulta su estado.</p>

            <a class="btn" href="<%=ctx%>/NetworkOperatorServlet?action=nuevaIncidencia">
                Registrar incidencia
            </a>

            <form method="get" action="<%=ctx%>/NetworkOperatorServlet">
                <input type="hidden" name="action" value="incidencias">
                <input type="text" name="buscar" placeholder="Buscar código o título"
                       value="<%=buscar%>">

                <select name="estado">
                    <option value="">Todos los estados</option>
                    <option value="Detectada" <%= "Detectada".equals(estado) ? "selected" : "" %>>Detectada</option>
                    <option value="En análisis" <%= "En análisis".equals(estado) ? "selected" : "" %>>En análisis</option>
                    <option value="Servicio restaurado" <%= "Servicio restaurado".equals(estado) ? "selected" : "" %>>Servicio restaurado</option>
                    <option value="Cerrada" <%= "Cerrada".equals(estado) ? "selected" : "" %>>Cerrada</option>
                </select>
                <button type="submit">Buscar</button>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Limpiar</a>
            </form>

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Código</th>
                        <th>Título</th>
                        <th>Redes afectadas</th>
                        <th>Severidad</th>
                        <th>Estado</th>
                        <th>Fecha de detección</th>
                        <th>Acciones</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% for (Incidencia i : lista) { %>
                    <tr>
                        <td><%= i.getCodigo() %></td>
                        <td><%= i.getTitulo() %></td>
                        <td><%= i.getRedes() == null ? "-" : i.getRedes() %></td>
                        <td><%= i.getSeveridad() %></td>
                        <td><%= i.getEstado() %></td>
                        <td><%= i.getFechaDeteccion() == null ? "-" : i.getFechaDeteccion() %></td>
                        <td>
                            <a href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&id=<%=i.getIdIncidencia()%>">Ver</a>
                            |
                            <a href="<%=ctx%>/NetworkOperatorServlet?action=actualizarIncidencia&id=<%=i.getIdIncidencia()%>">Actualizar</a>
                        </td>
                    </tr>
                    <% } %>
                    <% if (lista.isEmpty()) { %>
                    <tr><td colspan="7">No hay incidencias registradas.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</div>
</body>
</html>
