var co = require('co'),
    iconv = require('iconv-lite'),
    Promise = require('bluebird'),
    parseString = Promise.promisify(require('xml2js').parseString),
    yaml = require('js-yaml'),
    config = require('./config');

function debug(value) {
  console.dir(value, {colors: true, depth: null});
}

function checkEncodingSupported(encoding) {
  console.assert(iconv.encodingExists(encoding),
    "encoding not supported: " + encoding);
}

function checkConfig(config) {
  debug(config);
  checkEncodingSupported(config.inputEncoding);
  checkEncodingSupported(config.outputEncoding);
}

function convert(stream, config) {
  var decoder = iconv.decodeStream(config.inputEncoding);
  return new Promise(function(resolve, reject) {
    stream.pipe(decoder).collect(function(err, xml) {
      if (err) reject(err);
      else resolve(parseString(xml));
    });
  });
}

function* extractTerms(data) {
  if (Array.isArray(data)) {
    for (item of data)
      yield* extractTerms(item);
    return;
  }
  if (data.section)
    yield* extractTerms(data.section);
  if (!data.title)
    return;
  var m = data.title[0].trim().match(/^([0-9.]+)\s*([\S]+)\s*([-' A-Za-z]*)$/);
  if (!m)
    return;
  var term = {term: m[2]};
  if (m[3])
    term.english = m[3];
  if (data.para)
    term.definition = data.para[0].trim();
  term.section = m[1];
  yield term;
}

function outputYaml(gen) {
  var terms = [];
  for (var x of gen) {
    debug(x);
    terms.push(x);
  }
  var yamlDoc = yaml.dump(terms);
  console.log(yamlDoc);
}

co(function*() {
  checkConfig(config);
  var xmlData = yield convert(process.stdin, config);
  debug(xmlData);
  var terms = extractTerms(xmlData);
  outputYaml(terms);
}).catch(function(e) {
  console.error('Error:', e.message);
});
