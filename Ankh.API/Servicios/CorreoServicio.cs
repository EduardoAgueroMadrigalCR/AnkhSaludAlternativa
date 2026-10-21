using Abstracciones.Modelos;
using Abstracciones.Servicios;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Net.Mail;
using System.Text;

namespace Servicios
{
    public class CorreoServicio : ICorreoServicio
    {
        private readonly SmtpConfiguracion _configuracion;
        private readonly ILogger<CorreoServicio> _logger;

        public CorreoServicio(IConfiguration configuration, ILogger<CorreoServicio> logger)
        {
            _configuracion = configuration.GetSection("Smtp").Get<SmtpConfiguracion>() ?? new SmtpConfiguracion();
            _logger = logger;
        }

        public async Task<bool> EnviarAsync(string destinatario, string asunto, string cuerpoHtml)
        {

            if (string.IsNullOrWhiteSpace(_configuracion.Host))
            {
                _logger.LogWarning("[CORREO SIMULADO - configure la sección Smtp para enviarlo] Para: {Destinatario} | Asunto: {Asunto} | Cuerpo: {Cuerpo}",
                    destinatario, asunto, cuerpoHtml);
                return true;
            }

            try
            {
                var remitente = string.IsNullOrWhiteSpace(_configuracion.Remitente) ? _configuracion.Usuario : _configuracion.Remitente;
                using var mensaje = new MailMessage
                {
                    From = new MailAddress(remitente, "Macrobiótica Ankh"),
                    Subject = asunto,
                    SubjectEncoding = Encoding.UTF8,
                    Body = cuerpoHtml,
                    BodyEncoding = Encoding.UTF8,
                    IsBodyHtml = true
                };
                mensaje.To.Add(destinatario);

                using var smtp = new SmtpClient(_configuracion.Host, _configuracion.Puerto)
                {
                    EnableSsl = _configuracion.UsarSsl,
                    Credentials = new NetworkCredential(_configuracion.Usuario, _configuracion.Password)
                };
                await smtp.SendMailAsync(mensaje);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "No se pudo enviar el correo a {Destinatario}", destinatario);
                return false;
            }
        }
    }
}
