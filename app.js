// Register Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').then(registration => {
      console.log('ServiceWorker registration successful');
    }).catch(err => {
      console.log('ServiceWorker registration failed: ', err);
    });
  });
}

let productsData = { combos: [], electrodomesticos: [], muebles: [] };

document.addEventListener('DOMContentLoaded', () => {
  fetch('products.json')
    .then(response => response.json())
    .then(data => {
      productsData = data;
      renderProducts('combos', data.combos);
      renderProducts('electrodomesticos', data.electrodomesticos);
      renderProducts('muebles', data.muebles);
      actualizarCarrito();
    })
    .catch(error => console.error('Error loading products:', error));
});

function renderProducts(categoryId, products) {
  // Find the gallery inside the section with id matching category or containing it
  let section = document.getElementById(categoryId) || document.querySelector(`section[id*="${categoryId}"]`);
  if (!section) return;
  const gallery = section.querySelector('.galeria');
  if (!gallery) return;

  gallery.innerHTML = '';
  
  if (products.length === 0) {
    gallery.innerHTML = '<p>No hay productos disponibles en esta categoría.</p>';
    return;
  }

  products.forEach(p => {
    const div = document.createElement('div');
    div.className = p.isAgotado ? 'producto agotado' : 'producto';
    div.innerHTML = `
      <img src="${p.image}" alt="${p.name}" onclick="abrirFoto('${p.image}', '${p.name}', event)">
      <h3>${p.name}</h3>
      <p>${p.description}</p>
      ${p.options && p.options.length > 0 ? 
        `<select class="selector-precio">
          ${p.options.map(opt => `<option value="${opt.value}">${opt.text}</option>`).join('')}
        </select>` 
        : '<p class="precio" style="display:none">0</p>'}
      ${p.isAgotado ? 
        `<button class="boton-agotado" disabled>Agotado</button>` : 
        `<button class="boton-carrito" onclick="agregarAlCarrito(this, '${p.name}')">Añadir al carrito 🛒</button>`}
    `;
    gallery.appendChild(div);
  });
}

// === Cart Logic ===
var carrito = [];
try { carrito = JSON.parse(localStorage.getItem("carrito")) || []; } catch(e) { carrito = []; }

function guardarCarrito() {
  localStorage.setItem("carrito", JSON.stringify(carrito));
}

function agregarAlCarrito(btnElement, nombre) {
  let container = btnElement.closest('.producto');
  let select = container.querySelector('.selector-precio');
  let precio = 0;
  
  if (select) {
    // If there's a select, get the price from the selected option value (assume value is numeric)
    precio = parseFloat(select.value.replace(/[^0-9.-]+/g,"")) || 0;
  }
  
  if (precio === 0) {
    // Try to parse from options text if value was not numeric
    if (select && select.options[select.selectedIndex]) {
        let txt = select.options[select.selectedIndex].text;
        let match = txt.match(/\$\s*(\d+(\.\d+)?)/);
        if (match) precio = parseFloat(match[1]);
    }
  }

  agregarAlCarritoReal(nombre, precio);
}

function agregarAlCarritoReal(nombre, precio) {
  carrito.push({ nombre: nombre, precio: precio });
  guardarCarrito();
  actualizarCarrito();
  
  // Visual feedback
  var toast = document.getElementById('custom-toast');
  if (toast) {
    var toastName = document.getElementById('toast-name');
    if (toastName) toastName.innerText = nombre;
    toast.style.display = 'block';
    toast.style.transform = 'translateX(0)';
    setTimeout(() => {
      toast.style.transform = 'translateX(150%)';
      setTimeout(() => { toast.style.display = 'none'; }, 400);
    }, 2500);
  }
}

function actualizarCarrito() {
  var lista = document.getElementById("lista-carrito");
  var totalSpan = document.getElementById("total");
  if (!lista || !totalSpan) return;

  lista.innerHTML = "";
  var total = 0;

  carrito.forEach((item, index) => {
    var li = document.createElement("li");
    li.innerHTML = `<span>${item.nombre} - $${item.precio.toLocaleString()}</span> <button class="item-remove" onclick="eliminarDelCarrito(${index})">❌</button>`;
    lista.appendChild(li);
    total += item.precio;
  });

  totalSpan.textContent = "Total: $" + total.toLocaleString();

  var badges = document.querySelectorAll('#contador-carrito, #cart-badge, #carrito-count');
  badges.forEach(b => {
    b.textContent = carrito.length;
    if (b.id === 'cart-badge') b.style.display = carrito.length > 0 ? 'flex' : 'none';
  });
}

window.eliminarDelCarrito = function(index) {
  carrito.splice(index, 1);
  guardarCarrito();
  actualizarCarrito();
}

window.vaciarCarrito = function() {
  if (carrito.length > 0 && confirm("¿Estás seguro de vaciar el carrito?")) {
    carrito.length = 0;
    guardarCarrito();
    actualizarCarrito();
  }
}

window.enviarWhatsApp = function() {
  if (carrito.length === 0) {
    alert("Tu carrito está vacío.");
    return;
  }

  var mensaje = "🛒 *Pedido desde el Catálogo Primera Mano:*\n\n";
  var total = 0;
  carrito.forEach(item => {
    mensaje += "• " + item.nombre + " - $" + item.precio.toLocaleString() + "\n";
    total += item.precio;
  });
  mensaje += "\n💰 *Total:* $" + total.toLocaleString() + "\n\n📞 Enviado desde el catálogo web.";

  var numeroWhatsApp = "5354449370";
  var url = "https://wa.me/" + numeroWhatsApp + "?text=" + encodeURIComponent(mensaje);
  window.open(url, "_blank");
}

window.toggleCarritoPanel = function() {
  var contenedor = document.getElementById("carrito-contenedor");
  if (contenedor) contenedor.classList.toggle("abierto");
}

window.toggleCarritoModal = window.toggleCarritoPanel;

// Modal details
window.abrirFoto = function(fullSrc, titulo, evt) {
  if (evt) evt.stopPropagation();
  var modal = document.getElementById('product-detail-modal');
  if (!modal) return;

  document.getElementById('product-detail-img').src = fullSrc;
  document.getElementById('product-detail-title').textContent = titulo;
  
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
}

window.cerrarDetalle = function() {
  var modal = document.getElementById('product-detail-modal');
  if (modal) {
    modal.style.display = 'none';
    document.body.style.overflow = '';
  }
}

window.filtrarProductos = function() {
  var q = document.getElementById('buscar-producto').value.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  document.querySelectorAll('.producto').forEach(function(p) {
    var name = p.querySelector('h3').textContent.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    var desc = p.querySelector('p').textContent.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    p.style.display = (name.includes(q) || desc.includes(q)) ? '' : 'none';
  });
}
