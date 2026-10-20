<%@ page import="java.util.ArrayList" %>
<%@ page import="pe.edu.oceanlink.bean.Servicio" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ArrayList<Servicio> lista = (ArrayList<Servicio>) request.getAttribute("lista");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servicios - OceanLink</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --sidebar-width: 250px;
            --primary-teal: #2c8a8d;
            --primary-dark: #1b365d;
            --bg-light: #f4f7f6;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-light);
            margin: 0;
            display: flex;
        }

        /* Sidebar Styles */
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
            gap: 10px;
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
            transition: all 0.2s;
        }

        .sidebar-menu li a:hover, .sidebar-menu li.active a {
            color: var(--primary-teal);
            background-color: #eef7f7;
            border-left: 4px solid var(--primary-teal);
        }

        /* Main Content */
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
            padding-bottom: 15px;
        }

        .breadcrumb-text {
            color: #888;
            font-size: 0.9rem;
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

        /* Cards & Tables */
        .card-custom {
            background: #ffffff;
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.03);
            padding: 25px;
        }

        .btn-teal {
            background-color: var(--primary-teal);
            color: white;
            border: none;
            padding: 8px 18px;
            border-radius: 6px;
        }

        .btn-teal:hover {
            background-color: #236f71;
            color: white;
        }

        .table custom th {
            color: #6c757d;
            font-weight: 600;
            border-bottom-width: 1px;
        }
    </style>
</head>
<body>

    <!-- Sidebar Capacity Planner -->
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

    <!-- Content Area -->
    <main class="main-content">
        <header class="top-header">
            <div>
                <span class="breadcrumb-text">OceanLink / Capacity Planner</span>
                <h2 class="fw-bold mb-0 mt-1">Gestión de Servicios</h2>
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
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h5 class="fw-bold mb-1">Lista de Servicios Disponibles</h5>
                    <p class="text-muted small mb-0">Catálogo general de servicios de capacidad y red de OceanLink</p>
                </div>
                <a href="<%=request.getContextPath()%>/ServicioServlet?action=formCrear" class="btn btn-teal">
                    <i class="fa-solid fa-plus me-1"></i> Nuevo Servicio
                </a>
            </div>

            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Nombre del Servicio</th>
                            <th>Descripción</th>
                            <th>Precio</th>
                            <th class="text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (lista != null && !lista.isEmpty()) {
                                for (Servicio s : lista) {
                        %>
                        <tr>
                            <td class="fw-bold">#<%=s.getIdServicio()%></td>
                            <td><span class="fw-semibold text-dark"><%=s.getNombre()%></span></td>
                            <td class="text-secondary"><%=s.getDescripcion()%></td>
                            <td class="fw-bold text-dark">$<%=String.format("%.2f", s.getPrecio())%></td>
                            <td class="text-center">
                                <a href="<%=request.getContextPath()%>/ServicioServlet?action=editar&id=<%=s.getIdServicio()%>" class="btn btn-sm btn-outline-primary me-1" title="Editar">
                                    <i class="fa-solid fa-pen"></i>
                                </a>
                                <a href="<%=request.getContextPath()%>/ServicioServlet?action=borrar&id=<%=s.getIdServicio()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Está seguro de eliminar este servicio?');" title="Eliminar">
                                    <i class="fa-solid fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-folder-open mb-2 fs-3 d-block"></i> No hay servicios registrados.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>