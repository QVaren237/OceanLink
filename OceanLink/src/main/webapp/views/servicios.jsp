<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Servicio" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ArrayList<Servicio> lista = (ArrayList<Servicio>) request.getAttribute("lista");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <title>Lista de Servicios</title>
</head>
<body>
    <div class='container mt-5'>
        <h1 class='mb-3'>Lista de Servicios en OceanLink</h1>
        <a class="btn btn-primary mb-3" href="<%=request.getContextPath()%>/ServicioServlet?action=formCrear">Crear Servicio</a>

        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Descripción</th>
                    <th>Precio</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <% for (Servicio s : lista) { %>
                <tr>
                    <td><%=s.getIdServicio()%></td>
                    <td><%=s.getNombre()%></td>
                    <td><%=s.getDescripcion()%></td>
                    <td><%=s.getPrecio()%></td>
                    <td>
                        <a href="<%=request.getContextPath()%>/ServicioServlet?action=editar&id=<%=s.getIdServicio()%>" class="btn btn-warning btn-sm">Editar</a>
                        <a href="<%=request.getContextPath()%>/ServicioServlet?action=borrar&id=<%=s.getIdServicio()%>" class="btn btn-danger btn-sm" onclick="return confirm('¿Seguro que deseas borrar?');">Borrar</a>
                    </td>
                </tr>
                <%  }  %>
            </tbody>
        </table>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
</body>
</html>