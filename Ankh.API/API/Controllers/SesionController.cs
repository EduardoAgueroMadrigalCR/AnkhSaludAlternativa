using Abstracciones.API;
using Abstracciones.Flujo;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class SesionController : ControllerBase, ISesionController
    {
        private readonly ISesionFlujo _sesionFlujo;

        public SesionController(ISesionFlujo sesionFlujo)
        {
            _sesionFlujo = sesionFlujo;
        }

        // RF-02: consulta los segundos restantes SIN reiniciar el contador de inactividad
        [HttpGet("Estado")]
        public async Task<IActionResult> EstadoAsync()
        {
            return Ok(await _sesionFlujo.ObtenerEstadoAsync(User.ObtenerIdSesion(), false));
        }

        // RF-02: el usuario esta activo o acepta extender la sesion desde el aviso emergente
        [HttpPost("Extender")]
        public async Task<IActionResult> ExtenderAsync()
        {
            return Ok(await _sesionFlujo.ObtenerEstadoAsync(User.ObtenerIdSesion(), true));
        }
    }
}
