using Abstracciones.DA;
using Abstracciones.Modelos;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace DA
{
    public class UsuarioDA : IUsuarioDA
    {
        private const CommandType SP = CommandType.StoredProcedure;
        private readonly SqlConnection _sqlConnection;

        public UsuarioDA(IRepositorioDapper repositorioDapper)
        {
            _sqlConnection = repositorioDapper.ObtenerRepositorioDapper();
        }

        public async Task<Usuario?> ObtenerPorCorreoAsync(string correo)
        {
            var resultado = await _sqlConnection.QueryAsync<Usuario>("[ObtenerUsuarioLogin]",
                new { CorreoElectronico = correo }, commandType: SP);
            return resultado.FirstOrDefault();
        }

        public async Task<Usuario?> ObtenerPorIdAsync(Guid id)
        {
            var resultado = await _sqlConnection.QueryAsync<Usuario>("[ObtenerUsuarioPorId]",
                new { Id = id }, commandType: SP);
            return resultado.FirstOrDefault();
        }

        public async Task<bool> RegistrarIntentoFallidoAsync(string correo)
        {
            return await _sqlConnection.ExecuteScalarAsync<bool>("[RegistrarIntentoFallido]",
                new { CorreoElectronico = correo }, commandType: SP);
        }

        public async Task RegistrarLoginExitosoAsync(Guid idUsuario, Guid idSesion)
        {
            await _sqlConnection.ExecuteAsync("[RegistrarLoginExitoso]",
                new { IdUsuario = idUsuario, IdSesion = idSesion }, commandType: SP);
        }

        public async Task<Guid> CrearAsync(string nombre, string correo, string passwordHash, int idRol, Guid idAdmin)
        {
            return await _sqlConnection.ExecuteScalarAsync<Guid>("[CrearUsuario]",
                new { Nombre = nombre, CorreoElectronico = correo, PasswordHash = passwordHash, IdRol = idRol, IdAdmin = idAdmin },
                commandType: SP);
        }

        public async Task<IEnumerable<Usuario>> ListarAsync()
        {
            return await _sqlConnection.QueryAsync<Usuario>("[ListarUsuarios]", commandType: SP);
        }

        public async Task<IEnumerable<Rol>> ListarRolesAsync()
        {
            return await _sqlConnection.QueryAsync<Rol>("[ListarRoles]", commandType: SP);
        }

        public async Task CambiarRolAsync(Guid idUsuario, int idRol, Guid idAdmin)
        {
            await _sqlConnection.ExecuteAsync("[CambiarRol]",
                new { IdUsuario = idUsuario, IdRol = idRol, IdAdmin = idAdmin }, commandType: SP);
        }

        public async Task ActualizarPerfilAsync(Guid idUsuario, string nombre, string correo)
        {
            await _sqlConnection.ExecuteAsync("[ActualizarPerfil]",
                new { IdUsuario = idUsuario, Nombre = nombre, CorreoElectronico = correo }, commandType: SP);
        }

        public async Task DesactivarAsync(Guid idUsuario, Guid idAdmin)
        {
            await _sqlConnection.ExecuteAsync("[DesactivarUsuario]",
                new { IdUsuario = idUsuario, IdAdmin = idAdmin }, commandType: SP);
        }

        public async Task ReactivarAsync(Guid idUsuario, Guid idAdmin)
        {
            await _sqlConnection.ExecuteAsync("[ReactivarUsuario]",
                new { IdUsuario = idUsuario, IdAdmin = idAdmin }, commandType: SP);
        }

        public async Task CambiarPasswordAsync(Guid idUsuario, string nuevoHash, Guid? idSesionActual)
        {
            await _sqlConnection.ExecuteAsync("[CambiarPassword]",
                new { IdUsuario = idUsuario, NuevoHash = nuevoHash, IdSesionActual = idSesionActual }, commandType: SP);
        }

        public async Task<bool> TieneAccesoAsync(Guid idUsuario, string modulo)
        {
            return await _sqlConnection.ExecuteScalarAsync<bool>("[VerificarAcceso]",
                new { IdUsuario = idUsuario, Modulo = modulo }, commandType: SP);
        }

        public async Task<IEnumerable<string>> ObtenerModulosAsync(Guid idUsuario)
        {
            return await _sqlConnection.QueryAsync<string>("[ObtenerModulosxUsuario]",
                new { IdUsuario = idUsuario }, commandType: SP);
        }
    }
}
