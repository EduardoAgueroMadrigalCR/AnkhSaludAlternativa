using Abstracciones.Modelos;

namespace Abstracciones.DA
{
    public interface IRecuperacionDA
    {
        Task<SolicitudRecuperacionResultado> SolicitarAsync(string correo, string tokenHash);
        Task RestablecerAsync(string tokenHash, string nuevoHash);
    }
}
