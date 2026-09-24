using Abstracciones.Excepciones;
using System.Data.SqlClient;

namespace API.Middleware
{
    /// <summary>
    /// Manejo centralizado de errores: convierte las reglas de negocio y los THROW 50xxx de los
    /// procedimientos almacenados en respuestas JSON { mensaje } con el codigo HTTP adecuado.
    /// </summary>
    public class ManejadorExcepcionesMiddleware : IMiddleware
    {
        private readonly ILogger<ManejadorExcepcionesMiddleware> _logger;

        public ManejadorExcepcionesMiddleware(ILogger<ManejadorExcepcionesMiddleware> logger)
        {
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, RequestDelegate next)
        {
            try
            {
                await next(context);
            }
            catch (ReglaNegocioException ex)
            {
                await ResponderAsync(context, ex.CodigoHttp, ex.Message);
            }
            catch (SqlException ex) when (ex.Number >= 50000 && ex.Number < 51000)
            {
                await ResponderAsync(context, ObtenerCodigoHttp(ex.Number), ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error no controlado");
                await ResponderAsync(context, StatusCodes.Status500InternalServerError,
                    "Ocurrió un error inesperado. Intente de nuevo");
            }
        }

        private static int ObtenerCodigoHttp(int numeroError) => numeroError switch
        {
            50040 => StatusCodes.Status404NotFound,   // correo sin cuenta
            50054 => StatusCodes.Status404NotFound,   // usuario no existe
            50053 => StatusCodes.Status409Conflict,   // correo en uso
            50061 => StatusCodes.Status409Conflict,   // ultimo administrador
            _ => StatusCodes.Status400BadRequest
        };

        private static async Task ResponderAsync(HttpContext context, int codigo, string mensaje)
        {
            if (context.Response.HasStarted) return;
            context.Response.StatusCode = codigo;
            await context.Response.WriteAsJsonAsync(new { mensaje });
        }
    }
}
