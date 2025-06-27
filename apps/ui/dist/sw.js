/**
 * Copyright 2018 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// If the loader is already loaded, just stop.
if (!self.define) {
  let registry = {};

  // Used for `eval` and `importScripts` where we can't get script URL by other means.
  // In both cases, it's safe to use a global var because those functions are synchronous.
  let nextDefineUri;

  const singleRequire = (uri, parentUri) => {
    uri = new URL(uri + ".js", parentUri).href;
    return registry[uri] || (

        new Promise(resolve => {
          if ("document" in self) {
            const script = document.createElement("script");
            script.src = uri;
            script.onload = resolve;
            document.head.appendChild(script);
          } else {
            nextDefineUri = uri;
            importScripts(uri);
            resolve();
          }
        })

      .then(() => {
        let promise = registry[uri];
        if (!promise) {
          throw new Error(`Module ${uri} didn’t register its module`);
        }
        return promise;
      })
    );
  };

  self.define = (depsNames, factory) => {
    const uri = nextDefineUri || ("document" in self ? document.currentScript.src : "") || location.href;
    if (registry[uri]) {
      // Module is already loading or loaded.
      return;
    }
    let exports = {};
    const require = depUri => singleRequire(depUri, uri);
    const specialDeps = {
      module: { uri },
      exports,
      require
    };
    registry[uri] = Promise.all(depsNames.map(
      depName => specialDeps[depName] || require(depName)
    )).then(deps => {
      factory(...deps);
      return exports;
    });
  };
}
define(['./workbox-c6c6fb7c'], (function (workbox) { 'use strict';

  self.addEventListener('message', event => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
      self.skipWaiting();
    }
  });

  /**
   * The precacheAndRoute() method efficiently caches and responds to
   * requests for URLs in the manifest.
   * See https://goo.gl/S9QRab
   */
  workbox.precacheAndRoute([{
    "url": "assets/About-C2jtc1U3.js",
    "revision": null
  }, {
    "url": "assets/Admin-36VAMV5K.js",
    "revision": null
  }, {
    "url": "assets/Callback-BHsiUm8K.js",
    "revision": null
  }, {
    "url": "assets/clsx-B-dksMZM.js",
    "revision": null
  }, {
    "url": "assets/FloatingTanStackRouterDevtools-DFr2IL18.js",
    "revision": null
  }, {
    "url": "assets/Home-C-GNqPKV.js",
    "revision": null
  }, {
    "url": "assets/main-Ch87Rj2V.css",
    "revision": null
  }, {
    "url": "assets/main-DKvBgGxR.js",
    "revision": null
  }, {
    "url": "assets/NotFound-DZAkn-5q.js",
    "revision": null
  }, {
    "url": "assets/SuperAdmin-DKWuqW-N.js",
    "revision": null
  }, {
    "url": "assets/vendor-CLyQEj53.js",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "ffed67e8e4a00ca08deb364d198b14af"
  }, {
    "url": "registerSW.js",
    "revision": "1872c500de691dce40960bb85481de07"
  }, {
    "url": "stats.html",
    "revision": "566819bc46b3514b26013d26488b6f98"
  }, {
    "url": "vendor/css/mapbox-gl.css",
    "revision": "4e32dfebe9cc16b5fc92f8b14a3add23"
  }, {
    "url": "vendor/css/maplibre-gl.css",
    "revision": "0c9f40d51c0916179649404cb3366050"
  }, {
    "url": "vendor/css/superfine.css",
    "revision": "73ee562c4959915f163c81a6c61cbb1f"
  }, {
    "url": "manifest.webmanifest",
    "revision": "ec017820a888c526d67a2e7e57cb396b"
  }], {});
  workbox.cleanupOutdatedCaches();
  workbox.registerRoute(new workbox.NavigationRoute(workbox.createHandlerBoundToURL("index.html")));

}));
//# sourceMappingURL=sw.js.map
