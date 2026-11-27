<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Activar cuenta · OceanLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css?v=3">
</head>
<body>

<div class="auth">
    <div class="auth-card" style="border:2px solid #14b8a6">

        <div class="brand brand-auth">
            <img class="brand-img"
                 src="${pageContext.request.contextPath}/assets/logo.png"
                 alt="OceanLink">
        </div>

        <% if (request.getAttribute("exito") != null) { %>

        <h1>¡Cuenta activada!</h1>

        <div style="margin:16px 0;background:#d1fae5;color:#065f46;padding:14px;border-radius:8px">
            <%= request.getAttribute("exito") %>
        </div>

        <a class="btn btn-primary"
           style="width:100%;justify-content:center"
           href="${pageContext.request.contextPath}/login.jsp">
            Ir a iniciar sesión
        </a>

        <% } else if (Boolean.TRUE.equals(request.getAttribute("tokenValido"))) { %>

        <h1>Activa tu cuenta</h1>
        <p class="sub">
            Crea una contraseña para comenzar a utilizar OceanLink.
        </p>

        <% if (request.getAttribute("error") != null) { %>
        <div style="margin:0 0 14px;background:#f3c3c8;color:#9e1b2b;padding:10px 12px;border-radius:8px;font-size:14px">
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form novalidate action="${pageContext.request.contextPath}/activar-cuenta"
              method="post">

            <input type="hidden" name="token" value="<%= request.getAttribute("token") %>">

            <div class="field">
                <label>Nueva contraseña</label>
                <input class="input"
                       type="password"
                       name="password"
                       minlength="8"
                       maxlength="256"
                       placeholder="Mínimo 8 caracteres"
                       required>
            </div>

            <div class="field">
                <label>Confirmar contraseña</label>
                <input class="input"
                       type="password"
                       name="confirmarPassword"
                       minlength="8"
                       maxlength="256"
                       placeholder="Repite tu contraseña"
                       required>
            </div>

            <button class="btn btn-primary"
                    type="submit"
                    style="width:100%;justify-content:center">
                Activar mi cuenta
            </button>
        </form>

        <% } else { %>

        <h1>Enlace no disponible</h1>

        <div style="margin:16px 0;background:#f3c3c8;color:#9e1b2b;padding:14px;border-radius:8px">
            <%= request.getAttribute("error") != null
                    ? request.getAttribute("error")
                    : "No se puede utilizar este enlace de activación." %>
        </div>

        <a class="btn btn-primary"
           style="width:100%;justify-content:center"
           href="${pageContext.request.contextPath}/LoginServlet">
            Volver al inicio de sesión
        </a>

        <% } %>

    </div>
</div>

</body>
</html>
