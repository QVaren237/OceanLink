<%@ page contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="pe.edu.oceanlink.bean.Usuario" %>

<%!
    private String h(Object valor) {
        return valor == null ? "" : valor.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String iniciales(Usuario u) {
        if (u == null) return "US";

        String nombre = u.getNombre() == null ? "" : u.getNombre().trim();
        String apellido = u.getApellido() == null ? "" : u.getApellido().trim();

        String resultado = "";

        if (!nombre.isEmpty()) {
            resultado += nombre.substring(0, 1);
        }

        if (!apellido.isEmpty()) {
            resultado += apellido.substring(0, 1);
        }

        return resultado.isEmpty() ? "US" : resultado.toUpperCase();
    }
%>

<%
    Usuario cuenta = (Usuario) request.getAttribute("cuenta");

    if (cuenta == null) {
        response.sendRedirect(
                request.getContextPath() + "/LoginServlet"
        );
        return;
    }

    String ctx = request.getContextPath();

    String nombreRol = (String) request.getAttribute("nombreRol");

    String urlPanel = (String) request.getAttribute("urlPanel");

    String fotoPerfil = (String) request.getAttribute("fotoPerfil");
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>OceanLink · Editar mi usuario</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">

    <link rel="preconnect"
          href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@500;600;700;800&display=swap"
          rel="stylesheet">

    <link rel="stylesheet"
          href="<%=ctx%>/css/styles.css">
</head>

<body class="no-shell profile-edit-page">

<main class="profile-edit-main">

    <header class="topbar profile-edit-topbar">
        <div class="crumb">
            OceanLink / <%=h(nombreRol)%>
        </div>
    </header>

    <section class="profile-edit-content">

        <div class="profile-edit-head">
            <div>
                <p class="eyebrow">CUENTA</p>

                <h1>Editar mi usuario</h1>

                <div class="psub">
                    Actualiza los datos de tu cuenta.
                </div>
            </div>
        </div>

        <% if(request.getAttribute("error") != null) { %>

        <div class="banner banner-err" role="alert">
            <%=h(request.getAttribute("error"))%>
        </div>

        <% } %>

        <% if("1".equals(request.getParameter("guardado"))) { %>

        <div class="info-strip" role="status">
            Perfil actualizado correctamente.
        </div>

        <% } %>

        <section class="profile-edit-card">

            <form action="<%=ctx%>/PerfilServlet"
                  method="post"
                  enctype="multipart/form-data"
                  class="profile-edit-form">

                <input type="hidden"
                       name="quitarFoto"
                       id="quitarFoto"
                       value="false">

                <div class="profile-edit-left">

                    <label class="field-label">
                        Nombre <span class="required-mark">*</span>

                        <input class="input"
                               type="text"
                               name="nombre"
                               maxlength="50"
                               value="<%=h(cuenta.getNombre())%>"
                               required>
                    </label>

                    <label class="field-label">
                        Apellido <span class="required-mark">*</span>

                        <input class="input"
                               type="text"
                               name="apellido"
                               maxlength="50"
                               value="<%=h(cuenta.getApellido())%>"
                               required>
                    </label>

                    <label class="field-label">
                        Correo electrónico
                        <span class="required-mark">*</span>

                        <input class="input"
                               type="email"
                               name="correo"
                               maxlength="50"
                               value="<%=h(cuenta.getCorreo())%>"
                               required>
                    </label>

                    <div class="field-label">
                        Mi contraseña actual
                        <span class="required-mark">*</span>

                        <div class="password-field">

                            <input class="password-input input"
                                   id="current-password"
                                   type="password"
                                   name="claveActual"
                                   autocomplete="current-password"
                                   required>
                        </div>
                    </div>

                    <div class="field-label">
                        Contraseña nueva

                        <div class="password-field">

                            <input class="password-input input"
                                   id="new-password"
                                   type="password"
                                   name="nuevaPassword"
                                   maxlength="256"
                                   autocomplete="new-password"
                                   placeholder="Ingresa una nueva contraseña">
                        </div>
                    </div>

                    <div class="field-label">
                        Confirmar contraseña

                        <div class="password-field">

                            <input class="password-input input"
                                   id="confirm-password"
                                   type="password"
                                   name="confirmarPassword"
                                   maxlength="256"
                                   autocomplete="new-password"
                                   placeholder="Repite la nueva contraseña">
                        </div>
                    </div>

                    <label class="field-label">
                        Cambio de rol

                        <input class="input"
                               type="text"
                               value="<%=h(nombreRol)%>"
                               disabled>
                    </label>

                    <div class="profile-edit-divider"></div>

                    <div class="profile-edit-actions">

                        <a class="btn btn-outline"
                           href="<%=h(urlPanel)%>">
                            Cancelar
                        </a>

                        <button class="btn btn-primary"
                                type="submit">
                            Aceptar
                        </button>

                    </div>

                </div>

                <div class="profile-edit-image">

                    <div class="profile-photo-placeholder"
                         id="fotoIniciales"
                            <%=fotoPerfil != null ? "hidden" : ""%>>

                        <span><%=h(iniciales(cuenta))%></span>

                    </div>

                    <img class="no-profile-photo"
                         id="fotoVista"
                         alt="Foto de perfil"
                        <%=fotoPerfil == null
                            ? "hidden"
                            : "src=\"" + h(fotoPerfil) + "\""%>>

                    <div class="profile-image-actions">

                        <label class="btn btn-primary"
                               for="fotoArchivo">
                            Editar imagen
                        </label>

                        <input id="fotoArchivo"
                               name="foto"
                               type="file"
                               accept="image/png,image/jpeg"
                               hidden>

                        <button class="btn btn-outline"
                                type="button"
                                id="quitarImagen">
                            Quitar
                        </button>

                    </div>

                    <p>
                        Foto de perfil del usuario.
                        Formato JPG o PNG, máximo 2 MB.
                    </p>

                </div>

            </form>

        </section>

    </section>

    <footer class="appfoot profile-edit-footer">
        <span>OceanLink · Centro de operaciones</span>
    </footer>

</main>

<script>

    const archivo = document.getElementById("fotoArchivo");

    const vista = document.getElementById("fotoVista");

    const iniciales = document.getElementById("fotoIniciales");

    const quitarFoto = document.getElementById("quitarFoto");

    let preview;

    archivo.addEventListener("change", () => {

        const f = archivo.files[0];

        if (!f) return;

        if (f.size > 2097152 ||
            !["image/jpeg", "image/png"].includes(f.type)) {

            archivo.value = "";

            alert("Selecciona una imagen JPG o PNG de hasta 2 MB.");

            return;
        }

        if (preview) {
            URL.revokeObjectURL(preview);
        }

        preview = URL.createObjectURL(f);

        vista.src = preview;

        vista.hidden = false;

        iniciales.hidden = true;

        quitarFoto.value = "false";

    });

    document.getElementById("quitarImagen").addEventListener("click", () => {

        archivo.value = "";

        vista.hidden = true;

        iniciales.hidden = false;

        quitarFoto.value = "true";

    });

    document.querySelector(".profile-edit-form").addEventListener("submit", (e) => {

        const nueva = document.getElementById("new-password").value;

        const confirmar = document.getElementById("confirm-password").value;

        if (nueva !== confirmar) {

            e.preventDefault();

            alert("Las contraseñas nuevas no coinciden.");

        }

    });

</script>

</body>
</html>

