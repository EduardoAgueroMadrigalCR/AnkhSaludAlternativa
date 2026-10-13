using Abstracciones.DA;
using Abstracciones.Excepciones;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using Microsoft.AspNetCore.Http;

namespace Flujo
{
    public class CategoriaFlujo : ICategoriaFlujo
    {
        private readonly ICategoriaDA _categoriaDA;

        public CategoriaFlujo(ICategoriaDA categoriaDA)
        {
            _categoriaDA = categoriaDA;
        }

        public async Task<IEnumerable<Categoria>> ListarAsync() => await _categoriaDA.ListarAsync();

        public async Task<Categoria> ObtenerAsync(int id)
        {
            return await _categoriaDA.ObtenerPorIdAsync(id)
                ?? throw new ReglaNegocioException(StatusCodes.Status404NotFound, "La categoría no existe");
        }

        public async Task<Categoria> CrearAsync(CategoriaCrear categoria, Guid idUsuario)
        {
            var id = await _categoriaDA.CrearAsync(categoria.Nombre.Trim(), LimpiarOpcional(categoria.Descripcion), idUsuario);
            return await ObtenerAsync(id);
        }

        public async Task ActualizarAsync(int id, CategoriaActualizar categoria, Guid idUsuario)
        {
            await _categoriaDA.ActualizarAsync(id, categoria.Nombre.Trim(), LimpiarOpcional(categoria.Descripcion),
                categoria.Activa, idUsuario);
        }

        private static string? LimpiarOpcional(string? texto)
            => string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
    }
}
