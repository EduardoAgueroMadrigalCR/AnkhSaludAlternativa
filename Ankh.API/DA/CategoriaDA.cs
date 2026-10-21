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

        public async Task<Guid> CrearAsync(string nombre)
            => await _sqlConnection.ExecuteScalarAsync<Guid>("[CrearCategoria]", new { Nombre = nombre }, commandType: SP);

        public async Task ActualizarAsync(Guid id, string nombre)
            => await _sqlConnection.ExecuteAsync("[ActualizarCategoria]", new { Id = id, Nombre = nombre }, commandType: SP);

        public async Task EliminarAsync(Guid id)
            => await _sqlConnection.ExecuteAsync("[EliminarCategoria]", new { Id = id }, commandType: SP);

        public async Task<IEnumerable<Categoria>> ListarAsync()
            => await _sqlConnection.QueryAsync<Categoria>("[ListarCategorias]", commandType: SP);
    }
}
