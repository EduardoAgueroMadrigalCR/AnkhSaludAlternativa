
const AnkhProductos = (() => {
  const get = (ruta) => AnkhApi.get(ruta);


  async function publico(ruta) {
    let respuesta;
    try {
      respuesta = await fetch(AnkhProductos.API_URL + ruta);
    } catch {
      throw new Error('No se pudo conectar con el servidor. Verifique que la API esté en ejecución.');
    }
    const texto = await respuesta.text();
    let datos = null;
    if (texto) { try { datos = JSON.parse(texto); } catch { /* sin JSON */ } }
    if (!respuesta.ok) throw new Error((datos && datos.mensaje) || 'Ocurrió un error inesperado');
    return datos;
  }
  const post = (ruta, cuerpo) => AnkhApi.post(ruta, cuerpo);
  const put = (ruta, cuerpo) => AnkhApi.put ? AnkhApi.put(ruta, cuerpo) : AnkhApi.post(ruta, cuerpo); // put ya existe en ankh-api.js

  async function eliminarConMetodo(ruta, metodo) {

    const actual = AnkhApi.sesion();
    const encabezados = { 'Content-Type': 'application/json' };
    if (actual) encabezados.Authorization = 'Bearer ' + actual.token;
    const respuesta = await fetch(ruta.startsWith('http') ? ruta : (AnkhProductos.API_URL + ruta), { method: metodo, headers: encabezados });
    let datos = null;
    const texto = await respuesta.text();
    if (texto) { try { datos = JSON.parse(texto); } catch {} }
    if (!respuesta.ok) throw new Error((datos && datos.mensaje) || 'Ocurrió un error inesperado');
    return datos;
  }

  return {

    buscar: (texto, idMarca, idCategoria) => {
      const parametros = new URLSearchParams();
      if (texto) parametros.set('texto', texto);
      if (idMarca) parametros.set('idMarca', idMarca);
      if (idCategoria) parametros.set('idCategoria', idCategoria);
      return publico('/Producto/Buscar?' + parametros.toString());
    },
    obtener: (id) => publico(`/Producto/${id}`),

    listarMarcas: () => publico('/Marca'),
    listarCategorias: () => publico('/Categoria'),
    crearMarca: (nombre) => post('/Marca', { nombre }),
    crearCategoria: (nombre) => post('/Categoria', { nombre }),
    actualizarMarca: (id, nombre) => put('/Marca/' + id, { nombre }),
    actualizarCategoria: (id, nombre) => put('/Categoria/' + id, { nombre }),
    eliminarMarca: (id) => eliminarConMetodo('/Marca/' + id, 'DELETE'),
    eliminarCategoria: (id) => eliminarConMetodo('/Categoria/' + id, 'DELETE'),

    listarTodos: () => get('/Producto'),
    crear: (producto) => post('/Producto', producto),
    actualizar: (id, producto) => put('/Producto/' + id, producto),
    historial: (id) => get(`/Producto/${id}/Historial`),

    descontinuar: (id, forzar = false) => put(`/Producto/${id}/Descontinuar?forzar=${forzar}`),
    reactivar: (id) => put(`/Producto/${id}/Reactivar`),
    eliminar: (id) => eliminarConMetodo('/Producto/' + id, 'DELETE'),

    async importar(archivo) {
      const actual = AnkhApi.sesion();
      const formData = new FormData();
      formData.append('archivo', archivo);
      const respuesta = await fetch(AnkhProductos.API_URL + '/Producto/Importar', {
        method: 'POST',
        headers: actual ? { Authorization: 'Bearer ' + actual.token } : {},
        body: formData
      });
      const datos = await respuesta.json().catch(() => null);
      if (!respuesta.ok) throw new Error((datos && datos.mensaje) || 'Ocurrió un error inesperado');
      return datos;
    }
  };
})();

AnkhProductos.API_URL = 'http://localhost:5049/api';
