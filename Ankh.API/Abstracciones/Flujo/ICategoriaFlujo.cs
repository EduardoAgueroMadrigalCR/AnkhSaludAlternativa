using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface ICategoriaFlujo
    {
        Task<Guid> CrearAsync(CategoriaCrear categoria);
        Task ActualizarAsync(Guid id, CategoriaCrear categoria);
        Task EliminarAsync(Guid id);
        Task<IEnumerable<Categoria>> ListarAsync();
    }
}
