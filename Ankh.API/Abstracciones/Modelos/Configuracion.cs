using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class TokenConfiguracion
    {
        [Required]
        [StringLength(100, MinimumLength = 32)]
        public string Key { get; set; } = string.Empty;
        [Required]
        public string Issuer { get; set; } = string.Empty;
        public string Audience { get; set; } = string.Empty;
        [Required]
        public double Expires { get; set; }
    }

    public class SmtpConfiguracion
    {
        public string Host { get; set; } = string.Empty;
        public int Puerto { get; set; } = 587;
        public string Usuario { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Remitente { get; set; } = string.Empty;
        public bool UsarSsl { get; set; } = true;
    }
}
