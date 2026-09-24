namespace Abstracciones.Modelos
{
    public class EstadoSesion
    {
        public int SegundosRestantes { get; set; }
        public int SegundosAviso { get; set; }
        public bool Valida => SegundosRestantes > 0;
        public bool DebeAvisar => Valida && SegundosRestantes <= SegundosAviso;
    }
}
