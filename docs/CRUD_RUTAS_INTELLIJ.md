# CRUD de rutas en IntelliJ

## Rama preparada

La rama local `Crud-CapacityPlanner` parte de `origin/crud-landing-segmento-usuarios`
(nombre real de la rama de infraestructura, con «usuarios» en plural).
Incluye estaciones, segmentos, usuarios y las modificaciones de esa rama.
No hace falta fusionarla de nuevo ni copiar sus archivos manualmente.

Los cambios locales previos de los tres DAO y de IntelliJ se conservaron.
Hay además un respaldo llamado `Respaldo local antes de Crud-CapacityPlanner` en Git stash.
No apliques ese stash nuevamente sobre esta rama: sus cambios ya fueron restaurados.

Para repetir el proceso en otra copia limpia del repositorio, desde la terminal de IntelliJ:

```powershell
git fetch origin
git switch --no-track -c Crud-CapacityPlanner origin/crud-landing-segmento-usuarios
```

Si la copia tiene trabajo pendiente, guárdalo antes de cambiar de rama y recupéralo después.
En esta copia la rama ya existe: basta comprobar `git branch --show-current`.

## Archivos y patrón del curso

Se utiliza la estructura de las PPT 6.5 JDBC, 7.2 MVC y 7.3 CRUD:

1. `bean/Ruta.java`: datos de ruta y datos del JOIN para mostrarlos.
2. `bean/RutaSegmento.java`: composición de la ruta y datos del segmento.
3. `dao/RutaDAO.java`: consultas y operaciones JDBC con PreparedStatement y cierre de recursos.
4. `servlet/RutaServlet.java`: `doGet`, `doPost`, `switch(action)`, atributos de request, forward y redirect.
5. `webapp/views/`: listado, formulario, detalle y vistas de Capacity Planner, con fragmentos JSP compartidos.
6. `webapp/css/styles.css`: todos los estilos. El JavaScript de búsqueda, paginación y orden del recorrido está dentro de `rutas.jsp` y `ruta-form.jsp`.

No se agregaron frameworks ni dependencias al POM.
El aspecto reutiliza `css/styles.css`, el logo, colores y tipografía de los HTML de Capacity Planner.
Las JSP se abren mediante el Servlet. Si una vista de Capacity Planner se abre directamente sin sus datos, redirige al controlador correspondiente.

## Preparar MySQL

La base `oceanlink` debe existir con las tablas del script `OceanLink_DB_FIXED.sql`.
Este módulo no necesita cambiar el esquema: escribe en `ruta` y `ruta_segmento`.
Consulta también `landing_station`, `segmento`, `servicio` y `solicitud`.

Si la base ya existe, no es necesario ejecutar nuevamente todo el script.
Comprueba que tenga estaciones y segmentos antes de crear una ruta.

En `RutaDAO.abrirConexion()`, ajusta `user`, `pass` y `url` a tu instalación local de MySQL.
La configuración inicial usa `root`/`root`, igual que los ejemplos de clase.
No incluyas tu contraseña personal al hacer commit.

Ejemplos de los datos de prueba del script:

- Manta → Lima → Arica: `SEG-MAN-LIM`, seguido de `SEG-LIM-ARI`.
- Guayaquil → Manta → Lima: `SEG-GYE-MAN`, seguido de `SEG-MAN-LIM`.
- Arica → Antofagasta → Valparaíso: debe guardarse como `No operativa`, por el estado de sus tramos.

## Ejecutar en IntelliJ

1. Comprueba que el selector de Git indique `Crud-CapacityPlanner`. Si no se actualiza, sincroniza los archivos desde disco.
2. En la ventana Maven, recarga el proyecto asociado a `OceanLink/pom.xml`.
3. Usa el SDK Amazon Corretto 17 que ya tienes instalado.
4. Ejecuta Maven → Lifecycle → `package`.
5. Abre Run → Edit Configurations → tu configuración de Tomcat 10.1.61.
6. En Deployment, comprueba el artefacto `OceanLink:war exploded` y su Application context.
   Si usas Smart Tomcat, verifica su Deployment directory y Context path equivalentes.
7. Inicia MySQL y ejecuta Tomcat. Tras agregar clases Java o nuevas JSP, realiza un Redeploy.
8. Si el contexto es `/OceanLink`, abre `http://localhost:8080/OceanLink/capacity-planner/panel`.
   Si IntelliJ tiene otro contexto, sustituye `/OceanLink` por ese valor.
9. Selecciona Rutas en el menú propio de Capacity Planner. El acceso directo es
   `http://localhost:8080/OceanLink/capacity-planner/rutas`. El menú del Administrador no contiene este módulo.

## Qué probar

- Registrar una ruta con código único, nombre, extremos distintos y al menos un segmento.
- Ver el detalle, los tramos ordenados y la capacidad disponible del recorrido.
- Buscar por código/nombre/extremos, filtrar por estado, ordenar y cambiar de página.
- Editar datos, agregar/quitar segmentos y cambiar su orden.
- Abrir la advertencia de desactivación, cancelarla y comprobar que conserva el estado.
- Confirmar Desactivar para pasar de Operativa a No operativa mediante POST.
- Verificar que desactivar conserve la ruta, sus segmentos, servicios y solicitudes.
- Rechazar códigos duplicados, segmentos repetidos, recorridos desconectados o con ciclos.
- Rechazar un destino que no coincida con el final del recorrido.
- Permitir recorrer un cable en cualquiera de sus dos sentidos.
- Rechazar una ruta Operativa con tramos en mantenimiento o fuera de servicio.
- Impedir cambiar el recorrido de una ruta con servicios o solicitudes asociados.
- Mostrar deshabilitado el botón Desactivar cuando la ruta ya está No operativa.
- Ante un error de MySQL, mostrar el error sin anunciar un guardado exitoso.

El formulario valida en el navegador y el DAO vuelve a validar en el servidor.
Los cambios de ruta y sus tramos se confirman juntos mediante una transacción JDBC;
si falla una sentencia se ejecuta rollback, para evitar registros parciales.

`ruta_segmento.capacidadRuta` conserva la capacidad total del tramo al componer la ruta,
como en los INSERT de ejemplo. No representa capacidad consumida ni reservada.
El CRUD de rutas no modifica la capacidad utilizada o reservada de `segmento`.
Los módulos de servicios y reservas deberán hacerlo al implementar sus propias reglas.

La capacidad disponible del recorrido es el mínimo de las capacidades disponibles de
sus segmentos; la disponibilidad operativa se comprueba por separado.

La protección por usuario y rol deberá conectarse al módulo de autenticación del equipo.
El texto «Capacity Planner» identifica el área de las vistas; no autentica al visitante.

## Comprobación de recorridos sin MySQL

Desde la carpeta que contiene el POM, con Java 17 y Maven configurados:

```powershell
mvn test-compile
java -cp "target/classes;target/test-classes" pe.edu.oceanlink.dao.RutaRecorridoCheck
```

Esta verificación cubre recorridos directos e inversos, desconexiones, ciclos, duplicados,
destinos incorrectos, estados y límites de campos. Se ejecuta explícitamente con `java`;
no utiliza un motor de pruebas adicional.

Verificaciones realizadas al preparar esta implementación:

- Maven `package`: compilación y generación del WAR correctas con Java 17.
- Compilador JSP de Tomcat 10.1.61: los 19 JSP del proyecto, incluidos los fragmentos compartidos, compilan sin errores.
- JavaScript: comprobación de sintaxis correcta.
- Validador de recorridos: 14 comprobaciones correctas.
- JDBC/MySQL: 15 comprobaciones correctas del panel, estados de solicitud, umbral
  crítico mayor al 95%, desactivación, rechazo de operaciones repetidas y conservación
  de rutas, segmentos, servicios y solicitudes. Se utilizó un esquema temporal que se
  eliminó al terminar, sin modificar `oceanlink`.

Estas verificaciones no sustituyen la prueba visual y del flujo desde tu configuración de IntelliJ.

## Subir tu trabajo desde IntelliJ

Los cambios están preparados localmente, sin commit ni push automático.

1. Abre Commit y selecciona los archivos nuevos del CRUD, este documento y los archivos del panel propio de Capacity Planner.
2. Revisa aparte las modificaciones previas de los tres DAO y las de `.idea`: no son parte del CRUD de rutas.
3. Comprueba que no se incluyan contraseñas personales, archivos `target` ni configuraciones locales del IDE.
4. Crea el commit, por ejemplo: `Implementa CRUD de rutas para Capacity Planner`.
5. Abre Git → Push y publica `Crud-CapacityPlanner` en `origin`.
   Desde la terminal, el equivalente es `git push -u origin Crud-CapacityPlanner`.

La integración posterior de `Crud_Servicios` se debe coordinar con su responsable;
esa rama no fue fusionada en esta implementación.

## Separación de las vistas por rol

Todas las vistas están directamente en `webapp/views/`. El panel, perfil y fragmentos
del planificador usan nombres con prefijo `capacity-planner-`; las vistas del CRUD son
`rutas.jsp`, `ruta-form.jsp` y `ruta-detalle.jsp`. `CapacityPlannerServlet` gestiona el panel y `RutaServlet`
el CRUD. Los enlaces de este menú permanecen dentro de `/capacity-planner/`.
La dirección antigua `/RutaServlet` se conserva como alias por compatibilidad.

El encabezado usa el diseño de `CapacityPlanner/panel.html`: avatar, nombre, rol y menú
de perfil. Cuando exista autenticación, el equipo puede guardar un Bean Usuario en
`session.setAttribute("usuarioSesion", usuario)`; el encabezado mostrará sus datos.
Mientras no exista esa sesión, se utiliza el nombre de la maqueta (Gerson García).
Mi perfil es una consulta y Cerrar sesión invalida la sesión del navegador. La integración
del login y de los permisos sigue correspondiendo al módulo de autenticación.

Los enlaces de servicios, capacidad, solicitudes, alertas e histórico están habilitados
y apuntan a direcciones propias bajo `/capacity-planner/`. Hasta implementar sus
controladores o páginas, esas direcciones devolverán 404, tal como se solicitó.
Todos los JSP de este rol declaran UTF-8 explícitamente. Los fragmentos son
`capacity-planner-inicio.jsp` y `capacity-planner-fin.jsp`, incluidos mediante
`<jsp:include>`, como se muestra en la PPT 7.2. Los datos compartidos usan
atributos de request: no se comparten variables locales entre páginas incluidas.

Sólo existe `webapp/css/styles.css`. No se utilizan archivos JSPF ni una carpeta
para JavaScript. El menú del planificador sigue separado del Administrador, aunque
las vistas conviven en el mismo directorio, diferenciadas por su nombre.

## Verificación de la reorganización de vistas

Se comprobó el WAR después de `clean package`: contiene únicamente `css/styles.css`,
los JSP están en `views` (además del `index.jsp` original de entrada) y no incluye
archivos JSPF, una carpeta js ni las ubicaciones anteriores de las vistas.
En el navegador se verificaron el panel, la búsqueda del listado, la selección de
estaciones y segmentos, la confirmación del formulario y el perfil. La revisión del
formulario se canceló antes de guardar, sin insertar datos de prueba en oceanlink.

## Panel original y desactivación de rutas

El panel sigue el HTML `CapacityPlanner/panel.html`: los cuatro indicadores, buscador,
tabla de cliente/servicio/enlace/capacidad/estado y paginación. Los datos se consultan
mediante JDBC y viajan en `PanelCapacityPlanner` y `ServicioResumen`.
El indicador ACTIVOS cuenta clientes activos; los enlaces monitoreados son todos los
segmentos registrados. Pendientes incluye Registrada, En evaluación y Pendiente por
capacidad. Crítico significa capacidad utilizada / total mayor que 95%, excluyendo
totales cero. La cartera muestra una fila por servicio y segmento de su ruta; un servicio
con varios tramos puede aparecer en varias filas. Ver cartera completa muestra todas
las filas del panel sin dirigir a vistas de Administrador.

En Rutas se usan iconos de ojo, lápiz y apagado con etiquetas accesibles. El apagado
abre un diálogo con Cancelar y Sí, desactivar. Confirmar envía `action=desactivar` por
POST; `RutaDAO.desactivarRuta()` actualiza únicamente `ruta.estado`. No hay eliminación
física de rutas ni acción eliminar disponible en el controlador. Para volver a Operativa
puede utilizarse Editar, respetando las validaciones de infraestructura existentes.

Se verificaron en navegador la búsqueda y paginación del panel, los iconos, el diálogo
con el nombre de la ruta y la cancelación sin cambios. La persistencia de la desactivación
se probó en un esquema temporal separado de los datos del proyecto.
