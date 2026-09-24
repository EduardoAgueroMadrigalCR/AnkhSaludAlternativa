using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // RF-04: endpoints publicos (el usuario no puede iniciar sesion)
    [AllowAnonymous]
    [ApiController]
    [Route("api/[controller]")]
    public class RecuperacionController : ControllerBase, IRecuperacionController
    {
        private readonly IRecuperacionFlujo _recuperacionFlujo;

        public RecuperacionController(IRecuperacionFlujo recuperacionFlujo)
        {
            _recuperacionFlujo = recuperacionFlujo;
        }

        [HttpPost("Solicitar")]
        public async Task<IActionResult> SolicitarAsync([FromBody] RecuperacionSolicitud solicitud)
        {
            await _recuperacionFlujo.SolicitarAsync(solicitud);
            return Ok(new { mensaje = "Le enviamos un correo con el enlace para restablecer su contraseña" });
        }

        [HttpPost("Restablecer")]
        public async Task<IActionResult> RestablecerAsync([FromBody] RestablecerPasswordRequest solicitud)
        {
            await _recuperacionFlujo.RestablecerAsync(solicitud);
            return Ok(new { mensaje = "Contraseña restablecida. Ya puede iniciar sesión" });
        }
    }
}
