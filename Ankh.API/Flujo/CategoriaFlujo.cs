using Abstracciones.DA;
using Abstracciones.Flujo;
using Abstracciones.Modelos;

namespace Flujo
{
    public class CategoriaFlujo : ICategoriaFlujo
    {
        private readonly ICategoriaDA _categoriaDA;

        public CategoriaFlujo(ICategoriaDA categoriaDA)
        {
            _categoriaDA = categoriaDA;
        }

        public async Task<Guid> CrearAsync(CategoriaCrear categoria) => await _categoriaDA.CrearAsync(categoria.Nombre.Trim());

        public async Task ActualizarAsync(Guid id, CategoriaCrear categoria) => await _categoriaDA.ActualizarAsync(id, categoria.Nombre.Trim());

        public async Task EliminarAsync(Guid id) => await _categoriaDA.EliminarAsync(id);

        public async Task<IEnumerable<Categoria>> ListarAsync() => await _categoriaDA.ListarAsync();
    }
}
