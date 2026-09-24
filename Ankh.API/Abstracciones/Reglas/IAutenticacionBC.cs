using Abstracciones.Modelos;

namespace Abstracciones.Reglas
{
    public interface IAutenticacionBC
    {
        Task<LoginRespuesta> LoginAsync(LoginRequest login);
    }
}
