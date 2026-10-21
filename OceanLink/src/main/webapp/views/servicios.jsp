<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%! private String e(Object value) {
    if(value == null) return "";
    return String.valueOf(value).replace("&","&amp;").replace("<","&lt;")
      .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
} %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.Servicio" %>
<%
List<Map<String,Object>> clientes=(List<Map<String,Object>>)request.getAttribute("clientes");
List<Servicio> lista=(List<Servicio>)request.getAttribute("lista");
Integer clienteId=(Integer)request.getAttribute("clienteId");
String clienteNombre=(String)request.getAttribute("clienteNombre");
%>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Clientes y servicios · OceanLink</title><style>
:root{--teal:#2c8a8d;--dark:#1b365d}*{box-sizing:border-box}body{margin:0;background:#f4f7f6;color:#263946;font-family:'Segoe UI',Arial,sans-serif}header{background:white;padding:18px 5%;border-bottom:1px solid #dce5e5;display:flex;align-items:center;gap:16px}header img{height:42px}nav{margin-left:auto}a{color:var(--teal)}nav a{margin-left:20px}main{max-width:1100px;margin:32px auto;padding:0 20px}section{background:white;border:1px solid #e3ecec;border-radius:12px;padding:24px;margin:20px 0;box-shadow:0 3px 10px #00000006}h1{color:var(--dark)}table{border-collapse:collapse;width:100%}th,td{padding:12px;border-bottom:1px solid #e8eeee;text-align:left}th{background:#f2f7f6}input,select{display:block;width:100%;padding:11px;border:1px solid #bfcfcf;border-radius:7px;margin:8px 0 18px}label{font-weight:600}button,.btn{display:inline-block;background:var(--teal);color:white;border:0;border-radius:7px;padding:10px 17px;cursor:pointer;text-decoration:none}button:hover,.btn:hover{background:#1b6264;color:white}.muted{color:#687f84}.actions{display:flex;gap:10px;align-items:center;flex-wrap:wrap}.inline{display:inline-flex;align-items:center;gap:8px;margin:0}.inline select{width:auto;margin:0}.notice{padding:12px;background:#e8f6f1;border-radius:7px;color:#125b40}footer{padding:18px;text-align:center;color:#607b7e}@media(max-width:700px){table{display:block;overflow:auto}header{flex-wrap:wrap}}
</style></head><body><header><img src="<%=request.getContextPath()%>/assets/logo.png" alt="OceanLink"><strong>OceanLink · Capacity Planner</strong><nav><a href="<%=request.getContextPath()%>/ServicioServlet">Servicios por cliente</a></nav></header>
<main><h1><%=clienteId==null?"Clientes":"Información del cliente: "+e(clienteNombre)%></h1>
<% if(clienteId==null){ %>
<section><h2>Servicios por cliente</h2><p class="muted">Selecciona un cliente para consultar sus servicios contratados.</p>
<input type="search" id="buscar" placeholder="Buscar cliente por nombre" oninput="buscarClientes(this.value)">
<table id="tablaClientes"><thead><tr><th>ID</th><th>Razón social</th><th>Acciones</th></tr></thead><tbody>
<% if(clientes!=null)for(Map<String,Object> c:clientes){ %><tr><td><%=c.get("id")%></td><td><%=e(c.get("nombre"))%></td><td><a class="btn" href="<%=request.getContextPath()%>/ServicioServlet?action=detalle&amp;cliente=<%=c.get("id")%>">Ver servicios</a></td></tr><% } %>
</tbody></table></section>
<script>function buscarClientes(q){document.querySelectorAll('#tablaClientes tbody tr').forEach(tr=>tr.hidden=!tr.textContent.toLowerCase().includes(q.toLowerCase()));}</script>
<% }else{ %>
<div class="actions"><a href="<%=request.getContextPath()%>/ServicioServlet">← Volver a clientes</a>
<a class="btn" href="<%=request.getContextPath()%>/ServicioServlet?action=formCrear&amp;cliente=<%=clienteId%>">+ Asignar nuevo servicio</a></div>
<% if(request.getParameter("creado")!=null){ %><p class="notice">El servicio se guardó correctamente (ID <%=e(request.getParameter("creado"))%>).</p><% } %>
<% if(request.getParameter("actualizado")!=null){ %><p class="notice">El estado del servicio fue actualizado.</p><% } %>
<section><h2>Servicios contratados</h2><input type="search" placeholder="Buscar servicio" oninput="document.querySelectorAll('#tablaServicios tbody tr').forEach(r=>r.hidden=!r.textContent.toLowerCase().includes(this.value.toLowerCase()))">
<table id="tablaServicios"><thead><tr><th>ID servicio</th><th>Origen</th><th>Destino</th><th>Capacidad (Gbps)</th><th>Fecha de activación</th><th>Estado</th><th>Acción</th></tr></thead><tbody>
<% if(lista!=null)for(Servicio s:lista){ %>
<tr><td><%=e(s.getCodigo())%></td><td><%=e(s.getOrigen())%></td><td><%=e(s.getDestino())%></td><td><%=s.getCapacidadContratada()%></td><td><%=s.getFechaActivacion()%></td><td><%=e(s.getEstado())%></td><td>
<form method="post" action="<%=request.getContextPath()%>/ServicioServlet?action=estado" class="inline">
<input type="hidden" name="idServicio" value="<%=s.getIdServicio()%>"><input type="hidden" name="cliente" value="<%=clienteId%>">
<select name="estado" aria-label="Nuevo estado del servicio">
<option value="Activo" <%= "Activo".equals(s.getEstado())?"selected":"" %>>Activo</option>
<option value="Suspendido" <%= "Suspendido".equals(s.getEstado())?"selected":"" %>>Suspendido</option>
<option value="Cancelado" <%= "Cancelado".equals(s.getEstado())?"selected":"" %>>Cancelado</option>
</select><button type="submit">Guardar estado</button></form>
</td></tr><% } %>
<% if(lista==null||lista.isEmpty()){ %><tr><td colspan="7">Este cliente aún no tiene servicios registrados.</td></tr><% } %>
</tbody></table></section>
<% } %></main><footer>OceanLink · Gestión de servicios</footer></body></html>