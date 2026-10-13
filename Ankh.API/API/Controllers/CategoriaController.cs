using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // Consultar: cualquier usuario autenticado. Crear y editar: Administrador y Encargado de Inventario.
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriaController : ControllerBase, ICategoriaController
    {
        private readonly ICategoriaFlujo _categoriaFlujo;

        public CategoriaController(ICategoriaFlujo categoriaFlujo)
        {
            _categoriaFlujo = categoriaFlujo;
        }

        [HttpGet]
        public async Task<IActionResult> ListarAsync()
        {
            return Ok(await _categoriaFlujo.ListarAsync());
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> ObtenerAsync([FromRoute] int id)
        {
            return Ok(await _categoriaFlujo.ObtenerAsync(id));
        }

        [Authorize(Roles = RolesAcceso.GestionCatalogo)]
        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] CategoriaCrear categoria)
        {
            var creada = await _categoriaFlujo.CrearAsync(categoria, User.ObtenerIdUsuario());
            return StatusCode(StatusCodes.Status201Created, creada);
        }

        [Authorize(Roles = RolesAcceso.GestionCatalogo)]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> ActualizarAsync([FromRoute] int id, [FromBody] CategoriaActualizar categoria)
        {
            await _categoriaFlujo.ActualizarAsync(id, categoria, User.ObtenerIdUsuario());
            return NoContent();
        }
    }
}
