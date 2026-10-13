using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class CategoriaDA : ICategoriaDA
    {
        private const CommandType SP = CommandType.StoredProcedure;
        private readonly SqlConnection _sqlConnection;

        public CategoriaDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<IEnumerable<Categoria>> ListarAsync()
        {
            return await _sqlConnection.QueryAsync<Categoria>("[ListarCategorias]", commandType: SP);
        }

        public async Task<Categoria?> ObtenerPorIdAsync(int id)
        {
            var resultado = await _sqlConnection.QueryAsync<Categoria>("[ObtenerCategoriaPorId]",
                new { Id = id }, commandType: SP);
            return resultado.FirstOrDefault();
        }

        public async Task<int> CrearAsync(string nombre, string? descripcion, Guid idUsuario)
        {
            return await _sqlConnection.ExecuteScalarAsync<int>("[CrearCategoria]",
                new { Nombre = nombre, Descripcion = descripcion, IdUsuario = idUsuario }, commandType: SP);
        }

        public async Task ActualizarAsync(int id, string nombre, string? descripcion, bool activa, Guid idUsuario)
        {
            await _sqlConnection.ExecuteAsync("[ActualizarCategoria]",
                new { Id = id, Nombre = nombre, Descripcion = descripcion, Activa = activa, IdUsuario = idUsuario },
                commandType: SP);
        }
    }
}
