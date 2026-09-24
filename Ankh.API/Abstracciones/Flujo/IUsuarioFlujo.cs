using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface IUsuarioFlujo
    {
        // Administracion (RF-05, RF-06, RF-08)
        Task<ResultadoCrearUsuario> CrearAsync(UsuarioCrear usuario, Guid idAdmin);
        Task<IEnumerable<Usuario>> ListarAsync();
        Task<IEnumerable<Rol>> ListarRolesAsync();
        Task CambiarRolAsync(Guid idUsuario, int idRol, Guid idAdmin);
        Task DesactivarAsync(Guid idUsuario, Guid idAdmin);
        Task ReactivarAsync(Guid idUsuario, Guid idAdmin);

        // Acceso por modulo (RF-06)
        Task<bool> TieneAccesoAsync(Guid idUsuario, string modulo);
        Task<IEnumerable<string>> ObtenerModulosAsync(Guid idUsuario);

        // Cuenta propia (RF-03, RF-07)
        Task<Usuario> ObtenerPerfilAsync(Guid idUsuario);
        Task ActualizarPerfilAsync(Guid idUsuario, PerfilActualizar perfil);
        Task CambiarPasswordAsync(Guid idUsuario, Guid idSesion, CambioPasswordRequest solicitud);
    }
}
