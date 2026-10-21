using Abstracciones.DA;
using Abstracciones.Excepciones;
using Abstracciones.Flujo;
using Abstracciones.Modelos;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;

namespace Flujo
{
    public class ProductoFlujo : IProductoFlujo
    {

        private static readonly string[] ColumnasRequeridas =
            { "CodigoProducto", "Nombre", "Marca", "Categoria", "Precio", "Stock" };

        private readonly IProductoDA _productoDA;
        private readonly IMarcaDA _marcaDA;
        private readonly ICategoriaDA _categoriaDA;

        public ProductoFlujo(IProductoDA productoDA, IMarcaDA marcaDA, ICategoriaDA categoriaDA)
        {
            _productoDA = productoDA;
            _marcaDA = marcaDA;
            _categoriaDA = categoriaDA;
        }

        public async Task<Guid> CrearAsync(ProductoCrear producto, Guid idUsuario)
            => await _productoDA.CrearAsync(Normalizar(producto), idUsuario);

        public async Task ActualizarAsync(Guid id, ProductoCrear producto, Guid idUsuario)
            => await _productoDA.ActualizarAsync(id, Normalizar(producto), idUsuario);

        public async Task<Producto> ObtenerPorIdAsync(Guid id)
            => await _productoDA.ObtenerPorIdAsync(id) ?? throw new ReglaNegocioException(404, "El producto no existe");

        public async Task<IEnumerable<Producto>> ListarAsync() => await _productoDA.ListarAsync();

        public async Task<IEnumerable<Producto>> BuscarAsync(ProductoFiltro filtro) => await _productoDA.BuscarAsync(filtro);

        public async Task<IEnumerable<ProductoHistorialItem>> ObtenerHistorialAsync(Guid idProducto)
            => await _productoDA.ObtenerHistorialAsync(idProducto);

        // RF-12
        public async Task<DescontinuarResultado> DescontinuarAsync(Guid id, Guid idUsuario, bool forzar)
            => await _productoDA.DescontinuarAsync(id, idUsuario, forzar);

        public async Task ReactivarAsync(Guid id, Guid idUsuario) => await _productoDA.ReactivarAsync(id, idUsuario);

        private static ProductoCrear Normalizar(ProductoCrear p)
        {
            p.CodigoProducto = p.CodigoProducto.Trim();
            p.Nombre = p.Nombre.Trim();
            p.Descripcion = p.Descripcion?.Trim();
            p.ImagenUrl = string.IsNullOrWhiteSpace(p.ImagenUrl) ? null : p.ImagenUrl.Trim();
            return p;
        }

        public async Task<ImportacionResultado> ImportarAsync(IFormFile archivo, Guid idUsuario)
        {
            if (archivo == null || archivo.Length == 0)
                throw new ReglaNegocioException(400, "Debe adjuntar un archivo");

            if (!Path.GetExtension(archivo.FileName).Equals(".xlsx", StringComparison.OrdinalIgnoreCase))
                throw new ReglaNegocioException(400, "Formato de archivo no válido. Debe ser un Excel (.xlsx)");

            using var stream = new MemoryStream();
            await archivo.CopyToAsync(stream);
            stream.Position = 0;

            XLWorkbook libro;
            try
            {
                libro = new XLWorkbook(stream);
            }
            catch
            {
                throw new ReglaNegocioException(400, "Formato de archivo no válido. Verifique que sea un Excel (.xlsx) sin daños");
            }

            using (libro)
            {
                var hoja = libro.Worksheets.FirstOrDefault()
                    ?? throw new ReglaNegocioException(400, "Formato de archivo no válido. El archivo no tiene hojas");
                return await ImportarDesdeHojaAsync(hoja, idUsuario);
            }
        }

        private async Task<ImportacionResultado> ImportarDesdeHojaAsync(IXLWorksheet hoja, Guid idUsuario)
        {
            var filaEncabezado = hoja.Row(1);
            var columnas = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var celda in filaEncabezado.CellsUsed())
            {
                var titulo = celda.GetString().Trim();
                if (!string.IsNullOrEmpty(titulo)) columnas[titulo] = celda.Address.ColumnNumber;
            }

            var faltantes = ColumnasRequeridas.Where(c => !columnas.ContainsKey(c)).ToList();
            if (faltantes.Count > 0)
                throw new ReglaNegocioException(400,
                    $"Formato de archivo no válido. Faltan las columnas: {string.Join(", ", faltantes)}");

            var marcasExistentes = (await _marcaDA.ListarAsync())
                .ToDictionary(m => m.Nombre, m => m.Id, StringComparer.OrdinalIgnoreCase);
            var categoriasExistentes = (await _categoriaDA.ListarAsync())
                .ToDictionary(c => c.Nombre, c => c.Id, StringComparer.OrdinalIgnoreCase);
            var codigosEnArchivo = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            var resultado = new ImportacionResultado();
            var ultimaFila = hoja.LastRowUsed()?.RowNumber() ?? 1;

            for (int numeroFila = 2; numeroFila <= ultimaFila; numeroFila++)
            {
                var fila = hoja.Row(numeroFila);
                if (fila.IsEmpty()) continue;
                resultado.TotalFilas++;

                string Texto(string columna) => columnas.TryGetValue(columna, out var col)
                    ? fila.Cell(col).GetString().Trim() : string.Empty;

                var codigo = Texto("CodigoProducto");
                var nombre = Texto("Nombre");
                var nombreMarca = Texto("Marca");
                var nombreCategoria = Texto("Categoria");
                var descripcion = columnas.ContainsKey("Descripcion") ? Texto("Descripcion") : null;
                var imagen = columnas.ContainsKey("Imagen") ? Texto("Imagen") : null;

                if (string.IsNullOrEmpty(codigo) || string.IsNullOrEmpty(nombre) ||
                    string.IsNullOrEmpty(nombreMarca) || string.IsNullOrEmpty(nombreCategoria))
                {
                    resultado.Omitidos.Add(Omitido(numeroFila, "Faltan datos obligatorios (código, nombre, marca o categoría)"));
                    continue;
                }
                if (!codigosEnArchivo.Add(codigo))
                {
                    resultado.Omitidos.Add(Omitido(numeroFila, $"El código '{codigo}' está repetido dentro del archivo"));
                    continue;
                }
                if (!decimal.TryParse(Texto("Precio"), out var precio) || precio < 0)
                {
                    resultado.Omitidos.Add(Omitido(numeroFila, "El precio no es un número válido"));
                    continue;
                }
                if (!int.TryParse(Texto("Stock"), out var stock) || stock < 0)
                {
                    resultado.Omitidos.Add(Omitido(numeroFila, "El stock no es un número entero válido"));
                    continue;
                }

                try
                {
                    var idMarca = await ObtenerOCrearAsync(marcasExistentes, nombreMarca, _marcaDA.CrearAsync);
                    var idCategoria = await ObtenerOCrearAsync(categoriasExistentes, nombreCategoria, _categoriaDA.CrearAsync);

                    await _productoDA.CrearAsync(new ProductoCrear
                    {
                        CodigoProducto = codigo,
                        Nombre = nombre,
                        Descripcion = descripcion,
                        ImagenUrl = string.IsNullOrWhiteSpace(imagen) ? null : imagen,
                        IdMarca = idMarca,
                        IdCategoria = idCategoria,
                        Precio = precio,
                        Stock = stock
                    }, idUsuario);

                    resultado.Importados++;
                }
                catch (ReglaNegocioException ex)
                {
                    resultado.Omitidos.Add(Omitido(numeroFila, ex.Message));
                }
                catch (System.Data.SqlClient.SqlException ex) when (ex.Number >= 50000 && ex.Number < 51000)
                {

                    resultado.Omitidos.Add(Omitido(numeroFila, ex.Message));
                }
            }

            return resultado;
        }

        private static ImportacionFilaOmitida Omitido(int fila, string motivo) => new() { Fila = fila, Motivo = motivo };

        private static async Task<Guid> ObtenerOCrearAsync(Dictionary<string, Guid> cache, string nombre, Func<string, Task<Guid>> crear)
        {
            if (cache.TryGetValue(nombre, out var id)) return id;
            id = await crear(nombre);
            cache[nombre] = id;
            return id;
        }
    }
}
