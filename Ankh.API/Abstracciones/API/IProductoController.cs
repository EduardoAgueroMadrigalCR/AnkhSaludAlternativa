using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IProductoController
    {
        Task<IActionResult> ListarAsync();
        Task<IActionResult> ObtenerAsync([FromRoute] int id);
        Task<IActionResult> CrearAsync([FromBody] ProductoCrear producto);
        Task<IActionResult> ActualizarAsync([FromRoute] int id, [FromBody] ProductoActualizar producto);
    }
}
