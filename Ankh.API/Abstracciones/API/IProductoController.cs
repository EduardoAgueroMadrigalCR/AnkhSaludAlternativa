using Abstracciones.Modelos;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IProductoController
    {
        Task<IActionResult> BuscarAsync([FromQuery] string? texto, [FromQuery] Guid? idMarca, [FromQuery] Guid? idCategoria);
        Task<IActionResult> ListarAsync();
        Task<IActionResult> ObtenerPorIdAsync([FromRoute] Guid id);
        Task<IActionResult> CrearAsync([FromBody] ProductoCrear producto);
        Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] ProductoCrear producto);
        Task<IActionResult> ObtenerHistorialAsync([FromRoute] Guid id);
        Task<IActionResult> DescontinuarAsync([FromRoute] Guid id, [FromQuery] bool forzar);
        Task<IActionResult> ReactivarAsync([FromRoute] Guid id);
        Task<IActionResult> ImportarAsync(IFormFile archivo);
    }
}
