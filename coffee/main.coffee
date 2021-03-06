
parser = require 'cirru-color'

paper2 = document.querySelector('#paper')
paper = paper2.getContext '2d'
text = document.querySelector '#text'

w = innerWidth
h = innerHeight

paper2.setAttribute 'width', w
paper2.setAttribute 'height', h
text.style.width = w + 'px'
text.style.height = h + 'px'

paper.font = '18px Monaco'

lineWidth = 20
lineHeight = 20
fontSize = 20

startX = 10
startY = 40

colors =
  func: 'yellow'
  para: 'gray'
  punc: 'hsl(262, 100%, 86%)'
  dollar: 'hsl(300, 100%, 73%)'
  string: 'hsl(60, 41%, 90%)'
  'string-text': 'hsl(60, 41%, 70%)'
  escape: 'hsl(0, 87%, 69%)'
  'escape-text': 'red'

render = ->
  paper.clearRect 0, 0, screen.width, screen.height
  countX = -1
  parser.parse(text.value).map (line) ->
    countX += 1
    x = startX + countX * lineWidth
    countY = -1
    line.map (obj) ->
      paper.fillStyle = colors[obj.type] or 'blue'
      obj.text.split('').map (char) ->
        countY += 1
        y = startY + countY * lineHeight
        paper.fillText char, x, y

  cursor = text.selectionStart
  before = text.value[...cursor].split('\n')
  posx = before.length - 1
  posy = before[before.length - 1].length
  myx = startX + posx * lineWidth
  myy = startY + (posy - 1) * lineHeight
  paper.fillStyle = 'white'
  paper.fillRect myx, (myy + 10), 30, 2

text.addEventListener 'keyup', render

req = new XMLHttpRequest
req.open 'GET', './data/demo.cirru'
req.send()
req.onload = ->
  text.value = req.responseText
  render()
