using Abstracciones.DA;
using Abstracciones.Flujo;
using Abstracciones.Modelos;

namespace Flujo
{
    public class SesionFlujo : ISesionFlujo
    {
        private readonly ISesionDA _sesionDA;

        public SesionFlujo(ISesionDA sesionDA)
        {
            _sesionDA = sesionDA;
        }

        public async Task<EstadoSesion> ObtenerEstadoAsync(Guid idSesion, bool refrescar)
        {
            return await _sesionDA.ValidarAsync(idSesion, refrescar);
        }
    }
}
