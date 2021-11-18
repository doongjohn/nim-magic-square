## This example show how to have real time pixie using glfw API.

# import std/math
import staticglfw
import opengl
import pixie

const
  w: int = 500
  h: int = 500
  center = (x: w / 2, y: h / 2)

var
  screen = newImage(w, h)
  ctx = newContext(screen)
  frameCount = 0
  window: Window

screen.fill(parseHex "ffffff")

proc drawRect(x, y, width, height: float) =
  ctx.fillRect(x - width / 2, y - height / 2, width, height)

proc display =
  ## Called every frame by main while loop

  ctx.fillStyle = parseHex "db3327"
  drawRect center.x, center.y, 100.0, 100.0

  ctx.fillStyle = parseHex "278ddb"
  drawRect center.x, center.y + 100, 100.0, 100.0

  ctx.fillStyle = rgba(255, 100, 255, 255)
  drawRect center.x - 100, center.y + 100, 100.0, 100.0
  drawRect center.x + 100, center.y + 100, 100.0, 100.0

  # update texture with new pixels from surface
  var dataPtr = ctx.image.data[0].addr
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, GLsizei w, GLsizei h, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr)

  # draw a quad over the whole screen
  glClear(GL_COLOR_BUFFER_BIT)
  glBegin(GL_QUADS)
  glTexCoord2d(0.0, 0.0); glVertex2d(-1.0, +1.0)
  glTexCoord2d(1.0, 0.0); glVertex2d(+1.0, +1.0)
  glTexCoord2d(1.0, 1.0); glVertex2d(+1.0, -1.0)
  glTexCoord2d(0.0, 1.0); glVertex2d(-1.0, -1.0)
  glEnd()

  inc frameCount
  swapBuffers(window)

if init() == 0:
  quit("Failed to Initialize GLFW.")

windowHint(RESIZABLE, false.cint)
window = createWindow(w.cint, h.cint, "Magic square", nil, nil)

makeContextCurrent(window)
loadExtensions()

# allocate a texture and bind it
var dataPtr = ctx.image.data[0].addr
glTexImage2D(GL_TEXTURE_2D, 0, 3, GLsizei w, GLsizei h, 0, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
glEnable(GL_TEXTURE_2D)


proc onMouseButton(window: Window, button: cint, action: cint, modifiers: cint) {.cdecl.} =
  if button == MOUSE_BUTTON_RIGHT:
    stdout.write "RMB "
    case action
    of PRESS: echo "down"
    of RELEASE: echo "up"
    else: discard
  if button == MOUSE_BUTTON_LEFT:
    stdout.write "LMB "
    case action
    of PRESS: echo "down"
    of RELEASE: echo "up"
    else: discard

discard setMouseButtonCallback(window, onMouseButton)


while windowShouldClose(window) != 1:
  pollEvents()
  display()