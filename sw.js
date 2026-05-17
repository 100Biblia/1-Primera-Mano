// ===============================================================
//  SERVICE WORKER — Caché Multicapa para Primera Mano
//  Optimizado para conexiones ultra-lentas (Cuba)
// ===============================================================

const CACHE_VERSION = 'pm-v1';
const SHELL_CACHE = CACHE_VERSION + '-shell';
const IMG_CACHE = CACHE_VERSION + '-images';
const DYNAMIC_CACHE = CACHE_VERSION + '-dynamic';

// Archivos críticos que se cachean al instalar (carga instantánea)
const SHELL_FILES = [
  '/1-Primera-Mano/',
  '/1-Primera-Mano/index.html',
  '/1-Primera-Mano/manifest.json',
  '/1-Primera-Mano/icons/icon-192.png'
];

// ──────────── INSTALACIÓN ────────────
self.addEventListener('install', (event) => {
  console.log('[SW] Instalando Service Worker...');
  event.waitUntil(
    caches.open(SHELL_CACHE).then((cache) => {
      return cache.addAll(SHELL_FILES).catch(err => {
        console.warn('[SW] Algunos archivos no se pudieron cachear:', err);
      });
    })
  );
  self.skipWaiting();
});

// ──────────── ACTIVACIÓN: Limpiar cachés viejas ────────────
self.addEventListener('activate', (event) => {
  console.log('[SW] Activando...');
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter(k => !k.startsWith(CACHE_VERSION))
            .map(k => caches.delete(k))
      );
    })
  );
  self.clients.claim();
});

// ──────────── ESTRATEGIA DE FETCH ────────────
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Ignorar peticiones que no sean GET
  if (event.request.method !== 'GET') return;

  // Ignorar analytics y scripts externos
  if (url.hostname.includes('goatcounter') || url.hostname.includes('gc.zgo.at')) return;

  // IMÁGENES: Cache-first (nunca recargar si ya está en caché)
  if (isImage(event.request)) {
    event.respondWith(cacheFirst(event.request, IMG_CACHE));
    return;
  }

  // HTML PRINCIPAL: Stale-while-revalidate (mostrar caché + actualizar en background)
  if (event.request.mode === 'navigate' || url.pathname.endsWith('.html') || url.pathname.endsWith('/')) {
    event.respondWith(staleWhileRevalidate(event.request, SHELL_CACHE));
    return;
  }

  // TODO LO DEMÁS: Cache-first con fallback a red
  event.respondWith(cacheFirst(event.request, DYNAMIC_CACHE));
});

// ──────────── ESTRATEGIAS ────────────

// Cache-first: Prioridad absoluta al caché local
async function cacheFirst(request, cacheName) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(cacheName);
      cache.put(request, response.clone());
    }
    return response;
  } catch (e) {
    // Sin conexión y sin caché: devolver página offline genérica
    return new Response('<h1 style="text-align:center;margin-top:40vh;font-family:sans-serif;color:#d4af37">📡 Sin conexión</h1>', {
      headers: { 'Content-Type': 'text/html' }
    });
  }
}

// Stale-while-revalidate: Mostrar caché inmediatamente + actualizar en background
async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  const fetchPromise = fetch(request).then(async (response) => {
    if (response.ok) {
      // Comparar con la versión cacheada
      const newText = await response.clone().text();
      let hasChanged = true;

      if (cached) {
        const oldText = await cached.clone().text();
        hasChanged = oldText !== newText;
      }

      // Guardar la nueva versión
      await cache.put(request, response.clone());

      // Si cambió, notificar a la página para mostrar banner de actualización
      if (hasChanged && cached) {
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
          client.postMessage({ type: 'CONTENT_UPDATED' });
        });
      }
    }
    return response;
  }).catch(() => cached);

  // Devolver la versión cacheada inmediatamente (o esperar la red si no hay caché)
  return cached || fetchPromise;
}

// ──────────── UTILIDADES ────────────
function isImage(request) {
  const url = request.url.toLowerCase();
  return url.endsWith('.webp') || url.endsWith('.jpg') || url.endsWith('.jpeg') ||
         url.endsWith('.png') || url.endsWith('.gif') || url.endsWith('.svg');
}
