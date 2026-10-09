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

// Eine Grundmenge, zerlegt in vier Teile. Die Schnitte laufen von Rand zu Rand
// bzw. enden auf einem anderen Schnitt, sodass genau vier Gebiete entstehen.
#let partitionsbild() = canvas({
  import draw: *

  let (b, h) = (5.0, 2.6)
  rect((0, 0), (b, h), radius: 0.3, stroke: 0.8pt + black, fill: luma(96%))

  let schnitt = 0.8pt + black
  line((1.5, h), (1.2, 1.2), (1.8, 0), stroke: schnitt)
  line((1.27, 1.2), (3.0, 1.5), (b, 1.1), stroke: schnitt)
  line((3.0, 1.5), (3.4, 0), stroke: schnitt)

  let punkt(pos, name, anker: "west") = {
    circle(pos, radius: 0.05, fill: black, stroke: none)
    content((pos.at(0) + 0.08, pos.at(1)), text(size: 9pt, name), anchor: anker)
  }
  punkt((0.45, 1.9), $a$)
  punkt((0.75, 0.55), $b$)
  punkt((2.2, 2.05), $c$)
  punkt((3.3, 2.1), $d$)
  punkt((4.2, 1.7), $e$)
  punkt((2.3, 0.6), $f$)
  punkt((4.1, 0.45), $g$)
})
