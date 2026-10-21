using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class Marca
    {
        public Guid Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool Activa { get; set; }
    }

    public class MarcaCrear
    {
        [Required(ErrorMessage = "El nombre de la marca es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar 100 caracteres")]
        public string Nombre { get; set; } = string.Empty;
    }
}
