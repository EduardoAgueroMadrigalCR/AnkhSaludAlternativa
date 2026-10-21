using Abstracciones.API;
using Abstracciones.Flujo;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // RF-06: que modulos puede usar el usuario actual (la interfaz oculta lo que no le corresponde)
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class AccesoController : ControllerBase, IAccesoController
    {
        private readonly IUsuarioFlujo _usuarioFlujo;

        public AccesoController(IUsuarioFlujo usuarioFlujo)
        {
            _usuarioFlujo = usuarioFlujo;
        }

        [HttpGet("Modulos")]
        public async Task<IActionResult> ObtenerModulosAsync()
        {
            return Ok(await _usuarioFlujo.ObtenerModulosAsync(User.ObtenerIdUsuario()));
        }

        [HttpGet("{modulo}")]
        public async Task<IActionResult> VerificarAsync([FromRoute] string modulo)
        {
            var tieneAcceso = await _usuarioFlujo.TieneAccesoAsync(User.ObtenerIdUsuario(), modulo);
            if (!tieneAcceso)
                return StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "No tiene permisos para acceder a este módulo" });
            return Ok(new { tieneAcceso });
        }
    }
}
