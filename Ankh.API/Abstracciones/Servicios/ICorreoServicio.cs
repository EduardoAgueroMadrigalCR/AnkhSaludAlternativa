namespace Abstracciones.Servicios
{
    public interface ICorreoServicio
    {
        /// <returns>true si el correo se envio (o se simulo en desarrollo), false si fallo.</returns>
        Task<bool> EnviarAsync(string destinatario, string asunto, string cuerpoHtml);
    }
}
