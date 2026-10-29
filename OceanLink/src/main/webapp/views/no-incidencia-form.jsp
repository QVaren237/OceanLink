
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="pe.edu.oceanlink.bean.Segmento" %>
<%
    String ctx = request.getContextPath();
    ArrayList<Segmento> segmentos =
        (ArrayList<Segmento>) request.getAttribute("segmentos");
    if (segmentos == null) segmentos = new ArrayList<>();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registrar incidencia - OceanLink</title>
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
        <header class="topbar"><h2>Registrar incidencia</h2></header>
        <section class="content">
            <h1>Nueva incidencia</h1>
            <p>Completa los datos de la incidencia detectada.</p>

            <% if (error != null) { %>
                <p class="error"><%=error%></p>
            <% } %>

            <form method="post" action="<%=ctx%>/NetworkOperatorServlet">
                <input type="hidden" name="action" value="crearIncidencia">

                <label for="titulo">Título *</label>
                <input id="titulo" name="titulo" type="text" required maxlength="150">

                <label for="descripcion">Descripción *</label>
                <textarea id="descripcion" name="descripcion" required rows="4"></textarea>

                <label for="severidad">Severidad *</label>
                <select id="severidad" name="severidad" required>
                    <option value="">Selecciona una severidad</option>
                    <option value="Crítica">Crítica</option>
                    <option value="Alta">Alta</option>
                    <option value="Media">Media</option>
                    <option value="Baja">Baja</option>
                </select>

                <fieldset>
                    <legend>Redes afectadas *</legend>
                    <% for (Segmento s : segmentos) { %>
                        <label>
                            <input type="checkbox" name="segmentos"
                                   value="<%=s.getIdSegmento()%>">
                            <%=s.getCodigo()%> -
                            <%=s.getNombreOrigen()%> a <%=s.getNombreDestino()%>
                        </label>
                        <br>
                    <% } %>
                </fieldset>

                <button type="submit">Registrar incidencia</button>
                <a href="<%=ctx%>/NetworkOperatorServlet?action=incidencias">Cancelar</a>
            </form>
        </section>
    </main>
</div>
</body>
</html>
