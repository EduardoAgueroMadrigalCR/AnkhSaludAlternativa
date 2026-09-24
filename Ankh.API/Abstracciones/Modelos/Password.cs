using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public static class PoliticaPassword
    {
        public const string Patron = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,64}$";
        public const string Mensaje = "La contraseña debe tener entre 8 y 64 caracteres e incluir mayúscula, minúscula, número y símbolo";
    }

    // RF-03
    public class CambioPasswordRequest
    {
        [Required(ErrorMessage = "La contraseña actual es obligatoria")]
        public string PasswordActual { get; set; } = string.Empty;

        [Required(ErrorMessage = "La nueva contraseña es obligatoria")]
        [RegularExpression(PoliticaPassword.Patron, ErrorMessage = PoliticaPassword.Mensaje)]
        public string NuevaPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Debe confirmar la nueva contraseña")]
        [Compare(nameof(NuevaPassword), ErrorMessage = "La confirmación no coincide con la nueva contraseña")]
        public string ConfirmarPassword { get; set; } = string.Empty;
    }

    // RF-04
    public class RecuperacionSolicitud
    {
        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido")]
        public string CorreoElectronico { get; set; } = string.Empty;
    }

    public class RestablecerPasswordRequest
    {
        [Required(ErrorMessage = "El token es obligatorio")]
        public string Token { get; set; } = string.Empty;

        [Required(ErrorMessage = "La nueva contraseña es obligatoria")]
        [RegularExpression(PoliticaPassword.Patron, ErrorMessage = PoliticaPassword.Mensaje)]
        public string NuevaPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Debe confirmar la nueva contraseña")]
        [Compare(nameof(NuevaPassword), ErrorMessage = "La confirmación no coincide con la nueva contraseña")]
        public string ConfirmarPassword { get; set; } = string.Empty;
    }

    public class SolicitudRecuperacionResultado
    {
        public Guid Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public int MinutosVigencia { get; set; }
    }
}
