using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface IProductoFlujo
    {
        Task<IEnumerable<Producto>> ListarAsync();
        Task<Producto> ObtenerAsync(int id);
        Task<Producto> CrearAsync(ProductoCrear producto, Guid idUsuario);
        Task ActualizarAsync(int id, ProductoActualizar producto, Guid idUsuario);
    }
}
