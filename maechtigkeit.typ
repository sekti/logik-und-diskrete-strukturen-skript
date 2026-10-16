// maechtigkeit.typ
// Bilder für den Abschnitt über Mächtigkeit.

#import "@preview/cetz:0.4.2": canvas, draw

#let farbeA = rgb("#cc0000")
#let farbeB = rgb("#0050b0")

// Die vier Typen von Zusammenhangskomponenten im Beweis von Cantor-Schröder-
// Bernstein. A-Knoten sind rote Kreise, B-Knoten blaue Quadrate.
//
//   modus: "fg" zeigt alle Kanten: f (von A nach B) durchgezogen,
//               g (von B nach A) gestrichelt.
//          "h"  zeigt die Bijektion h fett; die übrigen Kanten blass.
//               Typ 1, 3, 4: h folgt f. Typ 2: h geht entgegen g.
#let csbtypen(modus: "fg") = canvas({
  import draw: *

  let r = 0.1
  let dx = 1.1
  let blass = luma(75%)

  // Knoten: (x, y, istA)
  let knoten(p, istA) = {
    if istA {
      circle(p, radius: r, fill: farbeA, stroke: none)
    } else {
      rect((p.at(0) - r, p.at(1) - r), (p.at(0) + r, p.at(1) + r), fill: farbeB, stroke: none)
    }
  }
  let kante(p, q, farbe: black, dick: false, gestrichelt: false) = {
    let (vx, vy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let len = calc.sqrt(vx * vx + vy * vy)
    let (ex, ey) = (vx / len, vy / len)
    let s = r + 0.07
    line(
      (p.at(0) + ex * s, p.at(1) + ey * s), (q.at(0) - ex * s, q.at(1) - ey * s),
      stroke: (paint: farbe, thickness: if dick { 1.4pt } else { 0.8pt },
               dash: if gestrichelt { "dashed" } else { none }),
      mark: (end: ">", scale: if dick { 0.7 } else { 0.55 }, fill: farbe),
    )
  }
  let punkte(p, q) = line(p, q, stroke: (paint: luma(55%), thickness: 0.8pt, dash: "dotted"))

  // Eine Kette als Liste von (Punkt, istA); Kanten laufen von links nach rechts.
  // hrueck: true heißt, h nimmt bei den A-Knoten die Kante von links (also g rückwärts).
  let kette(pts, hrueck: false) = {
    for i in range(pts.len() - 1) {
      let ((p, pa), (q, qa)) = (pts.at(i), pts.at(i + 1))
      if modus == "fg" {
        kante(p, q, gestrichelt: not pa)
      } else {
        let istH = if hrueck { qa } else { pa }  // A-Knoten links (f) bzw. rechts (g rückwärts)
        if istH {
          if hrueck { kante(q, p, dick: true) } else { kante(p, q, dick: true) }
        } else {
          kante(p, q, farbe: blass)
        }
      }
    }
    for (p, istA) in pts { knoten(p, istA) }
  }

  let zeile(y, start, n, ersterA) = range(n).map(i => ((start + i * dx, y), calc.even(i) == ersterA))

  let titel(y, t) = content((-0.9, y), text(size: 8pt, t), anchor: "east")

  // Typ 1: Strahl ab einem A-Knoten
  let y1 = 0
  titel(y1, [Typ 1])
  let k1 = zeile(y1, 0, 5, true)
  kette(k1)
  punkte((4 * dx + 0.25, y1), (4 * dx + 0.75, y1))

  // Typ 2: Strahl ab einem B-Knoten
  let y2 = -0.9
  titel(y2, [Typ 2])
  let k2 = zeile(y2, 0, 5, false)
  kette(k2, hrueck: true)
  punkte((4 * dx + 0.25, y2), (4 * dx + 0.75, y2))

  // Typ 3: Doppelstrahl
  let y3 = -1.8
  titel(y3, [Typ 3])
  let k3 = zeile(y3, 0, 5, true)
  punkte((-0.75, y3), (-0.25, y3))
  kette(k3)
  punkte((4 * dx + 0.25, y3), (4 * dx + 0.75, y3))

  // Typ 4: Kreis a → b → a' → b' → a
  let y4 = -2.75
  titel(y4 - 0.4, [Typ 4])
  let (c1, c2, c3, c4) = ((0.55, y4), (1.65, y4), (1.65, y4 - 0.8), (0.55, y4 - 0.8))
  let zyk = ((c1, true), (c2, false), (c3, true), (c4, false), (c1, true))
  kette(zyk)
})
