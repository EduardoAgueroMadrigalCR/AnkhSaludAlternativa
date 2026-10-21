using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IMarcaController
    {
        Task<IActionResult> ListarAsync();
        Task<IActionResult> CrearAsync([FromBody] MarcaCrear marca);
        Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] MarcaCrear marca);
        Task<IActionResult> EliminarAsync([FromRoute] Guid id);
    }
}
