# encoding: utf-8

argv = require('optimist').argv
co = require 'co'
csv = require 'fast-csv'
iconv = require 'iconv-lite'
Promise = require 'bluebird'
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

Array::last = -> @[@length - 1]

parseTitle = (text) ->
  m = text.match /([0-9]+[.0-9]*)\u3000(.+)$/
  return null unless m?
  s = m[2].split '\u3000'
  {
    "#{config.labels.term}": s[i]
    "#{config.labels.english}": s[i + 1] or ''
    "#{config.labels.definition}": ''
    "#{config.labels.section}": m[1]
  } for i in [0...s.length] by 2

parseContent = (context, content) ->
  text = content.trim().replace /<!\[CDATA\[|\]\]>/g, ''
  return unless text
  switch context.tagStack.last()
    when 'title'
      context.recentTerms = parseTitle text
    when 'para'
      if context.recentTag is 'title' and context.recentTerms?
        terms = context.recentTerms
        for term in terms
          term[config.labels.definition] = text
        Array::push.apply context.result, terms
        context.recentTerms = null

parse = (doc) ->
  context =
    result: []
    tagStack: []
    recentTerms: null
    recentTag: null
  for line in doc.split /\r\n|\n/
    opening = line.match /^\s*<(\w+)( [^>]*)?>/
    closing = line.match /<(\/?)(\w+)>\s*$/
    context.tagStack.push opening[1] if opening
    contentBegin = if opening then opening.index + opening[0].length else 0
    contentEnd = if closing then closing.index else line.length
    parseContent context, line.slice contentBegin, contentEnd
    context.recentTag = context.tagStack.pop() if closing
  context.result.filter (term) -> term[config.labels.definition]

convert = (stream, config) ->
  decoder = iconv.decodeStream config.inputEncoding
  new Promise (resolve, reject) ->
    stream.pipe(decoder).collect (err, xml) ->
      if err
        reject err
      else
        resolve parse xml

convertCrlf = (str) ->
  str.replace /\n/g, '\r\n'

output = (terms, stream, config) ->
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
  terms = yield convert process.stdin, config
  debug terms
  yield output terms, process.stdout, config
.catch (e) ->
  console.error "Error: #{e.message}"
