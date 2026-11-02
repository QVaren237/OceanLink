<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.Ruta" %>
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
        response.sendRedirect(request.getContextPath() + "/capacity-planner/rutas?action=formCrear");
        return;
    }
%>
<%
    Ruta ruta = (Ruta) request.getAttribute("ruta");
    ArrayList<LandingStation> estaciones = (ArrayList<LandingStation>) request.getAttribute("estaciones");
    ArrayList<RutaSegmento> catalogo = (ArrayList<RutaSegmento>) request.getAttribute("segmentos");
    boolean edicion = ruta.getIdRuta() > 0;
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<div class="page-head"><div><a class="link" href="<%= request.getContextPath() %>/capacity-planner/rutas">← Volver a rutas</a><h1><%= edicion ? "Editar ruta" : "Registrar nueva ruta" %></h1><p class="psub">Define los extremos y agrega los segmentos en el orden del recorrido.</p></div></div>
<% if (request.getAttribute("error") != null) { %><div class="banner banner-err" role="alert"><%= h(request.getAttribute("error")) %></div><% } %>
<% if (ruta.isEnUso()) { %><div class="info-strip"><div>Esta ruta tiene <strong><%= ruta.getCantidadServicios() %> servicios</strong> y <strong><%= ruta.getCantidadSolicitudes() %> solicitudes</strong>. Puedes actualizar sus datos, pero debes conservar su recorrido.</div></div><% } %>
<form class="card card-pad" id="formRuta" method="post" action="<%= request.getContextPath() %>/capacity-planner/rutas">
    <input type="hidden" name="action" value="guardar"><input type="hidden" name="idRuta" value="<%= ruta.getIdRuta() == 0 ? "" : ruta.getIdRuta() %>">
    <div class="ruta-form-grid">
        <div class="field"><label for="codigo">Código *</label><input class="input" id="codigo" name="codigo" maxlength="30" required value="<%= h(ruta.getCodigo()) %>" placeholder="RUT-LIM-ARI"></div>
        <div class="field"><label for="nombre">Nombre *</label><input class="input" id="nombre" name="nombre" maxlength="100" required value="<%= h(ruta.getNombre()) %>" placeholder="Lima - Arica"></div>
        <div class="field"><label for="origen">Estación de origen *</label><select class="input" id="origen" name="idEstacionOrigen" required><option value="">Seleccionar estación</option><% for (LandingStation estacion : estaciones) { %><option value="<%= estacion.getIdLandingStation() %>" <%= estacion.getIdLandingStation() == ruta.getIdEstacionOrigen() ? "selected" : "" %>><%= h(estacion.getNombre()) %> · <%= h(estacion.getCodigo()) %></option><% } %></select></div>
        <div class="field"><label for="destino">Estación de destino *</label><select class="input" id="destino" name="idEstacionDestino" required><option value="">Seleccionar estación</option><% for (LandingStation estacion : estaciones) { %><option value="<%= estacion.getIdLandingStation() %>" <%= estacion.getIdLandingStation() == ruta.getIdEstacionDestino() ? "selected" : "" %>><%= h(estacion.getNombre()) %> · <%= h(estacion.getCodigo()) %></option><% } %></select></div>
        <div class="field"><label for="estado">Estado *</label><select class="input" id="estado" name="estado" required><option <%= "Operativa".equals(ruta.getEstado()) ? "selected" : "" %>>Operativa</option><option <%= "No operativa".equals(ruta.getEstado()) ? "selected" : "" %>>No operativa</option></select></div>
        <div class="field"><label for="descripcion">Descripción</label><textarea class="input" id="descripcion" name="descripcion" maxlength="255" rows="3"><%= h(ruta.getDescripcion()) %></textarea></div>
    </div>
    <section class="ruta-section" aria-labelledby="tituloSegmentos">
        <h2 id="tituloSegmentos">Segmentos de la ruta</h2><p class="psub">El primer segmento debe partir del origen y el último llegar al destino. Puedes recorrer los cables en ambos sentidos.</p>
        <div class="ruta-add"><label for="catalogoSegmentos">Segmento disponible<select class="input" id="catalogoSegmentos"><option value="">Seleccionar segmento</option><% for (RutaSegmento tramo : catalogo) { %><option value="<%= tramo.getIdSegmento() %>" data-origen="<%= tramo.getIdEstacionOrigen() %>" data-destino="<%= tramo.getIdEstacionDestino() %>" data-estado="<%= h(tramo.getEstado()) %>" data-codigo="<%= h(tramo.getCodigo()) %>"><%= h(tramo.getCodigo()) %> · <%= h(tramo.getNombreOrigen()) %> ↔ <%= h(tramo.getNombreDestino()) %> · <%= h(tramo.getEstado()) %></option><% } %></select></label><button type="button" class="btn btn-outline" id="agregarSegmento">+ Agregar segmento</button></div>
        <div id="errorRecorrido" class="banner banner-err" role="alert" hidden></div>
        <div class="table-wrap"><table><thead><tr><th>Orden</th><th>Segmento</th><th>Acciones</th></tr></thead><tbody id="tramosElegidos">
        <% for (RutaSegmento elegido : ruta.getSegmentos()) {
            RutaSegmento informacion = null;
            for (RutaSegmento candidato : catalogo) if (candidato.getIdSegmento() == elegido.getIdSegmento()) informacion = candidato;
        %>
            <tr data-id="<%= elegido.getIdSegmento() %>"><td class="orden-tramo"></td><td><input type="hidden" name="idSegmento" value="<%= elegido.getIdSegmento() %>"><span><%= informacion == null ? "Segmento no disponible: " + elegido.getIdSegmento() : h(informacion.getCodigo()) + " · " + h(informacion.getNombreOrigen()) + " ↔ " + h(informacion.getNombreDestino()) + " · " + h(informacion.getEstado()) %></span></td><td><div class="actions"><button class="btn btn-outline btn-sm" type="button" data-mover="-1" aria-label="Subir segmento">↑</button><button class="btn btn-outline btn-sm" type="button" data-mover="1" aria-label="Bajar segmento">↓</button><button class="btn btn-danger btn-sm" type="button" data-quitar>Quitar</button></div></td></tr>
        <% } %>
        </tbody></table></div><p id="sinSegmentos" class="ruta-empty">Todavía no has agregado segmentos.</p>
    </section>
    <div class="form-actions"><a class="btn btn-outline" href="<%= request.getContextPath() %>/capacity-planner/rutas">Cancelar</a><button class="btn btn-primary" type="submit">Revisar y guardar</button></div>
</form>
<dialog id="confirmarRuta" class="ruta-dialog"><h2>Confirmar <%= edicion ? "cambios" : "registro" %></h2><p id="resumenRuta"></p><div class="form-actions"><button class="btn btn-outline" type="button" id="volverFormulario">Volver a editar</button><button class="btn btn-primary" type="button" id="guardarRuta">Confirmar y guardar</button></div></dialog>
<script>
"use strict";

(() => {
    const formulario = document.getElementById("formRuta");
    if (!formulario) return;
    const cuerpo = document.getElementById("tramosElegidos");
    const catalogo = document.getElementById("catalogoSegmentos");
    const error = document.getElementById("errorRecorrido");
    const dialogo = document.getElementById("confirmarRuta");
    function informar(mensaje) { error.textContent = mensaje; error.hidden = !mensaje; }
    function actualizar() {
        const filas = Array.from(cuerpo.rows);
        filas.forEach((fila, i) => {
            fila.querySelector(".orden-tramo").textContent = i + 1;
            fila.querySelector('[data-mover="-1"]').disabled = i === 0;
            fila.querySelector('[data-mover="1"]').disabled = i === filas.length - 1;
        });
        document.getElementById("sinSegmentos").hidden = filas.length > 0;
        Array.from(catalogo.options).forEach(opcion => { opcion.disabled = filas.some(fila => fila.dataset.id === opcion.value); });
        informar("");
    }
    document.getElementById("agregarSegmento").addEventListener("click", () => {
        const opcion = catalogo.selectedOptions[0];
        if (!opcion || !opcion.value) { informar("Selecciona un segmento para agregarlo."); return; }
        if (Array.from(cuerpo.rows).some(fila => fila.dataset.id === opcion.value)) { informar("Ese segmento ya está en la ruta."); return; }
        const fila = document.createElement("tr"); fila.dataset.id = opcion.value;
        const orden = fila.insertCell(); orden.className = "orden-tramo";
        const datos = fila.insertCell();
        const input = document.createElement("input"); input.type = "hidden"; input.name = "idSegmento"; input.value = opcion.value;
        datos.append(input, document.createTextNode(opcion.textContent));
        const acciones = document.createElement("div"); acciones.className = "actions";
        [["↑", "Subir segmento", "-1"], ["↓", "Bajar segmento", "1"], ["Quitar", "Quitar segmento", ""]].forEach(([texto, etiqueta, movimiento]) => {
            const boton = document.createElement("button"); boton.type = "button"; boton.textContent = texto; boton.setAttribute("aria-label", etiqueta);
            boton.className = "btn btn-sm " + (movimiento ? "btn-outline" : "btn-danger");
            if (movimiento) boton.dataset.mover = movimiento; else boton.dataset.quitar = "";
            acciones.appendChild(boton);
        });
        fila.insertCell().appendChild(acciones); cuerpo.appendChild(fila); catalogo.value = ""; actualizar();
    });
    cuerpo.addEventListener("click", event => {
        const boton = event.target.closest("button"); if (!boton) return;
        const fila = boton.closest("tr");
        if (boton.hasAttribute("data-quitar")) fila.remove();
        else if (boton.dataset.mover === "-1" && fila.previousElementSibling) cuerpo.insertBefore(fila, fila.previousElementSibling);
        else if (boton.dataset.mover === "1" && fila.nextElementSibling) cuerpo.insertBefore(fila.nextElementSibling, fila);
        actualizar();
    });
    let confirmado = false;
    formulario.addEventListener("submit", event => {
        if (confirmado) return;
        event.preventDefault();
        let actual = document.getElementById("origen").value;
        const destino = document.getElementById("destino").value;
        const ids = Array.from(cuerpo.rows).map(fila => fila.dataset.id);
        if (actual === destino) { informar("El origen y el destino deben ser diferentes."); return; }
        if (!ids.length) { informar("Agrega por lo menos un segmento."); return; }
        const visitadas = new Set([actual]);
        for (const id of ids) {
            const opcion = Array.from(catalogo.options).find(opcion => opcion.value === id);
            if (!opcion) { informar("Hay un segmento no disponible. Quítalo y selecciona otro."); return; }
            if (opcion.dataset.origen === actual) actual = opcion.dataset.destino;
            else if (opcion.dataset.destino === actual) actual = opcion.dataset.origen;
            else { informar("El segmento " + opcion.dataset.codigo + " no conecta con el anterior. Revisa el orden."); return; }
            if (visitadas.has(actual)) { informar("El recorrido no puede volver a una estación ya visitada."); return; }
            visitadas.add(actual);
            if (document.getElementById("estado").value === "Operativa" && !["Operativo", "Degradado"].includes(opcion.dataset.estado)) {
                informar("El segmento " + opcion.dataset.codigo + " no está disponible. Guarda la ruta como No operativa."); return;
            }
        }
        if (actual !== destino) { informar("El último segmento no llega a la estación de destino."); return; }
        informar("");
        document.getElementById("resumenRuta").textContent = document.getElementById("codigo").value + " · " + document.getElementById("nombre").value + ". Recorrido: " + document.getElementById("origen").selectedOptions[0].textContent + " → " + document.getElementById("destino").selectedOptions[0].textContent + ", con " + ids.length + " segmento(s). Estado: " + document.getElementById("estado").value + ".";
        dialogo.showModal();
    });
    document.getElementById("volverFormulario").addEventListener("click", () => dialogo.close());
    document.getElementById("guardarRuta").addEventListener("click", event => {
        if (!formulario.reportValidity()) { dialogo.close(); return; }
        confirmado = true; event.currentTarget.disabled = true; formulario.requestSubmit();
    });
    actualizar();
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp" />
