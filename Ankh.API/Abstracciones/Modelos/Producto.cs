using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{
    public class ProductoCrear
    {
        [Required(ErrorMessage = "El nombre del producto es obligatorio")]
        [StringLength(120, ErrorMessage = "El nombre no puede superar 120 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [StringLength(250, ErrorMessage = "La descripción no puede superar 250 caracteres")]
        public string? Descripcion { get; set; }

        [StringLength(1000, ErrorMessage = "Los detalles no pueden superar 1000 caracteres")]
        public string? Detalles { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "La categoría es obligatoria")]
        public int IdCategoria { get; set; }

        [Range(0.01, 9999999999.99, ErrorMessage = "El precio debe ser mayor que cero")]
        public decimal Precio { get; set; }

        // Ruta relativa (images/archivo.jpg) o URL http(s). Sin ":" en rutas relativas para impedir esquemas como javascript:
        [StringLength(300, ErrorMessage = "La ruta de la imagen no puede superar 300 caracteres")]
        [RegularExpression(@"^(https?://[^\s<>""']+|[\w\-./+ ()%]+)$",
            ErrorMessage = "La imagen debe ser una ruta (images/archivo.jpg) o una URL http(s) válida")]
        public string? Imagen { get; set; }
    }

    public class ProductoActualizar : ProductoCrear
    {
        public bool Activo { get; set; } = true;
    }

    public class Producto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string? Detalles { get; set; }
        public int IdCategoria { get; set; }
        public string Categoria { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string? Imagen { get; set; }
        public bool Activo { get; set; }
    }
}
