<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Restablecer contraseña - OceanLink</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #eaf7f7;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }

        .contenedor {
            background: white;
            width: 380px;
            padding: 35px;
            border: 2px solid #00b5a5;
            border-radius: 22px;
            text-align: center;
        }

        h1 { color: #173d45; }

        input {
            width: 100%;
            box-sizing: border-box;
            padding: 13px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 10px;
        }

        button {
            width: 100%;
            padding: 14px;
            margin-top: 15px;
            background: #079da5;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: bold;
            cursor: pointer;
        }

        .error { color: #c62828; }
        .mensaje { color: #168044; }
        a { color: #078c96; }
    </style>
</head>
<body>

<div class="contenedor">

    <h1>Restablecer contraseña</h1>

    <% if (request.getAttribute("error") != null) { %>
    <p class="error">
        <%= request.getAttribute("error") %>
    </p>
    <% } %>

    <% if (request.getAttribute("mensaje") != null) { %>
    <p class="mensaje">
        <%= request.getAttribute("mensaje") %>
    </p>
    <a href="${pageContext.request.contextPath}/LoginServlet">
        Volver al inicio de sesión
    </a>

    <% } else if (request.getAttribute("token") != null) { %>

    <p>Ingresa tu nueva contraseña.</p>

    <form action="${pageContext.request.contextPath}/RestablecerPasswordServlet"
          method="post">

        <input type="hidden" name="token"
               value="<%= request.getAttribute("token") %>">

        <input type="password" name="password"
               placeholder="Nueva contraseña"
               minlength="8" maxlength="256" required>

        <input type="password" name="confirmarPassword"
               placeholder="Confirmar nueva contraseña"
               minlength="8" maxlength="256" required>

        <button type="submit">Cambiar contraseña</button>
    </form>

    <% } %>

</div>

<script src="${pageContext.request.contextPath}/js/validacion-auto.js"></script>
</body>
</html>
