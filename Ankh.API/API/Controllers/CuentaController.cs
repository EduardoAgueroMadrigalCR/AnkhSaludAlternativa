using Abstracciones.API;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using API.Extensiones;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    // Autogestion de la cuenta propia (cualquier rol): RF-03 y RF-07
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class CuentaController : ControllerBase, ICuentaController
    {
        private readonly IUsuarioFlujo _usuarioFlujo;

        public CuentaController(IUsuarioFlujo usuarioFlujo)
        {
            _usuarioFlujo = usuarioFlujo;
        }

        [HttpGet("Perfil")]
        public async Task<IActionResult> ObtenerPerfilAsync()
        {
            return Ok(await _usuarioFlujo.ObtenerPerfilAsync(User.ObtenerIdUsuario()));
        }

        [HttpPut("Perfil")]
        public async Task<IActionResult> ActualizarPerfilAsync([FromBody] PerfilActualizar perfil)
        {
            await _usuarioFlujo.ActualizarPerfilAsync(User.ObtenerIdUsuario(), perfil);
            return Ok(new { mensaje = "Perfil actualizado correctamente" });
        }

        [HttpPut("Password")]
        public async Task<IActionResult> CambiarPasswordAsync([FromBody] CambioPasswordRequest solicitud)
        {
            await _usuarioFlujo.CambiarPasswordAsync(User.ObtenerIdUsuario(), User.ObtenerIdSesion(), solicitud);
            return Ok(new { mensaje = "Contraseña actualizada correctamente" });
        }
    }
}
