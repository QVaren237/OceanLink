<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace,pe.edu.oceanlink.bean.CapacidadServicio" %>
<%!
 private String h(Object v) { return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String numero(BigDecimal v) { return v==null?"Sin datos":v.stripTrailingZeros().toPlainString(); }
 private String capacidad(BigDecimal v) { return v==null?"Sin datos":numero(v)+" Gbps"; }
 private String porcentaje(BigDecimal v) { return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).toPlainString()+"%"; }
 private String estadoClase(String estado) {
  return "Operativo".equals(estado)||"Activo".equals(estado)?"pill-ok":"Fuera de servicio".equals(estado)||"Cancelado".equals(estado)?"pill-crit":"pill-warn";
 }
%>
<%
 String ctx=request.getContextPath();
 if(request.getAttribute("titulo")==null){response.sendRedirect(ctx+"/capacity-planner/capacidad");return;}
%>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="capacidad-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% }else{ %>
<% CapacidadEnlace enlace=(CapacidadEnlace)request.getAttribute("enlace");ArrayList<CapacidadServicio> servicios=(ArrayList<CapacidadServicio>)request.getAttribute("servicios");if(servicios==null)servicios=new ArrayList<>();if(enlace!=null){ %>

            <div style="margin-bottom: 5px;">
                <a href="<%=ctx%>/capacity-planner/capacidad" class="link">&lt;- Volver a Capacidad</a>
            </div>
            
            <div class="page-head">
                <div>
                    <h1><%=h(enlace.getCodigo())%>: <%=h(enlace.getNombre())%></h1>
                    <div class="psub">Análisis técnico, comercial y estado de capacidad del segmento submarino.</div>
                </div>
                <div class="grow"></div>
                <button class="btn btn-outline" type="button" id="exportarFicha">
                    <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:4px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                    Exportar Ficha Técnica
                </button>
            </div>

            <!-- Grid de Paneles Superiores -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; margin-bottom: 20px;">
                
                <!-- Panel 1: Estado y Capacidad -->
                <div class="card card-pad" style="border-top: 4px solid var(--teal);">
                    <h3 style="font-family: var(--head); font-size: 14px; font-weight: 800; margin-bottom: 15px; color: var(--ink); display: flex; justify-content: space-between;">
                        Estado de Capacidad
                        <span class="pill <%=estadoClase(enlace.getEstado())%>" style="font-size: 9px;"><span class="dot"></span><%=enlace.getEstado()==null?"Sin datos":h(enlace.getEstado())%></span>
                    </h3>
                    
                    <div style="display: flex; justify-content: space-between; font-size: 12px; font-weight: 800; margin-bottom: 8px;">
                        <span style="color: var(--teal-dd);"><%=capacidad(enlace.getCapacidadAsignada())%> Asignados</span>
                        <span style="color: var(--muted);"><%=capacidad(enlace.getCapacidadDisponible())%> Disponibles</span>
                    </div>
                    
                    <div class="progress-track" style="height: 12px; background: var(--line); border-radius: 6px; overflow: hidden; margin-bottom: 16px;">
                        <div class="progress-fill capacidad-fill-<%=enlace.getClaseUtilizacion()%>" style="width:<%=enlace.getAnchoProgreso()%>%;height:100%"></div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-size: 11px;">
                        <div style="background: var(--surface-2); padding: 10px; border-radius: 8px; border: 1px solid var(--line);">
                            <span style="color: var(--muted); display: block; margin-bottom: 4px;">Capacidad Total Bruta</span>
                            <strong style="font-size: 14px;"><%=capacidad(enlace.getCapacidadTotal())%></strong>
                        </div>
                        <div style="background: var(--surface-2); padding: 10px; border-radius: 8px; border: 1px solid var(--line);">
                            <span style="color: var(--muted); display: block; margin-bottom: 4px;">Utilización Actual</span>
                            <strong style="font-size:14px" class="capacidad-text-<%=enlace.getClaseUtilizacion()%>"><%=porcentaje(enlace.getPorcentajeUtilizacion())%></strong>
                        </div>
                    </div>
                </div>

                <!-- Panel 2: Ficha Técnica -->
                <div class="card card-pad">
                    <h3 style="font-family: var(--head); font-size: 14px; font-weight: 800; margin-bottom: 15px; color: var(--ink);">Especificaciones Físicas</h3>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 11.5px;">
                        <div>
                            <span style="color: var(--muted); display: block;">Nodo Origen (Landing)</span>
                            <strong style="color: var(--ink);"><%=h(enlace.getNombreOrigen())%> · <%=h(enlace.getUbicacionOrigen())%></strong>
                        </div>
                        <div>
                            <span style="color: var(--muted); display: block;">Nodo Destino (Landing)</span>
                            <strong style="color: var(--ink);"><%=h(enlace.getNombreDestino())%> · <%=h(enlace.getUbicacionDestino())%></strong>
                        </div>
                        <div style="margin-top: 5px;">
                            <span style="color: var(--muted); display: block;">Longitud del Cable</span>
                            <strong><%=enlace.getLongitudKm()==null?"Sin datos":numero(enlace.getLongitudKm())+" km"%></strong>
                        </div>
                        <div style="margin-top: 5px;">
                            <span style="color: var(--muted); display: block;">Latencia Promedio</span>
                            <strong>No registrada</strong>
                        </div>
                        <div style="margin-top: 5px; grid-column: span 2;">
                            <span style="color: var(--muted); display: block;">Topología / Pares de Fibra</span>
                            <strong>No registrada</strong>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabla Detallada de Clientes y Servicios -->
            <div class="card">
                <div class="card-head">
                    <h3>Servicios y Clientes Alojados</h3>
                </div>
                
                <div class="card-pad" style="border-bottom: 1px solid var(--line); display: flex; gap: 15px; align-items: center; flex-wrap: wrap;">
                    <div class="usearch-box" style="flex: 1; min-width: 300px;">
                        <span class="usearch-ic"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span>
                        <input id="detalleSearch" type="search" aria-label="Buscar servicios por ID, cliente o RUC" placeholder="Buscar por ID, cliente, RUC o tipo de servicio...">
                    </div>
                    <select class="input" style="width: 180px; font-size: 11.5px;" id="filtroEstado">
                        <option value="">Todos los estados</option>
                        <option value="Activo">Activos</option>
                        <option value="Mantenimiento">En Mantenimiento</option><option value="Suspendido">Suspendidos</option><option value="Cancelado">Cancelados</option>
                    </select>
                </div>

                <div class="table-wrap">
                    <table id="detalleTable">
                        <thead>
                            <tr>
                                <th class="sortable" data-col="0">ID Servicio<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="1">Cliente / Titular<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="2">Ruta Extremo a Extremo<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="3">Consumo<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="4">Estado<span class="sarrow">⇅</span></th>
                                <th>Opciones</th>
                            </tr>
                        </thead>
                        <tbody>
<% for(CapacidadServicio servicio:servicios){ %>
<tr data-fila data-estado="<%=h(servicio.getEstado())%>">
 <td data-sort="<%=h(servicio.getCodigo())%>"><strong><%=h(servicio.getCodigo())%></strong></td>
 <td data-sort="<%=h(servicio.getCliente())%>"><div class="u-cell"><div class="u-av" style="background:var(--mint);color:var(--teal-dd)"><%=h(servicio.getIniciales())%></div><div><div class="u-name"><%=h(servicio.getCliente())%></div><div class="u-mail">RUC: <%=h(servicio.getRuc())%></div></div></div></td>
 <td data-sort="<%=h(servicio.getRuta())%>"><div style="font-size:11px"><%=h(servicio.getRuta())%></div></td>
 <td data-sort="<%=h(servicio.getCapacidadContratada())%>"><strong><%=servicio.getCapacidadContratada()==null?"Sin asignar":capacidad(servicio.getCapacidadContratada())%></strong></td>
 <td data-sort="<%=h(servicio.getEstado())%>"><span class="pill <%=estadoClase(servicio.getEstado())%>"><span class="dot"></span><%=h(servicio.getEstado())%></span></td>
 <td><a class="btn btn-outline btn-icon" title="Ver servicios del cliente" aria-label="Ver servicios de <%=h(servicio.getCliente())%>" href="<%=ctx%>/capacity-planner/servicios?action=detalle&amp;cliente=<%=servicio.getIdCliente()%>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M8 13h8M8 17h8"/></svg></a></td>
</tr>
<% } %>
</tbody>
                    </table>
                </div>

                <nav class="pagination" id="capacidadPaginas" aria-label="Paginación de servicios"></nav>
            </div>
        <% } } %>
</div>
<script>
(function(){
 const tabla=document.querySelector('.capacidad-vista table');if(!tabla)return;
 const cuerpo=tabla.tBodies[0],filas=Array.from(cuerpo.querySelectorAll('tr[data-fila]'));
 const buscar=document.getElementById('usearch')||document.getElementById('detalleSearch'),filtro=document.getElementById('filtroEstado'),paginacion=document.getElementById('capacidadPaginas');
 const numericas=tabla.id==='capacidadTable'?[2,3,4,5,7]:[3];let pagina=1,columna=-1,ascendente=true;
 function pintar(){
  const texto=buscar.value.trim().toLocaleLowerCase('es');let visibles=filas.filter(f=>f.textContent.toLocaleLowerCase('es').includes(texto)&&(!filtro||!filtro.value||f.dataset.estado===filtro.value));
  if(columna>=0)visibles.sort((a,b)=>{const x=a.cells[columna].dataset.sort||'',y=b.cells[columna].dataset.sort||'';if(numericas.includes(columna)){if(!x)return y?1:0;if(!y)return -1;return (Number(x)-Number(y))*(ascendente?1:-1);}return x.localeCompare(y,'es',{numeric:true})*(ascendente?1:-1);});
  const paginas=Math.max(1,Math.ceil(visibles.length/5));pagina=Math.min(pagina,paginas);cuerpo.replaceChildren(...visibles.slice((pagina-1)*5,pagina*5));
  if(!visibles.length){const tr=cuerpo.insertRow(),td=tr.insertCell();td.colSpan=tabla.tHead.rows[0].cells.length;td.className='ruta-empty';td.textContent='No se encontraron registros para los filtros seleccionados.';}
  paginacion.replaceChildren();function boton(texto,destino,deshabilitado){const b=document.createElement('button');b.type='button';b.className='page-btn'+(texto===String(pagina)?' active':'');b.textContent=texto;b.disabled=deshabilitado;b.setAttribute('aria-label',texto==='‹'?'Página anterior':texto==='›'?'Página siguiente':'Página '+texto);if(texto===String(pagina))b.setAttribute('aria-current','page');b.onclick=()=>{pagina=destino;pintar();};paginacion.appendChild(b);}
  boton('‹',pagina-1,pagina===1);for(let n=1;n<=paginas;n++)boton(String(n),n,false);boton('›',pagina+1,pagina===paginas);
 }
 buscar.addEventListener('input',()=>{pagina=1;pintar();});if(filtro)filtro.addEventListener('change',()=>{pagina=1;pintar();});
 tabla.querySelectorAll('th.sortable').forEach(th=>{th.tabIndex=0;th.setAttribute('role','button');function ordenar(){const nueva=Number(th.dataset.col);ascendente=columna===nueva?!ascendente:true;columna=nueva;pagina=1;tabla.querySelectorAll('th.sortable').forEach(t=>{t.removeAttribute('aria-sort');t.querySelector('.sarrow').textContent='⇅';});th.setAttribute('aria-sort',ascendente?'ascending':'descending');th.querySelector('.sarrow').textContent=ascendente?'▲':'▼';pintar();}th.addEventListener('click',ordenar);th.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();ordenar();}});});pintar();
 tabla.addEventListener('click',e=>{const b=e.target.closest('[data-reserva-pendiente]');if(!b)return;document.getElementById('reservaPendienteTexto').textContent='La reserva para '+b.dataset.nombre+' estará disponible en la siguiente etapa del módulo de Capacidad.';document.getElementById('reservaPendiente').showModal();});
 const imprimir=document.getElementById('exportarFicha');if(imprimir){imprimir.addEventListener('click',()=>window.print());window.addEventListener('beforeprint',()=>cuerpo.replaceChildren(...filas));window.addEventListener('afterprint',pintar);}
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
