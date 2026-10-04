// induktion.typ
// Illustration zum Satz über die Summe der ersten n ungeraden Zahlen.

#import "@preview/cetz:0.4.2": canvas, draw

// Ein n×n-Quadrat, zerlegt in die n „Winkel“ (Gnomone). Der k-te Winkel
// besteht aus 2k-1 Feldern, ist schwarz umrandet und trägt diese Zahl in
// seiner Ecke.
#let quadratbild(n: 5, feld: 0.62) = canvas({
  import draw: *

  let farben = (
    rgb("#eef4fa"), rgb("#d8e7f4"), rgb("#c2daee"), rgb("#accde8"), rgb("#96c0e2"),
    rgb("#80b3dc"), rgb("#6aa6d6"),
  )

  // Felder
  for i in range(1, n + 1) {
    for j in range(1, n + 1) {
      let k = calc.max(i, j)
      rect(
        ((i - 1) * feld, (j - 1) * feld),
        (i * feld, j * feld),
        fill: farben.at(calc.rem(k - 1, farben.len())),
        stroke: 0.4pt + rgb("#ffffff"),
      )
    }
  }

  // Umrandung der Winkel. Der k-te Winkel besteht aus der obersten Zeile
  // und der rechten Spalte des k×k-Quadrats, ist also L-förmig.
  for k in range(1, n + 1) {
    if k == 1 {
      rect((0, 0), (feld, feld), stroke: 1.1pt + black)
    } else {
      line(
        (0, (k - 1) * feld),
        ((k - 1) * feld, (k - 1) * feld),
        ((k - 1) * feld, 0),
        (k * feld, 0),
        (k * feld, k * feld),
        (0, k * feld),
        close: true,
        stroke: 1.1pt + black,
      )
    }
  }

  // Anzahl der Felder je Winkel, in dessen Ecke
  for k in range(1, n + 1) {
    content(((k - 0.5) * feld, (k - 0.5) * feld), text(size: 8pt)[#(2 * k - 1)])
  }
})
