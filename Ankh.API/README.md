# Ankh – Módulo de Seguridad y Usuarios (RF-01 a RF-08)

## 1. Dónde va cada cosa

```
ANKH/                      <- raíz de tu repositorio
├── Ankh.API/              <- NUEVO (copiar esta carpeta completa)
│   ├── BD/                <- scripts SQL Server
│   ├── Abstracciones/  DA/  Flujo/  Reglas/  Servicios/  API/
├── login.html             <- REEMPLAZA
├── perfil.html            <- REEMPLAZA
├── index.html             <- REEMPLAZA (solo se agregó 1 línea <script>)
├── styles.css             <- REEMPLAZA (se agregaron estilos al final)
├── recuperar.html         <- NUEVO
├── restablecer.html       <- NUEVO
├── usuarios.html          <- NUEVO
└── scripts/ankh-api.js    <- NUEVO
```

## 2. Pasos para ponerlo a funcionar

**A. Base de datos**
1. Abra `Ankh.API/BD/Ankh_BD_Completo.sql` en SSMS (o Azure Data Studio) y ejecútelo completo.
2. Crea la base `AnkhDB`, las tablas, los procedimientos almacenados y los datos iniciales.
   Si la base ya existe con tablas, no hace nada (no borra datos).

**B. Cadena de conexión** (`Ankh.API/API/appsettings.json` → `ConnectionStrings:BDAnkh`)
- Windows con autenticación integrada (como el ejemplo del profe):
  `Data Source=.;Initial Catalog=AnkhDB;Integrated Security=True;Trust Server Certificate=True`
- SQL Server con usuario y contraseña (Mac/Docker, o Windows con `sa`):
  `Data Source=localhost,1433;Initial Catalog=AnkhDB;User Id=sa;Password=SU_CLAVE;Trust Server Certificate=True`

**C. Crear la solución (una sola vez)** – en una terminal dentro de `Ankh.API/`:
```
dotnet new sln -n Ankh.API
dotnet sln add Abstracciones/Abstracciones.csproj DA/DA.csproj Flujo/Flujo.csproj Reglas/Reglas.csproj Servicios/Servicios.csproj API/API.csproj
dotnet build
```
Después, en **Visual Studio**: *Archivo → Abrir → Proyecto o solución → `Ankh.API.sln`*, clic derecho en `API` → *Establecer como proyecto de inicio*, perfil **https**, F5.
Se abre Swagger en `https://localhost:7253/swagger`.

**D. Certificado HTTPS de desarrollo** (si el navegador bloquea las llamadas): `dotnet dev-certs https --trust`

**E. Interfaz web**: abra la carpeta ANKH en VS Code y use *Live Server* (puerto 5500) sobre `login.html`.
Si usa otro puerto, agréguelo en `appsettings.json` → `Cors:Origenes` y `App:UrlFrontend`.
Si la API corre en otro puerto, cambie `API_URL` al inicio de `scripts/ankh-api.js`.

**F. Primer ingreso**: `marina0759@hotmail.com` / `Ankh2026!` → el sistema obliga a cambiar la contraseña.

**G. Correos** (RF-04 y RF-05): mientras `Smtp:Host` esté vacío, el correo NO se envía; se imprime en la consola de la API (ahí verá el enlace de recuperación y la contraseña temporal). Para envío real, llene la sección `Smtp` (Gmail: `smtp.gmail.com`, puerto 587, contraseña de aplicación).

**H. Antes de entregar**: cambie `Token:Key` por una clave propia de 32+ caracteres.

## 3. Qué hace cada RF

| RF | Base de datos (procedimientos) | Endpoint | Pantalla |
|----|-------------------------------|----------|----------|
| RF-01 Login, bloqueo 3 intentos / 15 min | `ObtenerUsuarioLogin`, `RegistrarIntentoFallido`, `RegistrarLoginExitoso` | `POST /api/Autenticacion/login` | `login.html` |
| RF-02 Sesión expira a 10 min, aviso a 30 s | `ValidarSesion`, `CerrarSesion` | `GET /api/Sesion/Estado`, `POST /api/Sesion/Extender`, `POST /api/Autenticacion/logout` | aviso emergente (todas las páginas) |
| RF-03 Cambiar contraseña | `ObtenerUsuarioPorId`, `CambiarPassword` | `PUT /api/Cuenta/Password` | `perfil.html` |
| RF-04 Recuperar contraseña (enlace 30 min) | `SolicitarRecuperacion`, `RestablecerPassword` | `POST /api/Recuperacion/Solicitar` y `/Restablecer` | `recuperar.html`, `restablecer.html` |
| RF-05 Crear usuarios (admin) | `CrearUsuario` | `POST /api/Usuario` | `usuarios.html` |
| RF-06 Asignar roles / acceso por módulo | `CambiarRol`, `VerificarAcceso`, `ObtenerModulosxUsuario` | `PUT /api/Usuario/{id}/Rol`, `GET /api/Acceso/Modulos` | `usuarios.html`, `perfil.html` |
| RF-07 Actualizar perfil | `ActualizarPerfil` | `PUT /api/Cuenta/Perfil` | `perfil.html` |
| RF-08 Desactivar / reactivar cuentas | `DesactivarUsuario`, `ReactivarUsuario` | `PUT /api/Usuario/{id}/Desactivar` y `/Reactivar` | `usuarios.html` |

Todos los mensajes de error son los de sus criterios de aceptación.

## 4. Cómo está estructurado (igual que el ejemplo del profe)

- **Abstracciones**: modelos con validaciones por anotaciones + todas las interfaces.
- **DA**: Dapper llamando procedimientos almacenados (`UsuarioDA`, `SesionDA`, `RecuperacionDA`).
- **Reglas**: lógica de negocio pura: login, hash BCrypt, contraseñas temporales, tokens.
- **Flujo**: orquesta Reglas + DA + Servicios.
- **Servicios**: envío de correo (SMTP).
- **API**: controladores delgados, JWT, Swagger, CORS y un middleware que convierte los errores de negocio y de SQL en respuestas JSON `{ "mensaje": "..." }`.

## 5. Decisiones que debe conocer

- **SQL Server y no MySQL/EF**: el proyecto del curso pide Dapper + procedimientos almacenados y su documento DN01 habla de MySQL, Entity Framework y Razor. Conviene actualizar el DN01 para que coincida con lo que se programó.
- **Contraseñas**: la interfaz manda la contraseña por HTTPS y el servidor la guarda con BCrypt. Nunca se guarda ni se compara en texto plano (el ejemplo del profe comparaba hashes que venían del cliente).
- **Roles**: Administrador (la dueña), Vendedor y Encargado de Inventario, como pide el RF-06. Los módulos por rol están en la tabla `RolesxModulo`.
- **Cuentas nuevas (RF-05)**: el administrador no escribe contraseña; el sistema genera una temporal, la envía por correo y obliga a cambiarla en el primer ingreso.
- **Interfaz**: se quitó "Crear cuenta" del login (las cuentas las crea la administradora) y los campos teléfono/dirección de `perfil.html`, que no forman parte de RF-07. `catalogo.html`, `producto.html` y `pedido.html` no se tocaron.
- **Sesión en el navegador**: el token se guarda en `sessionStorage` (se borra al cerrar la pestaña).
- **No se pudo compilar aquí** (sin .NET en el entorno de trabajo). Si al hacer `dotnet build` aparece algún error, envíeme el mensaje exacto y lo corrijo.

## 6. Para los siguientes módulos

Proteja cada controlador nuevo con el rol que corresponda, por ejemplo:
`[Authorize(Roles = "Administrador,Encargado de Inventario")]`.
Los módulos que ya existen en la tabla `Modulos` son: Usuarios, Productos, Inventario, Ventas y Reportes.

## 7. Módulo de Productos y Categorías

Registrar y editar productos; crear y editar categorías.

**Base de datos**: ejecute `Ankh.API/BD/Productos_Categorias.sql` en SSMS **después** de `Ankh_BD_Completo.sql`.
Es idempotente (se puede correr varias veces sin perder datos). Crea las tablas `Categorias` y `Productos`,
los 8 procedimientos almacenados, asigna los módulos Productos e Inventario al rol *Encargado de Inventario*
(el script completo no lo hacía) y carga las 5 categorías y 5 productos que hoy están fijos en `index.js`.
Los mismos objetos están por separado en `BD/dbo/Tables` y `BD/dbo/Stored Procedures`.

| Acción | Procedimiento | Endpoint | Pantalla |
|--------|---------------|----------|----------|
| Listar / ver categorías | `ListarCategorias`, `ObtenerCategoriaPorId` | `GET /api/Categoria`, `GET /api/Categoria/{id}` | `categorias.html` |
| Crear categoría | `CrearCategoria` | `POST /api/Categoria` | `categorias.html` |
| Editar categoría (nombre, descripción, activa) | `ActualizarCategoria` | `PUT /api/Categoria/{id}` | `categorias.html` |
| Listar / ver productos | `ListarProductos`, `ObtenerProductoPorId` | `GET /api/Producto`, `GET /api/Producto/{id}` | `productos.html` |
| Registrar producto | `CrearProducto` | `POST /api/Producto` | `productos.html` |
| Editar producto (incluye activar/desactivar) | `ActualizarProducto` | `PUT /api/Producto/{id}` | `productos.html` |

**Permisos**: consultar lo puede hacer cualquier usuario con sesión (el Vendedor consulta productos);
crear y editar solo *Administrador* y *Encargado de Inventario* (`RolesAcceso.GestionCatalogo`).
`categorias.html` es solo para esos dos roles; `productos.html` se muestra en modo solo lectura al Vendedor.

**Reglas de negocio** (los mensajes salen de los procedimientos y llegan a la pantalla tal cual):
- El nombre de la categoría y el del producto son obligatorios y únicos.
- El precio debe ser mayor que cero (`DECIMAL(12,2)`).
- Un producto debe pertenecer a una categoría existente; para crearlo o dejarlo activo la categoría debe estar activa.
- No se puede desactivar una categoría que tiene productos activos.
- No hay borrado físico: productos y categorías se desactivan (misma filosofía que los usuarios). Cada alta y cambio queda en `Bitacora`.
- La imagen es una ruta (`images/archivo.jpg`) o una URL `http(s)`; no se suben archivos.

**Pendiente (otro módulo)**: el stock vive en Inventario, y `index.js` / `producto.html` siguen leyendo su
lista fija; los productos creados aquí todavía no se muestran en la tienda pública.
