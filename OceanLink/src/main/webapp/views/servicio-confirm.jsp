<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%! private String e(Object value) {
    if(value == null) return "";
    return String.valueOf(value).replace("&","&amp;").replace("<","&lt;")
      .replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
} %>
<%@ page import="pe.edu.oceanlink.bean.Servicio" %>
<% Servicio s=(Servicio)request.getAttribute("servicio"); %>
<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Confirmar servicio · OceanLink</title><style>
:root{--teal:#2c8a8d;--dark:#1b365d}*{box-sizing:border-box}body{margin:0;background:#f4f7f6;color:#263946;font-family:'Segoe UI',Arial,sans-serif}header{background:white;padding:18px 5%;border-bottom:1px solid #dce5e5;display:flex;align-items:center;gap:16px}header img{height:42px}nav{margin-left:auto}a{color:var(--teal)}nav a{margin-left:20px}main{max-width:1100px;margin:32px auto;padding:0 20px}section{background:white;border:1px solid #e3ecec;border-radius:12px;padding:24px;margin:20px 0;box-shadow:0 3px 10px #00000006}h1{color:var(--dark)}table{border-collapse:collapse;width:100%}th,td{padding:12px;border-bottom:1px solid #e8eeee;text-align:left}th{background:#f2f7f6}input,select{display:block;width:100%;padding:11px;border:1px solid #bfcfcf;border-radius:7px;margin:8px 0 18px}label{font-weight:600}button,.btn{display:inline-block;background:var(--teal);color:white;border:0;border-radius:7px;padding:10px 17px;cursor:pointer;text-decoration:none}button:hover,.btn:hover{background:#1b6264;color:white}.muted{color:#687f84}.actions{display:flex;gap:10px;align-items:center;flex-wrap:wrap}.inline{display:inline-flex;align-items:center;gap:8px;margin:0}.inline select{width:auto;margin:0}.notice{padding:12px;background:#e8f6f1;border-radius:7px;color:#125b40}footer{padding:18px;text-align:center;color:#607b7e}@media(max-width:700px){table{display:block;overflow:auto}header{flex-wrap:wrap}}
</style></head><body><header><img src="<%=request.getContextPath()%>/assets/logo.png" alt="OceanLink"><strong>OceanLink · Capacity Planner</strong><nav><a href="<%=request.getContextPath()%>/ServicioServlet">Servicios por cliente</a></nav></header>
<main><h1>Confirmar asignación de servicio</h1><section>
<p><strong>Cliente:</strong> <%=e(request.getAttribute("clienteNombre"))%></p>
<p><strong>Ruta:</strong> <%=e(request.getAttribute("rutaNombre"))%></p>
<p><strong>Origen:</strong> <%=e(s.getOrigen())%></p>
<p><strong>Destino:</strong> <%=e(s.getDestino())%></p>
<p><strong>Capacidad contratada:</strong> <%=s.getCapacidadContratada()%> Gbps</p>
<p><strong>Fecha de activación:</strong> <%=s.getFechaActivacion()%></p>
<p><strong>Estado inicial:</strong> Activo</p>
<form method="post" action="<%=request.getContextPath()%>/ServicioServlet?action=guardar">
<input type="hidden" name="cliente" value="<%=s.getIdCliente()%>">
<input type="hidden" name="ruta" value="<%=s.getIdRuta()%>">
<input type="hidden" name="capacidad" value="<%=s.getCapacidadContratada()%>">
<input type="hidden" name="fechaActivacion" value="<%=s.getFechaActivacion()%>">
<div class="actions"><a href="<%=request.getContextPath()%>/ServicioServlet?action=formCrear&amp;cliente=<%=s.getIdCliente()%>">Volver a editar</a><button type="submit">Confirmar y guardar</button></div>
</form></section></main></body></html>