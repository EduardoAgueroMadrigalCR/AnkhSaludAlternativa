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

        public async Task<Guid> CrearAsync(ProductoCrear p, Guid idUsuario)
            => await _sqlConnection.ExecuteScalarAsync<Guid>("[CrearProducto]", new
            {
                p.CodigoProducto, p.Nombre, p.Descripcion, p.ImagenUrl, p.IdMarca, p.IdCategoria, p.Precio, p.Stock, IdUsuario = idUsuario
            }, commandType: SP);

        public async Task ActualizarAsync(Guid id, ProductoCrear p, Guid idUsuario)
            => await _sqlConnection.ExecuteAsync("[ActualizarProducto]", new
            {
                Id = id, p.Nombre, p.Descripcion, p.ImagenUrl, p.IdMarca, p.IdCategoria, p.Precio, p.Stock, IdUsuario = idUsuario
            }, commandType: SP);

        public async Task<Producto?> ObtenerPorIdAsync(Guid id)
        {
            var resultado = await _sqlConnection.QueryAsync<Producto>("[ObtenerProductoPorId]", new { Id = id }, commandType: SP);
            return resultado.FirstOrDefault();
        }

        public async Task<IEnumerable<Producto>> ListarAsync()
            => await _sqlConnection.QueryAsync<Producto>("[ListarProductos]", commandType: SP);

        public async Task<IEnumerable<Producto>> BuscarAsync(ProductoFiltro filtro)
            => await _sqlConnection.QueryAsync<Producto>("[BuscarProductos]", new
            {
                filtro.Texto, filtro.IdMarca, filtro.IdCategoria, filtro.SoloActivos
            }, commandType: SP);

        public async Task<IEnumerable<ProductoHistorialItem>> ObtenerHistorialAsync(Guid idProducto)
            => await _sqlConnection.QueryAsync<ProductoHistorialItem>("[ObtenerHistorialProducto]",
                new { IdProducto = idProducto }, commandType: SP);

        public async Task<DescontinuarResultado> DescontinuarAsync(Guid id, Guid idUsuario, bool forzar)
            => await _sqlConnection.QuerySingleAsync<DescontinuarResultado>("[DescontinuarProducto]",
                new { Id = id, IdUsuario = idUsuario, Forzar = forzar }, commandType: SP);

        public async Task ReactivarAsync(Guid id, Guid idUsuario)
            => await _sqlConnection.ExecuteAsync("[ReactivarProducto]", new { Id = id, IdUsuario = idUsuario }, commandType: SP);
    }
}
