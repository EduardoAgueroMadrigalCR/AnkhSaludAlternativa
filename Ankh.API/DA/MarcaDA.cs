using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class MarcaDA : IMarcaDA
    {
        private const CommandType SP = CommandType.StoredProcedure;
        private readonly SqlConnection _sqlConnection;

        public MarcaDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<Guid> CrearAsync(string nombre)
            => await _sqlConnection.ExecuteScalarAsync<Guid>("[CrearMarca]", new { Nombre = nombre }, commandType: SP);

        public async Task ActualizarAsync(Guid id, string nombre)
            => await _sqlConnection.ExecuteAsync("[ActualizarMarca]", new { Id = id, Nombre = nombre }, commandType: SP);

        public async Task EliminarAsync(Guid id)
            => await _sqlConnection.ExecuteAsync("[EliminarMarca]", new { Id = id }, commandType: SP);

        public async Task<IEnumerable<Marca>> ListarAsync()
            => await _sqlConnection.QueryAsync<Marca>("[ListarMarcas]", commandType: SP);
    }
}
