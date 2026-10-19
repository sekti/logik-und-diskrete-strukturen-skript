// maechtigkeit.typ
// Bilder für den Abschnitt über Mächtigkeit.

#import "@preview/cetz:0.4.2": canvas, draw

#let farbeA = rgb("#cc0000")
#let farbeB = rgb("#0050b0")

// Die vier Typen von Zusammenhangskomponenten im Beweis von Cantor-Schröder-
// Bernstein. A-Knoten sind rot, B-Knoten blau. Die drei Strahlen stehen
// untereinander, der Kreis (Typ 4) rechts daneben.
//
//   modus: "fg" zeigt alle Kanten, jeweils mit f oder g beschriftet.
//          "h"  zeigt die Bijektion h fett und mit h beschriftet; die übrigen
//               Kanten blass. Typ 1, 3, 4: h folgt f. Typ 2: h geht entgegen g.
#let csbtypen(modus: "fg") = canvas({
  import draw: *

  let r = 0.1
  let dx = 1.1
  let blass = luma(78%)

  let knoten(p, istA) = circle(p, radius: r, fill: if istA { farbeA } else { farbeB }, stroke: none)

  // Kante von p nach q; die Beschriftung steht auf der Seite, in die `n` zeigt.
  let kante(p, q, name, n, farbe: black, dick: false) = {
    let (vx, vy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let len = calc.sqrt(vx * vx + vy * vy)
    let (ex, ey) = (vx / len, vy / len)
    let s = r + 0.07
    line(
      (p.at(0) + ex * s, p.at(1) + ey * s), (q.at(0) - ex * s, q.at(1) - ey * s),
      stroke: (paint: farbe, thickness: if dick { 1.4pt } else { 0.8pt }),
      mark: (end: ">", scale: if dick { 0.7 } else { 0.55 }, fill: farbe),
    )
    if name != none {
      let m = ((p.at(0) + q.at(0)) / 2 + n.at(0) * 0.2, (p.at(1) + q.at(1)) / 2 + n.at(1) * 0.2)
      content(m, text(size: 8pt, fill: farbe, name))
    }
  }

  // Drei Punkte als Zeichen für „geht unendlich weiter“
  let weiter(x, y) = for i in range(3) { circle((x + i * 0.14, y), radius: 0.025, fill: black, stroke: none) }

  // Kette aus (Punkt, istA, Normale für die Beschriftung). Kanten laufen von
  // jedem Knoten zum nächsten. hrueck: h nimmt die Kante rückwärts (Typ 2).
  let kette(pts, hrueck: false) = {
    for i in range(pts.len() - 1) {
      let ((p, pa, n), (q, qa, _)) = (pts.at(i), pts.at(i + 1))
      let name = if pa { $f$ } else { $g$ }
      if modus == "fg" {
        kante(p, q, name, n)
      } else if hrueck and qa {
        kante(q, p, $h$, n, dick: true)
      } else if not hrueck and pa {
        kante(p, q, $h$, n, dick: true)
      } else {
        kante(p, q, none, n, farbe: blass)
      }
    }
    for (p, istA, _) in pts { knoten(p, istA) }
  }

  let oben = (0, 1)
  let zeile(y, n, ersterA) = range(n).map(i => ((i * dx, y), calc.even(i) == ersterA, oben))
  let titel(p, t) = content(p, text(size: 8pt, t), anchor: "east")
  let ende = 4 * dx + 0.3

  // Typ 1: Strahl ab einem A-Knoten
  titel((-0.75, 0), [Typ 1])
  kette(zeile(0, 5, true))
  weiter(ende, 0)

  // Typ 2: Strahl ab einem B-Knoten
  titel((-0.75, -0.9), [Typ 2])
  kette(zeile(-0.9, 5, false), hrueck: true)
  weiter(ende, -0.9)

  // Typ 3: Doppelstrahl
  titel((-0.75, -1.8), [Typ 3])
  weiter(-0.58, -1.8)
  kette(zeile(-1.8, 5, true))
  weiter(ende, -1.8)

  // Typ 4: Kreis der Länge 6, im Uhrzeigersinn, abwechselnd A und B
  let (mx, my, rr) = (7.2, -0.95, 0.95)
  content((mx, my + rr + 0.38), text(size: 8pt)[Typ 4])
  let ecke(k) = {
    let w = 90deg - k * 60deg
    (mx + rr * calc.cos(w), my + rr * calc.sin(w))
  }
  let zyk = range(7).map(k => {
    // Normale der Kante k → k+1 zeigt vom Mittelpunkt weg
    let w = 90deg - (k + 0.5) * 60deg
    (ecke(calc.rem(k, 6)), calc.even(k), (calc.cos(w), calc.sin(w)))
  })
  kette(zyk)
})
