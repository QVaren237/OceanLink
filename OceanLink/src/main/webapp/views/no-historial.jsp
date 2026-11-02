<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.*" %>
<%!
 private String h(Object v) { return v==null?"—":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String pill(String v) {
   if (v==null) return "pill-neutral";
   if (Arrays.asList("Crítica","Detectada","Fuera de servicio","Rechazada").contains(v)) return "pill-crit";
   if (Arrays.asList("Operativo","Servicio restaurado","Aprobada","Baja").contains(v)) return "pill-ok";
   if (Arrays.asList("Media","En mantenimiento").contains(v)) return "pill-info";
   return "Cerrada".equals(v)?"pill-neutral":"pill-warn";
 }
%>
<% String ctx=request.getContextPath(); %>
<% request.setAttribute("tituloNO","Historial de incidencias");request.setAttribute("seccionNO","historial");
ArrayList<Incidencia> lista=(ArrayList<Incidencia>)request.getAttribute("lista");if(lista==null)lista=new ArrayList<>();
%>
<jsp:include page="/views/no-inicio.jsp"/>
<div class="page-head"><div><h1>Historial de incidencias</h1><div class="psub">Consulta todas las incidencias registradas.</div></div><div class="grow"></div></div><div class="card"><div class="card-pad table-toolbar"><div class="usearch-box table-search"><span class="usearch-ic"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span><input id="hist-search" type="search" placeholder="Buscar por ticket, título o segmento..."></div><select class="input" id="hist-status" aria-label="Filtrar por estado"><option value="">Todos los estados</option><option>Detectada</option><option>En análisis</option><option>Reparación programada</option><option>En reparación</option><option>Servicio restaurado</option><option>Cerrada</option></select></div><div class="table-wrap"><table data-no-table><thead><tr><th class="sortable">Ticket <span class="sarrow">▲</span></th><th>Título <span class="sarrow">▲</span></th><th class="sortable">Severidad <span class="sarrow">▲</span></th><th>Segmentos <span class="sarrow">▲</span></th><th class="sortable">Estado <span class="sarrow">▲</span></th><th>Registrada <span class="sarrow">▲</span></th></tr></thead><tbody><% for(Incidencia i:lista){ %><tr data-row data-estado="<%=h(i.getEstado())%>"><td class="u-name"><a class="no-incidencia-link" href="<%=ctx%>/NetworkOperatorServlet?action=detalleIncidencia&amp;id=<%=i.getIdIncidencia()%>"><%=h(i.getCodigo())%></a></td><td><%=h(i.getTitulo())%></td><td><span class="pill <%=pill(i.getSeveridad())%>"><span class="dot"></span><%=h(i.getSeveridad())%></span></td><td><% if(i.getRedes()!=null)for(String red:i.getRedes().split(", ")){ %><span class="seg-tag"><%=h(red)%></span><% } %></td><td><span class="pill <%=pill(i.getEstado())%>"><span class="dot"></span><%=h(i.getEstado())%></span></td><td><%=h(i.getFechaDeteccion())%></td></tr><% } %></tbody></table></div><nav class="pagination" aria-label="Paginación"></nav></div><% if(request.getAttribute("eventos")!=null){ %><div class="card"><div class="card-pad section-title">Eventos de la incidencia</div><div class="obs-list"><% for(ObservacionIncidencia evento:(ArrayList<ObservacionIncidencia>)request.getAttribute("eventos")){ %><div class="obs-item"><div class="obs-date"><%=h(evento.getFechaRegistro())%> · <%=h(evento.getTipo())%></div><div class="obs-text"><%=h(evento.getDetalle())%></div></div><% } %></div></div><% } %><script>
(function(){
 const table=document.querySelector('[data-no-table]');if(!table)return;
 const tbody=table.tBodies[0],rows=Array.from(tbody.querySelectorAll('tr[data-row]'));
 const search=document.querySelector('.table-search input'),filter=document.querySelector('.table-toolbar select');
 const nav=document.querySelector('.pagination');let page=1,col=-1,asc=true;
 function paint(){
  const q=(search?search.value:'').toLocaleLowerCase('es');
  let found=rows.filter(r=>r.textContent.toLocaleLowerCase('es').includes(q)&&(!filter||!filter.value||r.dataset.estado===filter.value));
  if(col>=0)found.sort((a,b)=>a.cells[col].textContent.trim().localeCompare(b.cells[col].textContent.trim(),'es',{numeric:true})*(asc?1:-1));
  const total=Math.max(1,Math.ceil(found.length/5));page=Math.min(page,total);tbody.replaceChildren(...found.slice((page-1)*5,page*5));
  if(!found.length){const tr=tbody.insertRow(),td=tr.insertCell();td.colSpan=table.tHead.rows[0].cells.length;td.textContent='No hay resultados para los filtros seleccionados.';}
  nav.replaceChildren();function button(text,n,disabled){let b=document.createElement('button');b.type='button';b.className='page-btn'+(text===String(page)?' active':'');b.textContent=text;b.disabled=disabled;b.setAttribute('aria-label',text==='‹'?'Página anterior':text==='›'?'Página siguiente':'Página '+text);if(text===String(page))b.setAttribute('aria-current','page');b.onclick=()=>{page=n;paint();};nav.appendChild(b);}
  button('‹',page-1,page===1);for(let n=1;n<=total;n++)button(String(n),n,false);button('›',page+1,page===total);
 }
 if(search)search.oninput=()=>{page=1;paint();};if(filter)filter.onchange=()=>{page=1;paint();};
 Array.from(table.tHead.rows[0].cells).forEach((th,n)=>{if(th.textContent.trim()==='Acción')return;th.classList.add('sortable');th.tabIndex=0;function sort(){asc=col===n?!asc:true;col=n;page=1;paint();table.querySelectorAll('.sarrow').forEach(s=>s.textContent='⇅');let a=th.querySelector('.sarrow');if(a)a.textContent=asc?'▲':'▼';}th.onclick=sort;th.onkeydown=e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();sort();}};});paint();
})();
</script>
<jsp:include page="/views/no-fin.jsp"/>
