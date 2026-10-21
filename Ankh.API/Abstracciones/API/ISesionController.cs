using Microsoft.AspNetCore.Mvc;

namespace Abstracciones.API
{
    public interface ISesionController
    {
        Task<IActionResult> EstadoAsync();
        Task<IActionResult> ExtenderAsync();
    }
}
