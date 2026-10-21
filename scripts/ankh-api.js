/* ANKH - cliente de la API (RF-01 a RF-08)
   La interfaz NO tiene logica de negocio: solo llama a los endpoints de Ankh.API. */
const AnkhApi = (() => {
  // Debe coincidir con el "applicationUrl" https de API/Properties/launchSettings.json
  const API_URL = 'http://localhost:5049/api';
  const CLAVE_SESION = 'ankh-sesion';
  const SEGUNDOS_ENTRE_EXTENSIONES = 30;

  let sondeo = null;
  let cuentaRegresiva = null;
  let ultimaExtension = 0;
  let avisoVisible = false;
  let segundosRestantes = 0;

  function sesion() {
    try { return JSON.parse(sessionStorage.getItem(CLAVE_SESION)); } catch { return null; }
  }

  function guardarSesion(datos) {
    sessionStorage.setItem(CLAVE_SESION, JSON.stringify(datos));

    localStorage.setItem('ankh-state', JSON.stringify({ user: { name: datos.nombre, email: datos.correo, rol: datos.rol, loggedIn: true } }));
  }

  function limpiarSesion() {
    sessionStorage.removeItem(CLAVE_SESION);
    localStorage.removeItem('ankh-state');
    detenerControlSesion();
  }

  async function pedir(metodo, ruta, cuerpo, conToken = true) {
    const encabezados = { 'Content-Type': 'application/json' };
    const actual = sesion();
    if (conToken && actual) encabezados.Authorization = 'Bearer ' + actual.token;

    let respuesta;
    try {
      respuesta = await fetch(API_URL + ruta, {
        method: metodo,
        headers: encabezados,
        body: cuerpo ? JSON.stringify(cuerpo) : undefined
      });
    } catch {
      throw new Error('No se pudo conectar con el servidor. Verifique que la API esté en ejecución.');
    }

    let datos = null;
    const texto = await respuesta.text();
    if (texto) { try { datos = JSON.parse(texto); } catch { /* respuesta sin JSON */ } }

    if (respuesta.status === 401 && conToken) {
      limpiarSesion();
      sessionStorage.setItem('ankh-aviso', (datos && datos.mensaje) || 'Su sesión expiró. Inicie sesión de nuevo.');
      window.location.href = 'login.html';
      throw new Error('Sesión expirada');
    }
    if (!respuesta.ok) throw new Error((datos && datos.mensaje) || 'Ocurrió un error inesperado');
    return datos;
  }

  async function login(correo, password) {
    const r = await pedir('POST', '/Autenticacion/login', { correoElectronico: correo, password }, false);
    guardarSesion({ token: r.accessToken, idUsuario: r.idUsuario, nombre: r.nombre, rol: r.rol, correo, debeCambiarPassword: r.debeCambiarPassword });
    return r;
  }

  async function logout() {
    try { await pedir('POST', '/Autenticacion/logout'); } catch { /* aun asi se cierra localmente */ }
    limpiarSesion();
    window.location.href = 'login.html';
  }

  function requiereSesion() {
    const actual = sesion();
    if (!actual) { window.location.href = 'login.html'; return null; }
    iniciarControlSesion();
    pintarNav();
    return actual;
  }

  function requiereAdmin() {
    const actual = requiereSesion();
    if (actual && actual.rol !== 'Administrador') { window.location.href = 'index.html'; return null; }
    return actual;
  }

  function pintarNav() {
    const actual = sesion();
    const nav = document.querySelector('.site-nav');
    if (!nav || !actual) return;
    const agregar = (marca, href, texto) => {
      if (nav.querySelector(`[${marca}]`)) return;
      const enlace = document.createElement('a');
      enlace.href = href;
      enlace.textContent = texto;
      enlace.setAttribute(marca, '');
      nav.appendChild(enlace);
    };
    if (actual.rol === 'Administrador') agregar('data-usuarios', 'usuarios.html', 'Usuarios');
    if (actual.rol === 'Administrador' || actual.rol === 'Encargado de Inventario') agregar('data-catalogo', 'productos.html', 'Catálogo');
  }

  function iniciarControlSesion() {
    if (sondeo) return;

    const alActividad = () => {
      if (avisoVisible) return;
      const ahora = Date.now();
      if (ahora - ultimaExtension > SEGUNDOS_ENTRE_EXTENSIONES * 1000) {
        ultimaExtension = ahora;
        pedir('POST', '/Sesion/Extender').catch(() => {});
      }
    };
    ['click', 'keydown', 'scroll'].forEach(e => window.addEventListener(e, alActividad, { passive: true }));

    sondeo = setInterval(async () => {
      try {
        const estado = await pedir('GET', '/Sesion/Estado');
        if (estado.debeAvisar) mostrarAviso(estado.segundosRestantes);
      } catch { /* si la sesion expiro, pedir() redirige al login */ }
    }, 10000);
  }

  function detenerControlSesion() {
    clearInterval(sondeo); sondeo = null;
    clearInterval(cuentaRegresiva); cuentaRegresiva = null;
    avisoVisible = false;
  }

  function mostrarAviso(segundos) {
    if (avisoVisible) return;
    avisoVisible = true;
    segundosRestantes = segundos;

    const fondo = document.createElement('div');
    fondo.id = 'avisoSesion';
    fondo.className = 'aviso-sesion';
    fondo.innerHTML = `
      <div class="card aviso-sesion-caja" role="alertdialog" aria-live="assertive">
        <h2>Su sesión está por expirar</h2>
        <p>Por inactividad, la sesión se cerrará en <strong id="avisoSegundos">${segundos}</strong> segundos.</p>
        <div class="profile-actions" style="margin-top:18px">
          <button class="button-primary" id="avisoExtender">Mantener sesión</button>
          <button class="button-secondary" id="avisoSalir">Cerrar sesión</button>
        </div>
      </div>`;
    document.body.appendChild(fondo);

    cuentaRegresiva = setInterval(() => {
      segundosRestantes -= 1;
      const etiqueta = document.getElementById('avisoSegundos');
      if (etiqueta) etiqueta.textContent = Math.max(segundosRestantes, 0);
      if (segundosRestantes <= 0) {
        limpiarSesion();
        sessionStorage.setItem('ankh-aviso', 'Su sesión se cerró por inactividad.');
        window.location.href = 'login.html';
      }
    }, 1000);

    document.getElementById('avisoExtender').addEventListener('click', async () => {
      try {
        await pedir('POST', '/Sesion/Extender');
        clearInterval(cuentaRegresiva); cuentaRegresiva = null;
        avisoVisible = false;
        fondo.remove();
      } catch { /* pedir() redirige si ya expiro */ }
    });
    document.getElementById('avisoSalir').addEventListener('click', logout);
  }

  function esc(texto) {
    const d = document.createElement('div');
    d.textContent = texto == null ? '' : String(texto);
    return d.innerHTML;
  }

  function mostrar(elemento, texto, esError = false) {
    elemento.textContent = texto;
    elemento.classList.remove('hidden', 'status-ok', 'status-error');
    elemento.classList.add(esError ? 'status-error' : 'status-ok');
  }

  if (!sesion()) localStorage.removeItem('ankh-state');
  document.addEventListener('DOMContentLoaded', () => {
    if (sesion()) { iniciarControlSesion(); pintarNav(); }
  });

  return {
    sesion, login, logout, requiereSesion, requiereAdmin, esc, mostrar,
    get: (ruta) => pedir('GET', ruta),
    post: (ruta, cuerpo, conToken = true) => pedir('POST', ruta, cuerpo, conToken),
    put: (ruta, cuerpo) => pedir('PUT', ruta, cuerpo),
    actualizarSesion: (cambios) => { const s = sesion(); if (s) guardarSesion({ ...s, ...cambios }); }
  };
})();
