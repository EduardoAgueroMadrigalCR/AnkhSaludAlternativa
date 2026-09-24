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
    public class RecuperacionFlujo : IRecuperacionFlujo
    {
        private readonly IRecuperacionDA _recuperacionDA;
        private readonly IContrasenaBC _contrasenaBC;
        private readonly ICorreoServicio _correoServicio;
        private readonly IConfiguration _configuration;

        public RecuperacionFlujo(IRecuperacionDA recuperacionDA, IContrasenaBC contrasenaBC, ICorreoServicio correoServicio, IConfiguration configuration)
        {
            _recuperacionDA = recuperacionDA;
            _contrasenaBC = contrasenaBC;
            _correoServicio = correoServicio;
            _configuration = configuration;
        }

        public async Task SolicitarAsync(RecuperacionSolicitud solicitud)
        {
            var (token, hash) = _contrasenaBC.GenerarTokenRecuperacion();
            var usuario = await _recuperacionDA.SolicitarAsync(solicitud.CorreoElectronico.Trim(), hash);

            var enlace = $"{_configuration["App:UrlFrontend"]}/restablecer.html?token={Uri.EscapeDataString(token)}";
            var cuerpo = $"<p>Hola {WebUtility.HtmlEncode(usuario.Nombre)},</p>" +
                         "<p>Recibimos una solicitud para restablecer su contraseña en el sistema de Macrobiótica Ankh.</p>" +
                         $"<p><a href=\"{enlace}\">Restablecer contraseña</a></p>" +
                         $"<p>El enlace es válido por {usuario.MinutosVigencia} minutos y solo puede usarse una vez. " +
                         "Si usted no lo solicitó, ignore este mensaje.</p>";

            var enviado = await _correoServicio.EnviarAsync(usuario.CorreoElectronico, "Recuperación de contraseña - Ankh", cuerpo);
            if (!enviado)
                throw new ReglaNegocioException(StatusCodes.Status503ServiceUnavailable,
                    "No se pudo enviar el correo de recuperación. Intente de nuevo más tarde");
        }

        public async Task RestablecerAsync(RestablecerPasswordRequest solicitud)
        {
            await _recuperacionDA.RestablecerAsync(
                _contrasenaBC.HashearToken(solicitud.Token),
                _contrasenaBC.Hashear(solicitud.NuevaPassword));
        }
    }
}
