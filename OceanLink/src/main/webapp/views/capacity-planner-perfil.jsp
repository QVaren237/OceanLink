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
        response.sendRedirect(request.getContextPath() + "/capacity-planner/panel?action=perfil");
        return;
    }
%>
<jsp:include page="/views/capacity-planner-inicio.jsp" />
<% Usuario perfilPlanner = (Usuario) request.getAttribute("perfilPlanner"); %>
<div class="page-head"><div><h1>Mi perfil</h1><div class="psub">Información de tu cuenta y área de trabajo.</div></div></div>
<div class="card card-pad planner-profile">
    <div class="avatar"><%= h(request.getAttribute("inicialesPlanner")) %></div>
    <div><h2><%= h(request.getAttribute("nombrePlanner")) %></h2><p>Capacity Planner</p>
        <% if (perfilPlanner != null && perfilPlanner.getCorreo() != null) { %><p><%= h(perfilPlanner.getCorreo()) %></p><% } %>
    </div>
</div>
<div><a class="btn btn-outline" href="<%= request.getContextPath() %>/capacity-planner/panel">Volver al panel</a></div>
<jsp:include page="/views/capacity-planner-fin.jsp" />
