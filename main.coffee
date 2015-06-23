# encoding: utf-8

argv = require('optimist').argv
co = require 'co'
csv = require 'fast-csv'
iconv = require 'iconv-lite'
Promise = require 'bluebird'
xml2js = require 'xml2js'
yaml = require 'js-yaml'
config = require './config'

formatters =
  csv: (data) ->
    Promise.promisify(csv.writeToString) data, config.csvOptions
  json: (data) ->
    Promise.resolve JSON.stringify data, null, config.jsonIndentOption
  yaml: (data) ->
    Promise.resolve yaml.dump data

debug = (value) ->
  console.dir value, {colors: true, depth: null} if config.debug

checkEncodingSupported = (encoding) ->
  console.assert iconv.encodingExists(encoding),
    "encoding not supported: #{encoding}"

checkConfig = (config) ->
  if argv.d or argv.debug
    config.debug = true
  if argv.i
    config.inputEncoding = argv.i
  if argv.o
    config.outputEncoding = argv.o
  if argv.f or argv.format
    config.format = argv.f or argv.format
  if config.debug
    config.outputEncoding = config.terminalEncoding
  debug config
  checkEncodingSupported config.inputEncoding
  checkEncodingSupported config.outputEncoding

superscriptChars = (match, char) ->
  switch char
    when '2' then '²'
    when '3' then '³'
    else throw Error "Cannot convert superscript: #{char}"

convert = (stream, config) ->
  decoder = iconv.decodeStream config.inputEncoding
  new Promise (resolve, reject) ->
    stream.pipe(decoder).collect (err, xml) ->
      if err
        reject err
      else
        xml = xml.replace /<superscript>(\w+)<\/superscript>/g, superscriptChars
        resolve Promise.promisify(xml2js.parseString) xml

getText = (x) -> (x._ or x).trim()

getDefinition = (data) ->
  (getText para for para in data).join '\n'

extractTerms = (data) ->
  data = data.book if data.book?
  data = data.chapter if data.chapter?
  if  Array.isArray data
    for item in data
      yield from extractTerms item
    return
  if data.section?
    yield from extractTerms data.section
    return
  return unless data.title?
  m = data.title[0].trim().match /^([0-9.]+)\s*([\S]+)\s*([-' A-Za-z]*)$/
  return unless m
  term = {}
  term[config.labels.term] = m[2]
  term[config.labels.english] = m[3] or ''
  term[config.labels.definition] = getDefinition(data.para or {})
  term[config.labels.section] = m[1]
  yield term

foreach = (gen, fn) ->
  `for (var x of gen) { fn(x) }`
  return

convertCrlf = (str) ->
  str.replace /\n/g, '\r\n'

output = (gen, stream, config) ->
  terms = []
  foreach gen, (x) ->
    debug x
    terms.push x
  unless config.format of formatters
    return Promise.reject new Error "unsupported format: #{config.format}"
  formatter = formatters[config.format]
  encoder = iconv.encodeStream config.outputEncoding
  encoder.pipe stream
  formatter(terms).then (data) ->
    new Promise (resolve, reject) ->
      encoder.write convertCrlf data
      encoder.end resolve

co () ->
  checkConfig config
  xmlData = yield convert process.stdin, config
  #debug xmlData
  terms = extractTerms xmlData
  yield output terms, process.stdout, config
.catch (e) ->
  console.error "Error: #{e.message}"
