using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface ICategoriaController
    {
        Task<IActionResult> ListarAsync();
        Task<IActionResult> CrearAsync([FromBody] CategoriaCrear categoria);
        Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] CategoriaCrear categoria);
        Task<IActionResult> EliminarAsync([FromRoute] Guid id);
    }
}
