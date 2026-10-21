using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class RecuperacionDA : IRecuperacionDA
    {
        private readonly SqlConnection _sqlConnection;

        public RecuperacionDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<SolicitudRecuperacionResultado> SolicitarAsync(string correo, string tokenHash)
        {
            return await _sqlConnection.QuerySingleAsync<SolicitudRecuperacionResultado>("[SolicitarRecuperacion]",
                new { CorreoElectronico = correo, TokenHash = tokenHash }, commandType: CommandType.StoredProcedure);
        }

        public async Task RestablecerAsync(string tokenHash, string nuevoHash)
        {
            await _sqlConnection.ExecuteAsync("[RestablecerPassword]",
                new { TokenHash = tokenHash, NuevoHash = nuevoHash }, commandType: CommandType.StoredProcedure);
        }
    }
}
