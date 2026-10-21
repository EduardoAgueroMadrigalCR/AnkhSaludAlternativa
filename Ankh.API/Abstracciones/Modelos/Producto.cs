using System.ComponentModel.DataAnnotations;

namespace Abstracciones.Modelos
{

    public class ProductoCrear
    {
        [Required(ErrorMessage = "El código de producto es obligatorio")]
        [StringLength(30, ErrorMessage = "El código no puede superar 30 caracteres")]
        public string CodigoProducto { get; set; } = string.Empty;

        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(150, ErrorMessage = "El nombre no puede superar 150 caracteres")]
        public string Nombre { get; set; } = string.Empty;

        [StringLength(500, ErrorMessage = "La descripción no puede superar 500 caracteres")]
        public string? Descripcion { get; set; }

        [StringLength(300, ErrorMessage = "La ruta de la imagen no puede superar 300 caracteres")]
        public string? ImagenUrl { get; set; }

        [Required(ErrorMessage = "La marca es obligatoria")]
        public Guid IdMarca { get; set; }

        [Required(ErrorMessage = "La categoría es obligatoria")]
        public Guid IdCategoria { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "El precio no puede ser negativo")]
        public decimal Precio { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "El stock no puede ser negativo")]
        public int Stock { get; set; }
    }

    public class Producto
    {
        public Guid Id { get; set; }
        public string CodigoProducto { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string? ImagenUrl { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public bool Descontinuado { get; set; }
        public Guid IdMarca { get; set; }
        public string Marca { get; set; } = string.Empty;
        public Guid IdCategoria { get; set; }
        public string Categoria { get; set; } = string.Empty;
        public DateTime FechaCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }

    public class ProductoFiltro
    {
        public string? Texto { get; set; }
        public Guid? IdMarca { get; set; }
        public Guid? IdCategoria { get; set; }
        public bool SoloActivos { get; set; } = true;
    }

    public class ProductoHistorialItem
    {
        public string Campo { get; set; } = string.Empty;
        public string? ValorAnterior { get; set; }
        public string? ValorNuevo { get; set; }
        public DateTime Fecha { get; set; }
        public string? Usuario { get; set; }
    }

    public class DescontinuarResultado
    {
        public bool RequiereConfirmacion { get; set; }
        public int StockActual { get; set; }
    }


    public class ImportacionFilaOmitida
    {
        public int Fila { get; set; }
        public string Motivo { get; set; } = string.Empty;
    }

    public class ImportacionResultado
    {
        public int TotalFilas { get; set; }
        public int Importados { get; set; }
        public List<ImportacionFilaOmitida> Omitidos { get; set; } = new();
    }
}
