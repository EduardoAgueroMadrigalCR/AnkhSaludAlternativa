using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    // RF-07
    public class PerfilActualizar
    {
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar 100 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido")]
        [StringLength(150, ErrorMessage = "El correo no puede superar 150 caracteres")]
        public string CorreoElectronico { get; set; } = string.Empty;
    }
}
