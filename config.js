var config = {
  inputEncoding: 'cp936',
  outputEncoding: 'utf16',
  debug: false
};

if (config.debug) {
  // Default encoding for Windows command line / *nix console.
  config.outputEncoding = (process.platform == 'win32') ? 'cp936' : 'utf8';
}

module.exports = config;
