<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>
<%@ page import="pe.edu.oceanlink.bean.Ruta" %>
<%@ page import="pe.edu.oceanlink.bean.RutaSegmento" %>
<%@ page import="pe.edu.oceanlink.bean.LandingStation" %>
<%!
    // Escape para texto y atributos HTML; nunca insertar datos en JavaScript inline.
    private String h(Object valor) {
        return valor == null ? "" : valor.toString().replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    if (request.getAttribute("titulo") == null) {
        response.sendRedirect(request.getContextPath() + "/capacity-planner/panel?action=sesionCerrada");
        return;
    }
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<div class="card center-state"><h1>Sesión cerrada</h1><p>La sesión de este navegador ha finalizado.</p><a class="btn btn-outline" href="<%= request.getContextPath() %>/capacity-planner/panel">Volver al panel</a></div>
<jsp:include page="/views/capacity-planner-fin.jsp" />
