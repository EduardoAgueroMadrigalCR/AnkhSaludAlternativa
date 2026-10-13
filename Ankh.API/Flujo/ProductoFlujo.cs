using Abstracciones.DA;
using Abstracciones.Excepciones;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Microsoft.AspNetCore.Http;

namespace Flujo
{
    public class ProductoFlujo : IProductoFlujo
    {
        private readonly IProductoDA _productoDA;

        public ProductoFlujo(IProductoDA productoDA)
        {
            _productoDA = productoDA;
        }

        public async Task<IEnumerable<Producto>> ListarAsync() => await _productoDA.ListarAsync();

        public async Task<Producto> ObtenerAsync(int id)
        {
            return await _productoDA.ObtenerPorIdAsync(id)
                ?? throw new ReglaNegocioException(StatusCodes.Status404NotFound, "El producto no existe");
        }

        public async Task<Producto> CrearAsync(ProductoCrear producto, Guid idUsuario)
        {
            Normalizar(producto);
            var id = await _productoDA.CrearAsync(producto, idUsuario);
            return await ObtenerAsync(id);
        }

        public async Task ActualizarAsync(int id, ProductoActualizar producto, Guid idUsuario)
        {
            Normalizar(producto);
            await _productoDA.ActualizarAsync(id, producto, idUsuario);
        }

        // Quita espacios y convierte los textos opcionales vacios en null
        private static void Normalizar(ProductoCrear producto)
        {
            producto.Nombre = producto.Nombre.Trim();
            producto.Descripcion = LimpiarOpcional(producto.Descripcion);
            producto.Detalles = LimpiarOpcional(producto.Detalles);
            producto.Imagen = LimpiarOpcional(producto.Imagen);
            producto.Precio = decimal.Round(producto.Precio, 2, MidpointRounding.AwayFromZero);
        }

        private static string? LimpiarOpcional(string? texto)
            => string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}
