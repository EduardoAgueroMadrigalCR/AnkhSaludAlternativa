using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // RF-10: Administrador y Encargado de Inventario gestionan marcas y categorías
    [Authorize(Roles = "Administrador,Encargado de Inventario")]
    [ApiController]
    [Route("api/[controller]")]
    public class MarcaController : ControllerBase, IMarcaController
    {
        private readonly IMarcaFlujo _marcaFlujo;

        public MarcaController(IMarcaFlujo marcaFlujo)
        {
            _marcaFlujo = marcaFlujo;
        }

        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> ListarAsync() => Ok(await _marcaFlujo.ListarAsync());

        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] MarcaCrear marca)
            => StatusCode(StatusCodes.Status201Created, new { id = await _marcaFlujo.CrearAsync(marca) });

        [HttpPut("{id:guid}")]
        public async Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] MarcaCrear marca)
        {
            await _marcaFlujo.ActualizarAsync(id, marca);
            return NoContent();
        }

        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> EliminarAsync([FromRoute] Guid id)
        {
            await _marcaFlujo.EliminarAsync(id);
            return NoContent();
        }
    }
}
