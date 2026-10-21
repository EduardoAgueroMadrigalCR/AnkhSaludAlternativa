using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface ISesionDA
    {
        Task<EstadoSesion> ValidarAsync(Guid idSesion, bool refrescar);
        Task CerrarAsync(Guid idSesion);
    }
}
