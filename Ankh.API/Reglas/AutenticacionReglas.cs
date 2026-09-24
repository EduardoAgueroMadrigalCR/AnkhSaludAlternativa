using Abstracciones.DA;
using Abstracciones.Excepciones;
using Abstracciones.Modelos;
using Abstracciones.Reglas;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace Reglas
{
    public class AutenticacionReglas : IAutenticacionBC
    {
        private const string MensajeCredenciales = "Usuario o contraseña incorrectos";

        private readonly IConfiguration _configuration;
        private readonly IUsuarioDA _usuarioDA;
        private readonly IContrasenaBC _contrasenaBC;

        public AutenticacionReglas(IConfiguration configuration, IUsuarioDA usuarioDA, IContrasenaBC contrasenaBC)
        {
            _configuration = configuration;
            _usuarioDA = usuarioDA;
            _contrasenaBC = contrasenaBC;
        }

        public async Task<LoginRespuesta> LoginAsync(LoginRequest login)
        {
            var correo = login.CorreoElectronico.Trim();
            var usuario = await _usuarioDA.ObtenerPorCorreoAsync(correo);

            if (usuario == null)
                throw new ReglaNegocioException(StatusCodes.Status401Unauthorized, MensajeCredenciales);

            // RF-08 escenario 2
            if (!usuario.Activo)
                throw new ReglaNegocioException(StatusCodes.Status403Forbidden, "Cuenta desactivada, contacte al administrador");

            // RF-01 escenario 3
            if (usuario.Bloqueado)
                throw new ReglaNegocioException(StatusCodes.Status423Locked,
                    $"La cuenta está bloqueada temporalmente por intentos fallidos. Podrá intentar de nuevo después de las {usuario.BloqueadoHasta:HH:mm}");

            // RF-01 escenario 2
            if (!_contrasenaBC.Verificar(login.Password, usuario.PasswordHash))
            {
                var bloqueado = await _usuarioDA.RegistrarIntentoFallidoAsync(correo);
                if (bloqueado)
                    throw new ReglaNegocioException(StatusCodes.Status423Locked,
                        "Se alcanzó el máximo de intentos fallidos. La cuenta fue bloqueada temporalmente");
                throw new ReglaNegocioException(StatusCodes.Status401Unauthorized, MensajeCredenciales);
            }

            // RF-01 escenario 1 + RF-02: se abre una sesion controlada por inactividad
            var idSesion = Guid.NewGuid();
            await _usuarioDA.RegistrarLoginExitosoAsync(usuario.Id, idSesion);

            return new LoginRespuesta
            {
                ValidacionExitosa = true,
                AccessToken = GenerarToken(usuario, idSesion),
                IdUsuario = usuario.Id,
                Nombre = usuario.Nombre,
                Rol = usuario.Rol,
                DebeCambiarPassword = usuario.DebeCambiarPassword
            };
        }

        private string GenerarToken(Usuario usuario, Guid idSesion)
        {
            var configuracion = _configuration.GetSection("Token").Get<TokenConfiguracion>()
                ?? throw new InvalidOperationException("Falta la sección 'Token' en appsettings.json");

            var llave = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuracion.Key));
            var claims = new List<Claim>
            {
                new Claim("sub", usuario.Id.ToString()),
                new Claim("sid", idSesion.ToString()),
                new Claim("name", usuario.Nombre),
                new Claim("email", usuario.CorreoElectronico),
                new Claim("role", usuario.Rol)
            };

            var token = new JwtSecurityToken(
                configuracion.Issuer,
                configuracion.Audience,
                claims,
                expires: DateTime.UtcNow.AddMinutes(configuracion.Expires),
                signingCredentials: new SigningCredentials(llave, SecurityAlgorithms.HmacSha256));

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
