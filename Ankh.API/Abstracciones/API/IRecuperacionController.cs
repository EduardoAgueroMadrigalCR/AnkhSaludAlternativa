using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IRecuperacionController
    {
        Task<IActionResult> SolicitarAsync([FromBody] RecuperacionSolicitud solicitud);
        Task<IActionResult> RestablecerAsync([FromBody] RestablecerPasswordRequest solicitud);
    }
}
