using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class SesionDA : ISesionDA
    {
        private readonly SqlConnection _sqlConnection;

        public SesionDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<EstadoSesion> ValidarAsync(Guid idSesion, bool refrescar)
        {
            return await _sqlConnection.QuerySingleAsync<EstadoSesion>("[ValidarSesion]",
                new { IdSesion = idSesion, Refrescar = refrescar }, commandType: CommandType.StoredProcedure);
        }

        public async Task CerrarAsync(Guid idSesion)
        {
            await _sqlConnection.ExecuteAsync("[CerrarSesion]",
                new { IdSesion = idSesion }, commandType: CommandType.StoredProcedure);
        }
    }
}
