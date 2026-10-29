
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%
    String ctx = request.getContextPath();
    ArrayList<String[]> clientes =
        (ArrayList<String[]>) request.getAttribute("clientes");
    ArrayList<String[]> rutas =
        (ArrayList<String[]>) request.getAttribute("rutas");
    if (clientes == null) clientes = new ArrayList<>();
    if (rutas == null) rutas = new ArrayList<>();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nueva solicitud - OceanLink</title>
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
        <header class="topbar"><h2>Nueva solicitud de capacidad</h2></header>
        <section class="content">
            <h1>Registrar solicitud</h1>

            <% if (error != null) { %>
                <p class="error"><%=error%></p>
            <% } %>

            <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
                <input type="hidden" name="action" value="crearSolicitud">

                <label for="idCliente">Cliente *</label>
                <select id="idCliente" name="idCliente" required>
                    <option value="">Selecciona un cliente</option>
                    <% for (String[] cliente : clientes) { %>
                        <option value="<%=cliente[0]%>"><%=cliente[1]%></option>
                    <% } %>
                </select>

                <label for="idRuta">Ruta *</label>
                <select id="idRuta" name="idRuta" required>
                    <option value="">Selecciona una ruta</option>
                    <% for (String[] ruta : rutas) { %>
                        <option value="<%=ruta[0]%>"><%=ruta[1]%></option>
                    <% } %>
                </select>

                <label for="capacidad">Capacidad solicitada *</label>
                <input id="capacidad" name="capacidad" type="number"
                       min="0.01" step="0.01" required>

                <label for="fechaLimite">Fecha límite</label>
                <input id="fechaLimite" name="fechaLimite" type="date"
                       min="<%=LocalDate.now()%>">

                <label for="motivo">Motivo de la solicitud *</label>
                <textarea id="motivo" name="motivo" rows="4" required></textarea>

                <label for="observacion">Observaciones</label>
                <textarea id="observacion" name="observacion" rows="3"></textarea>

                <button type="submit">Registrar solicitud</button>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=solicitudes">Cancelar</a>
            </form>
        </section>
    </main>
</div>
</body>
</html>
