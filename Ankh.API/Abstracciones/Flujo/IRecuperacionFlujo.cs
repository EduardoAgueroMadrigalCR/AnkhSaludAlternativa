using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface IRecuperacionFlujo
    {
        Task SolicitarAsync(RecuperacionSolicitud solicitud);
        Task RestablecerAsync(RestablecerPasswordRequest solicitud);
    }
}
