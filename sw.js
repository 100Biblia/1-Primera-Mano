
// Fuerza actualización agresiva del SW para quitar el viejo
const SW_VERSION = 'pm-sw-robusto-' + Date.now(); 

// Nombres fijos de caché para mantener los datos entre actualizaciones
const SHELL_CACHE = 'pm-shell-cache';
const IMG_CACHE = 'pm-image-cache';

self.addEventListener('install', (event) => {
  self.skipWaiting(); // Obliga al navegador a usar este nuevo SW inmediatamente
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        // Solo borramos cachés que no sean los nuestros fijos
        keys.filter(k => k !== SHELL_CACHE && k !== IMG_CACHE && k.startsWith('pm-')).map(k => caches.delete(k))
      );
    })
  );
  self.clients.claim(); // Toma control de las pestañas abiertas
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);

  // Ignorar peticiones externas de analíticas o whatsapp
  if (url.hostname.includes('goatcounter') || url.hostname.includes('gc.zgo.at') || url.hostname.includes('wa.me')) return;

  // 1. IMÁGENES: Cache-First
  // Las fotos no cambian, si están en memoria, se cargan instantáneo. Si no, se descargan.
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

  // 2. HTML Y RESTO: Stale-While-Revalidate (El algoritmo más robusto)
  // Devuelve la memoria INMEDIATAMENTE (cero pantalla blanca). 
  // En segundo plano, descarga la versión nueva silenciosamente.
  event.respondWith(
    caches.match(event.request).then(cachedResponse => {
      // Lanzar petición de red silenciosa
      const fetchPromise = fetch(event.request).then(networkResponse => {
        if (networkResponse.ok) {
          const clone = networkResponse.clone();
          caches.open(SHELL_CACHE).then(cache => {
             cache.put(event.request, clone);
          });
        }
        return networkResponse;
      }).catch(() => {
        // Falla en background porque el usuario no tiene internet. 
        // No pasa nada, igual estamos mostrando la caché.
      });

      // Lo importante: si hay caché, devuélvelo AL INSTANTE.
      // Si el cliente es 100% nuevo y no tiene caché, espera a la red.
      return cachedResponse || fetchPromise.then(res => {
        if (res) return res;
        // Si no hay red ni caché (caso extremo primerizo sin internet)
        return new Response('<h1 style="color:#d4af37;text-align:center;margin-top:40vh;font-family:sans-serif">📡 Sin conexión a internet</h1>', {
          headers: { 'Content-Type': 'text/html; charset=utf-8' }
        });
      });
    })
  );
});
