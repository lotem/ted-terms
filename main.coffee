co = require 'co'
iconv = require 'iconv-lite'
Promise = require 'bluebird'
parseString = Promise.promisify require('xml2js').parseString
config = require './config'

checkConfig = (config) ->
  #console.dir config, colors: true
  # I/O encoding supported?
  console.assert iconv.encodingExists(config.inputEncoding),
    "encoding not supported: #{config.inputEncoding}"
  console.assert iconv.encodingExists(config.outputEncoding),
    "encoding not supported: #{config.outputEncoding}"

convert = (stream, config) ->
  decoder = iconv.decodeStream config.inputEncoding
  new Promise (resolve, reject) ->
    stream.pipe(decoder).collect (err, xml) ->
      reject err if err
      resolve parseString xml

co ->
  checkConfig config
  data = yield convert process.stdin, config
  console.dir data,
    colors: true
    depth: null
.catch (e) ->
  console.error 'Error:', e.message
