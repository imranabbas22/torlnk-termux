#!/usr/bin/env node
'use strict';

var major = parseInt(process.versions.node.split('.')[0], 10);
if (major < 22) {
  process.stderr.write(
    '\ntorlnk-termux requires Node.js v22 or later.\n' +
     'You are running v' + process.versions.node + '.\n\n' +
     'Upgrade:  https://nodejs.org\n' +
     'With nvm: nvm install 22 && nvm use 22\n' +
     'Termux:   pkg install nodejs\n'
  );
  process.exit(1);
}

// The WebRTC stack (webtorrent -> simple-peer -> webrtc-polyfill) eagerly
// requires node-datachannel's native binary, which only install scripts
// download; npm 12 skips those scripts by default, so the binary is often
// absent and the eager import would kill startup. When it cannot load,
// redirect webrtc-polyfill to an inert stub: simple-peer then reports
// WEBRTC_SUPPORT = false and downloads run on TCP/uTP and DHT peers alone.
var redirectWebrtc = function () {
  var path = require('node:path');
  var stubPath = path.join(__dirname, 'webrtc-stub.mjs');
  var Module = require('node:module');

  // Node 22.15+: use registerHooks (the official API)
  if (typeof Module.registerHooks === 'function') {
    var stubUrl = require('node:url').pathToFileURL(stubPath).href;
    Module.registerHooks({
      resolve: function (specifier, context, nextResolve) {
        if (specifier === 'webrtc-polyfill') {
          return { url: stubUrl, shortCircuit: true };
        }
        return nextResolve(specifier, context);
      },
    });
    return;
  }

  // Node 22.0-22.14: intercept CJS resolution so node-datachannel never loads.
  // This also catches the ESM import chain (webrtc-polyfill -> node-datachannel)
  // because Node's ESM loader falls back to CJS for bare specifiers in node_modules.
  var stubCjs = path.join(__dirname, 'webrtc-stub.cjs');
  var origResolve = Module._resolveFilename;
  Module._resolveFilename = function (request, parent, isMain, options) {
    if (request === 'webrtc-polyfill' || request === 'node-datachannel') {
      return stubCjs;
    }
    return origResolve.call(this, request, parent, isMain, options);
  };
};

try {
  require('node-datachannel');
} catch (err) {
  redirectWebrtc();
  process.stderr.write(
    'torlnk-termux: WebRTC peers unavailable (native module not installed); ' +
      'TCP/UDP peers still work. https://github.com/imranabbas22/torlnk-termux/issues/60\n'
  );
}

import('./index.js').catch(function (err) {
  process.stderr.write('\ntorlnk-termux failed to start:\n');
  process.stderr.write('  ' + (err && err.stack ? err.stack : String(err || 'unknown error')) + '\n');
  process.exit(1);
});

// Catch any stray unhandled rejections or exceptions
process.on('unhandledRejection', function (err) {
  process.stderr.write('\ntorlnk-termux: unhandled rejection: ' + String(err) + '\n');
});
process.on('uncaughtException', function (err) {
  process.stderr.write('\ntorlnk-termux: uncaught exception: ' + (err.stack || err.message) + '\n');
  process.exit(1);
});
