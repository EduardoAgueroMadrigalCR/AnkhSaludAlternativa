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

const promotions = window.homePromotions || [];
let currentPromotionIndex = 0;
let userState = getUserState();
const state = { cart: [], orders: [] };

const homeProducts = [
  {
    id: 1,
    name: 'Ashwagandha Premium',
    category: 'Bienestar',
    description: 'Suplemento herbal para equilibrio y energía diaria.',
    image: 'images/ASHWAGANDHA.jpg',
    price: 82000,
    inStock: true,
    discount: true,
    isNew: false
  },
  {
    id: 2,
    name: 'Vitamina D3 + B12',
    category: 'Salud',
    description: 'Fórmula para energía, inmunidad y soporte óseo.',
    image: 'images/D3+B12.jpg',
    price: 49500,
    inStock: true,
    discount: false,
    isNew: true
  },
  {
    id: 3,
    name: 'Colágeno Marino',
    category: 'Belleza',
    description: 'Refuerza piel, cabello y articulaciones con colágeno puro.',
    image: 'images/COLAGENOMARINO.png',
    price: 142000,
    inStock: true,
    discount: true,
    isNew: false
  },
  {
    id: 4,
    name: 'DHEA 10mg',
    category: 'Vitalidad',
    description: 'Apoya bienestar hormonal y energía natural.',
    image: 'images/DHEA10MG.jpg',
    price: 78000,
    inStock: false,
    discount: false,
    isNew: false
  },
  {
    id: 5,
    name: 'Pasta dental fresca',
    category: 'Cuidado',
    description: 'Protección dental diaria con sensación fresca.',
    image: 'images/TOOTHPASTE.jpg',
    price: 18900,
    inStock: true,
    discount: false,
    isNew: true
  }
];

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
      price: 'Desde $99.000',
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
  return '$' + value.toLocaleString('es-CO');
}

function loadCart() {
  const saved = localStorage.getItem('ankh-cart');
  state.cart = saved ? JSON.parse(saved) : [];
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
  const orderItems = state.cart.map(cartItem => {
    const product = homeProducts.find(product => product.id === cartItem.id);
    return {
      id: cartItem.id,
      name: product.name,
      quantity: cartItem.quantity,
      price: product.price,
      subtotal: product.price * cartItem.quantity
    };
  });

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

function renderHomeProducts() {
  const productCount = document.getElementById('productCount');
  if (productCount) {
    productCount.textContent = `${homeProducts.length} productos`;
  }

  homeProductGrid.innerHTML = homeProducts.map(product => {
    const isAdded = state.cart.some(item => item.id === product.id);
    return `
      <article class="product-preview-card" data-id="${product.id}">
        <img src="${product.image}" alt="${product.name}" />
        <div class="product-preview-content">
          <strong>${product.name}</strong>
          <span class="badge badge-light">${product.category}</span>
          <p>${product.description}</p>
          <div class="promo-card-footer">
            <strong>${formatMoney(product.price)}</strong>
            <button class="button-primary add-btn" data-id="${product.id}" type="button">${isAdded ? 'Eliminar' : 'Agregar'}</button>
          </div>
        </div>
      </article>
    `;
  }).join('');

  homeProductGrid.querySelectorAll('.product-preview-card').forEach(card => {
    card.addEventListener('click', event => {
      const buttonClicked = event.target.closest('.add-btn');
      if (buttonClicked) return;
      const productId = Number(card.dataset.id);
      window.location.href = `producto.html?id=${productId}`;
    });
  });

  homeProductGrid.querySelectorAll('.add-btn').forEach(button => {
    button.addEventListener('click', event => {
      event.stopPropagation();
      toggleCartItem(Number(button.dataset.id));
    });
  });
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

  cartList.innerHTML = state.cart.map(item => {
    const product = homeProducts.find(product => product.id === item.id);
    const subtotal = product.price * item.quantity;
    return `
      <div class="cart-item" data-id="${item.id}">
        <div class="cart-item-details">
          <strong>${product.name}</strong>
          <div class="cart-item-meta">
            <span>${formatMoney(product.price)} c/u</span>
            <span>Cantidad: ${item.quantity}</span>
          </div>
          <small>Subtotal: ${formatMoney(subtotal)}</small>
        </div>
        <div class="cart-item-actions">
          <div class="quantity-row">
            <button class="button-secondary" data-id="${item.id}" data-action="decrease">−</button>
            <span>${item.quantity}</span>
            <button class="button-secondary" data-id="${item.id}" data-action="increase">+</button>
          </div>
          <button class="button-tertiary remove-item" data-id="${item.id}">Eliminar</button>
        </div>
      </div>
    `;
  }).join('');

  const total = state.cart.reduce((sum, item) => {
    const product = homeProducts.find(product => product.id === item.id);
    return sum + product.price * item.quantity;
  }, 0);

  if (cartTotal) cartTotal.textContent = formatMoney(total);

  cartList.querySelectorAll('.remove-item').forEach(button => {
    button.addEventListener('click', () => removeItem(Number(button.dataset.id)));
  });
  cartList.querySelectorAll('[data-action]').forEach(button => {
    button.addEventListener('click', () => changeQuantity(Number(button.dataset.id), button.dataset.action));
  });
}

function addToCart(productId) {
  resetReceiptView();
  const existing = state.cart.find(item => item.id === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    state.cart.push({ id: productId, quantity: 1 });
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
  renderHomeProducts();
  renderCart();
  updateCartBadge();

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