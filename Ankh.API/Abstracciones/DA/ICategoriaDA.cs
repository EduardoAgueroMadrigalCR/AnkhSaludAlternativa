using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface ICategoriaDA
    {
        Task<IEnumerable<Categoria>> ListarAsync();
        Task<Categoria?> ObtenerPorIdAsync(int id);
        Task<int> CrearAsync(string nombre, string? descripcion, Guid idUsuario);
        Task ActualizarAsync(int id, string nombre, string? descripcion, bool activa, Guid idUsuario);
    }
}
