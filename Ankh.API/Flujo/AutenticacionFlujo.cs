using Abstracciones.DA;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Abstracciones.Reglas;

namespace Flujo
{
    public class AutenticacionFlujo : IAutenticacionFlujo
    {
        private readonly IAutenticacionBC _autenticacionBC;
        private readonly ISesionDA _sesionDA;

        public AutenticacionFlujo(IAutenticacionBC autenticacionBC, ISesionDA sesionDA)
        {
            _autenticacionBC = autenticacionBC;
            _sesionDA = sesionDA;
        }

        public async Task<LoginRespuesta> LoginAsync(LoginRequest login)
        {
            return await _autenticacionBC.LoginAsync(login);
        }

        public async Task LogoutAsync(Guid idSesion)
        {
            await _sesionDA.CerrarAsync(idSesion);
        }
    }
}
