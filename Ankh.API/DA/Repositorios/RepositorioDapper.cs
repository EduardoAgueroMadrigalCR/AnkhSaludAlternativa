using Abstracciones.DA;
using Microsoft.Extensions.Configuration;
using System.Data.SqlClient;

namespace DA.Repositorios
{
    public class RepositorioDapper : IRepositorioDapper
    {
        private readonly SqlConnection _connection;

        public RepositorioDapper(IConfiguration configuration)
        {
            _connection = new SqlConnection(configuration.GetConnectionString("BDAnkh"));
        }

        public SqlConnection ObtenerRepositorioDapper()
        {
            return _connection;
        }
    }
}
