using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IUsuarioController
    {
        Task<IActionResult> CrearAsync([FromBody] UsuarioCrear usuario);
        Task<IActionResult> ListarAsync();
        Task<IActionResult> ListarRolesAsync();
        Task<IActionResult> CambiarRolAsync([FromRoute] Guid id, [FromBody] CambioRolRequest solicitud);
        Task<IActionResult> DesactivarAsync([FromRoute] Guid id);
        Task<IActionResult> ReactivarAsync([FromRoute] Guid id);
    }
}
