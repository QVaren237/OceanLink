<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
 private String esc(String s) {
     if(s==null)return "—";
     return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
 }
%>
<%
 @SuppressWarnings("unchecked")
 java.util.ArrayList<pe.edu.oceanlink.bean.SupervisorEvento> eventos =
     (java.util.ArrayList<pe.edu.oceanlink.bean.SupervisorEvento>)request.getAttribute("eventos");
 if(eventos==null){response.sendRedirect(request.getContextPath()+"/supervisor/incidencias");return;}
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Seguimiento de Fallas · OceanLink</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/supervisor.css">
<style>
  /* Nuevo color para la gravedad Media basado en la imagen */
  .pill-media { background: #e6e0f8; color: #434493; }
  .pill-media .dot { background: #8a7ab9; }
</style>
</head>
<body>
<div class="shell">
  <jsp:include page="/views/supervisor-sidebar.jsp">
    <jsp:param name="moduloSupervisor" value="incidencias" />
  </jsp:include>
  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Supervisor</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0" aria-label="Perfil de usuario">
        <div class="avatar"><%= pe.edu.oceanlink.util.Vista.iniciales(session) %></div>
        <div class="uinfo"><div class="un"><%= pe.edu.oceanlink.util.Vista.nombre(session) %></div><div class="ur">Supervisor</div></div>
        <span class="ucaret" aria-hidden="true">▾</span>
        <div class="usermenu"><a href="#">Editar perfil</a><a href="<%= request.getContextPath() %>/sesion-cerrada.jsp">Cerrar sesión</a></div>
      </div>
    </div>
    <div class="content">
      <div class="page-head">
        <div>
          <h1>Fallas y Mantenimientos</h1>
          <div class="psub">Revisa el impacto en clientes provocado por eventos en la red.</div>
        </div>
      </div>
      
      <div class="card">
        <!-- Bloque de filtros en línea -->
        <div class="card-pad" style="border-bottom: 1px solid var(--line); display: flex; gap: 14px; align-items: center;">
          <div class="usearch-box" style="flex: 1; max-width: 420px; min-width: 320px;">
            <span class="usearch-ic"><svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg></span>
            <input id="usearch" placeholder="Buscar por tramo o ID...">
          </div>
          
          <div style="width: 220px;">
            <select id="severityFilter" class="input" style="height: 38px; cursor: pointer;">
              <option value="all">Todas las gravedades</option>
              <option value="Crítica">Crítica</option>
              <option value="Alta">Alta</option>
              <option value="Media">Media</option>
              <option value="Baja">Baja</option>
            </select>
          </div>
        </div>

        <div class="table-wrap">
          <table id="utable">
            <thead>
              <tr>
                <th class="sortable" data-col="0">ID Evento <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="1">Tipo <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="2">Tramo <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="3">Gravedad <span class="sarrow">⇅</span></th>
                <th class="sortable" data-col="4">Estado <span class="sarrow">⇅</span></th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody id="eventBody">
<% if(eventos.isEmpty()) { %>
<tr class="empty-row"><td colspan="6" style="text-align:center;padding:28px;color:var(--muted)">No hay incidencias ni mantenimientos registrados.</td></tr>
<% } else { for(pe.edu.oceanlink.bean.SupervisorEvento e : eventos) {
 String sev=e.getGravedad();
 String pill="pill-ok";
 if("Crítica".equalsIgnoreCase(sev)||"Critica".equalsIgnoreCase(sev)) pill="pill-crit";
 else if("Alta".equalsIgnoreCase(sev)) pill="pill-warn";
 else if("Media".equalsIgnoreCase(sev)) pill="pill-media";
%>
<tr>
<td data-sort="<%=esc(e.getCodigo())%>"><strong><%=esc(e.getCodigo())%></strong></td>
<td><%=esc(e.getTipo())%></td><td><%=esc(e.getTramo())%></td>
<td data-sort="<%=sev==null ? "" : esc(sev)%>">
<% if(sev==null || sev.isBlank()){ %>—<% }else{ %><span class="pill <%=pill%>"><span class="dot"></span><%=esc(sev)%></span><% } %></td>
<td><%=esc(e.getEstado())%></td>
<td><div class="actions"><button type="button" class="btn-icon" title="Ver clientes afectados" data-clave="<%=esc(e.getClave())%>" data-codigo="<%=esc(e.getCodigo())%>" data-tramo="<%=esc(e.getTramo())%>" onclick="abrirModal(this)">
<svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
</button></div></td>
</tr>
<% } } %>
</tbody>
          </table>
        </div>
        
        <!-- Paginación -->
        <div class="pagination" id="eventPagination" aria-label="Páginas de eventos"></div>

      </div>
    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<!-- Modal de clientes asociados a la infraestructura de este evento -->
<div class="modal-back" id="modalAfectacion" role="dialog" aria-modal="true" aria-labelledby="tituloAfectados">
  <div class="modal" style="width:600px;max-width:94vw;">
    <h3 id="tituloAfectados">Clientes Afectados</h3>
    <p>Tramo involucrado: <strong id="tramoModal"></strong></p>
    <div class="table-wrap" id="clientesAfectados" style="margin-top:15px;border:1px solid var(--line);border-radius:9px;">Consultando...</div>
    <div class="form-actions" style="margin-top:20px;text-align:right;"><button type="button" class="btn btn-primary" onclick="cerrarModal()">Cerrar revisión</button></div>
  </div>
</div>
<script>
const endpoint = '<%=request.getContextPath()%>/supervisor/afectados';
function abrirModal(button) {
 const modal=document.getElementById('modalAfectacion');
 document.getElementById('tituloAfectados').textContent='Clientes Afectados ('+button.dataset.codigo+')';
 document.getElementById('tramoModal').textContent=button.dataset.tramo;
 const target=document.getElementById('clientesAfectados');target.textContent='Consultando...';
 modal.classList.add('open');
 const clave=button.dataset.clave;
 fetch(endpoint+'?clave='+encodeURIComponent(clave),{credentials:'same-origin'})
   .then(r=>{if(!r.ok)throw Error('No se pudo consultar');return r.text();})
   .then(markup=>{if(modal.classList.contains('open') && document.getElementById('tituloAfectados').textContent.includes(button.dataset.codigo))target.innerHTML=markup;})
   .catch(()=>target.textContent='No fue posible consultar los clientes afectados.');
}
function cerrarModal(){document.getElementById('modalAfectacion').classList.remove('open');}
document.getElementById('modalAfectacion').addEventListener('click',e=>{if(e.target.id==='modalAfectacion')cerrarModal();});
document.addEventListener('keydown',e=>{if(e.key==='Escape')cerrarModal();});
(function(){
 const table=document.getElementById('utable'), body=document.getElementById('eventBody'), q=document.getElementById('usearch'), sev=document.getElementById('severityFilter'), pagination=document.getElementById('eventPagination');
 const rows=Array.from(body.rows).filter(r=>!r.classList.contains('empty-row'));
 let page=1,col=-1,asc=true;const size=5;
 function update(){
  const query=q.value.trim().toLocaleLowerCase('es'); const severity=sev.value;
  const filtered=rows.filter(r=>r.innerText.toLocaleLowerCase('es').includes(query) && (severity==='all' || (r.cells[3].dataset.sort||'')===severity));
  if(col>=0)filtered.sort((a,b)=>{const x=a.cells[col].dataset.sort||a.cells[col].innerText,y=b.cells[col].dataset.sort||b.cells[col].innerText;return (asc?1:-1)*x.localeCompare(y,'es',{numeric:true});});
  rows.forEach(r=>r.style.display='none');
  const pages=Math.max(1,Math.ceil(filtered.length/size));page=Math.min(page,pages);
  filtered.slice((page-1)*size,page*size).forEach(r=>{body.appendChild(r);r.style.display='';});
  pagination.replaceChildren();
  if(rows.length===0 || filtered.length===0)return;
  function btn(text,target,disabled,active){const b=document.createElement('button');b.type='button';b.className='page-btn'+(active?' active':'');b.textContent=text;b.disabled=disabled;b.addEventListener('click',()=>{page=target;update();});pagination.appendChild(b);}
  btn('‹',page-1,page===1,false);
  const candidates=[1,page-1,page,page+1,pages].filter(n=>n>=1&&n<=pages);const nums=[...new Set(candidates)].sort((a,b)=>a-b);let last=0;
  nums.forEach(n=>{if(n-last>1){const sp=document.createElement('span');sp.className='page-ellipsis';sp.textContent='…';pagination.appendChild(sp);}btn(String(n),n,false,n===page);last=n;});
  btn('›',page+1,page===pages,false);
 }
 q.addEventListener('input',()=>{page=1;update();});sev.addEventListener('change',()=>{page=1;update();});
 table.querySelectorAll('th.sortable').forEach(th=>th.addEventListener('click',()=>{const n=+th.dataset.col;if(col===n)asc=!asc;else{col=n;asc=true;}table.querySelectorAll('th.sortable').forEach(h=>h.querySelector('.sarrow').textContent=+h.dataset.col===col?(asc?'▲':'▼'):'⇅');page=1;update();}));
 update();
})();
</script>
</body>
</html>
