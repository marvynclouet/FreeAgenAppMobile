'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "5895cd607bf6e038195fd329db7a8c5d",
"version.json": "9a5f97e9a08536f5ce3bc9e294719b1b",
"index.html": "12d83fc3c3e30a58b9078a4a11937588",
"/": "12d83fc3c3e30a58b9078a4a11937588",
"main.dart.js": "4fdd2c1bb8fd752838e4e039e791fb97",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "2d959f21f6a028624b5ad2af81338ca6",
"assets/AssetManifest.json": "87beaf5a2e7b48f1787f08baafd09a79",
"assets/NOTICES": "53653f4853d794dbe2a3e0a792ee28f1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "e14f4cda98da037473b0446b3e0e127e",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "f68943c3d044aaf6225bc5171a99c2fe",
"assets/fonts/MaterialIcons-Regular.otf": "828eab177a5da11a6b9fd29e9e1837e2",
"assets/assets/Image%2520ChatGPT%25205%2520mai%25202025%2520(3).png": "86606410da7cdda5131addebb06c3771",
"assets/assets/Image%2520ChatGPT%25205%2520mai%25202025%2520Maquette%2520mobile.png": "ad7f72360654e8a74b7d633e9e9c757a",
"assets/assets/5%2520mai%25202025,%252011_34_29.png": "5de3879eaacc130577c0c5e433e749cb",
"assets/assets/dieat.png": "462dbc2c8b7ec26105deb51dd27135b2",
"assets/assets/Maquette%2520app%2520mobile%25205%2520mai%25202025.png": "913193ce9b176b75c6e56c9f073f7237",
"assets/assets/handibasket.png": "09048750f6c72523e991e9640d3017e4",
"assets/assets/PHOTO-2025-05-22-15-45-26.jpg": "0ae45e2d796cf58c337899fe01230eb8",
"assets/assets/Capture%2520d%25E2%2580%2599%25C3%25A9cran%25202025-05-04%2520%25C3%25A0%252023.50.23.png": "6b865915807fb99f0d62e9e5d53c8b42",
"assets/assets/Image%2520ChatGPT%25204%2520mai%25202025%2520Maquette%2520mobile.png": "3fb141508f0547b352237f0be15e6161",
"assets/assets/Capture%2520d%25E2%2580%2599%25C3%25A9cran%25202025-05-04%2520%25C3%25A0%252023.50.34.png": "a9665c9e3528032666113df34a2c5f61",
"assets/assets/Logo%2520Paris%2520Basketball.webp": "758b2f5b366a680025761ac2f67d13f3",
"assets/assets/players.png": "09048750f6c72523e991e9640d3017e4",
"assets/assets/Maquette%2520app%2520mobile%25205%2520mai%25202025%2520(3).png": "4732dd0baa5afeae45958c018a79ddfe",
"assets/assets/profile.jpg": "29ba01ce3b7f642a676eb9b47480b6f3",
"assets/assets/highlights.png": "5804e176021ce234842c3bb90666a13e",
"assets/assets/lawyers.png": "95774ada97870d59d19e840ee31a4838",
"assets/assets/StadeRennaisBasket.png": "44493b36789b49861ca63e2f90580a34",
"assets/assets/coach.png": "b7381a6bfc0c79af9801c19f6169e06b",
"assets/assets/IMG_8255.PNG": "29ba01ce3b7f642a676eb9b47480b6f3",
"assets/assets/teams.png": "0dbed50890f746093fd796229cbc94d3",
"assets/assets/player.png": "09048750f6c72523e991e9640d3017e4",
"assets/assets/Logo%2520Asvel%2520Homme%25202020.png": "128827688001b964f33061dce0c18445",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
