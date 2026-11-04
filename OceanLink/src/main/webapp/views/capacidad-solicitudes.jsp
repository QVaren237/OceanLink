<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.ArrayList,java.math.BigDecimal,java.math.RoundingMode,pe.edu.oceanlink.bean.CapacidadEnlace,pe.edu.oceanlink.bean.CapacidadServicio,pe.edu.oceanlink.bean.EvaluacionCapacidad,pe.edu.oceanlink.bean.SolicitudCapacidad,pe.edu.oceanlink.bean.Usuario,java.util.*" %>
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
<%
ArrayList<SolicitudCapacidad> solicitudes=(ArrayList<SolicitudCapacidad>)request.getAttribute("solicitudes");if(solicitudes==null)solicitudes=new ArrayList<>();
%>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="capacidad-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>

            <div class="page-head">
                <div>
                    <h1>Bandeja de Solicitudes</h1>
                    <div class="psub">Evalúa y gestiona las peticiones de nueva capacidad o ampliación de servicios.</div>
                </div>
            </div>

            <div class="card">
                <div class="card-pad" style="border-bottom:1px solid var(--line)">
                    <div class="usearch-box" style="max-width:50%;min-width:420px">
                        <span class="usearch-ic">
                            <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                        </span>
                        <input id="usearch" type="search" aria-label="Buscar solicitud o cliente" placeholder="Buscar por ID de solicitud o cliente...">
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="solicitudesPlannerTable">
                        <thead>
                            <tr>
                                <th class="sortable" data-col="0">ID Solicitud<span class="sarrow">▼</span></th>
                                <th class="sortable" data-col="1">Fecha<span class="sarrow">▼</span></th>
                                <th class="sortable" data-col="2">Cliente<span class="sarrow">▼</span></th>
                                <th class="sortable" data-col="3">Enlace Solicitado<span class="sarrow">▼</span></th>
                                <th class="sortable" data-col="4">Capacidad<span class="sarrow">▼</span></th>
                                <th class="sortable" data-col="5">Estado<span class="sarrow">▼</span></th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody><% for(SolicitudCapacidad solicitud:solicitudes){ %><tr data-fila>
<td data-sort="<%=h(solicitud.getCodigo())%>"><strong><%=h(solicitud.getCodigo())%></strong></td><td data-sort="<%=h(solicitud.getFechaSolicitud())%>"><%=h(solicitud.getFechaSolicitud())%></td>
<td data-sort="<%=h(solicitud.getCliente())%>"><%=h(solicitud.getCliente())%></td><td data-sort="<%=h(solicitud.getRuta())%>"><%=h(solicitud.getRuta())%></td>
<td data-sort="<%=solicitud.getCapacidadSolicitada()%>"><strong><%=capacidad(BigDecimal.valueOf(solicitud.getCapacidadSolicitada()))%></strong></td>
<td data-sort="<%=h(solicitud.getEstado())%>"><span class="pill <%="Rechazada".equals(solicitud.getEstado())?"pill-crit":Arrays.asList("Aprobada","Reservada","Activa","Provisionada").contains(solicitud.getEstado())?"pill-ok":"pill-warn"%>"><span class="dot"></span><%=h(solicitud.getEstado())%></span></td>
<td><a class="btn btn-primary btn-sm" href="<%=ctx%>/capacity-planner/solicitudes?action=evaluar&amp;id=<%=solicitud.getIdSolicitud()%>">Evaluar / Detalle</a></td></tr><% } %>
</tbody>
                    </table>
                </div>
                
                <nav class="pagination" id="capacidadPaginas" aria-label="Paginación de solicitudes"></nav>
            </div>
        
</div>
<script>
(function(){
 const tabla=document.querySelector('.capacidad-vista table');if(!tabla)return;
 const cuerpo=tabla.tBodies[0],filas=Array.from(cuerpo.querySelectorAll('tr[data-fila]'));
 const buscar=document.getElementById('usearch')||document.getElementById('detalleSearch'),filtro=document.getElementById('filtroEstado'),paginacion=document.getElementById('capacidadPaginas');
 const numericas=tabla.id==='solicitudesPlannerTable'?[4]:[3];let pagina=1,columna=-1,ascendente=true;
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
