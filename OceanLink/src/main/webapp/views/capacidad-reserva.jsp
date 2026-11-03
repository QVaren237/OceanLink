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
CapacidadEnlace enlace=(CapacidadEnlace)request.getAttribute("enlace");
EvaluacionCapacidad evaluacion=(EvaluacionCapacidad)request.getAttribute("evaluacion");
ArrayList<CapacidadServicio> servicios=(ArrayList<CapacidadServicio>)request.getAttribute("servicios");if(servicios==null)servicios=new ArrayList<>();
Map<Integer,ArrayList<CapacidadEnlace>> tramos=(Map<Integer,ArrayList<CapacidadEnlace>>)request.getAttribute("tramosServicios");if(tramos==null)tramos=new LinkedHashMap<>();
ArrayList<String[]> responsables=(ArrayList<String[]>)request.getAttribute("responsables");if(responsables==null)responsables=new ArrayList<>();
Set<String> seleccionados=new HashSet<>();if(request.getParameterValues("segmentos")!=null)seleccionados.addAll(Arrays.asList(request.getParameterValues("segmentos")));
%>
<jsp:include page="/views/capacity-planner-inicio.jsp"/>
<div class="capacidad-vista">
<% if(request.getAttribute("error")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("error"))%></div><% } %>
<% if(enlace!=null){ %>
            <div style="margin-bottom: 5px;">
                <a href="<%=ctx%>/capacity-planner/capacidad" class="link">&lt;- Volver a Capacidad</a>
            </div>

            <div class="page-head">
                <div>
                    <h1>Reservar Capacidad - Enlace: <%=h(enlace.getNombre())%> (<%=h(enlace.getCodigo())%>)</h1>
                </div>
            </div>

            <form id="reservaForm" class="card card-pad" method="post" action="<%=ctx%>/capacity-planner/capacidad">
<input type="hidden" name="action" value="reservar"><input type="hidden" name="id" value="<%=enlace.getIdSegmento()%>">
<input type="hidden" name="idServicio" id="servicioReserva" value="<%=h(request.getParameter("idServicio"))%>">
<input type="hidden" name="tokenReserva" value="<%=h(request.getAttribute("tokenReserva"))%>">
<input type="hidden" name="segmentos" value="<%=enlace.getIdSegmento()%>">
<% if(evaluacion!=null){ %><input type="hidden" name="idSolicitud" value="<%=evaluacion.getSolicitud().getIdSolicitud()%>"><div class="info-strip"><div class="ii">i</div><div>Reserva vinculada a <strong><%=h(evaluacion.getSolicitud().getCodigo())%></strong>. Se reservará la capacidad aprobada en toda su ruta.</div></div><% }else{ %><div class="info-strip"><div class="ii">i</div><div>Reserva directa para un servicio. No requiere una solicitud previa.</div></div><% } %>
                <div style="display: flex; gap: 30px; align-items: flex-start;">
                    <div class="field">
                        <label>Capacidad disponible actual</label>
                        <input type="text" class="input" value="<%=capacidad(enlace.getCapacidadDisponible())%>" disabled style="background-color: var(--line); width: 200px;">
                    </div>
                    <div class="field" style="flex: 1;">
                        <label>Cantidad a reservar (Gbps)</label>
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <input type="number" id="cantidadReserva" name="cantidad" class="input" value="<%=evaluacion!=null?BigDecimal.valueOf(evaluacion.getSolicitud().getCapacidadSolicitada()).toPlainString():h(request.getParameter("cantidad"))%>" <%=evaluacion!=null?"readonly":""%> placeholder="Ej: 40" min="0.01" step="0.01" required style="width: 200px;">
                            <div id="errorMsg" class="err" style="display: none; margin: 0; max-width: 300px; line-height: 1.3;">
                                La cantidad debe ser positiva y no superar la disponibilidad de los segmentos elegidos.
                            </div>
                        </div>
                    </div>
                </div>

                <div class="field" style="margin-top: 20px;">
                    <label>Servicios asignados en este enlace</label>
                    <div class="card" style="box-shadow: none; border: 1px solid var(--line-strong); border-radius: 12px; overflow: hidden;">
                        
                        <div class="card-pad" style="background: var(--surface); padding: 10px 15px; border-bottom: 1px solid var(--line);">
                            <div class="usearch-box" style="width: 100%;">
                                <span class="usearch-ic">
                                    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
                                </span>
                                <input id="usearch" type="search" aria-label="Buscar servicio o empresa" placeholder="Buscar servicio o empresa...">
                            </div>
                        </div>
                        
                        <div class="table-wrap" style="border: none; border-radius: 0;">
                            <table id="reservasTable">
                                <thead>
                                    <tr>
                                        <th class="sortable" data-col="0">Empresa<span class="sarrow">▼</span></th>
                                        <th class="sortable" data-col="1">ID - Servicio<span class="sarrow">▼</span></th>
                                        <th class="sortable" data-col="2">RUC<span class="sarrow">▼</span></th>
                                        <th class="sortable" data-col="3">Capacidad<span class="sarrow">▼</span></th>
                                        <th style="text-align: center;">Selección</th>
                                    </tr>
                                </thead>
                                <tbody><% for(CapacidadServicio servicio:servicios){ %><tr data-fila>
<td data-sort="<%=h(servicio.getCliente())%>"><%=h(servicio.getCliente())%></td><td data-sort="<%=h(servicio.getCodigo())%>"><%=h(servicio.getCodigo())%></td><td data-sort="<%=h(servicio.getRuc())%>"><%=h(servicio.getRuc())%></td>
<td data-sort="<%=h(servicio.getCapacidadContratada())%>"><%=servicio.getCapacidadContratada()==null?"Sin asignar":capacidad(servicio.getCapacidadContratada())%></td>
<td style="text-align:center"><input type="radio" name="servicioUI" class="radio-tabla" value="<%=servicio.getIdServicio()%>" aria-label="Seleccionar <%=h(servicio.getCodigo())%>" <%=String.valueOf(servicio.getIdServicio()).equals(request.getParameter("idServicio"))?"checked":""%>></td></tr><% } %>
</tbody>
                            </table>
                            
                            <nav class="pagination" id="capacidadPaginas" aria-label="Paginación de servicios"></nav>
                        </div>
                    </div>
                </div>

                <div class="field reserva-tramos"><label>Segmentos a reservar *</label><p class="hint">La cantidad indicada se reservará en cada segmento seleccionado.</p>
<% for(CapacidadServicio servicio:servicios){ %><div data-tramos-servicio="<%=servicio.getIdServicio()%>" data-codigo="<%=h(servicio.getCodigo())%>" hidden><% for(CapacidadEnlace tramo:tramos.get(servicio.getIdServicio())){boolean esBase=tramo.getIdSegmento()==enlace.getIdSegmento(); %>
<label class="reserva-tramo"><input type="checkbox" <%=esBase||evaluacion!=null?"":"name=\"segmentos\""%> value="<%=tramo.getIdSegmento()%>" data-tramo data-disponible="<%=h(tramo.getCapacidadDisponible())%>" data-base="<%=esBase%>" data-vinculado="<%=evaluacion!=null%>" data-codigo="<%=h(tramo.getCodigo())%>" <%=esBase||evaluacion!=null||seleccionados.contains(String.valueOf(tramo.getIdSegmento()))?"checked":""%> disabled>
<span><strong><%=h(tramo.getCodigo())%></strong> · <%=h(tramo.getNombre())%> · <%=capacidad(tramo.getCapacidadDisponible())%> disponibles · <%=h(tramo.getEstado())%></span></label>
<% if(evaluacion!=null&&!esBase){ %><input type="hidden" name="segmentos" value="<%=tramo.getIdSegmento()%>" disabled><% } %>
<% } %></div><% } %></div><div class="field reserva-responsable"><label for="idResponsable">Capacity Planner responsable *</label>
<% if(request.getAttribute("responsableSesion") instanceof Usuario){Usuario actor=(Usuario)request.getAttribute("responsableSesion"); %><div class="ro-field"><%=h(actor.getNombre())%> <%=h(actor.getApellido())%></div>
<% }else{ %><select class="input" id="idResponsable" name="idResponsable" required><option value="">Selecciona al responsable</option><% for(String[] actor:responsables){ %><option value="<%=actor[0]%>" <%=actor[0].equals(request.getParameter("idResponsable"))?"selected":""%>><%=h(actor[1])%></option><% } %></select><% } %></div><div class="form-actions" style="margin-top: 30px;">
                    <a href="<%=ctx%>/capacity-planner/capacidad" class="btn btn-outline">Cancelar</a>
                    <button type="submit" class="btn btn-primary">Confirmar Reserva</button>
                </div>
            </form>
        <% if(servicios.isEmpty()){ %><div class="banner banner-err">No hay servicios disponibles para reservar en este enlace. Registra primero el servicio de un cliente activo.</div><% } %><% } %><dialog id="confirmarReserva" class="ruta-dialog"><h2>Confirmar reserva</h2><p id="resumenReserva"></p><div class="form-actions"><button type="button" class="btn btn-outline" id="cancelarReserva">Volver a editar</button><button type="button" class="btn btn-primary" id="guardarReserva">Guardar reserva</button></div></dialog>
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
</script><script>
(function(){const form=document.getElementById('reservaForm');if(!form)return;
const tabla=document.getElementById('reservasTable'),servicio=document.getElementById('servicioReserva'),cantidad=document.getElementById('cantidadReserva'),error=document.getElementById('errorMsg'),dialog=document.getElementById('confirmarReserva');let confirmado=false;
function sincronizar(){document.querySelectorAll('[data-tramos-servicio]').forEach(grupo=>{const activo=grupo.dataset.tramosServicio===servicio.value;grupo.hidden=!activo;grupo.querySelectorAll('input').forEach(c=>{c.disabled=!activo||c.dataset.base==='true'||c.dataset.vinculado==='true';});});}
tabla.addEventListener('change',e=>{if(e.target.name==='servicioUI'){servicio.value=e.target.value;sincronizar();}});sincronizar();
form.addEventListener('submit',e=>{if(confirmado){document.getElementById('guardarReserva').disabled=true;return;}e.preventDefault();error.style.display='none';
if(!servicio.value){error.textContent='Selecciona un servicio.';error.style.display='block';return;}
const grupo=Array.from(document.querySelectorAll('[data-tramos-servicio]')).find(g=>g.dataset.tramosServicio===servicio.value),elegidos=Array.from(grupo.querySelectorAll('[data-tramo]')).filter(c=>c.checked),valor=Number(cantidad.value);
if(!Number.isFinite(valor)||valor<=0||elegidos.some(c=>!c.dataset.disponible||valor>Number(c.dataset.disponible))){error.textContent='La cantidad supera la disponibilidad de alguno de los segmentos elegidos.';error.style.display='block';return;}
document.getElementById('resumenReserva').textContent='Se reservarán '+cantidad.value+' Gbps para el servicio '+grupo.dataset.codigo+' en '+elegidos.map(c=>c.dataset.codigo).join(', ')+'. Confirma los datos antes de guardar.';dialog.showModal();});
document.getElementById('cancelarReserva').onclick=()=>dialog.close();document.getElementById('guardarReserva').onclick=()=>{confirmado=true;form.requestSubmit();};
})();
</script>
<jsp:include page="/views/capacity-planner-fin.jsp"/>
