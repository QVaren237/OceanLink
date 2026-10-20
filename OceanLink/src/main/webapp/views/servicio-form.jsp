<%@ page import="pe.edu.oceanlink.bean.Servicio" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Servicio servicio = (Servicio) request.getAttribute("servicio");
    boolean esEditar = (servicio != null);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" crossorigin="anonymous">
    <title><%= esEditar ? "Editar" : "Crear" %> Servicio</title>
</head>
<body>
    <div class='container mt-5'>
        <div class="row justify-content-center">
            <div class="col-md-6">
                <h1 class='mb-3'><%= esEditar ? "Editar Servicio" : "Crear un nuevo servicio" %></h1>

                <form method="POST" action="<%=request.getContextPath()%>/ServicioServlet?action=guardar">

                    <% if(esEditar){ %>
                        <input type="hidden" name="idServicio" value="<%=servicio.getIdServicio()%>">
                    <% } %>

                    <div class="form-group mb-3">
                        <label for="nombre" class="form-label">Nombre del servicio</label>
                        <input type="text" class="form-control" name="nombre" id="nombre" value="<%= esEditar ? servicio.getNombre() : "" %>" required>
                    </div>

                    <div class="form-group mb-3">
                        <label for="descripcion" class="form-label">Descripción</label>
                        <textarea class="form-control" name="descripcion" id="descripcion" rows="3" required><%= esEditar ? servicio.getDescripcion() : "" %></textarea>
                    </div>

                    <div class="form-group mb-4">
                        <label for="precio" class="form-label">Precio</label>
                        <input type="number" step="0.01" class="form-control" name="precio" id="precio" value="<%= esEditar ? servicio.getPrecio() : "" %>" required>
                    </div>

                    <a href="<%=request.getContextPath()%>/ServicioServlet" class="btn btn-danger">Regresar</a>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
</body>
</html>