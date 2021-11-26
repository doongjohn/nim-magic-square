import pixie
import app


proc drawRect*(x, y, width, height: float) =
  ctx.fillRect(x - width / 2, y - height / 2, width, height)


proc clearScreen* =
  ctx.fillStyle = static: parseHex "ffffff"
  drawRect center.x, center.y, screenSize.w.float, screenSize.h.float
