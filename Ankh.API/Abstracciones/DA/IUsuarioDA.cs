using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface IUsuarioDA
    {
        Task<Usuario?> ObtenerPorCorreoAsync(string correo);
        Task<Usuario?> ObtenerPorIdAsync(Guid id);
        Task<bool> RegistrarIntentoFallidoAsync(string correo);
        Task RegistrarLoginExitosoAsync(Guid idUsuario, Guid idSesion);
        Task<Guid> CrearAsync(string nombre, string correo, string passwordHash, int idRol, Guid idAdmin);
        Task<IEnumerable<Usuario>> ListarAsync();
        Task<IEnumerable<Rol>> ListarRolesAsync();
        Task CambiarRolAsync(Guid idUsuario, int idRol, Guid idAdmin);
        Task ActualizarPerfilAsync(Guid idUsuario, string nombre, string correo);
        Task DesactivarAsync(Guid idUsuario, Guid idAdmin);
        Task ReactivarAsync(Guid idUsuario, Guid idAdmin);
        Task CambiarPasswordAsync(Guid idUsuario, string nuevoHash, Guid? idSesionActual);
        Task<bool> TieneAccesoAsync(Guid idUsuario, string modulo);
        Task<IEnumerable<string>> ObtenerModulosAsync(Guid idUsuario);
    }
}
