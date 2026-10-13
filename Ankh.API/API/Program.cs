using Abstracciones.DA;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Abstracciones.Reglas;
using Abstracciones.Servicios;
using API.Middleware;
using DA;
using DA.Repositorios;
using Flujo;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Reglas;
using Servicios;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

var tokenConfiguracion = builder.Configuration.GetSection("Token").Get<TokenConfiguracion>()
    ?? throw new InvalidOperationException("Falta la sección 'Token' en appsettings.json");

// ---------- Autenticacion JWT + control de sesion por inactividad (RF-01 / RF-02) ----------
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
{
    options.MapInboundClaims = false;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = tokenConfiguracion.Issuer,
        ValidAudience = tokenConfiguracion.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenConfiguracion.Key)),
        ClockSkew = TimeSpan.Zero,
        NameClaimType = "name",
        RoleClaimType = "role"
    };

    options.Events = new JwtBearerEvents
    {
        // Cada peticion valida la sesion en la BD y reinicia el contador de inactividad.
        // /api/Sesion/Estado solo consulta, para que el "polling" del aviso no mantenga viva la sesion.
        OnTokenValidated = async contexto =>
        {
            var claimSesion = contexto.Principal?.FindFirst("sid")?.Value;
            if (!Guid.TryParse(claimSesion, out var idSesion))
            {
                contexto.Fail("Sesión inválida");
                return;
            }

            var sesionFlujo = contexto.HttpContext.RequestServices.GetRequiredService<ISesionFlujo>();
            var refrescar = !contexto.HttpContext.Request.Path.StartsWithSegments("/api/Sesion/Estado", StringComparison.OrdinalIgnoreCase);
            var estado = await sesionFlujo.ObtenerEstadoAsync(idSesion, refrescar);
            if (!estado.Valida)
                contexto.Fail("La sesión expiró por inactividad");
        },
        OnChallenge = contexto =>
        {
            contexto.HandleResponse();
            contexto.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return contexto.Response.WriteAsJsonAsync(new { mensaje = "La sesión expiró o no es válida. Inicie sesión de nuevo" });
        },
        OnForbidden = contexto =>
        {
            contexto.Response.StatusCode = StatusCodes.Status403Forbidden;
            return contexto.Response.WriteAsJsonAsync(new { mensaje = "No tiene permisos para esta acción" });
        }
    };
});
builder.Services.AddAuthorization();

// ---------- Controladores: errores de validacion (anotaciones) en formato { mensaje, errores } ----------
builder.Services.AddControllers().ConfigureApiBehaviorOptions(opciones =>
{
    opciones.InvalidModelStateResponseFactory = contexto =>
    {
        var errores = contexto.ModelState.Values
            .SelectMany(v => v.Errors)
            .Select(e => e.ErrorMessage)
            .Where(m => !string.IsNullOrWhiteSpace(m))
            .Distinct()
            .ToList();
        return new BadRequestObjectResult(new { mensaje = errores.FirstOrDefault() ?? "Datos inválidos", errores });
    };
});

// ---------- Swagger con boton "Authorize" para pegar el JWT ----------
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(opciones =>
{
    opciones.SwaggerDoc("v1", new OpenApiInfo { Title = "Ankh API", Version = "v1" });
    opciones.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Pegue el accessToken devuelto por POST /api/Autenticacion/login"
    });
    opciones.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } },
            Array.Empty<string>()
        }
    });
});

// ---------- Inyeccion de dependencias ----------
builder.Services.AddScoped<IRepositorioDapper, RepositorioDapper>();
builder.Services.AddScoped<IUsuarioDA, UsuarioDA>();
builder.Services.AddScoped<ISesionDA, SesionDA>();
builder.Services.AddScoped<IRecuperacionDA, RecuperacionDA>();
builder.Services.AddScoped<ICategoriaDA, CategoriaDA>();
builder.Services.AddScoped<IProductoDA, ProductoDA>();

builder.Services.AddScoped<IContrasenaBC, ContrasenaReglas>();
builder.Services.AddScoped<IAutenticacionBC, AutenticacionReglas>();

builder.Services.AddScoped<IAutenticacionFlujo, AutenticacionFlujo>();
builder.Services.AddScoped<ISesionFlujo, SesionFlujo>();
builder.Services.AddScoped<IUsuarioFlujo, UsuarioFlujo>();
builder.Services.AddScoped<IRecuperacionFlujo, RecuperacionFlujo>();
builder.Services.AddScoped<ICategoriaFlujo, CategoriaFlujo>();
builder.Services.AddScoped<IProductoFlujo, ProductoFlujo>();

builder.Services.AddScoped<ICorreoServicio, CorreoServicio>();
builder.Services.AddTransient<ManejadorExcepcionesMiddleware>();

// ---------- CORS para la interfaz web ----------
var origenes = builder.Configuration.GetSection("Cors:Origenes").Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(opciones =>
{
    opciones.AddPolicy("InterfazWeb", politica =>
        politica.WithOrigins(origenes).AllowAnyMethod().AllowAnyHeader());
});

var app = builder.Build();

app.UseMiddleware<ManejadorExcepcionesMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("InterfazWeb");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
