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
    public class AutenticacionController : ControllerBase, IAutenticacionController
    {
        private readonly IAutenticacionFlujo _autenticacionFlujo;

        public AutenticacionController(IAutenticacionFlujo autenticacionFlujo)
        {
            _autenticacionFlujo = autenticacionFlujo;
        }

        // RF-01
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> LoginAsync([FromBody] LoginRequest login)
        {
            return Ok(await _autenticacionFlujo.LoginAsync(login));
        }

        [Authorize]
        [HttpPost("logout")]
        public async Task<IActionResult> LogoutAsync()
        {
            await _autenticacionFlujo.LogoutAsync(User.ObtenerIdSesion());
            return NoContent();
        }
    }
}
