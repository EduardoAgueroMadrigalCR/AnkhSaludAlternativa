using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface ISesionFlujo
    {
        Task<EstadoSesion> ObtenerEstadoAsync(Guid idSesion, bool refrescar);
    }
}
