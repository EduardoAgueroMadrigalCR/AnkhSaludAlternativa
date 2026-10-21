using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface IMarcaFlujo
    {
        Task<Guid> CrearAsync(MarcaCrear marca);
        Task ActualizarAsync(Guid id, MarcaCrear marca);
        Task EliminarAsync(Guid id);
        Task<IEnumerable<Marca>> ListarAsync();
    }
}
