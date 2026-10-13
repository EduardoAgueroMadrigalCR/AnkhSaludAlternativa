using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class CategoriaCrear
    {
        [Required(ErrorMessage = "El nombre de la categoría es obligatorio")]
        [StringLength(80, ErrorMessage = "El nombre no puede superar 80 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [StringLength(250, ErrorMessage = "La descripción no puede superar 250 caracteres")]
        public string? Descripcion { get; set; }
    }

    public class CategoriaActualizar : CategoriaCrear
    {
        public bool Activa { get; set; } = true;
    }

    public class Categoria
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public bool Activa { get; set; }
        public int ProductosActivos { get; set; }
    }
}
