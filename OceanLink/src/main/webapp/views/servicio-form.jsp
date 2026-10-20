<%@ page import="pe.edu.oceanlink.bean.Servicio" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Servicio servicio = (Servicio) request.getAttribute("servicio");
    boolean esEditar = (servicio != null);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEditar ? "Editar" : "Nuevo" %> Servicio - OceanLink</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --sidebar-width: 250px;
            --primary-teal: #2c8a8d;
            --bg-light: #f4f7f6;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-light);
            margin: 0;
            display: flex;
        }

        .sidebar {
            width: var(--sidebar-width);
            height: 100vh;
            background-color: #ffffff;
            position: fixed;
            top: 0;
            left: 0;
            border-right: 1px solid #e0e0e0;
            display: flex;
            flex-direction: column;
            z-index: 100;
        }

        .sidebar-brand {
            padding: 20px;
            display: flex;
            align-items: center;
        }

        .sidebar-brand img {
            height: 45px;
        }

        .sidebar-menu {
            list-style: none;
            padding: 10px 0;
            margin: 0;
        }

        .sidebar-menu li a {
            display: flex;
            align-items: center;
            padding: 12px 25px;
            color: #555;
            text-decoration: none;
            font-weight: 500;
            gap: 12px;
        }

        .sidebar-menu li a:hover, .sidebar-menu li.active a {
            color: var(--primary-teal);
            background-color: #eef7f7;
            border-left: 4px solid var(--primary-teal);
        }

        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: 20px 40px;
        }

        .top-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background-color: #d1e7dd;
            color: #0f5132;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .card-custom {
            background: #ffffff;
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            padding: 30px;
            max-width: 650px;
            margin: 0 auto;
        }

        .btn-teal {
            background-color: var(--primary-teal);
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 6px;
        }

        .btn-teal:hover {
            background-color: #236f71;
            color: white;
        }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-brand">
            <img src="<%=request.getContextPath()%>/CapacityPlanner/Capacidad/assets/logo.png" alt="OceanLink Logo" onerror="this.src='https://via.placeholder.com/150x50?text=OceanLink'">
        </div>
        <ul class="sidebar-menu">
            <li><a href="#"><i class="fa-solid fa-chart-line"></i> Dashboard</a></li>
            <li><a href="#"><i class="fa-solid fa-network-wired"></i> Capacidad</a></li>
            <li class="active"><a href="<%=request.getContextPath()%>/ServicioServlet"><i class="fa-solid fa-server"></i> Servicios</a></li>
            <li><a href="#"><i class="fa-solid fa-users"></i> Clientes</a></li>
            <li><a href="#"><i class="fa-solid fa-bell"></i> Alertas</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <header class="top-header">
            <div>
                <span class="text-muted small">OceanLink / Capacity Planner / Servicios</span>
                <h2 class="fw-bold mb-0 mt-1"><%= esEditar ? "Editar Servicio" : "Registrar Servicio" %></h2>
            </div>
            <div class="user-profile">
                <div class="avatar">SA</div>
                <div>
                    <div class="fw-bold text-dark" style="font-size: 0.9rem;">Sebastian Arce</div>
                    <small class="text-muted" style="font-size: 0.75rem;">Capacity Planner</small>
                </div>
            </div>
        </header>

        <section class="card-custom">
            <h5 class="fw-bold mb-3"><%= esEditar ? "Formulario de Edición" : "Datos del Nuevo Servicio" %></h5>

            <form method="POST" action="<%=request.getContextPath()%>/ServicioServlet?action=guardar">

                <% if(esEditar) { %>
                    <input type="hidden" name="idServicio" value="<%=servicio.getIdServicio()%>">
                <% } %>

                <div class="mb-3">
                    <label for="nombre" class="form-label fw-semibold">Nombre del Servicio</label>
                    <input type="text" class="form-control" name="nombre" id="nombre" placeholder="Ej: Ancho de Banda Dedicado 10Gbps" value="<%= esEditar ? servicio.getNombre() : "" %>" required>
                </div>

                <div class="mb-3">
                    <label for="descripcion" class="form-label fw-semibold">Descripción</label>
                    <textarea class="form-control" name="descripcion" id="descripcion" rows="3" placeholder="Detalle técnico o alcance del servicio..." required><%= esEditar ? servicio.getDescripcion() : "" %></textarea>
                </div>

                <div class="mb-4">
                    <label for="precio" class="form-label fw-semibold">Precio ($)</label>
                    <input type="number" step="0.01" class="form-control" name="precio" id="precio" placeholder="0.00" value="<%= esEditar ? servicio.getPrecio() : "" %>" required>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="<%=request.getContextPath()%>/ServicioServlet" class="btn btn-light px-4">Cancelar</a>
                    <button type="submit" class="btn btn-teal"><i class="fa-solid fa-floppy-disk me-1"></i> Guardar Servicio</button>
                </div>
            </form>
        </section>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>