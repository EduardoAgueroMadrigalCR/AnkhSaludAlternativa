using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class Categoria
    {
        public Guid Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool Activa { get; set; }
    }

    public class CategoriaCrear
    {
        [Required(ErrorMessage = "El nombre de la categoría es obligatorio")]
        [StringLength(100, ErrorMessage = "El nombre no puede superar 100 caracteres")]
        public string Nombre { get; set; } = string.Empty;
    }
}
