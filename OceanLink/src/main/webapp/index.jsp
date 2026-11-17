<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // La aplicación ahora arranca en el LOGIN.
    // Cada usuario, al iniciar sesión, entra automáticamente a la vista de su rol.
    response.sendRedirect(request.getContextPath() + "/LoginServlet");
%>
