namespace Abstracciones.Reglas
{
    public interface IContrasenaBC
    {
        string Hashear(string password);
        bool Verificar(string password, string hash);
        string GenerarTemporal();
        (string Token, string Hash) GenerarTokenRecuperacion();
        string HashearToken(string token);
    }
}
