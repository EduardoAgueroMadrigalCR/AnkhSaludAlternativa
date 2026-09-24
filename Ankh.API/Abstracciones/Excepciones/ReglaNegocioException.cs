namespace Abstracciones.Excepciones
{
    /// <summary>
    /// Error controlado de negocio. El middleware de la API lo convierte en una respuesta HTTP con su mensaje.
    /// </summary>
    public class ReglaNegocioException : Exception
    {
        public int CodigoHttp { get; }

        public ReglaNegocioException(int codigoHttp, string mensaje) : base(mensaje)
        {
            CodigoHttp = codigoHttp;
        }
    }
}
