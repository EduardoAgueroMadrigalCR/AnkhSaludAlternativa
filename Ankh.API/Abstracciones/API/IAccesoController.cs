using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface IAccesoController
    {
        Task<IActionResult> ObtenerModulosAsync();
        Task<IActionResult> VerificarAsync([FromRoute] string modulo);
    }
}
