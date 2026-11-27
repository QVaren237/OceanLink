<%@ page pageEncoding="UTF-8" %>
<% String moduloSupervisor = request.getParameter("moduloSupervisor"); %>
  <aside class="side supervisor-sidebar">
    <div class="brand brand-side"><img class="brand-img" src="<%= request.getContextPath() %>/assets/logo.png" alt="Ocean Link Logistics"></div>
    <nav class="nav-sec" aria-label="Módulos de Supervisor">
      <div class="nav-label">Módulos</div>
      <a class="nav-item<%= "panel".equals(moduloSupervisor) ? " active" : "" %>"<%= "panel".equals(moduloSupervisor) ? " aria-current=\"page\"" : "" %> href="<%= request.getContextPath() %>/supervisor/panel">
        <svg viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
        <span>Panel</span>
      </a>
      <a class="nav-item<%= "incidencias".equals(moduloSupervisor) ? " active" : "" %>"<%= "incidencias".equals(moduloSupervisor) ? " aria-current=\"page\"" : "" %> href="<%=request.getContextPath()%>/supervisor/incidencias">
        <svg viewBox="0 0 24 24"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <span>Fallas y Mantenimientos</span>
      </a>
      <a class="nav-item<%= "reportes".equals(moduloSupervisor) ? " active" : "" %>"<%= "reportes".equals(moduloSupervisor) ? " aria-current=\"page\"" : "" %> href="<%=request.getContextPath()%>/supervisor/reportes">
        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        <span>Reportes Históricos</span>
      </a>
      <a class="nav-item<%= "estadisticas".equals(moduloSupervisor) ? " active" : "" %>"<%= "estadisticas".equals(moduloSupervisor) ? " aria-current=\"page\"" : "" %> href="<%= request.getContextPath() %>/supervisor/estadisticas">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 3v17h17M8 16v-4m5 4V8m5 8V5"/></svg>
        <span>Estadísticas</span>
      </a>
    </nav>
    <div class="side-foot">
      <div class="role-badge">
        <div class="rl">Rol activo</div>
        <div class="rn"><span class="dot"></span>Supervisor</div>
      </div>
    </div>
  </aside>
