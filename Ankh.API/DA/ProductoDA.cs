using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class ProductoDA : IProductoDA
    {
        private const CommandType SP = CommandType.StoredProcedure;
        private readonly SqlConnection _sqlConnection;

        public ProductoDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<IEnumerable<Producto>> ListarAsync()
        {
            return await _sqlConnection.QueryAsync<Producto>("[ListarProductos]", commandType: SP);
        }

        public async Task<Producto?> ObtenerPorIdAsync(int id)
        {
            var resultado = await _sqlConnection.QueryAsync<Producto>("[ObtenerProductoPorId]",
                new { Id = id }, commandType: SP);
            return resultado.FirstOrDefault();
        }

        public async Task<int> CrearAsync(ProductoCrear producto, Guid idUsuario)
        {
            var parametros = ArmarParametros(producto, idUsuario);
            return await _sqlConnection.ExecuteScalarAsync<int>("[CrearProducto]", parametros, commandType: SP);
        }

        public async Task ActualizarAsync(int id, ProductoActualizar producto, Guid idUsuario)
        {
            var parametros = ArmarParametros(producto, idUsuario);
            parametros.Add("Id", id);
            parametros.Add("Activo", producto.Activo);
            await _sqlConnection.ExecuteAsync("[ActualizarProducto]", parametros, commandType: SP);
        }

        // El precio se envia con precision y escala explicitas (DECIMAL(12,2)) para no perder centimos.
        private static DynamicParameters ArmarParametros(ProductoCrear producto, Guid idUsuario)
        {
            var parametros = new DynamicParameters();
            parametros.Add("Nombre", producto.Nombre);
            parametros.Add("Descripcion", producto.Descripcion);
            parametros.Add("Detalles", producto.Detalles);
            parametros.Add("IdCategoria", producto.IdCategoria);
            parametros.Add("Precio", producto.Precio, DbType.Decimal, precision: 12, scale: 2);
            parametros.Add("Imagen", producto.Imagen);
            parametros.Add("IdUsuario", idUsuario);
            return parametros;
        }
    }
}
