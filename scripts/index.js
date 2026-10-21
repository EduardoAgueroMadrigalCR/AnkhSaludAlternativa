const navProfile = document.getElementById('navProfile');
const mainActionBtn = document.getElementById('mainActionBtn');
const promoImage = document.getElementById('promoImage');
const promoTitle = document.getElementById('promoTitle');
const promoDescription = document.getElementById('promoDescription');
const promoLabel = document.getElementById('promoLabel');
const promoPrice = document.getElementById('promoPrice');
const promoButton = document.getElementById('promoButton');
const promoPrev = document.getElementById('promoPrev');
const promoNext = document.getElementById('promoNext');
const homeProductGrid = document.getElementById('homeProductGrid');
const cartCount = document.getElementById('cartCount');
const cartDrawer = document.getElementById('cartDrawer');
const cartToggle = document.getElementById('cartToggle');
const closeCart = document.getElementById('closeCart');
const cartList = document.getElementById('cartList');
const cartTotal = document.getElementById('cartTotal');
const checkoutForm = document.getElementById('checkoutForm');
const checkoutReceipt = document.getElementById('checkoutReceipt');
const checkoutMessage = document.getElementById('checkoutMessage');
const searchInput = document.getElementById('searchInput');
const brandSelect = document.getElementById('brandSelect');
const categoryButtons = document.getElementById('categoryButtons');
const sortSelect = document.getElementById('sortSelect');
const filterStock = document.getElementById('filterStock');
const filterNew = document.getElementById('filterNew');
const clearFilters = document.getElementById('clearFilters');

const promotions = window.homePromotions || [];
let currentPromotionIndex = 0;
let userState = getUserState();
const state = { cart: [], orders: [] };


const filtros = { texto: '', idMarca: '', idCategoria: '', soloStock: true, soloNuevos: false, orden: 'popular' };
let categorias = [];
let catalogo = [];         
let errorCatalogo = '';
let temporizadorBusqueda = null;
const IMAGEN_POR_DEFECTO = 'images/ANKH-logo.png';


function esc(valor) {
  return String(valor == null ? '' : valor)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function getUserState() {
  const saved = localStorage.getItem('ankh-state');
  if (!saved) return { loggedIn: false };
  try {
    const parsed = JSON.parse(saved);
    return parsed.user || { loggedIn: false };
  } catch (error) {
    return { loggedIn: false };
  }
}

function getCurrentPromotion() {
  if (!promotions.length) {
    return {
      title: 'Promoción destacada',
      description: 'Disfruta descuentos especiales en productos seleccionados.',
      image: 'images/P5.jpg',
      label: 'Oferta limitada',
      price: 'Desde ₡99.000',
      link: 'index.html'
    };
  }
  return promotions[currentPromotionIndex];
}

function updateHeaderLink() {
  if (!navProfile) return;
  if (userState.loggedIn) {
    navProfile.textContent = 'Perfil';
    navProfile.href = 'perfil.html';
  } else {
    navProfile.textContent = 'Iniciar sesión';
    navProfile.href = 'login.html';
    const mainActionBtn = document.getElementById('mainActionBtn');
    if (mainActionBtn) {
      mainActionBtn.textContent = 'Iniciar sesión';
      mainActionBtn.href = 'login.html';
    }
  }
}

function renderPromotion() {
  const currentPromotion = getCurrentPromotion();
  promoImage.src = currentPromotion.image;
  promoImage.alt = currentPromotion.title;
  promoTitle.textContent = currentPromotion.title;
  promoDescription.textContent = currentPromotion.description;
  promoLabel.textContent = currentPromotion.label;
  promoPrice.textContent = currentPromotion.price;
  promoButton.href = currentPromotion.link;
}

function changePromotion(direction = 1) {
  if (!promotions.length) return;
  currentPromotionIndex = (currentPromotionIndex + direction + promotions.length) % promotions.length;
  renderPromotion();
}

function formatMoney(value) {
  return '₡' + value.toLocaleString('es-CO');
}

function loadCart() {
  const saved = localStorage.getItem('ankh-cart');
  let items = [];
  try { items = saved ? JSON.parse(saved) : []; } catch (error) { items = []; }

  state.cart = items.filter(item => typeof item.id === 'string' && item.name && item.price != null);
}

function saveCart() {
  localStorage.setItem('ankh-cart', JSON.stringify(state.cart));
}

function loadOrders() {
  const saved = localStorage.getItem('ankh-orders');
  state.orders = saved ? JSON.parse(saved) : [];
}

function saveOrders() {
  localStorage.setItem('ankh-orders', JSON.stringify(state.orders));
}

function resetReceiptView() {
  if (checkoutReceipt) {
    checkoutReceipt.classList.add('hidden');
    checkoutReceipt.innerHTML = '';
  }
  if (checkoutForm) {
    checkoutForm.classList.remove('hidden');
  }
  if (checkoutMessage) {
    checkoutMessage.classList.add('hidden');
  }
}

function createOrder(address) {
  const orderItems = state.cart.map(cartItem => ({
    id: cartItem.id,
    name: cartItem.name,
    quantity: cartItem.quantity,
    price: cartItem.price,
    subtotal: cartItem.price * cartItem.quantity
  }));

  const total = orderItems.reduce((sum, item) => sum + item.subtotal, 0);
  const order = {
    id: `PED-${Date.now()}`,
    date: new Date().toISOString(),
    address,
    total,
    items: orderItems,
    userName: userState.loggedIn ? userState.name : 'Invitado',
    userEmail: userState.loggedIn ? userState.email : ''
  };

  state.orders.unshift(order);
  saveOrders();
  return order;
}

function renderReceipt(order) {
  return `
    <div class="invoice-card">
      <div class="invoice-header">
        <span>Factura de compra</span>
        <strong>${order.id}</strong>
      </div>
      <div class="invoice-row">
        <span>Fecha</span>
        <strong>${new Date(order.date).toLocaleString('es-CO')}</strong>
      </div>
      ${order.items.map(item => `
        <div class="invoice-item">
          <span>${item.name} x${item.quantity}</span>
          <strong>${formatMoney(item.subtotal)}</strong>
        </div>
      `).join('')}
      <div class="invoice-total">
        <span>Total</span>
        <strong>${formatMoney(order.total)}</strong>
      </div>
      <div class="invoice-note">Dirección: ${order.address}</div>
      <div class="invoice-note">Cliente: ${order.userName}</div>
      <a class="button-secondary" href="pedido.html?orderId=${order.id}">Ver pedido</a>
    </div>
  `;
}

function updateCartBadge() {
  if (!cartCount) return;
  const totalCount = state.cart.reduce((sum, item) => sum + item.quantity, 0);
  cartCount.textContent = totalCount;
}

function esReciente(producto) {
  if (!producto.fechaCreacion) return false;
  const dias = (Date.now() - new Date(producto.fechaCreacion).getTime()) / 86400000;
  return dias <= 30;
}


function productosVisibles() {
  let lista = catalogo.slice();
  if (filtros.soloStock) lista = lista.filter(p => p.stock > 0);
  if (filtros.soloNuevos) lista = lista.filter(esReciente);

  if (filtros.orden === 'priceLow') lista.sort((a, b) => a.precio - b.precio);
  else if (filtros.orden === 'priceHigh') lista.sort((a, b) => b.precio - a.precio);
  else if (filtros.orden === 'newest') lista.sort((a, b) => new Date(b.fechaCreacion) - new Date(a.fechaCreacion));
  return lista;
}

function hayFiltrosActivos() {
  return !!(filtros.texto || filtros.idMarca || filtros.idCategoria || filtros.soloNuevos);
}

function renderHomeProducts() {
  const productCount = document.getElementById('productCount');
  const lista = productosVisibles();

  if (errorCatalogo) {
    if (productCount) productCount.textContent = '';
    homeProductGrid.innerHTML = `<div class="cart-empty">${esc(errorCatalogo)}</div>`;
    return;
  }

  if (productCount) productCount.textContent = `${lista.length} ${lista.length === 1 ? 'producto' : 'productos'}`;

  if (!lista.length) {
    homeProductGrid.innerHTML = `
      <div class="cart-empty">
        No se encontraron productos.
        ${hayFiltrosActivos() || filtros.soloStock ? 'Pruebe limpiando los filtros o con otra búsqueda.' : ''}
        <div style="margin-top:12px"><button type="button" class="button-secondary" id="emptyClear">Limpiar filtros</button></div>
      </div>`;
    const emptyClear = document.getElementById('emptyClear');
    if (emptyClear) emptyClear.addEventListener('click', limpiarFiltros);
    return;
  }

  homeProductGrid.innerHTML = lista.map(product => {
    const isAdded = state.cart.some(item => item.id === product.id);
    const agotado = product.stock <= 0;
    return `
      <article class="product-preview-card" data-id="${esc(product.id)}">
        <img src="${esc(product.imagenUrl || IMAGEN_POR_DEFECTO)}" alt="${esc(product.nombre)}"
             onerror="this.onerror=null;this.src='${IMAGEN_POR_DEFECTO}'" />
        <div class="product-preview-content">
          <strong>${esc(product.nombre)}</strong>
          <span class="badge badge-light">${esc(product.categoria)}</span>
          <span class="badge badge-light">${esc(product.marca)}</span>
          <p>${esc(product.descripcion || '')}</p>
          <div class="promo-card-footer">
            <strong>${formatMoney(product.precio)}</strong>
            <button class="button-primary add-btn" data-id="${esc(product.id)}" type="button" ${agotado && !isAdded ? 'disabled' : ''}>${isAdded ? 'Eliminar' : (agotado ? 'Agotado' : 'Agregar')}</button>
          </div>
        </div>
      </article>
    `;
  }).join('');

  homeProductGrid.querySelectorAll('.product-preview-card').forEach(card => {
    card.addEventListener('click', event => {
      const buttonClicked = event.target.closest('.add-btn');
      if (buttonClicked) return;
      window.location.href = `producto.html?id=${encodeURIComponent(card.dataset.id)}`;
    });
  });

  homeProductGrid.querySelectorAll('.add-btn').forEach(button => {
    button.addEventListener('click', event => {
      event.stopPropagation();
      toggleCartItem(button.dataset.id);
    });
  });
}


async function cargarCatalogo() {
  try {
    catalogo = await AnkhProductos.buscar(filtros.texto, filtros.idMarca, filtros.idCategoria);
    errorCatalogo = '';
  } catch (error) {
    catalogo = [];
    errorCatalogo = error.message;
  }
  renderHomeProducts();
}

function renderCategoryButtons() {
  const botones = [{ id: '', nombre: 'Todas' }, ...categorias];
  categoryButtons.innerHTML = botones.map(c => `
    <button type="button" class="category-pill ${filtros.idCategoria === c.id ? 'active' : ''}" data-category="${esc(c.id)}">${esc(c.nombre)}</button>
  `).join('');

  categoryButtons.querySelectorAll('.category-pill').forEach(button => {
    button.addEventListener('click', () => {
      filtros.idCategoria = button.dataset.category;
      renderCategoryButtons();
      cargarCatalogo();
    });
  });
}

async function cargarMarcasYCategorias() {
  try {
    const marcas = await AnkhProductos.listarMarcas();
    categorias = await AnkhProductos.listarCategorias();
    brandSelect.innerHTML = '<option value="">Todas las marcas</option>' +
      marcas.map(m => `<option value="${esc(m.id)}">${esc(m.nombre)}</option>`).join('');

  
    const porNombre = new URLSearchParams(window.location.search).get('categoria');
    if (porNombre) {
      const encontrada = categorias.find(c => c.nombre.toLowerCase() === porNombre.toLowerCase());
      if (encontrada) filtros.idCategoria = encontrada.id;
    }
  } catch (error) {
    categorias = [];
  }
  renderCategoryButtons();
}

function limpiarFiltros() {
  filtros.texto = ''; filtros.idMarca = ''; filtros.idCategoria = '';
  filtros.soloStock = true; filtros.soloNuevos = false; filtros.orden = 'popular';
  searchInput.value = '';
  brandSelect.value = '';
  sortSelect.value = 'popular';
  filterStock.checked = true;
  filterNew.checked = false;
  renderCategoryButtons();
  cargarCatalogo();
}

function toggleCartItem(productId) {
  if (state.cart.some(item => item.id === productId)) {
    removeItem(productId);
  } else {
    addToCart(productId);
  }
}

function renderCart() {
  if (!cartList) return;
  if (!state.cart.length) {
    cartList.innerHTML = '<div class="cart-empty">Tu carrito está vacío.</div>';
    if (cartTotal) cartTotal.textContent = formatMoney(0);
    return;
  }

  const IMAGEN_POR_DEFECTO = 'images/ANKH-logo.png';

  cartList.innerHTML = state.cart.map(item => {
    const subtotal = item.price * item.quantity;
    const imgPath = (item.imagenUrl && item.imagenUrl.trim() !== '') ? item.imagenUrl.trim() : IMAGEN_POR_DEFECTO;

    return `
      <div class="cart-item" data-id="${esc(item.id)}">
        <img 
          src="${esc(imgPath)}" 
          alt="${esc(item.name)}" 
          class="cart-item-img"
          onerror="this.onerror=null; this.src='${IMAGEN_POR_DEFECTO}';" 
        />
        <div class="cart-item-details">
          <strong>${esc(item.name)}</strong>
          <div class="cart-item-meta">
            <span>${formatMoney(item.price)} c/u</span>
            <span>Cantidad: ${item.quantity}</span>
          </div>
          <small>Subtotal: ${formatMoney(subtotal)}</small>
          <div class="cart-item-actions">
            <div class="quantity-row">
              <button class="button-secondary" data-id="${esc(item.id)}" data-action="decrease">−</button>
              <span>${item.quantity}</span>
              <button class="button-secondary" data-id="${esc(item.id)}" data-action="increase">+</button>
            </div>
            <button class="button-tertiary remove-item" data-id="${esc(item.id)}">Eliminar</button>
          </div>
        </div>
      </div>
    `;
  }).join('');


  const total = state.cart.reduce((sum, item) => sum + item.price * item.quantity, 0);

  if (cartTotal) cartTotal.textContent = formatMoney(total);

  cartList.querySelectorAll('.remove-item').forEach(button => {
    button.addEventListener('click', () => removeItem(button.dataset.id));
  });
  cartList.querySelectorAll('[data-action]').forEach(button => {
    button.addEventListener('click', () => changeQuantity(button.dataset.id, button.dataset.action));
  });
}

function addToCart(productId) {
  resetReceiptView();
  const existing = state.cart.find(item => item.id === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    const product = catalogo.find(p => p.id === productId);
    if (!product) return;

    state.cart.push({ 
  id: productId, 
  quantity: 1, 
  name: product.nombre, 
  price: product.precio,
  imagenUrl: product.imagenUrl || 'images/ANKH-logo.png' 
});
  }
  saveCart();
  updateCartBadge();
  renderCart();
  renderHomeProducts();
}

function removeItem(productId) {
  resetReceiptView();
  state.cart = state.cart.filter(item => item.id !== productId);
  saveCart();
  updateCartBadge();
  renderCart();
  renderHomeProducts();
}

function changeQuantity(productId, action) {
  resetReceiptView();
  const item = state.cart.find(entry => entry.id === productId);
  if (!item) return;
  item.quantity += action === 'increase' ? 1 : -1;
  if (item.quantity < 1) {
    state.cart = state.cart.filter(entry => entry.id !== productId);
  }
  saveCart();
  updateCartBadge();
  renderCart();
  renderHomeProducts();
}

function showCart() {
  if (cartDrawer) cartDrawer.classList.add('open');
}

function hideCart() {
  if (cartDrawer) cartDrawer.classList.remove('open');
}

function handleCheckout(event) {
  event.preventDefault();
  const addressInput = document.getElementById('checkoutAddress');
  const address = addressInput ? addressInput.value.trim() : '';
  if (!address) return;
  if (!state.cart.length) {
    if (checkoutMessage) {
      checkoutMessage.textContent = 'Agrega al menos un producto antes de pagar.';
      checkoutMessage.style.color = '#d32f2f';
      checkoutMessage.classList.remove('hidden');
    }
    return;
  }

  const order = createOrder(address);
  if (checkoutReceipt) {
    checkoutReceipt.innerHTML = renderReceipt(order);
    checkoutReceipt.classList.remove('hidden');
  }
  if (checkoutMessage) {
    checkoutMessage.textContent = 'Factura generada con éxito. Revisa tu pedido o sigue comprando.';
    checkoutMessage.style.color = 'var(--verde-principal)';
    checkoutMessage.classList.remove('hidden');
  }
  if (checkoutForm) {
    checkoutForm.classList.add('hidden');
  }

  state.cart = [];
  saveCart();
  updateCartBadge();
  renderCart();
  renderHomeProducts();
}

function initHome() {
  updateHeaderLink();
  loadCart();
  loadOrders();
  renderPromotion();
  renderCart();
  updateCartBadge();

  searchInput.addEventListener('input', () => {
    clearTimeout(temporizadorBusqueda);
    temporizadorBusqueda = setTimeout(() => { filtros.texto = searchInput.value.trim(); cargarCatalogo(); }, 300);
  });
  brandSelect.addEventListener('change', () => { filtros.idMarca = brandSelect.value; cargarCatalogo(); });
  sortSelect.addEventListener('change', () => { filtros.orden = sortSelect.value; renderHomeProducts(); });
  filterStock.addEventListener('change', () => { filtros.soloStock = filterStock.checked; renderHomeProducts(); });
  filterNew.addEventListener('change', () => { filtros.soloNuevos = filterNew.checked; renderHomeProducts(); });
  clearFilters.addEventListener('click', limpiarFiltros);

  cargarMarcasYCategorias().then(cargarCatalogo);

  if (promoPrev) {
    promoPrev.addEventListener('click', () => changePromotion(-1));
  }
  if (promoNext) {
    promoNext.addEventListener('click', () => changePromotion(1));
  }

  if (cartToggle) cartToggle.addEventListener('click', showCart);
  if (closeCart) closeCart.addEventListener('click', hideCart);
  if (checkoutForm) checkoutForm.addEventListener('submit', handleCheckout);

  setInterval(() => changePromotion(1), 7000);
}

initHome();
