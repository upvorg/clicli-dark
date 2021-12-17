'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "canvaskit/canvaskit.js": "43fa9e17039a625450b6aba93baf521e",
"canvaskit/profiling/canvaskit.js": "f3bfccc993a1e0bfdd3440af60d99df4",
"canvaskit/profiling/canvaskit.wasm": "a9610cf39260f60fbe7524a785c66101",
"canvaskit/canvaskit.wasm": "04ed3c745ff1dee16504be01f9623498",
"main.dart.js": "c5fa21756b4481d627b01cdf1c64c4b9",
"version.json": "f12389f771071e08403f5c0bebdeb0d8",
"splash/img/light-background.png": "f349a1aa9eaa032b381262a7039bb9b1",
"splash/style.css": "5c74776d35b9e85d790997a9f2349a2d",
"manifest.json": "990cdc7b07d4a0f268e67ad5c22f12e4",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"assets/NOTICES": "e4b0552eb444fd4e8c4fca264d1695b3",
"assets/AssetManifest.json": "f2dd97f66838ed35ab9780087b634c5e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/assets/ic_ranking.svg": "0562fcf1cc2f4a6ba07e69704a75f2ac",
"assets/assets/%25E6%2588%2591%25E7%259A%2584.svg": "2f733a74915b3990a79b002f423df439",
"assets/assets/Sunny.svg": "e633283576de8f932b118afcf343bea3",
"assets/assets/play.svg": "f3165e2db784eaa89561180c7ee11456",
"assets/assets/Search.svg": "234a7afbd08bc279d262000dbce97881",
"assets/assets/Fire.svg": "0a093932e50811a6e18cd9100e260961",
"assets/assets/%25E5%2591%25A8.svg": "77e3b8deb43339a75a47b7cc91353677",
"assets/assets/share.svg": "0eac54206ae9919d16f062b369d253b2",
"assets/assets/collect.svg": "d753121153719fb1533dde0d62a3033b",
"assets/assets/play_outline.svg": "bca5179934726a23cbc5c164ccb41f45",
"assets/assets/no_photo.png": "ab2df94c62e31fe7b9e6ed12edb2b525",
"assets/assets/loading.gif": "ac94db59d0bee453a8d057bfa664fd33",
"assets/assets/Moon.svg": "cfc41dbd106dd2ca6dd13ce59ebe45a8",
"assets/assets/%25E7%2588%25B1%25E5%25BF%2583.svg": "c1229a6890b99393f41dc3767fe3a947",
"assets/assets/qq.svg": "ee8cf6252fee9fbc52e5e175c9b6f093",
"assets/assets/rxa-image-error-filled.svg": "02d86e254e5c59f71586e8c074fb3283",
"assets/assets/%25E5%2585%25B3%25E6%25B3%25A8.svg": "f8c1d331481ec4da43b9f251e9e281ec",
"assets/assets/login_bg.webp": "873f2643a94eac7e1a170002a7b0afff",
"assets/assets/error.png": "9febde4e2fbcd5906d6d5e1f007ab911",
"assets/assets/%25E7%25B3%25BB%25E7%25BB%259F%25E6%259B%25B4%25E6%2596%25B0.svg": "c3dfb21e7b316eb5fbb686863e43a89f",
"assets/assets/%25E5%258E%2586%25E5%258F%25B2.svg": "6e3b49e8a6aeab7afe193edb88aa2a4c",
"assets/assets/%25E5%258F%2591%25E7%258E%25B0.svg": "f9881a8407aa14596a46e18f047133f2",
"assets/assets/home-fill.svg": "9df37510ca114291ee79be89dfc73b38",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/packages/flutter_widget_from_html_core/test/images/logo.png": "57838d52c318faff743130c3fcfae0c6",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"index.html": "6fa8629e072253457390d9cd50776780",
"/": "6fa8629e072253457390d9cd50776780",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
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
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
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
