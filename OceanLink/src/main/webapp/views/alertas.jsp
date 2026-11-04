<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace" %>
<%!
 private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
 private String numero(BigDecimal v){return v==null?"Sin datos":v.stripTrailingZeros().toPlainString();}
 private String porcentaje(BigDecimal v){return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).toPlainString()+"%";}
%>
<% String ctx=request.getContextPath();if(request.getAttribute("titulo")==null){response.sendRedirect(ctx+"/capacity-planner/alertas");return;} %>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="alertas-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% ArrayList<CapacidadEnlace> alertas=(ArrayList<CapacidadEnlace>)request.getAttribute("alertas");if(alertas==null)alertas=new ArrayList<>();int criticas=0;for(CapacidadEnlace e:alertas)if(e.isAlertaCritica())criticas++; %>

            <div class="page-head">
                <div>
                    <h1>Monitoreo Proactivo de Saturación</h1>
                    <div class="psub">Segmentos de fibra óptica con utilización superior al umbral preventivo (85%).</div>
                </div>
                
                <div class="legend-box alertas-estilo-1">
                    <div class="legend-items">
                        <span><span class="pill pill-crit alertas-estilo-2"><span class="dot"></span></span> Atención Inmediata</span>
                    </div>
                </div>
            </div>

            <div class="kpis">
                <div class="kpi alertas-estilo-3">
                    <span class="kbadge alertas-estilo-4">CRÍTICO</span>
                    <div class="kv"><%=criticas%></div>
                    <div class="kl">Enlaces > 95%</div>
                </div>
                <div class="kpi alertas-estilo-5">
                    <span class="kbadge alertas-estilo-6">PREVENTIVO</span>
                    <div class="kv"><%=alertas.size()-criticas%></div>
                    <div class="kl">Enlaces 85% - 95%</div>
                </div>
            </div>

            <div class="card">
                <div class="card-pad alertas-estilo-7">
                    <div class="usearch-box alertas-estilo-8">
                        <span class="usearch-ic">
                            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                        </span>
                        <input id="usearch" type="search" aria-label="Buscar por enlace o identificador" placeholder="Buscar por enlace o ID...">
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="alertasTable">
                        <thead>
                            <tr>
                                <th data-col="0" class="sortable">Identificador<span class="sarrow">▼</span></th>
                                <th data-col="1" class="sortable">Segmento (Origen - Destino)<span class="sarrow">▼</span></th>
                                <th data-col="2" class="sortable">Tráfico Total<span class="sarrow">▼</span></th>
                                <th data-col="3" class="sortable alertas-estilo-9">Nivel de Utilización<span class="sarrow">▼</span></th>
                                <th data-col="4" class="sortable">Estado<span class="sarrow">▼</span></th>
                                <th>Acción Recomendada</th>
                            </tr>
                        </thead>
                        <tbody>
<% for(CapacidadEnlace enlace:alertas){boolean critica=enlace.isAlertaCritica();String nivel=critica?"crit":"warn"; %>
<tr data-fila>
<td data-sort="<%=h(enlace.getCodigo())%>"><strong><%=h(enlace.getCodigo())%></strong></td>
<td data-sort="<%=h(enlace.getNombre())%>"><%=h(enlace.getNombre())%></td>
<td data-sort="<%=h(enlace.getCapacidadAsignada())%>"><%=numero(enlace.getCapacidadAsignada())%> Gbps / <%=numero(enlace.getCapacidadTotal())%> Gbps</td>
<td data-sort="<%=h(enlace.getPorcentajeUtilizacion())%>"><div class="alertas-medicion"><span class="text-<%=nivel%>"><%=porcentaje(enlace.getPorcentajeUtilizacion())%></span><span class="alertas-libres"><%=numero(enlace.getCapacidadDisponible())%> Gbps Libres</span></div><div class="progress-track"><div class="progress-fill fill-<%=nivel%>" data-ancho="<%=enlace.getAnchoProgreso()%>"></div></div></td>
<td data-sort="<%=critica?2:1%>"><span class="pill pill-<%=nivel%>"><span class="dot"></span><%=critica?"Saturado":"Alerta"%></span></td>
<td><div class="actions"><a href="<%=ctx%>/capacity-planner/alertas?action=ampliacion&amp;id=<%=enlace.getIdSegmento()%>" class="btn <%=critica?"btn-danger":"btn-outline alertas-accion-preventiva"%> btn-sm">Planificar Ampliación</a></div></td>
</tr>
<% } %>
</tbody>
                    </table>
                </div>
                
                <nav class="pagination" id="alertasPaginas" aria-label="Paginación de alertas"></nav>
</div>
<script>
(function(){
 document.querySelectorAll('[data-ancho]').forEach(el=>el.style.width=el.dataset.ancho+'%');
 const tabla=document.querySelector('.alertas-vista table');if(!tabla)return;
 const cuerpo=tabla.tBodies[0],filas=Array.from(cuerpo.querySelectorAll('tr[data-fila]'));
 const buscar=document.getElementById('usearch')||document.getElementById('detalleSearch'),filtro=document.getElementById('filtroEstado'),paginacion=document.getElementById('alertasPaginas');
 const numericas=[2,3,4];let pagina=1,columna=-1,ascendente=true;
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
</div>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
