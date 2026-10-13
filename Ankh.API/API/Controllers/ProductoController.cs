using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // Consultar: cualquier usuario autenticado (el Vendedor consulta productos).
    // Registrar y editar: Administrador y Encargado de Inventario.
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ProductoController : ControllerBase, IProductoController
    {
        private readonly IProductoFlujo _productoFlujo;

        public ProductoController(IProductoFlujo productoFlujo)
        {
            _productoFlujo = productoFlujo;
        }

        [HttpGet]
        public async Task<IActionResult> ListarAsync()
        {
            return Ok(await _productoFlujo.ListarAsync());
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> ObtenerAsync([FromRoute] int id)
        {
            return Ok(await _productoFlujo.ObtenerAsync(id));
        }

        [Authorize(Roles = RolesAcceso.GestionCatalogo)]
        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] ProductoCrear producto)
        {
            var creado = await _productoFlujo.CrearAsync(producto, User.ObtenerIdUsuario());
            return StatusCode(StatusCodes.Status201Created, creado);
        }

        [Authorize(Roles = RolesAcceso.GestionCatalogo)]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> ActualizarAsync([FromRoute] int id, [FromBody] ProductoActualizar producto)
        {
            await _productoFlujo.ActualizarAsync(id, producto, User.ObtenerIdUsuario());
            return NoContent();
        }
    }
}
