
EventEmitter = (require 'events').EventEmitter
vkey = require 'vkey'

MAX_LINES = 999

class ConsoleWidget extends EventEmitter
  constructor: (@opts) ->
    @opts ?= {}
    @opts.widthPx ?= 200
    @opts.rows ?= 10
    @opts.lineHeightPx ?= 20
    @opts.font ?= '12pt Menlo, Courier, \'Courier New\', monospace'

    @createNodes()
    @registerEvents()

  show: () ->
    @containerNode.style.visibility = ''

  hide: () ->
    @containerNode.style.visibility = 'hidden'

  focusInput: () ->
    @inputNode.focus()

  setInput: (text) ->
    @inputNode.value = text

  open: (text=undefined) ->
    @show()
    @setInput(text) if text?
    @focusInput()

  log: (text) ->
    @logNode(document.createTextNode(text))

  logNode: (node) ->
    @outputNode.appendChild(node)
    @outputNode.appendChild(document.createElement('br'))
    @scrollOutput()
    # TODO: discard last lines
  
  scrollOutput: () ->
    @outputNode.scrollByLines(MAX_LINES + 1)

  createNodes: () ->
    @containerNode = document.createElement('div')
    @containerNode.setAttribute 'style', "
    width: #{@opts.widthPx}px;
    height: #{@opts.lineHeightPx * @opts.rows}px;
    border: 1px solid white;
    color: white;
    visibility: hidden;
    bottom: 0px;
    position: absolute;
    font: #{@opts.font};
    "

    @outputNode = document.createElement('div')
    @outputNode.setAttribute 'style', "
    overflow-y: scroll; 
    width: 100%;
    height: #{@opts.lineHeightPx * (@opts.rows - 1)}px;
    "
    # TODO: scrollbar styles for better visibility 

    @inputNode = document.createElement('input')
    @inputNode.setAttribute 'style', "
    width: 100%;
    height: #{@opts.lineHeightPx}px;
    padding: 0px;
    border: 1px dashed white;
    background-color: transparent;
    color: white;
    font: #{@opts.font};
    "

    @containerNode.appendChild(@outputNode)
    @containerNode.appendChild(@inputNode)

    document.body.appendChild(@containerNode)  # note: starts off hidden

  registerEvents: () ->
    document.body.addEventListener 'keydown', @onKeydown = (ev) =>
      key = vkey[ev.keyCode]

      if key == '<enter>'
        @lastInput = @inputNode.value
        @emit 'input', @inputNode.value
        @inputNode.value = ''
      else if key == '<up>'
        @inputNode.value = @lastInput if @lastInput?

  unregisterEvents: () ->
    document.body.removeEventListener 'keydown', @onKeydown

consoleWidget = new ConsoleWidget()

for i in [0..10]
  consoleWidget.log "hello #{i}"

consoleWidget.open('/')

consoleWidget.on 'input', (text) ->
  consoleWidget.log text

# to show transparency
document.body.style.background = 'url(http://i.imgur.com/bmm7HK4.png)'
document.body.style.backgroundSize = '100% auto'
