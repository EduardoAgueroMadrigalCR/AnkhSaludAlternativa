using Abstracciones.Modelos;
using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IAutenticacionController
    {
        Task<IActionResult> LoginAsync([FromBody] LoginRequest login);
        Task<IActionResult> LogoutAsync();
    }
}
