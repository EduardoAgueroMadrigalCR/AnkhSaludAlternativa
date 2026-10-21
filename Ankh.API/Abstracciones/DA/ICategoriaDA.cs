using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface ICategoriaDA
    {
        Task<Guid> CrearAsync(string nombre);
        Task ActualizarAsync(Guid id, string nombre);
        Task EliminarAsync(Guid id);
        Task<IEnumerable<Categoria>> ListarAsync();
    }
}
