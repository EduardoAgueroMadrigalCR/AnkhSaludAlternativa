using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductoController : ControllerBase, IProductoController
    {
        private readonly IProductoFlujo _productoFlujo;

        public ProductoController(IProductoFlujo productoFlujo)
        {
            _productoFlujo = productoFlujo;
        }

        // RF-11: catálogo público, sin necesidad de iniciar sesión
        [AllowAnonymous]
        [HttpGet("Buscar")]
        public async Task<IActionResult> BuscarAsync([FromQuery] string? texto, [FromQuery] Guid? idMarca, [FromQuery] Guid? idCategoria)
        {
            var resultado = await _productoFlujo.BuscarAsync(new ProductoFiltro
            {
                Texto = string.IsNullOrWhiteSpace(texto) ? null : texto.Trim(),
                IdMarca = idMarca,
                IdCategoria = idCategoria,
                SoloActivos = true
            });
            return Ok(resultado);
        }

        // Listado administrativo (incluye descontinuados)
        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpGet]
        public async Task<IActionResult> ListarAsync() => Ok(await _productoFlujo.ListarAsync());

        [AllowAnonymous]
        [HttpGet("{id:guid}")]
        public async Task<IActionResult> ObtenerPorIdAsync([FromRoute] Guid id) => Ok(await _productoFlujo.ObtenerPorIdAsync(id));

        // RF-09
        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] ProductoCrear producto)
        {
            var id = await _productoFlujo.CrearAsync(producto, User.ObtenerIdUsuario());
            return StatusCode(StatusCodes.Status201Created, new { id });
        }

        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpPut("{id:guid}")]
        public async Task<IActionResult> ActualizarAsync([FromRoute] Guid id, [FromBody] ProductoCrear producto)
        {
            await _productoFlujo.ActualizarAsync(id, producto, User.ObtenerIdUsuario());
            return NoContent();
        }

        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpGet("{id:guid}/Historial")]
        public async Task<IActionResult> ObtenerHistorialAsync([FromRoute] Guid id) => Ok(await _productoFlujo.ObtenerHistorialAsync(id));

        // RF-12
        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpPut("{id:guid}/Descontinuar")]
        public async Task<IActionResult> DescontinuarAsync([FromRoute] Guid id, [FromQuery] bool forzar = false)
            => Ok(await _productoFlujo.DescontinuarAsync(id, User.ObtenerIdUsuario(), forzar));

        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpPut("{id:guid}/Reactivar")]
        public async Task<IActionResult> ReactivarAsync([FromRoute] Guid id)
        {
            await _productoFlujo.ReactivarAsync(id, User.ObtenerIdUsuario());
            return NoContent();
        }

        // RF-13
        [Authorize(Roles = "Administrador,Encargado de Inventario")]
        [HttpPost("Importar")]
        [RequestSizeLimit(10_000_000)]
        public async Task<IActionResult> ImportarAsync(IFormFile archivo)
            => Ok(await _productoFlujo.ImportarAsync(archivo, User.ObtenerIdUsuario()));
    }
}
