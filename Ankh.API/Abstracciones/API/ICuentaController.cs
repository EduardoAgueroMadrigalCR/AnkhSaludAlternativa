using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface ICuentaController
    {
        Task<IActionResult> ObtenerPerfilAsync();
        Task<IActionResult> ActualizarPerfilAsync([FromBody] PerfilActualizar perfil);
        Task<IActionResult> CambiarPasswordAsync([FromBody] CambioPasswordRequest solicitud);
    }
}
