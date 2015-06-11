var iconv  = require('iconv-lite'),
    config = require('./config.js');

function checkConfig(){
  console.dir(config, {colors: true});

  console.assert(iconv.encodingExists(config.inputEncoding),
    'encoding not supported: ' + config.inputEncoding);
  console.assert(iconv.encodingExists(config.outputEncoding),
    'encoding not supported: ' + config.outputEncoding);
}

function main(){
  checkConfig();
}

try {
  main();
} catch(e) {
  console.error('Error:', e.message);
}
