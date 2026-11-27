<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.sql.Timestamp,java.math.BigDecimal,pe.edu.oceanlink.bean.Mantenimiento" %>
<%!
    private String h(Object v) {
        return v == null ? "" : v.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String fecha(Object v) {
        return v == null ? "Sin registrar" : v instanceof Timestamp
                ? ((Timestamp) v).toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : h(v);
    }

    private String pill(String v) {
        return "Finalizado".equals(v) ? "pill-neutral" : "En ejecución".equals(v) ? "pill-ok" : "pill-warn";
    }

    private String dato(jakarta.servlet.http.HttpServletRequest r, String n) {
        String valor = r.getParameter(n);
        Object borrador = r.getAttribute("borradorMC");
        if (valor == null && borrador instanceof Map) {
            Object guardado = ((Map<?, ?>) borrador).get(n);
            if (guardado != null) valor = guardado.toString();
        }
        return h(valor);
    }
%>
<%
    String base = request.getContextPath() + "/maintenance-coordinator/mantenimientos";
    if (request.getAttribute("tituloMC") == null) {
        response.sendRedirect(base);
        return;
    }
    Mantenimiento m = (Mantenimiento) request.getAttribute("mantenimiento");
    List<String[]> eventos = (List<String[]>) request.getAttribute("eventosMC");
    if (eventos == null) eventos = Collections.emptyList();
    List<String[]> servicios = (List<String[]>) request.getAttribute("serviciosMC");
    if (servicios == null) servicios = Collections.emptyList();
%>
<jsp:include page="/views/mc-inicio.jsp"/>

<% if (request.getAttribute("errorMC") != null) { %>
    <div class="banner banner-err" role="alert"><%= h(request.getAttribute("errorMC")) %></div>
<% } %>

<% if (m != null) { %>
<div class="mc-detalle">
    <a class="link mc-detalle-volver" href="<%= base %>">← Volver a mantenimientos</a>

    <div class="page-head mc-detalle-encabezado">
        <div class="mc-detalle-titulo">
            <h1><%= h(m.getCodigo()) %> · <%= h(m.getTitulo()) %></h1>
        </div>
        <% if (!m.isFinalizado()) { %>
            <div class="mc-detalle-acciones">
                <a class="btn btn-outline" href="<%= base %>?action=estado&amp;id=<%= m.getIdMantenimiento() %>">Modificar estado</a>
                <% if ("En ejecución".equals(m.getEstado())) { %>
                    <a class="btn btn-primary" href="<%= base %>?action=finalizar&amp;id=<%= m.getIdMantenimiento() %>">Registrar finalización</a>
                <% } else { %>
                    <button class="btn btn-primary" disabled title="Primero cambia el mantenimiento a En ejecución">Registrar finalización</button>
                <% } %>
            </div>
        <% } %>
    </div>

    <% if (request.getAttribute("mensajeMC") != null) { %>
        <div class="info-strip" role="status"><%= h(request.getAttribute("mensajeMC")) %></div>
    <% } %>

    <div class="info-strip">
        <span class="ii" aria-hidden="true">!</span>
        <div>
            <div class="it">Mantenimiento <%= h(m.getTipo()) %><%= m.getIncidenciaCodigo() == null ? "" : " · Origen: " + h(m.getIncidenciaCodigo()) %></div>
            <div class="id"><%= m.getIncidenciaCodigo() == null
                    ? "Intervención preventiva programada sobre la infraestructura seleccionada."
                    : "Esta intervención física está diseñada para resolver la incidencia reportada por el Network Operator." %></div>
        </div>
    </div>

    <div class="mc-detalle-grid">
        <div class="mc-detalle-columna">
            <section class="card" aria-labelledby="mc-datos-titulo">
                <div class="card-head">
                    <div>
                        <span class="ch-sub">Planificación</span>
                        <h2 id="mc-datos-titulo">Datos generales</h2>
                    </div>
                    <span class="pill <%= pill(m.getEstado()) %>"><span class="dot" aria-hidden="true"></span><%= h(m.getEstado()) %></span>
                </div>
                <div class="card-pad">
                    <dl class="data-list">
                        <dt class="data-label">Infraestructura</dt>
                        <dd class="data-value">
                            <% if (m.getInfraestructuraCodigo() != null && !m.getInfraestructuraCodigo().isBlank()) { %>
                                <span class="seg-tag"><%= h(m.getInfraestructuraCodigo()) %></span>
                            <% } %>
                            <%= h(m.getInfraestructuraNombre()) %>
                        </dd>
                        <dt class="data-label">Fecha y hora</dt>
                        <dd class="data-value"><%= fecha(m.getFechaInicio()) %></dd>
                        <dt class="data-label">Duración estimada</dt>
                        <dd class="data-value"><%= m.getDuracionEstimada() == null
                                ? "Sin registrar" : h(m.getDuracionEstimada().stripTrailingZeros().toPlainString()) + " horas" %></dd>
                        <dt class="data-label">Responsable</dt>
                        <dd class="data-value"><%= h(m.getResponsable()) %></dd>
                        <% if (m.getDescripcion() != null && !m.getDescripcion().isBlank()) { %>
                            <dt class="data-label">Descripción técnica</dt>
                            <dd class="data-value mc-detalle-multilinea"><%= h(m.getDescripcion()) %></dd>
                        <% } %>
                        <% if (m.isFinalizado()) { %>
                            <dt class="data-label">Finalización</dt>
                            <dd class="data-value"><%= fecha(m.getFechaFin()) %></dd>
                            <dt class="data-label">Resultado</dt>
                            <dd class="data-value mc-detalle-multilinea"><%= h(m.getResultado()) %></dd>
                        <% } %>
                    </dl>
                </div>
            </section>

            <section class="card" aria-labelledby="mc-bitacora-titulo">
                <div class="card-head">
                    <div>
                        <span class="ch-sub">Bitácora</span>
                        <h2 id="mc-bitacora-titulo"><%= m.isFinalizado() ? "Actividades registradas" : "Registrar actividades" %></h2>
                    </div>
                </div>

                <% if (!m.isFinalizado()) { %>
                <form novalidate class="card-pad mc-detalle-form" method="post" action="<%= base %>">
                    <input type="hidden" name="action" value="actividad">
                    <input type="hidden" name="id" value="<%= m.getIdMantenimiento() %>">
                    <input type="hidden" name="token" value="<%= h(request.getAttribute("mcToken")) %>">
                    <div class="mc-detalle-actividad">
                        <div class="field">
                            <label for="mcNuevaActividad">Nueva actividad</label>
                            <input class="input" id="mcNuevaActividad" name="actividad" type="text"
                                   maxlength="2000" value="<%= dato(request, "actividad") %>"
                                   placeholder="Escribe una nueva actividad..." required>
                        </div>
                        <button class="btn btn-primary" type="submit">Agregar actividad</button>
                    </div>
                    <jsp:include page="/views/mc-responsable.jsp"/>
                </form>
                <% } %>

                <ul class="mc-detalle-eventos">
                    <% for (String[] e : eventos) { %>
                        <li>
                            <p class="mc-detalle-evento-meta"><%= h(e[0]) %> · <%= h(e[3]) %> · <%= h(e[1]) %></p>
                            <% if (e[5] != null) { %>
                                <p><strong><%= e[4] == null ? "" : h(e[4]) + " → " %><%= h(e[5]) %></strong></p>
                            <% } %>
                            <p class="mc-detalle-multilinea"><%= h(e[2]) %></p>
                        </li>
                    <% } %>
                    <% if (m.getActividades() != null && !m.getActividades().isBlank()) { %>
                        <li>
                            <p class="mc-detalle-evento-meta">Registro previo</p>
                            <p class="mc-detalle-multilinea"><%= h(m.getActividades()) %></p>
                        </li>
                    <% } else if (eventos.isEmpty()) { %>
                        <li class="mc-detalle-vacio">Todavía no hay actividades registradas.</li>
                    <% } %>
                </ul>
            </section>
        </div>

        <section class="card" aria-labelledby="mc-impacto-titulo">
            <div class="card-head">
                <div>
                    <span class="ch-sub">Impacto comercial</span>
                    <h2 id="mc-impacto-titulo">Servicios afectados</h2>
                </div>
            </div>
            <p class="card-pad mc-detalle-nota">Estos servicios perderán conectividad temporal si no cuentan con una ruta de protección activa en el Network Operator.</p>
            <div class="table-wrap">
                <table aria-labelledby="mc-impacto-titulo">
                    <thead>
                        <tr>
                            <th scope="col">Servicio</th>
                            <th scope="col">Cliente</th>
                            <th scope="col">Capacidad</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] sv : servicios) { %>
                            <tr>
                                <td class="u-name"><%= h(sv[0]) %></td>
                                <td><%= h(sv[1]) %></td>
                                <td><%= sv[2] == null ? "Sin asignar" : h(new BigDecimal(sv[2]).stripTrailingZeros().toPlainString()) + " Gbps" %></td>
                            </tr>
                        <% } %>
                        <% if (servicios.isEmpty()) { %>
                            <tr><td colspan="3" class="mc-detalle-vacio">No se encontraron servicios activos o suspendidos asociados a esta infraestructura.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</div>
<% } %>

<% request.setAttribute("mcValidacionNativa", Boolean.TRUE); %>
<script>function ocValida(f){var ok=true;var cs=f.querySelectorAll('input:not([type=hidden]),select,textarea');for(var i=0;i<cs.length;i++){(function(c){if(c.disabled)return;if(c._ocE){c._ocE.remove();c._ocE=null;}c.style.borderColor='';if(!c.checkValidity()){ok=false;var v=c.validity,m;if(v.valueMissing)m=(c.tagName==='SELECT')?'Selecciona una opción.':'Este campo es obligatorio.';else if(v.customError)m=c.validationMessage;else if(v.typeMismatch&&c.type==='email')m='Ingresa un correo válido.';else if(v.rangeUnderflow||v.rangeOverflow||v.stepMismatch||v.badInput)m='Ingresa un valor válido.';else m=c.validationMessage||'Revisa este campo.';var s=document.createElement('small');s.className='oc-err';s.style.cssText='display:block;color:#bd586d;font-size:10.5px;font-weight:600;margin-top:4px';s.textContent=m;c.insertAdjacentElement('afterend',s);c._ocE=s;c.style.borderColor='#c0334a';if(!c._ocB){c._ocB=1;var limpia=function(){if(c.checkValidity()&&c._ocE){c._ocE.remove();c._ocE=null;c.style.borderColor='';}};c.addEventListener('input',limpia);c.addEventListener('change',limpia);}}})(cs[i]);}return ok;}document.querySelectorAll('form').forEach(function(fm){if(fm.querySelector('[required]'))fm.addEventListener('submit',function(e){if(!ocValida(fm))e.preventDefault();});});</script>
<jsp:include page="/views/mc-fin.jsp"/>
