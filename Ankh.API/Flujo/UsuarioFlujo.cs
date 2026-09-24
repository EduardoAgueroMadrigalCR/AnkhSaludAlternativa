using Abstracciones.DA;
using Abstracciones.Excepciones;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Abstracciones.Reglas;
using Abstracciones.Servicios;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System.Net;

namespace Flujo
{
    public class UsuarioFlujo : IUsuarioFlujo
    {
        private readonly IUsuarioDA _usuarioDA;
        private readonly IContrasenaBC _contrasenaBC;
        private readonly ICorreoServicio _correoServicio;
        private readonly IConfiguration _configuration;

        public UsuarioFlujo(IUsuarioDA usuarioDA, IContrasenaBC contrasenaBC, ICorreoServicio correoServicio, IConfiguration configuration)
        {
            _usuarioDA = usuarioDA;
            _contrasenaBC = contrasenaBC;
            _correoServicio = correoServicio;
            _configuration = configuration;
        }

        // RF-05
        public async Task<ResultadoCrearUsuario> CrearAsync(UsuarioCrear usuario, Guid idAdmin)
        {
            var nombre = usuario.Nombre.Trim();
            var correo = usuario.CorreoElectronico.Trim();
            var passwordTemporal = _contrasenaBC.GenerarTemporal();

            var id = await _usuarioDA.CrearAsync(nombre, correo, _contrasenaBC.Hashear(passwordTemporal), usuario.IdRol, idAdmin);

            var urlFrontend = _configuration["App:UrlFrontend"];
            var cuerpo = $"<p>Hola {WebUtility.HtmlEncode(nombre)},</p>" +
                         "<p>Se creó su cuenta en el sistema de Macrobiótica Ankh.</p>" +
                         $"<p><b>Usuario:</b> {WebUtility.HtmlEncode(correo)}<br/><b>Contraseña temporal:</b> {passwordTemporal}</p>" +
                         $"<p>Ingrese en <a href=\"{urlFrontend}/login.html\">{urlFrontend}/login.html</a> y cambie la contraseña en su primer acceso.</p>";
            var enviado = await _correoServicio.EnviarAsync(correo, "Acceso al sistema Ankh", cuerpo);

            return new ResultadoCrearUsuario { Id = id, CorreoEnviado = enviado };
        }

        public async Task<IEnumerable<Usuario>> ListarAsync() => await _usuarioDA.ListarAsync();

        public async Task<IEnumerable<Rol>> ListarRolesAsync() => await _usuarioDA.ListarRolesAsync();

        // RF-06
        public async Task CambiarRolAsync(Guid idUsuario, int idRol, Guid idAdmin)
            => await _usuarioDA.CambiarRolAsync(idUsuario, idRol, idAdmin);

        public async Task<bool> TieneAccesoAsync(Guid idUsuario, string modulo)
            => await _usuarioDA.TieneAccesoAsync(idUsuario, modulo);

        public async Task<IEnumerable<string>> ObtenerModulosAsync(Guid idUsuario)
            => await _usuarioDA.ObtenerModulosAsync(idUsuario);

        // RF-08
        public async Task DesactivarAsync(Guid idUsuario, Guid idAdmin)
            => await _usuarioDA.DesactivarAsync(idUsuario, idAdmin);

        public async Task ReactivarAsync(Guid idUsuario, Guid idAdmin)
            => await _usuarioDA.ReactivarAsync(idUsuario, idAdmin);

        // RF-07
        public async Task<Usuario> ObtenerPerfilAsync(Guid idUsuario)
        {
            return await _usuarioDA.ObtenerPorIdAsync(idUsuario)
                ?? throw new ReglaNegocioException(StatusCodes.Status404NotFound, "El usuario no existe");
        }

        public async Task ActualizarPerfilAsync(Guid idUsuario, PerfilActualizar perfil)
        {
            await _usuarioDA.ActualizarPerfilAsync(idUsuario, perfil.Nombre.Trim(), perfil.CorreoElectronico.Trim());
        }

        // RF-03
        public async Task CambiarPasswordAsync(Guid idUsuario, Guid idSesion, CambioPasswordRequest solicitud)
        {
            var usuario = await ObtenerPerfilAsync(idUsuario);

            if (!_contrasenaBC.Verificar(solicitud.PasswordActual, usuario.PasswordHash))
                throw new ReglaNegocioException(StatusCodes.Status400BadRequest, "La contraseña actual no es correcta");

            if (_contrasenaBC.Verificar(solicitud.NuevaPassword, usuario.PasswordHash))
                throw new ReglaNegocioException(StatusCodes.Status400BadRequest, "La nueva contraseña debe ser distinta a la actual");

            await _usuarioDA.CambiarPasswordAsync(idUsuario, _contrasenaBC.Hashear(solicitud.NuevaPassword), idSesion);
        }
    }
}
