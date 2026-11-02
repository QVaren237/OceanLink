<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.PanelCapacityPlanner" %>
<%@ page import="pe.edu.oceanlink.bean.ServicioResumen" %>
<%@ page import="pe.edu.oceanlink.bean.RutaSegmento" %>
<%@ page import="pe.edu.oceanlink.bean.LandingStation" %>
<%!
    // Escape para texto y atributos HTML; nunca insertar datos en JavaScript inline.
    private String h(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    if (request.getAttribute("titulo") == null) {
        response.sendRedirect(request.getContextPath() + "/capacity-planner/panel");
        return;
    }
%>
<%
    PanelCapacityPlanner panel = (PanelCapacityPlanner) request.getAttribute("panel");
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<div class="page-head"><div><h1>Panel General de Operaciones</h1><div class="psub">Vista ejecutiva del estado de la infraestructura submarina y cartera comercial.</div></div></div>
<% if (request.getAttribute("error") != null) { %><div class="banner banner-err" role="alert"><%= h(request.getAttribute("error")) %></div><% } %>
<% if (panel != null) { %>
<div class="kpis">
    <div class="kpi"><span class="kbadge">ACTIVOS</span><div class="kv"><%= panel.getClientesActivos() %></div><div class="kl">Clientes registrados</div></div>
    <div class="kpi"><div class="kv"><%= panel.getSegmentosMonitoreados() %></div><div class="kl">Enlaces submarinos monitoreados</div></div>
    <div class="kpi planner-kpi-warning"><span class="kbadge">ATENCIÓN</span><div class="kv"><%= panel.getSolicitudesPendientes() %></div><div class="kl">Solicitudes pendientes de evaluación</div></div>
    <div class="kpi planner-kpi-danger"><span class="kbadge">RIESGO</span><div class="kv"><%= panel.getSegmentosCriticos() %></div><div class="kl">Enlace crítico (&gt; 95% uso)</div></div>
</div>
<div class="card" id="carteraServicios">
    <div class="card-pad planner-panel-toolbar">
        <div class="usearch-box"><span class="usearch-ic"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span><input id="panelSearch" type="search" aria-label="Buscar por cliente, servicio o enlace" placeholder="Buscar por cliente, servicio o enlace..."></div>
        <a class="link" id="verCartera" href="#carteraServicios">Ver cartera completa →</a>
    </div>
    <div class="table-wrap"><table id="panelTable">
        <thead><tr><th class="sortable" data-col="0"><button type="button">Cliente <span class="sarrow">⇅</span></button></th><th class="sortable" data-col="1"><button type="button">Servicio <span class="sarrow">⇅</span></button></th><th class="sortable" data-col="2"><button type="button">Enlace Submarino <span class="sarrow">⇅</span></button></th><th class="sortable" data-col="3"><button type="button">Capacidad <span class="sarrow">⇅</span></button></th><th class="sortable" data-col="4"><button type="button">Estado <span class="sarrow">⇅</span></button></th></tr></thead>
        <tbody>
        <% for (ServicioResumen servicio : panel.getServicios()) {
            String estadoServicio = servicio.getEstado();
            String claseEstado = "Activo".equals(estadoServicio) ? "pill-ok" : ("Cancelado".equals(estadoServicio) || "Crítico".equals(estadoServicio)) ? "pill-crit" : "pill-warn";
        %>
            <tr class="panel-data">
                <td data-sort="<%= h(servicio.getRazonSocial()) %>"><div class="u-cell"><div class="u-av"><%= h(servicio.getIniciales()) %></div><div><div class="u-name"><%= h(servicio.getRazonSocial()) %></div><div class="u-mail">ID: C<%= servicio.getIdCliente() %></div></div></div></td>
                <td data-sort="<%= h(servicio.getCodigoServicio()) %>"><strong><%= h(servicio.getCodigoServicio()) %></strong></td>
                <td data-sort="<%= h(servicio.getEnlace()) %>"><%= h(servicio.getEnlace()) %></td>
                <td data-sort="<%= h(servicio.getCapacidadContratada()) %>"><strong><%= h(servicio.getCapacidadContratada()) %> Gbps</strong></td>
                <td data-sort="<%= h(estadoServicio) %>"><span class="pill <%= claseEstado %>"><span class="dot"></span><%= h(estadoServicio) %></span></td>
            </tr>
        <% } %>
            <tr id="panelVacio"<%= panel.getServicios().isEmpty() ? "" : " hidden" %>><td colspan="5" class="ruta-empty">No se encontraron servicios para mostrar.</td></tr>
        </tbody>
    </table></div>
    <div class="pagination"><span id="panelResumen" aria-live="polite"></span><button type="button" class="page-btn" id="panelAnterior" aria-label="Página anterior">‹</button><div id="panelPaginas" class="planner-page-numbers"></div><button type="button" class="page-btn" id="panelSiguiente" aria-label="Página siguiente">›</button></div>
</div>
<% } %>
<script>
"use strict";
(() => {
    const tabla = document.getElementById("panelTable");
    if (!tabla) return;
    const cuerpo = tabla.tBodies[0];
    const filas = Array.from(cuerpo.querySelectorAll(".panel-data"));
    const buscar = document.getElementById("panelSearch");
    const anterior = document.getElementById("panelAnterior");
    const siguiente = document.getElementById("panelSiguiente");
    const numeros = document.getElementById("panelPaginas");
    let pagina = 1, porPagina = 5;
    let criterios = [];
    function valor(fila, col) { return fila.cells[col].getAttribute("data-sort") || fila.cells[col].textContent; }
    function pintar() {
        const consulta = buscar.value.toLocaleLowerCase("es").trim();
        const visibles = filas.filter(fila => fila.textContent.toLocaleLowerCase("es").includes(consulta));
        visibles.sort((a, b) => {
            for (const criterio of criterios) {
                const comparacion = valor(a, criterio.col).localeCompare(valor(b, criterio.col), "es", { numeric: true });
                if (comparacion) return comparacion * (criterio.asc ? 1 : -1);
            }
            return 0;
        });
        const paginas = Math.max(1, Math.ceil(visibles.length / porPagina));
        pagina = Math.min(pagina, paginas);
        filas.forEach(fila => { fila.hidden = true; });
        visibles.forEach((fila, i) => { cuerpo.appendChild(fila); fila.hidden = i < (pagina - 1) * porPagina || i >= pagina * porPagina; });
        document.getElementById("panelVacio").hidden = visibles.length > 0;
        document.getElementById("panelResumen").textContent = visibles.length + " registros · Página " + pagina + " de " + paginas;
        anterior.disabled = pagina <= 1; siguiente.disabled = pagina >= paginas;
        numeros.replaceChildren();
        for (let numero = Math.max(1, pagina - 2); numero <= Math.min(paginas, pagina + 2); numero++) {
            const boton = document.createElement("button"); boton.type = "button"; boton.className = "page-btn" + (numero === pagina ? " active" : ""); boton.textContent = numero;
            boton.setAttribute("aria-label", "Página " + numero);
            if (numero === pagina) boton.setAttribute("aria-current", "page");
            boton.addEventListener("click", () => { pagina = numero; pintar(); }); numeros.appendChild(boton);
        }
        tabla.querySelectorAll("th.sortable").forEach(th => {
            const criterio = criterios.find(c => c.col === Number(th.dataset.col));
            th.querySelector(".sarrow").textContent = criterio ? (criterio.asc ? "▲" : "▼") : "⇅";
            if (criterio) th.setAttribute("aria-sort", criterio.asc ? "ascending" : "descending"); else th.removeAttribute("aria-sort");
        });
    }
    buscar.addEventListener("input", () => { pagina = 1; pintar(); });
    anterior.addEventListener("click", () => { pagina--; pintar(); }); siguiente.addEventListener("click", () => { pagina++; pintar(); });
    tabla.querySelectorAll("th.sortable").forEach(th => th.querySelector("button").addEventListener("click", () => {
        const col = Number(th.dataset.col);
        if (criterios.length && criterios[0].col === col) criterios[0].asc = !criterios[0].asc;
        else { criterios = criterios.filter(c => c.col !== col); criterios.unshift({ col: col, asc: true }); }
        pagina = 1; pintar();
    }));
    document.getElementById("verCartera").addEventListener("click", () => { buscar.value = ""; pagina = 1; porPagina = Math.max(1, filas.length); pintar(); });
    pintar();
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp" />
