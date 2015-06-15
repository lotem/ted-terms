var config = {
  format: 'yaml',  // csv, json, yaml
  inputEncoding: 'cp936',
  outputEncoding: 'utf16',
  csvOptions: {headers: true},
  jsonIndentOption: 2,
  debug: false
};

if (config.debug) {
  // Default encoding for Windows command line / *nix console.
  config.outputEncoding = (process.platform == 'win32') ? 'cp936' : 'utf8';
}

module.exports = config;
