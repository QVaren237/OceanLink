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
<% ArrayList<CapacidadEnlace> enlaces=(ArrayList<CapacidadEnlace>)request.getAttribute("enlaces");if(enlaces==null)enlaces=new ArrayList<>(); %>

            <div class="page-head" style="margin-bottom: 10px;">
                <div>
                    <h1>Estado de Capacidad de Enlaces Submarinos</h1>
                    <div class="psub">Consulta de utilización y disponibilidad de la red troncal.</div>
                </div>
            </div>

            <div class="capacidad-leyenda">
                <div class="legend-box" style="width: max-content; margin: 0;">
                    <span style="text-align: center; display: block; margin-bottom: 5px; font-size: 10px; font-weight: 800; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px;">Utilization Level Guide</span>
                    <div class="legend-items" style="display: flex; gap: 14px; font-size: 11px; font-weight: 600;">
                        <span style="display: flex; align-items: center; gap: 4px;"><span class="pill pill-ok" style="padding:0; background:none; min-width: auto;"><span class="dot"></span></span> Normal (&lt; 80%)</span>
                        <span style="display: flex; align-items: center; gap: 4px;"><span class="pill pill-warn" style="padding:0; background:none; min-width: auto;"><span class="dot"></span></span> High (80% - 95%)</span>
                        <span style="display: flex; align-items: center; gap: 4px;"><span class="pill pill-crit" style="padding:0; background:none; min-width: auto;"><span class="dot"></span></span> Critical (&gt; 95%)</span>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-pad" style="border-bottom: 1px solid var(--line);">
                    <div class="usearch-box capacidad-buscador">
                        <span class="usearch-ic">
                            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                        </span>
                        <input id="usearch" type="search" aria-label="Buscar por enlace o identificador" placeholder="Buscar por enlace o ID...">
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="capacidadTable">
                        <thead>
                            <tr>
                                <th class="sortable" data-col="0">Enlace<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="1">Identificador<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="2">Capacidad Total<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="3">Capacidad Utilizada<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="4">Capacidad Reservada<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="5">Capacidad Disponible<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="6">Estado<span class="sarrow">⇅</span></th>
                                <th class="sortable" data-col="7">Utilización<span class="sarrow">⇅</span></th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
<% for(CapacidadEnlace enlace:enlaces){ %>
<tr data-fila>
 <td data-sort="<%=h(enlace.getNombre())%>"><%=h(enlace.getNombre())%></td>
 <td data-sort="<%=h(enlace.getCodigo())%>"><%=h(enlace.getCodigo())%></td>
 <td data-sort="<%=h(enlace.getCapacidadTotal())%>"><%=capacidad(enlace.getCapacidadTotal())%></td>
 <td data-sort="<%=h(enlace.getCapacidadUtilizada())%>"><%=capacidad(enlace.getCapacidadUtilizada())%></td>
 <td data-sort="<%=h(enlace.getCapacidadReservada())%>"><%=capacidad(enlace.getCapacidadReservada())%></td>
 <td data-sort="<%=h(enlace.getCapacidadDisponible())%>"><strong><%=capacidad(enlace.getCapacidadDisponible())%></strong></td>
 <td data-sort="<%=h(enlace.getEstado())%>"><span class="pill <%=estadoClase(enlace.getEstado())%>"><span class="dot"></span><%=enlace.getEstado()==null?"Sin datos":h(enlace.getEstado())%></span></td>
 <td data-sort="<%=h(enlace.getPorcentajeUtilizacion())%>" class="capacidad-text-<%=enlace.getClaseUtilizacion()%>" title="Utilizada más reservada respecto de la capacidad total: <%=h(enlace.getNivelUtilizacion())%>"><%=porcentaje(enlace.getPorcentajeUtilizacion())%></td>
 <td><div class="actions">
  <a class="btn btn-outline btn-icon" href="<%=ctx%>/capacity-planner/capacidad?action=detalle&amp;id=<%=enlace.getIdSegmento()%>" title="Ver detalles del enlace" aria-label="Ver detalle de <%=h(enlace.getCodigo())%>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></a>
  <a class="btn btn-outline btn-icon" href="<%=ctx%>/capacity-planner/capacidad?action=reserva&amp;id=<%=enlace.getIdSegmento()%>" title="Reservar capacidad" aria-label="Reservar capacidad en <%=h(enlace.getCodigo())%>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg></a>
 </div></td>
</tr>
<% } %>
</tbody>
                    </table>
                </div>
                
                <nav class="pagination" id="capacidadPaginas" aria-label="Paginación de enlaces"></nav>
            </div>
        <% } %>
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

 const imprimir=document.getElementById('exportarFicha');if(imprimir)imprimir.addEventListener('click',()=>window.print());
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
