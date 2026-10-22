using Abstracciones.Modelos;
using Microsoft.AspNetCore.Http;

namespace Abstracciones.Flujo
{
    public interface IProductoFlujo
    {
        Task<Guid> CrearAsync(ProductoCrear producto, Guid idUsuario);
        Task ActualizarAsync(Guid id, ProductoCrear producto, Guid idUsuario);
        Task<Producto> ObtenerPorIdAsync(Guid id);
        Task<IEnumerable<Producto>> ListarAsync();
        Task<IEnumerable<Producto>> BuscarAsync(ProductoFiltro filtro);
        Task<IEnumerable<ProductoHistorialItem>> ObtenerHistorialAsync(Guid idProducto);
        Task<DescontinuarResultado> DescontinuarAsync(Guid id, Guid idUsuario, bool forzar);
        Task ReactivarAsync(Guid id, Guid idUsuario);
        Task EliminarAsync(Guid id, Guid idUsuario);

        // RF-13
        Task<ImportacionResultado> ImportarAsync(IFormFile archivo, Guid idUsuario);
    }
}
