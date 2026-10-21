using Abstracciones.DA;
using Abstracciones.Flujo;
using Abstracciones.Modelos;

namespace Flujo
{
    public class MarcaFlujo : IMarcaFlujo
    {
        private readonly IMarcaDA _marcaDA;

        public MarcaFlujo(IMarcaDA marcaDA)
        {
            _marcaDA = marcaDA;
        }

        public async Task<Guid> CrearAsync(MarcaCrear marca) => await _marcaDA.CrearAsync(marca.Nombre.Trim());

        public async Task ActualizarAsync(Guid id, MarcaCrear marca) => await _marcaDA.ActualizarAsync(id, marca.Nombre.Trim());

        public async Task EliminarAsync(Guid id) => await _marcaDA.EliminarAsync(id);

        public async Task<IEnumerable<Marca>> ListarAsync() => await _marcaDA.ListarAsync();
    }
}
