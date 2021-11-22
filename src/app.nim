import staticglfw
import opengl
import vmath
import pixie


const screenSize* = (w: 600, h: 600)
const center* = vec2(screenSize.w / 2, screenSize.h / 2)

var ctx* = newContext(screenSize.w, screenSize.h)
var window*: Window
var frameCount = 0


# init glfw
if init() == 1:
  windowHint(RESIZABLE, false.cint)
  window = createWindow(screenSize.w.cint, screenSize.h.cint, "Magic square", nil, nil)
  makeContextCurrent(window)
  loadExtensions()
else:
  quit("Failed to Initialize GLFW.")


proc drawRect*(x, y, width, height: float) =
  ctx.fillRect(x - width / 2, y - height / 2, width, height)


proc clearScreen* =
  ctx.fillStyle = static: parseHex "ffffff"
  drawRect center.x, center.y, screenSize.w.float, screenSize.h.float


template main*(body: typed) =
  # allocate a texture and bind it
  var dataPtr = ctx.image.data[0].addr
  glTexImage2D(GL_TEXTURE_2D, 0, 3, GLsizei screenSize.w, GLsizei screenSize.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
  glEnable(GL_TEXTURE_2D)

  while windowShouldClose(window) != 1:
    ## Called every frame by main while loop
    pollEvents()
    body

    # update texture with new pixels from surface
    var dataPtr = ctx.image.data[0].addr
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, GLsizei screenSize.w, GLsizei screenSize.h, GL_RGBA, GL_UNSIGNED_BYTE, dataPtr)

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
