// aequivalenz.typ
// Bilder für den Abschnitt über Äquivalenzrelationen.

#import "@preview/cetz:0.4.2": canvas, draw

// Zwei kongruente Dreiecke: das zweite ist das erste, gedreht und verschoben.
#let kongruenzbild(winkel: 75deg, versatz: (3.6, -0.25)) = canvas({
  import draw: *

  let ecken = ((0, 0), (1.8, 0), (0.5, 1.2))
  let drehe(p) = (
    p.at(0) * calc.cos(winkel) - p.at(1) * calc.sin(winkel) + versatz.at(0),
    p.at(0) * calc.sin(winkel) + p.at(1) * calc.cos(winkel) + versatz.at(1),
  )

  let stil = (stroke: 0.8pt + black, fill: luma(92%))
  line(..ecken, close: true, ..stil)
  line(..ecken.map(drehe), close: true, ..stil)
})
