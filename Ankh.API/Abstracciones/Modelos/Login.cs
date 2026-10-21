using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class LoginRequest
    {
        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido")]
        public string CorreoElectronico { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        public string Password { get; set; } = string.Empty;
    }

    public class LoginRespuesta
    {
        public bool ValidacionExitosa { get; set; }
        public string AccessToken { get; set; } = string.Empty;
        public Guid IdUsuario { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Rol { get; set; } = string.Empty;
        public bool DebeCambiarPassword { get; set; }
    }
}
