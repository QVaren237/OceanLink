<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.sql.Timestamp,java.math.BigDecimal,pe.edu.oceanlink.bean.Mantenimiento" %>
<%!
 private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
 private String fecha(Object v){return v==null?"Sin registrar":v instanceof Timestamp?((Timestamp)v).toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")):h(v);}
 private String pill(String v){return "Finalizado".equals(v)?"pill-neutral":"En ejecución".equals(v)?"pill-ok":"pill-warn";}
 private String dato(jakarta.servlet.http.HttpServletRequest r,String n){String v=r.getParameter(n);Object b=r.getAttribute("borradorMC");if(v==null&&b instanceof Map){Object valor=((Map<?,?>)b).get(n);if(valor!=null)v=valor.toString();}return h(v);}
%>
<% String ctx=request.getContextPath(),base=ctx+"/maintenance-coordinator/mantenimientos";
if(request.getAttribute("tituloMC")==null){response.sendRedirect(base);return;}
Mantenimiento m=(Mantenimiento)request.getAttribute("mantenimiento"); %>
<jsp:include page="/views/mc-inicio.jsp"/>
<% if(request.getAttribute("errorMC")!=null){ %><div class="banner banner-err" role="alert"><%=h(request.getAttribute("errorMC"))%></div><% } %>
<% ArrayList<Mantenimiento> lista=(ArrayList<Mantenimiento>)request.getAttribute("listaMC");if(lista==null)lista=new ArrayList<>();boolean historial=Boolean.TRUE.equals(request.getAttribute("esHistorial")); %>

      <div class="page-head">
        <div>
          <h1><%=historial?"Historial de Mantenimientos (RF31)":"Gestión de Mantenimientos"%></h1>
          <div class="psub"><%=historial?"Registro inmutable de todas las intervenciones finalizadas.":"Control de intervenciones en infraestructura (Preventivas y Correctivas)."%></div>
        </div>
        <div class="grow"></div>
        <% if(!historial){ %><a class="btn btn-primary" href="<%=base%>?action=registro">+ Programar Mantenimiento (RF24)</a><% } %>
      </div>

      <div class="card">
        <div class="card-pad mc-ref-2">
          <div class="usearch-box mc-ref-3">
            <span class="usearch-ic"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span>
            <input type="text" id="usearch" aria-label="Buscar por ID, infraestructura o incidencia" placeholder="Buscar por ID, Infraestructura o Incidencia...">
          </div>
        </div>
        
        <div class="table-wrap">
          <table id="mantenimientosTable">
            <thead>
              <tr>
                <th class="sortable" data-col="0">ID<span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="1">Origen / Tipo<span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="2">Infraestructura<span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="3"><%=historial?"Fecha de Ejecución":"Inicio Programado"%><span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="4"><%=historial?"Resultado Final":"Estado"%><span class="sarrow">⇅</span></th>
                <% if(!historial){ %><th>Acción</th><% } %>
              </tr>
            </thead>
            <tbody><% for(Mantenimiento fila:lista){ %><tr data-fila>
<td data-sort="<%=h(fila.getCodigo())%>"><% if(historial){ %><a class="link" href="<%=base%>?action=detalle&amp;id=<%=fila.getIdMantenimiento()%>"><%=h(fila.getCodigo())%></a><% }else{ %><strong><%=h(fila.getCodigo())%></strong><% } %></td>
<td data-sort="<%=h(fila.getTipo())%>"><div class="mc-tipo <%= "Correctivo".equals(fila.getTipo())?"mc-correctivo":"mc-preventivo" %>"><%=h(fila.getTipo())%></div><% if(fila.getIncidenciaCodigo()!=null){ %><div class="mc-sub">Ref: <%=h(fila.getIncidenciaCodigo())%></div><% }else if(!historial){ %><div class="mc-sub">Rutina Programada</div><% } %></td>
<td data-sort="<%=h(fila.getInfraestructuraCodigo())%>"><span class="seg-tag"><%=h(fila.getInfraestructuraCodigo())%></span> <%=h(fila.getInfraestructuraNombre())%></td>
<td data-sort="<%=h(historial?fila.getFechaFin():fila.getFechaInicio())%>"><%=fecha(historial?fila.getFechaFin():fila.getFechaInicio())%></td>
<td data-sort="<%=h(historial?fila.getResultado():fila.getEstado())%>"><span class="pill <%=pill(fila.getEstado())%>"><span class="dot"></span><%=historial?"Finalizado":h(fila.getEstado())%></span><% if(historial){ %><div class="mc-sub mc-multilinea"><%=h(fila.getResultado())%></div><% } %></td>
<% if(!historial){ %><td><a class="btn btn-outline btn-sm" href="<%=base%>?action=detalle&amp;id=<%=fila.getIdMantenimiento()%>">Gestionar</a></td><% } %></tr><% } %></tbody>
          </table>
        </div>
        
        <nav class="pagination" id="mcPaginas" aria-label="Paginación de mantenimientos"></nav></div>
<script>
(function(){
 const tabla=document.querySelector('.mc-shell table');if(!tabla)return;
 const cuerpo=tabla.tBodies[0],filas=Array.from(cuerpo.querySelectorAll('tr[data-fila]'));
 const buscar=document.getElementById('usearch')||document.getElementById('detalleSearch'),filtro=document.getElementById('filtroEstado'),paginacion=document.getElementById('mcPaginas');
 const numericas=[];let pagina=1,columna=-1,ascendente=true;
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
<jsp:include page="/views/mc-fin.jsp"/>
