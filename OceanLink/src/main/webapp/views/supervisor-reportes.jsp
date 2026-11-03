<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
 private String esc(String s){if(s==null)return "—";return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
 @SuppressWarnings("unchecked")
 java.util.ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila> filas=(java.util.ArrayList<pe.edu.oceanlink.bean.SupervisorReporteFila>) request.getAttribute("filasReporte");
 if(filas==null){response.sendRedirect(request.getContextPath()+"/supervisor/reportes");return;}
 String tipo=(String)request.getAttribute("tipoReporte");
 String inicio=(String)request.getAttribute("fechaInicio");
 String fin=(String)request.getAttribute("fechaFin");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Reportes Históricos · OceanLink</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/supervisor.css">
</head>
<body>
<div class="shell">
  <aside class="side">
    <div class="brand brand-side"><img class="brand-img" src="<%=request.getContextPath()%>/assets/logo.png" alt="Ocean Link Logistics"></div>
    <nav class="nav-sec">
      <div class="nav-label">Módulos</div>
      <a class="nav-item" href="<%=request.getContextPath()%>/supervisor/panel">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
        <span>Panel</span>
      </a>
      <a class="nav-item" href="<%=request.getContextPath()%>/supervisor/incidencias">
        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <span>Fallas y Mantenimientos</span>
      </a>
      <a class="nav-item active" href="<%=request.getContextPath()%>/supervisor/reportes">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        <span>Reportes Históricos</span>
      </a>
    </nav>
    <div class="side-foot">
      <div class="role-badge">
        <div class="rl">Rol activo</div>
        <div class="rn"><span class="dot"></span>Supervisor</div>
      </div>
    </div>
  </aside>
  <div class="main">
    <div class="topbar">
      <div class="crumb">OceanLink / Supervisor</div>
      <div class="grow"></div>
      <div class="userpill" tabindex="0" aria-label="Perfil de Sebastian Arce">
        <div class="avatar">SA</div>
        <div class="uinfo"><div class="un">Sebastian Arce</div><div class="ur">Supervisor</div></div>
        <span class="ucaret" aria-hidden="true">▾</span>
        <div class="usermenu"><a href="#">Editar perfil</a><a href="#">Cerrar sesión</a></div>
      </div>
    </div>
    <div class="content">
      <div class="page-head">
        <div>
          <h1>Reportes de Gestión</h1>
          <div class="psub">Genera y descarga informes operativos utilizando filtros combinados.</div>
        </div>
      </div>
      
      <form method="get" action="<%=request.getContextPath()%>/supervisor/reportes" class="card card-pad" style="margin-bottom: 20px;">
        <div class="form-grid">
          <div class="field"><label for="filterType">Tipo de Informe</label>
            <select id="filterType" name="tipo" class="input">
              <option value="fallas" <%= "fallas".equals(tipo)?"selected":"" %>>Histórico de Fallas</option>
              <option value="capacidad" <%= "capacidad".equals(tipo)?"selected":"" %>>Uso de Capacidad</option>
              <option value="servicios" <%= "servicios".equals(tipo)?"selected":"" %>>Servicios por Cliente</option>
            </select>
          </div>
          <div class="field"><label for="filterStartDate">Fecha de Inicio</label><input type="date" id="filterStartDate" name="inicio" class="input" value="<%=esc(inicio)%>"></div>
          <div class="field"><label for="filterEndDate">Fecha de Fin</label><input type="date" id="filterEndDate" name="fin" class="input" value="<%=esc(fin)%>"></div>
          <div class="field" style="display:flex;align-items:flex-end;"><button type="submit" id="btnFilter" class="btn btn-outline" style="width:100%">Filtrar Datos</button></div>
        </div>
      </form>
      <div style="display:flex;justify-content:flex-end;margin-bottom:15px">
        <a class="btn btn-primary" title="Exportar y Descargar CSV" href="<%=request.getContextPath()%>/supervisor/exportar-csv?tipo=<%=tipo%>&amp;inicio=<%=inicio%>&amp;fin=<%=fin%>">
          <svg viewBox="0 0 24 24" style="width:16px;height:16px;stroke:currentColor;fill:none;stroke-width:2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg> Exportar CSV
        </a>
      </div>
      <div class="card">
        <div class="card-head"><h3 id="tableTitle">Resultados: <%= "capacidad".equals(tipo)?"Uso de Capacidad":("servicios".equals(tipo)?"Servicios por Cliente":"Histórico de Fallas") %></h3></div>
        <div class="table-wrap"><table id="utable"><thead><tr>
        <% String[] heads = "capacidad".equals(tipo) ? new String[]{"Segmento","Fecha Registro","Capacidad Total","Capacidad Disponible","Utilización"} : "servicios".equals(tipo) ? new String[]{"Cliente","Fecha Activación","Servicio","Ruta","Capacidad Contratada"} : new String[]{"ID Evento","Fecha Resolución","Tramo","Impacto Potencial","Estado Final"};
           for(int i=0;i<heads.length;i++){ %>
          <th class="sortable" data-col="<%=i%>"><%=esc(heads[i])%> <span class="sarrow">⇅</span></th>
        <% } %>
        </tr></thead><tbody id="reportBody">
        <% if(filas.isEmpty()){ %><tr class="no-data"><td colspan="5">No se encontraron registros para el informe y período seleccionados.</td></tr>
        <% } else { for(pe.edu.oceanlink.bean.SupervisorReporteFila f:filas){ %>
        <tr><td><strong><%=esc(f.getC1())%></strong></td><td><%=esc(f.getC2())%></td><td><%=esc(f.getC3())%></td><td><%=esc(f.getC4())%></td><td><%=esc(f.getC5())%></td></tr>
        <% } } %>
        </tbody></table></div>
        <div class="pagination" id="reportPagination"></div>
      </div>

    </div>
    <div class="appfoot"><span>OceanLink · Centro de operaciones</span></div>
  </div>
</div>

<script>
(function(){
  const tbody=document.getElementById('reportBody'),pages=document.getElementById('reportPagination');
  let rows=[...tbody.querySelectorAll('tr:not(.no-data)')],page=1,sortCol=-1,asc=true;
  const size=8;
  function paint(){
    const count=Math.ceil(rows.length/size);
    rows.forEach((r,i)=>r.style.display=(i>=((page-1)*size)&&i<page*size)?'':'none');
    pages.replaceChildren();
    if(!count)return;
    function btn(label,n,disabled,active){
      const el=document.createElement('button');el.type='button';el.className='page-btn'+(active?' active':'');el.textContent=label;
      el.disabled=disabled;el.addEventListener('click',()=>{page=n;paint();});pages.appendChild(el);
    }
    btn('‹',Math.max(1,page-1),page===1,false);
    let visible=new Set([1,count,page,page-1,page+1]);let prev=0;
    [...visible].filter(n=>n>=1&&n<=count).sort((a,b)=>a-b).forEach(n=>{
      if(n>prev+1){const dots=document.createElement('span');dots.className='page-ellipsis';dots.textContent='…';pages.appendChild(dots);}
      btn(String(n),n,false,n===page);prev=n;
    });
    btn('›',Math.min(count,page+1),page===count,false);
  }
  document.querySelectorAll('#utable th.sortable').forEach(th=>th.addEventListener('click',()=>{
    const col=Number(th.dataset.col);
    if(col===sortCol)asc=!asc;else{sortCol=col;asc=true;}
    rows.sort((a,b)=>{
      const x=a.cells[col].innerText.trim(),y=b.cells[col].innerText.trim();
      const d=x.localeCompare(y,'es',{numeric:true});return asc?d:-d;
    });
    rows.forEach(r=>tbody.appendChild(r));page=1;
    document.querySelectorAll('#utable th.sortable .sarrow').forEach((s,i)=>s.textContent=(i===col?(asc?'▲':'▼'):'⇅'));
    paint();
  }));
  paint();
})();
</script>
</body></html>
