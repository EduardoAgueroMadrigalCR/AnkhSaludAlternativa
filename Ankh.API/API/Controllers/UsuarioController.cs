using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // Administracion de usuarios: solo el rol Administrador (RF-05, RF-06, RF-08)
    [Authorize(Roles = "Administrador")]
    [ApiController]
    [Route("api/[controller]")]
    public class UsuarioController : ControllerBase, IUsuarioController
    {
        private readonly IUsuarioFlujo _usuarioFlujo;

        public UsuarioController(IUsuarioFlujo usuarioFlujo)
        {
            _usuarioFlujo = usuarioFlujo;
        }

        [HttpPost]
        public async Task<IActionResult> CrearAsync([FromBody] UsuarioCrear usuario)
        {
            var resultado = await _usuarioFlujo.CrearAsync(usuario, User.ObtenerIdUsuario());
            return StatusCode(StatusCodes.Status201Created, resultado);
        }

        [HttpGet]
        public async Task<IActionResult> ListarAsync()
        {
            return Ok(await _usuarioFlujo.ListarAsync());
        }

        [HttpGet("Roles")]
        public async Task<IActionResult> ListarRolesAsync()
        {
            return Ok(await _usuarioFlujo.ListarRolesAsync());
        }

        [HttpPut("{id:guid}/Rol")]
        public async Task<IActionResult> CambiarRolAsync([FromRoute] Guid id, [FromBody] CambioRolRequest solicitud)
        {
            await _usuarioFlujo.CambiarRolAsync(id, solicitud.IdRol, User.ObtenerIdUsuario());
            return NoContent();
        }

        [HttpPut("{id:guid}/Desactivar")]
        public async Task<IActionResult> DesactivarAsync([FromRoute] Guid id)
        {
            await _usuarioFlujo.DesactivarAsync(id, User.ObtenerIdUsuario());
            return NoContent();
        }

        [HttpPut("{id:guid}/Reactivar")]
        public async Task<IActionResult> ReactivarAsync([FromRoute] Guid id)
        {
            await _usuarioFlujo.ReactivarAsync(id, User.ObtenerIdUsuario());
            return NoContent();
        }
    }
}
