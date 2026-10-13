using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface ICategoriaController
    {
        Task<IActionResult> ListarAsync();
        Task<IActionResult> ObtenerAsync([FromRoute] int id);
        Task<IActionResult> CrearAsync([FromBody] CategoriaCrear categoria);
        Task<IActionResult> ActualizarAsync([FromRoute] int id, [FromBody] CategoriaActualizar categoria);
    }
}
