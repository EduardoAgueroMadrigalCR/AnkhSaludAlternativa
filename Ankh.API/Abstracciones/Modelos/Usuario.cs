using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Abstracciones.Modelos
{

    public class UsuarioCrear
    {
        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar 100 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio")]
        [EmailAddress(ErrorMessage = "El formato del correo no es válido")]
        [StringLength(150, ErrorMessage = "El correo no puede superar 150 caracteres")]
        public string CorreoElectronico { get; set; } = string.Empty;

        [Range(1, int.MaxValue, ErrorMessage = "El rol es obligatorio")]
        public int IdRol { get; set; }
    }

    public class ResultadoCrearUsuario
    {
        public Guid Id { get; set; }
        public bool CorreoEnviado { get; set; }
    }

    public class Usuario
    {
        public Guid Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;

        [JsonIgnore]
        public string PasswordHash { get; set; } = string.Empty;

        public int IdRol { get; set; }
        public string Rol { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public bool DebeCambiarPassword { get; set; }
        public bool Bloqueado { get; set; }
        public DateTime? BloqueadoHasta { get; set; }
        public DateTime? UltimoLogin { get; set; }
    }

    public class CambioRolRequest
    {
        [Range(1, int.MaxValue, ErrorMessage = "El rol es obligatorio")]
        public int IdRol { get; set; }
    }
}
