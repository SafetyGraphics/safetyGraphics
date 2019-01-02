library(hexSticker)

#red on white
imgurl <- "./inst/safetyGraphicsHex/noun_heart_rate_210541_ec5d57.png"
sticker(
  imgurl,
  filename="./inst/safetyGraphicsHex/safetyGraphicsHex.png",
  package = "safetygraphics",
  p_color = "#666666",
  p_size = 5,
  p_family = "serif",
  p_y = 0.5,
  s_x = 1,
  s_y=1.1,
  s_width = 0.8,
  h_color = "black",
  h_fill= "white")
