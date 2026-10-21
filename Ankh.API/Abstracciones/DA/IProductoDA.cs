using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface IProductoDA
    {
        Task<Guid> CrearAsync(ProductoCrear producto, Guid idUsuario);
        Task ActualizarAsync(Guid id, ProductoCrear producto, Guid idUsuario);
        Task<Producto?> ObtenerPorIdAsync(Guid id);
        Task<IEnumerable<Producto>> ListarAsync();
        Task<IEnumerable<Producto>> BuscarAsync(ProductoFiltro filtro);
        Task<IEnumerable<ProductoHistorialItem>> ObtenerHistorialAsync(Guid idProducto);
        Task<DescontinuarResultado> DescontinuarAsync(Guid id, Guid idUsuario, bool forzar);
        Task ReactivarAsync(Guid id, Guid idUsuario);
    }
}
