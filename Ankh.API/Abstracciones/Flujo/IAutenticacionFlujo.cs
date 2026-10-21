using Abstracciones.Modelos;

namespace Abstracciones.Flujo
{
    public interface IAutenticacionFlujo
    {
        Task<LoginRespuesta> LoginAsync(LoginRequest login);
        Task LogoutAsync(Guid idSesion);
    }
}
