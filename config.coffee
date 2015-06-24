# encoding: utf-8

module.exports =
  format: 'yaml'  # csv, json, yaml
  inputEncoding: 'utf8'
  outputEncoding: 'utf8'
  terminalEncoding: 'utf8'
  labels:
    term: '术语'
    english: '英文'
    definition: '定义'
    section: '章节'
  formattingTags:
    italic: '_'
    superscript: '^'
  csvOptions: {headers: true}
  jsonIndentOption: 2
  debug: false
