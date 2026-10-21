using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [Authorize(Roles = "Administrador,Encargado de Inventario")]
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriaController : ControllerBase, ICategoriaController
    {
        private readonly ICategoriaFlujo _categoriaFlujo;

        public CategoriaController(ICategoriaFlujo categoriaFlujo)
        {
            _categoriaFlujo = categoriaFlujo;
        }

        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> ListarAsync() => Ok(await _categoriaFlujo.ListarAsync());

        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] CategoriaCrear categoria)
            => StatusCode(StatusCodes.Status201Created, new { id = await _categoriaFlujo.CrearAsync(categoria) });

        [HttpPut("{id:guid}")]
        public async Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] CategoriaCrear categoria)
        {
            await _categoriaFlujo.ActualizarAsync(id, categoria);
            return NoContent();
        }

        [HttpDelete("{id:guid}")]
        public async Task<IActionResult> EliminarAsync([FromRoute] Guid id)
        {
            await _categoriaFlujo.EliminarAsync(id);
            return NoContent();
        }
    }
}
