using Abstracciones.Reglas;
using System.Security.Cryptography;
using System.Text;

namespace Reglas
{
    public class ContrasenaReglas : IContrasenaBC
    {
        private const string Mayusculas = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        private const string Minusculas = "abcdefghijkmnopqrstuvwxyz";
        private const string Digitos = "23456789";
        private const string Simbolos = "!@#$%*?";

        public string Hashear(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password, 11);
        }

        public bool Verificar(string password, string hash)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, hash);
            }
            catch
            {
                return false;
            }
        }

        public string GenerarTemporal()
        {
            var caracteres = new List<char>();
            for (int i = 0; i < 3; i++)
            {
                caracteres.Add(Mayusculas[RandomNumberGenerator.GetInt32(Mayusculas.Length)]);
                caracteres.Add(Minusculas[RandomNumberGenerator.GetInt32(Minusculas.Length)]);
                caracteres.Add(Digitos[RandomNumberGenerator.GetInt32(Digitos.Length)]);
                caracteres.Add(Simbolos[RandomNumberGenerator.GetInt32(Simbolos.Length)]);
            }
            for (int i = caracteres.Count - 1; i > 0; i--)
            {
                int j = RandomNumberGenerator.GetInt32(i + 1);
                (caracteres[i], caracteres[j]) = (caracteres[j], caracteres[i]);
            }
            return new string(caracteres.ToArray());
        }

        public (string Token, string Hash) GenerarTokenRecuperacion()
        {
            var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
                .Replace('+', '-').Replace('/', '_').TrimEnd('=');
            return (token, HashearToken(token));
        }

        public string HashearToken(string token)
        {
            return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
        }
    }
}
