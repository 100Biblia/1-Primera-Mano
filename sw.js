
const CACHE_VERSION = 'pm-v2-parcial'; // Forzando actualización
const SHELL_CACHE = CACHE_VERSION + '-shell';
const IMG_CACHE = CACHE_VERSION + '-images';

self.addEventListener('install', (event) => {
  self.skipWaiting(); // Toma control instantáneamente
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter(k => k !== SHELL_CACHE && k !== IMG_CACHE).map(k => caches.delete(k))
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);

  // Ignorar analytics
  if (url.hostname.includes('goatcounter') || url.hostname.includes('gc.zgo.at')) return;

  // IMÁGENES: Cache-First. Las fotos NO se vuelven a descargar nunca si ya se vieron. Ahorra muchísimos datos.
  if (url.pathname.match(/\.(webp|jpg|jpeg|png|gif|svg)$/i)) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        return cached || fetch(event.request).then(response => {
          if (response.ok) {
            const clone = response.clone();
            caches.open(IMG_CACHE).then(cache => cache.put(event.request, clone));
          }
          return response;
        });
      })
    );
    return;
  }

  // HTML, CSS, JS: Network-First. SIEMPRE intenta descargar la última versión de los precios y productos. 
  // Si no hay internet, entonces muestra lo último que vio. (Caché Parcial)
  event.respondWith(
    fetch(event.request).then(response => {
      if (response.ok) {
        const clone = response.clone();
        caches.open(SHELL_CACHE).then(cache => cache.put(event.request, clone));
      }
      return response;
    }).catch(() => {
      // Si el fetch falla (offline), devolvemos lo cacheado
      return caches.match(event.request).then(cached => {
        if (cached) return cached;
        return new Response('<h1 style="color:#d4af37;text-align:center;margin-top:40vh;font-family:sans-serif">📡 Sin conexión a internet y no hay datos guardados.</h1>', {
          headers: { 'Content-Type': 'text/html; charset=utf-8' }
        });
      });
    })
  );
});
