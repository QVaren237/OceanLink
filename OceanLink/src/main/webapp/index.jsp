<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirigir automáticamente al panel de administrador al entrar a la raíz
    response.sendRedirect(request.getContextPath() + "/PanelServlet");
%>