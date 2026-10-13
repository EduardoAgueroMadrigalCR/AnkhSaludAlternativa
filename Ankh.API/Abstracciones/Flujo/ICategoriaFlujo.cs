using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface ICategoriaFlujo
    {
        Task<IEnumerable<Categoria>> ListarAsync();
        Task<Categoria> ObtenerAsync(int id);
        Task<Categoria> CrearAsync(CategoriaCrear categoria, Guid idUsuario);
        Task ActualizarAsync(int id, CategoriaActualizar categoria, Guid idUsuario);
    }
}
