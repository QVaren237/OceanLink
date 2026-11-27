<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate,pe.edu.oceanlink.bean.SupervisorEstadisticas,pe.edu.oceanlink.bean.SupervisorMes,pe.edu.oceanlink.bean.SupervisorDatoGrafico" %>
<%
  SupervisorEstadisticas datos = (SupervisorEstadisticas) request.getAttribute("estadisticas");
  LocalDate inicio = (LocalDate) request.getAttribute("inicio");
  LocalDate fin = (LocalDate) request.getAttribute("fin");
  String periodo = (String) request.getAttribute("periodo");
  String error = (String) request.getAttribute("errorPeriodo");
  String rutaEstadisticas = request.getContextPath() + "/supervisor/estadisticas";
  if (datos == null && error == null) {
    response.sendRedirect(rutaEstadisticas);
    return;
  }
%>
<!DOCTYPE html>
<html lang="es" class="tema-supervisor">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Estadísticas del Supervisor · OceanLink</title>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=supervisor">
</head>
<body>
<div class="shell">
  <jsp:include page="/views/supervisor-sidebar.jsp">
    <jsp:param name="moduloSupervisor" value="estadisticas" />
  </jsp:include>
  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Supervisor</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0" aria-label="Perfil de usuario">
        <div class="avatar"<%= pe.edu.oceanlink.servlet.Vista.avatarAttr(session) %>><%= pe.edu.oceanlink.servlet.Vista.iniciales(session) %></div>
        <div class="uinfo"><div class="un"><%= pe.edu.oceanlink.servlet.Vista.nombre(session) %></div><div class="ur">Supervisor</div></div>
        <span class="ucaret" aria-hidden="true">▾</span>
        <div class="usermenu"><a href="<%= request.getContextPath() %>/PerfilServlet">Editar perfil</a><a href="<%= request.getContextPath() %>/sesion-cerrada.jsp">Cerrar sesión</a></div>
      </div>
    </div>

    <main class="content supervisor-estadisticas">
      <div class="page-head estadisticas-head">
        <div>
          <h1>Estadísticas de operaciones</h1>
          <% if (periodo != null) { %>
            <p class="psub">Período consultado: <%= periodo %></p>
          <% } %>
        </div>
        <% if (datos != null) { %>
        <a class="btn btn-primary" href="<%= rutaEstadisticas %>/pdf?inicio=<%= inicio %>&amp;fin=<%= fin %>">Exportar PDF</a>
        <% } %>
      </div>
      <form class="card card-pad estadisticas-filtros" method="get" action="<%= rutaEstadisticas %>">
        <div class="field">
          <label for="inicio">Fecha de inicio</label>
          <input class="input" type="date" name="inicio" id="inicio" min="1000-01-01" max="9999-12-31"
                 value="<%= inicio == null ? "" : inicio %>" required>
        </div>
        <div class="field">
          <label for="fin">Fecha de fin</label>
          <input class="input" type="date" name="fin" id="fin" min="1000-01-01" max="9999-12-31"
                 value="<%= fin == null ? "" : fin %>" required>
        </div>
        <div class="estadisticas-acciones">
          <button class="btn btn-outline" type="submit">Aplicar filtro</button>
          <a class="link" href="<%= rutaEstadisticas %>">Últimos 12 meses</a>
        </div>
        <% if (error != null) { %>
        <p class="estadisticas-error" role="alert"><%= error %></p>
        <% } %>
      </form>

      <% if (datos != null) { %>
      <dl class="estadisticas-kpis" aria-label="Indicadores del período">
        <div class="kpi estadisticas-kpi"><dt>Incidencias detectadas</dt><dd><%= datos.getTotalIncidencias() %></dd></div>
        <div class="kpi estadisticas-kpi"><dt>Mantenimientos</dt><dd><%= datos.getTotalMantenimientos() %></dd></div>
        <div class="kpi estadisticas-kpi"><dt>Segmentos involucrados</dt><dd><%= datos.getSegmentosInvolucrados() %></dd></div>
        <div class="kpi estadisticas-kpi"><dt>Clientes relacionados</dt><dd><%= datos.getClientesRelacionados() %></dd></div>
      </dl>

      <div class="estadisticas-graficos">
        <section class="card estadisticas-card">
          <div class="card-head"><h2>Evolución mensual</h2></div>
          <div class="card-pad estadisticas-grafico-body">
          <% if (datos.getMeses().isEmpty()) { %>
            <p class="estadisticas-nota">No se registraron incidencias ni mantenimientos en este período.</p>
          <% } else {
              int maximo = datos.getMaximoMensual();
          %>
            <ul class="estadisticas-leyenda">
              <li><span class="estadisticas-muestra" aria-hidden="true"></span>Incidencias detectadas</li>
              <li><span class="estadisticas-muestra mantenimiento" aria-hidden="true"></span>Mantenimientos</li>
            </ul>
            <ul class="estadisticas-serie">
              <% for (SupervisorMes mes : datos.getMeses()) { %>
              <li class="estadisticas-mes">
                <strong><%= mes.getEtiqueta() %></strong>
                <div class="estadisticas-barras">
                  <div class="estadisticas-barra">
                    <progress aria-label="Incidencias en <%= mes.getEtiqueta() %>" aria-valuetext="<%= mes.getIncidencias() %>" value="<%= mes.getIncidencias() %>" max="<%= maximo %>"></progress>
                    <span aria-hidden="true"><%= mes.getIncidencias() %></span>
                  </div>
                  <div class="estadisticas-barra mantenimiento">
                    <progress aria-label="Mantenimientos en <%= mes.getEtiqueta() %>" aria-valuetext="<%= mes.getMantenimientos() %>" value="<%= mes.getMantenimientos() %>" max="<%= maximo %>"></progress>
                    <span aria-hidden="true"><%= mes.getMantenimientos() %></span>
                  </div>
                </div>
              </li>
              <% } %>
            </ul>
            <p class="estadisticas-nota">Se muestran los meses con eventos en el período.</p>
          <% } %>
          </div>
        </section>

        <section class="card estadisticas-card">
          <div class="card-head"><h2>Estado y severidad de incidencias</h2></div>
          <div class="card-pad estadisticas-grafico-body">
            <dl class="estadisticas-estados" aria-label="Proporciones sobre las incidencias detectadas">
              <%
                String[] estados = {"Abiertas", "Cerradas", "Críticas o altas"};
                int[] cantidades = {datos.getIncidenciasAbiertas(), datos.getIncidenciasCerradas(), datos.getIncidenciasGraves()};
                int total = datos.getTotalIncidencias();
                for (int i = 0; i < estados.length; i++) {
                    int porcentaje = datos.porcentajeIncidencias(cantidades[i]);
              %>
              <div class="estadisticas-medidor">
                <dt><%= estados[i] %></dt>
                <dd>
                  <div class="estadisticas-arco" style="--avance: <%= porcentaje * 2.7 %>deg">
                    <span><%= total == 0 ? "—" : porcentaje + " %" %></span>
                  </div>
                  <div class="estadisticas-conteo"><%= cantidades[i] %> de <%= total %></div>
                </dd>
              </div>
              <% } %>
            </dl>
            <ul class="estadisticas-severidad">
              <% for (SupervisorDatoGrafico severidad : datos.getSeveridades()) { %>
              <li>
                <span><%= severidad.getEtiqueta() %></span>
                <div class="estadisticas-barra">
                  <progress aria-label="Severidad <%= severidad.getEtiqueta() %>" aria-valuetext="<%= severidad.getCantidad() %>"
                            value="<%= severidad.getCantidad() %>" max="<%= Math.max(1, datos.getTotalIncidencias()) %>"></progress>
                  <span aria-hidden="true"><%= severidad.getCantidad() %></span>
                </div>
              </li>
              <% } %>
            </ul>
          </div>
        </section>
      </div>
      <% } %>
    </main>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>
</body>
</html>
