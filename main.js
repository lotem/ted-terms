var co = require('co'),
    csv = require('fast-csv'),
    iconv = require('iconv-lite'),
    Promise = require('bluebird'),
    parseString = Promise.promisify(require('xml2js').parseString),
    yaml = require('js-yaml'),
    config = require('./config');

var formatters = {
  csv: function(data) {
    return Promise.promisify(csv.writeToString).call(null, data, config.csvOptions);
  },
  json: function(data) {
    return Promise.resolve(JSON.stringify(data, null, config.jsonIndentOption));
  },
  yaml: function(data) {
    return Promise.resolve(yaml.dump(data));
  }
};

function debug(value) {
  if (config.debug)
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
  var term = {};
  term[config.labels.term] = m[2];
  if (m[3])
    term[config.labels.english] = m[3];
  if (data.para)
    term[config.labels.definition] = data.para[0].trim();
  term[config.labels.section] = m[1];
  yield term;
}

function output(gen, stream, config) {
  var terms = [];
  for (var x of gen) {
    debug(x);
    terms.push(x);
  }
  if (!(config.format in formatters)) {
    return Promise.reject(new Error('unsupported format: ' + config.format));
  }
  var format = formatters[config.format];
  var encoder = iconv.encodeStream(config.outputEncoding);
  encoder.pipe(stream);
  return format(terms).then(function (data) {
    return new Promise(function(resolve, reject) {
      encoder.write(data);
      encoder.end(resolve);
    });
  });
}

co(function*() {
  checkConfig(config);
  var xmlData = yield convert(process.stdin, config);
  debug(xmlData);
  var terms = extractTerms(xmlData);
  yield output(terms, process.stdout, config);
}).catch(function(e) {
  console.error('Error:', e.message);
});
