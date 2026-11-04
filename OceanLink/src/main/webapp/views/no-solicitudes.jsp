<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.*" %>
<%!
 private String h(Object v) { return v==null?"—":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;"); }
 private String pill(String v) {
   if ("Rechazada".equals(v)) return "pill-crit";
   if (Arrays.asList("Aprobada","Reservada","Activa","Provisionada").contains(v)) return "pill-ok";
   return "pill-warn";
 }
%>
<% String ctx=request.getContextPath(); %>
<% request.setAttribute("tituloNO","Solicitudes de capacidad");request.setAttribute("seccionNO","solicitudes");
ArrayList<SolicitudCapacidad> lista=(ArrayList<SolicitudCapacidad>)request.getAttribute("lista");if(lista==null)lista=new ArrayList<>();
%>
<jsp:include page="/views/no-inicio.jsp"/>
<div class="page-head"><div><h1>Solicitudes de capacidad</h1><div class="psub">Consulta las solicitudes enviadas al Capacity Planner.</div></div><div class="grow"></div><a class="btn btn-primary" href="<%=ctx%>/NetworkOperatorServlet?action=nuevaSolicitud">+ Nueva solicitud</a></div><div class="card"><div class="card-pad table-toolbar"><div class="usearch-box table-search"><span class="usearch-ic"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span><input id="sol-search" type="search" placeholder="Buscar por solicitud, enlace o motivo..."></div><select class="input" aria-label="Filtrar por estado"><option value="">Todos los estados</option><option>Registrada</option><option>En evaluación</option><option>Pendiente por capacidad</option><option>Aprobada</option><option>Reservada</option><option>Provisionada</option><option>Cancelada</option><option>Rechazada</option></select></div><div class="table-wrap"><table data-no-table><thead><tr><th class="sortable">Solicitud <span class="sarrow">▲</span></th><th class="sortable">Enlace <span class="sarrow">▲</span></th><th class="sortable">Capacidad <span class="sarrow">▲</span></th><th class="sortable">Motivo <span class="sarrow">▲</span></th><th class="sortable">Estado <span class="sarrow">▲</span></th><th>Acción</th></tr></thead><tbody><% for(SolicitudCapacidad so:lista){ %><tr data-row data-estado="<%=h(so.getEstado())%>"><td class="u-name"><%=h(so.getCodigo())%></td><td><%=h(so.getRuta())%><br><small><%=h(so.getCliente())%></small></td><td><strong><%=so.getCapacidadSolicitada()%> Gbps</strong></td><td><%=h(so.getMotivo())%></td><td><span class="pill <%=pill(so.getEstado())%>"><span class="dot"></span><%=h(so.getEstado())%></span></td><td><a class="btn btn-outline btn-sm btn-eye" title="Ver solicitud" aria-label="Ver solicitud" href="<%=ctx%>/NetworkOperatorServlet?action=detalleSolicitud&amp;id=<%=so.getIdSolicitud()%>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2.5 12s3.5-5 9.5-5 9.5 5 9.5 5-3.5 5-9.5 5-9.5-5-9.5-5Z"/><circle cx="12" cy="12" r="2.5"/></svg></a></td></tr><% } %></tbody></table></div><nav class="pagination" aria-label="Paginación"></nav></div><script>
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
