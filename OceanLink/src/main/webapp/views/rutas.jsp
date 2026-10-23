<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.Ruta" %>
<%@ page import="pe.edu.oceanlink.bean.RutaSegmento" %>
<%@ page import="pe.edu.oceanlink.bean.LandingStation" %>
<%!
    private String h(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    if (request.getAttribute("titulo") == null) {
        response.sendRedirect(request.getContextPath() + "/capacity-planner/rutas");
        return;
    }
%>
<%
    ArrayList<Ruta> rutas = (ArrayList<Ruta>) request.getAttribute("lista");
    String resultado = request.getParameter("resultado");
    String mensaje = "creada".equals(resultado) ? "Ruta registrada correctamente." :
            "actualizada".equals(resultado) ? "Ruta actualizada correctamente." :
            "desactivada".equals(resultado) ? "Ruta desactivada correctamente." : "";
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<div class="page-head"><div><h1>Gestión de rutas</h1><p class="psub">Organiza los segmentos que conectan las estaciones de origen y destino.</p></div><div class="grow"></div><a class="btn btn-primary" href="<%= request.getContextPath() %>/capacity-planner/rutas?action=formCrear">+ Nueva ruta</a></div>
<% if (request.getAttribute("error") != null) { %><div class="banner banner-err" role="alert"><%= h(request.getAttribute("error")) %></div><% } %>
<% if (!mensaje.isEmpty()) { %><div class="banner ruta-success" role="status"><%= h(mensaje) %></div><% } %>
<% if (rutas != null) { %>
<div class="card">
    <div class="card-pad toolbar">
        <label class="ruta-search">Buscar rutas<input class="input" type="search" id="buscarRuta" placeholder="Código, nombre, origen o destino"></label>
        <label class="ruta-filter">Estado<select class="input" id="filtrarEstado"><option value="">Todos</option><option>Operativa</option><option>No operativa</option></select></label>
    </div>
    <div class="table-wrap"><table id="tablaRutas">
        <thead><tr><th><button type="button" data-col="0">Código ⇅</button></th><th><button type="button" data-col="1">Nombre ⇅</button></th><th><button type="button" data-col="2">Origen ⇅</button></th><th><button type="button" data-col="3">Destino ⇅</button></th><th>Segmentos</th><th>Estado</th><th>Acciones</th></tr></thead>
        <tbody>
        <% for (Ruta ruta : rutas) { %>
        <tr class="ruta-data" data-estado="<%= h(ruta.getEstado()) %>">
            <td><strong><%= h(ruta.getCodigo()) %></strong></td><td><%= h(ruta.getNombre()) %></td><td><%= h(ruta.getNombreOrigen()) %></td><td><%= h(ruta.getNombreDestino()) %></td><td><%= ruta.getCantidadSegmentos() %></td>
            <td><span class="pill <%= "Operativa".equals(ruta.getEstado()) ? "pill-ok" : "pill-warn" %>"><span class="dot"></span><%= h(ruta.getEstado()) %></span></td>
            <td><div class="actions">
                <a class="btn btn-outline btn-icon" title="Ver detalle" aria-label="Ver detalle de <%= h(ruta.getCodigo()) %>" href="<%= request.getContextPath() %>/capacity-planner/rutas?action=detalle&amp;id=<%= ruta.getIdRuta() %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg></a>
                <a class="btn btn-outline btn-icon" title="Editar ruta" aria-label="Editar <%= h(ruta.getCodigo()) %>" href="<%= request.getContextPath() %>/capacity-planner/rutas?action=editar&amp;id=<%= ruta.getIdRuta() %>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 20h4L19 9a2 2 0 0 0 0-2.8l-1.2-1.2a2 2 0 0 0-2.8 0L4 16zM13.5 6.5l4 4"/></svg></a>
                <button class="btn btn-danger btn-icon" type="button" title="<%= "Operativa".equals(ruta.getEstado()) ? "Desactivar ruta" : "Ruta ya No operativa" %>" aria-label="Desactivar <%= h(ruta.getCodigo()) %>" data-desactivar-ruta data-id="<%= ruta.getIdRuta() %>" data-nombre="<%= h(ruta.getCodigo() + " · " + ruta.getNombre()) %>" <%= "Operativa".equals(ruta.getEstado()) ? "" : "disabled" %>><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M18.36 6.64a9 9 0 1 1-12.73 0M12 2v10"/></svg></button>
            </div></td>
        </tr>
        <% } %>
        <tr id="sinRutas"<%= rutas.isEmpty() ? "" : " hidden" %>><td colspan="7" class="ruta-empty">No se encontraron rutas. Puedes registrar una nueva ruta.</td></tr>
        </tbody>
    </table></div>
    <nav class="pagination" id="paginacionRutas" aria-label="Paginación de rutas"></nav>
</div>
<% } else { %><div class="card card-pad"><a class="btn btn-outline" href="<%= request.getContextPath() %>/capacity-planner/rutas">Volver a intentar</a></div><% } %>
<dialog id="desactivarRuta" class="ruta-dialog" aria-labelledby="tituloDesactivar">
    <h2 id="tituloDesactivar">Desactivar ruta</h2><p id="advertenciaDesactivar"></p>
    <form id="formDesactivarRuta" method="post" action="<%= request.getContextPath() %>/capacity-planner/rutas">
        <input type="hidden" name="action" value="desactivar"><input type="hidden" name="id" id="idRutaDesactivar">
        <div class="form-actions"><button class="btn btn-outline" type="button" id="cancelarDesactivar">Cancelar</button><button class="btn btn-danger" type="submit" id="confirmarDesactivar">Sí, desactivar</button></div>
    </form>
</dialog>
<script>
"use strict";

(() => {
    const tabla = document.getElementById("tablaRutas");
    if (tabla) {
        const cuerpo = tabla.tBodies[0];
        const filas = Array.from(cuerpo.querySelectorAll(".ruta-data"));
        const buscar = document.getElementById("buscarRuta");
        const estado = document.getElementById("filtrarEstado");
        const paginacion = document.getElementById("paginacionRutas");
        let pagina = 1, columna = 0, ascendente = true;
        function pintar() {
            const texto = buscar.value.trim().toLocaleLowerCase("es");
            const visibles = filas.filter(fila => fila.textContent.toLocaleLowerCase("es").includes(texto) && (!estado.value || fila.dataset.estado === estado.value));
            visibles.sort((a, b) => a.cells[columna].textContent.localeCompare(b.cells[columna].textContent, "es", { numeric: true }) * (ascendente ? 1 : -1));
            const paginas = Math.max(1, Math.ceil(visibles.length / 5));
            pagina = Math.min(pagina, paginas);
            filas.forEach(fila => { fila.hidden = true; });
            visibles.forEach((fila, i) => { cuerpo.appendChild(fila); fila.hidden = i < (pagina - 1) * 5 || i >= pagina * 5; });
            document.getElementById("sinRutas").hidden = visibles.length > 0;
            // Misma estructura y clases que la paginación de Usuarios y Clientes.
            paginacion.replaceChildren();
            const anterior = document.createElement("button");
            anterior.type = "button";
            anterior.className = "page-btn";
            anterior.textContent = "‹";
            anterior.setAttribute("aria-label", "Página anterior");
            anterior.disabled = pagina <= 1;
            anterior.addEventListener("click", () => { pagina--; pintar(); });
            paginacion.appendChild(anterior);
            for (let numero = 1; numero <= paginas; numero++) {
                const boton = document.createElement("button");
                boton.type = "button";
                boton.className = "page-btn" + (numero === pagina ? " active" : "");
                boton.textContent = numero;
                boton.setAttribute("aria-label", "Página " + numero);
                if (numero === pagina) boton.setAttribute("aria-current", "page");
                boton.addEventListener("click", () => { pagina = numero; pintar(); });
                paginacion.appendChild(boton);
            }
            const siguiente = document.createElement("button");
            siguiente.type = "button";
            siguiente.className = "page-btn";
            siguiente.textContent = "›";
            siguiente.setAttribute("aria-label", "Página siguiente");
            siguiente.disabled = pagina >= paginas;
            siguiente.addEventListener("click", () => { pagina++; pintar(); });
            paginacion.appendChild(siguiente);
        }
        buscar.addEventListener("input", () => { pagina = 1; pintar(); });
        estado.addEventListener("change", () => { pagina = 1; pintar(); });
        tabla.querySelectorAll("thead button[data-col]").forEach(boton => boton.addEventListener("click", () => {
            const nueva = Number(boton.dataset.col);
            ascendente = nueva === columna ? !ascendente : true;
            columna = nueva; pintar();
        }));
        pintar();
    }

    const dialogo = document.getElementById("desactivarRuta");
    document.querySelectorAll("[data-desactivar-ruta]").forEach(boton => boton.addEventListener("click", () => {
        document.getElementById("idRutaDesactivar").value = boton.dataset.id;
        document.getElementById("advertenciaDesactivar").textContent = "¿Estás seguro de desactivar la ruta " + boton.dataset.nombre + "? Su estado cambiará de Operativa a No operativa. Se conservarán sus datos y segmentos asociados.";
        dialogo.showModal();
    }));
    document.getElementById("cancelarDesactivar").addEventListener("click", () => dialogo.close());
    document.getElementById("formDesactivarRuta").addEventListener("submit", () => { document.getElementById("confirmarDesactivar").disabled = true; });
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp" />
