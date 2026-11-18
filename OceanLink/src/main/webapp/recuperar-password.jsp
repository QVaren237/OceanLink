<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Recuperar contraseña · OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>

<div class="auth">
    <div class="auth-card" style="border:2px solid #14b8a6">

        <h1>Recuperar contraseña</h1>

        <p class="sub">
            Ingresa tu correo electrónico y te enviaremos
            un enlace para restablecer tu contraseña.
        </p>

        <% if (request.getAttribute("error") != null) { %>
        <div style="margin-bottom:14px;background:#f3c3c8;color:#9e1b2b;padding:10px 12px;border-radius:8px">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <% if (request.getAttribute("mensaje") != null) { %>
        <div style="margin-bottom:14px;background:#d1fae5;color:#065f46;padding:10px 12px;border-radius:8px">
            <%= request.getAttribute("mensaje") %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/RecuperarPasswordServlet"
              method="post">

            <div class="field">
                <label>Correo electrónico</label>
                <input class="input"
                       type="email"
                       name="correo"
                       placeholder="correo@ejemplo.com"
                       required>
            </div>

            <button class="btn btn-primary"
                    type="submit"
                    style="width:100%;justify-content:center">
                Enviar enlace de recuperación
            </button>

        </form>

        <p style="text-align:center;margin-top:20px">
            <a class="link"
               href="${pageContext.request.contextPath}/LoginServlet">
                Volver al inicio de sesión
            </a>
        </p>

    </div>
</div>

</body>
</html>
