using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface IProductoDA
    {
        Task<IEnumerable<Producto>> ListarAsync();
        Task<Producto?> ObtenerPorIdAsync(int id);
        Task<int> CrearAsync(ProductoCrear producto, Guid idUsuario);
        Task ActualizarAsync(int id, ProductoActualizar producto, Guid idUsuario);
    }
}
