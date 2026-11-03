<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace,pe.edu.oceanlink.bean.HistoricoCapacidad" %>
<%!
 private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
 private String numero(BigDecimal v){return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();}
 private String porcentaje(BigDecimal v){return v==null?"Sin datos":v.setScale(2,RoundingMode.HALF_UP).toPlainString()+"%";}
%>
<% String ctx=request.getContextPath();if(request.getAttribute("titulo")==null){response.sendRedirect(ctx+"/capacity-planner/alertas");return;} %>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="historico-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% ArrayList<CapacidadEnlace> enlaces=(ArrayList<CapacidadEnlace>)request.getAttribute("enlaces");if(enlaces==null)enlaces=new ArrayList<>();
ArrayList<HistoricoCapacidad> periodos=(ArrayList<HistoricoCapacidad>)request.getAttribute("periodos");if(periodos==null)periodos=new ArrayList<>();
CapacidadEnlace enlace=(CapacidadEnlace)request.getAttribute("enlace");String rango=request.getAttribute("rango")==null?"6meses":request.getAttribute("rango").toString();
BigDecimal crecimiento=(BigDecimal)request.getAttribute("crecimiento"),pico=(BigDecimal)request.getAttribute("pico"); %>

            <div class="page-head">
                <div>
                    <h1>Histórico de Utilización</h1>
                    <div class="psub">Analiza las tendencias de tráfico y el crecimiento de la demanda en el tiempo.</div>
                </div>
            </div>

            <!-- Panel de Filtros -->
            <form class="card card-pad" method="get" action="<%=ctx%>/capacity-planner/historico" class="historico-estilo-1">
                <div class="historico-estilo-2">
                    <div class="field historico-estilo-3">
                        <label for="idHistorico">Segmento de Red</label>
                        <select class="input" name="id" id="idHistorico" required>
<% for(CapacidadEnlace e:enlaces){ %><option value="<%=e.getIdSegmento()%>" <%=enlace!=null&&enlace.getIdSegmento()==e.getIdSegmento()?"selected":""%>><%=h(e.getCodigo())%>: <%=h(e.getNombre())%></option><% } %>
</select>
                    </div>
                    <div class="field historico-estilo-4">
                        <label for="rangoHistorico">Rango de Tiempo</label>
                        <select class="input" name="rango" id="rangoHistorico">
<option value="6meses" <%= "6meses".equals(rango)?"selected":"" %>>Últimos 6 meses</option>
<option value="actual" <%= "actual".equals(rango)?"selected":"" %>>Año actual (<%=java.time.LocalDate.now().getYear()%>)</option>
<option value="completo" <%= "completo".equals(rango)?"selected":"" %>>Histórico completo</option>
</select>
                    </div>
                    <button type="submit" class="btn btn-primary historico-estilo-5">Generar Reporte</button>
                    <button type="submit" name="action" value="exportar" class="btn btn-outline btn-icon historico-estilo-6" title="Exportar a Excel" aria-label="Exportar reporte CSV compatible con Excel">
                        <svg viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                    </button>
                </div>
            </form>
<!-- KPIs de Tendencia -->
            <div class="kpis">
                <div class="kpi">
                    <span class="kbadge historico-estilo-7">CRECIMIENTO</span>
                    <div class="kv" title="Variación relativa del tráfico promedio entre el primer y último mes con registros del período"><%=crecimiento==null?"—":(crecimiento.signum()>0?"+":"")+numero(crecimiento)%><span class="historico-estilo-8">%</span></div>
                    <div class="kl"><%= "6meses".equals(rango)?"Aumento en últimos 6 meses":"Aumento en período seleccionado" %></div>
                </div>
                <div class="kpi">
                    <div class="kv"><%=numero(pico)%><span class="historico-estilo-9">Gbps</span></div>
                    <div class="kl">Pico Máximo Registrado</div>
                </div>
                <div class="kpi">
                    <div class="kv"><%=enlace==null?"Sin datos":numero(enlace.getCapacidadTotal())%><span class="historico-estilo-10">Gbps</span></div>
                    <div class="kl">Capacidad Física Instalada</div>
                </div>
            </div>

            <!-- Tabla de Registros Históricos con Buscador -->
            <div class="card">
                <!-- Barra de búsqueda idéntica a dashboard.html -->
                <div class="card-pad historico-estilo-11">
                    <div class="usearch-box historico-estilo-12">
                        <span class="usearch-ic">
                            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                        </span>
                        <input id="usearch" type="search" aria-label="Buscar por periodo o tráfico" placeholder="Buscar por periodo o tráfico...">
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="historicoTable">
                        <thead>
                            <tr>
                                <th data-col="0" class="sortable">Periodo<span class="sarrow">▼</span></th>
                                <th data-col="1" class="sortable">Capacidad Instalada<span class="sarrow">▼</span></th>
                                <th data-col="2" class="sortable" title="Promedio de la capacidad utilizada en las muestras registradas del mes">Tráfico Promedio<span class="sarrow">▼</span></th>
                                <th data-col="3" class="sortable">Pico Máximo<span class="sarrow">▼</span></th>
                                <th data-col="4" class="sortable" title="Máximo de (utilizada más reservada) dividido entre capacidad total de cada muestra">Utilización Máx.<span class="sarrow">▼</span></th>
                                <th data-col="5" class="sortable">Tendencia<span class="sarrow">▼</span></th>
                            </tr>
                        </thead>
                        <tbody>
<% for(int i=periodos.size()-1;i>=0;i--){HistoricoCapacidad p=periodos.get(i);BigDecimal tendencia=p.getTendencia();String clase=p.getClaseUtilizacion(); %>
<tr data-fila>
<td data-sort="<%=h(p.getPeriodo())%>"><strong><%=h(p.getNombrePeriodo())%></strong></td>
<td data-sort="<%=h(p.getCapacidadInstalada())%>"><%=numero(p.getCapacidadInstalada())%> Gbps</td>
<td data-sort="<%=h(p.getPromedio())%>"><%=numero(p.getPromedio())%> Gbps</td>
<td data-sort="<%=h(p.getPico())%>"><%=numero(p.getPico())%> Gbps</td>
<td data-sort="<%=h(p.getUtilizacionMaxima())%>"><span class="pill pill-<%=clase%>"><span class="dot"></span><%=porcentaje(p.getUtilizacionMaxima())%></span></td>
<td data-sort="<%=h(tendencia)%>" class="text-<%=tendencia==null||tendencia.signum()==0?"neutral":tendencia.signum()<0?"ok":clase%>" title="Variación de la utilización máxima respecto del mes anterior con registros, en puntos porcentuales"><%=tendencia==null?"-":(tendencia.signum()>0?"↗ +":tendencia.signum()<0?"↘ ":"→ ")+numero(tendencia)+"%"%></td>
</tr>
<% } %>
</tbody>
                    </table>
                </div>
                
                <nav class="pagination" id="historicoPaginas" aria-label="Paginación de registros históricos"></nav>
</div>
<script>
(function(){
 document.querySelectorAll('[data-ancho]').forEach(el=>el.style.width=el.dataset.ancho+'%');
 const tabla=document.querySelector('.historico-vista table');if(!tabla)return;
 const cuerpo=tabla.tBodies[0],filas=Array.from(cuerpo.querySelectorAll('tr[data-fila]'));
 const buscar=document.getElementById('usearch')||document.getElementById('detalleSearch'),filtro=document.getElementById('filtroEstado'),paginacion=document.getElementById('historicoPaginas');
 const numericas=[1,2,3,4,5];let pagina=1,columna=-1,ascendente=true;
 function pintar(){
  const texto=buscar.value.trim().toLocaleLowerCase('es');let visibles=filas.filter(f=>f.textContent.toLocaleLowerCase('es').includes(texto)&&(!filtro||!filtro.value||f.dataset.estado===filtro.value));
  if(columna>=0)visibles.sort((a,b)=>{const x=a.cells[columna].dataset.sort||'',y=b.cells[columna].dataset.sort||'';if(numericas.includes(columna)){if(!x)return y?1:0;if(!y)return -1;return (Number(x)-Number(y))*(ascendente?1:-1);}return x.localeCompare(y,'es',{numeric:true})*(ascendente?1:-1);});
  const paginas=Math.max(1,Math.ceil(visibles.length/5));pagina=Math.min(pagina,paginas);cuerpo.replaceChildren(...visibles.slice((pagina-1)*5,pagina*5));
  if(!visibles.length){const tr=cuerpo.insertRow(),td=tr.insertCell();td.colSpan=tabla.tHead.rows[0].cells.length;td.className='ruta-empty';td.textContent='No se encontraron registros históricos para el segmento, período o búsqueda seleccionados.';}
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
