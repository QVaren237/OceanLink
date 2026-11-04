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
<% Map<?,?> b=(Map<?,?>)request.getAttribute("borradorMC"); %>

            <div class="card card-pad mc-ref-10">
                <h2 class="mc-ref-11">Confirmar Cambio de Estado</h2>
                <p class="mc-ref-12">Por favor, revisa que la información del cambio de fase sea correcta antes de registrarla en la bitácora.</p>
                
                <div class="mc-ref-13">
                    <div class="mc-ref-14">
                        <span class="mc-ref-15">Intervención:</span>
                        <strong class="mc-ref-16"><%=h(m.getCodigo())%></strong>
                        
                        <span class="mc-ref-17">Estado Anterior:</span>
                        <span class="pill pill-warn mc-ref-18"><span class="dot"></span><%=h(b.get("anterior"))%></span>

                        <span class="mc-ref-19">Nuevo Estado:</span>
                        <span class="pill pill-ok mc-ref-20"><span class="dot"></span><%=h(b.get("nuevoEstado"))%></span>
                        
                        <span class="mc-ref-21">Justificación:</span>
                        <span class="mc-ref-22"><%=h(b.get("justificacion"))%></span>
                    </div>
                </div>

                <div class="form-actions mc-ref-23">
                    <a href="<%=base%>?action=estado&amp;id=<%=m.getIdMantenimiento()%>" class="btn btn-outline">Editar Datos</a>
                    <form method="post" action="<%=base%>"><input type="hidden" name="action" value="confirmar"><input type="hidden" name="id" value="<%=m.getIdMantenimiento()%>"><input type="hidden" name="token" value="<%=h(b.get("token"))%>"><button type="submit" class="btn btn-primary">Confirmar Cambio</button></form>
                </div>
            </div>
        
<jsp:include page="/views/mc-fin.jsp"/>
