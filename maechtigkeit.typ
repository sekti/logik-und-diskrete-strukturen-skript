// maechtigkeit.typ
// Bilder für den Abschnitt über Mächtigkeit.

#import "@preview/cetz:0.4.2": canvas, draw

#let csbrot = rgb("#cc0000")

// Zwei Ketten aus dem Beweis von Cantor-Schröder-Bernstein, gezeichnet in zwei
// Bändern für A (oben) und B (unten). Links eine Kette, die in A ∖ g(B)
// beginnt, rechts eine, die in B ∖ f(A) beginnt.
//
//   modus: "fg" zeigt die Injektionen f (durchgezogen) und g (gestrichelt),
//          "h"  zeigt die daraus gebaute Bijektion h; die Elemente von C sind rot.
#let csbbild(modus: "fg") = canvas({
  import draw: *

  let (ya, yb) = (1.3, 0)
  let (x0, x1) = (-0.9, 8.1)
  rect((x0, ya - 0.4), (x1, ya + 0.4), radius: 0.2, stroke: 0.6pt + luma(60%), fill: luma(96%))
  rect((x0, yb - 0.4), (x1, yb + 0.4), radius: 0.2, stroke: 0.6pt + luma(60%), fill: luma(96%))
  content((x0 + 0.3, ya), $A$)
  content((x0 + 0.3, yb), $B$)

  // Kette 1: a0 -f-> b0 -g-> a1 -f-> b1 -g-> a2 …
  let k1 = (
    ("a0", 0.2, ya, $a_0$), ("b0", 0.95, yb, $b_0$), ("a1", 1.7, ya, $a_1$),
    ("b1", 2.45, yb, $b_1$), ("a2", 3.2, ya, $a_2$),
  )
  // Kette 2: b'0 -g-> a'0 -f-> b'1 -g-> a'1 -f-> b'2 …
  let k2 = (
    ("c0", 4.5, yb, $b'_0$), ("d0", 5.25, ya, $a'_0$), ("c1", 6.0, yb, $b'_1$),
    ("d1", 6.75, ya, $a'_1$), ("c2", 7.5, yb, $b'_2$),
  )
  let pos = (:)
  for (n, x, y, _) in k1 + k2 { pos.insert(n, (x, y)) }
  let inC = ("a0", "a1", "a2")

  let r = 0.07
  let pfeil(p, q, farbe: black, gestrichelt: false) = {
    let (dx, dy) = (q.at(0) - p.at(0), q.at(1) - p.at(1))
    let len = calc.sqrt(dx * dx + dy * dy)
    let (ex, ey) = (dx / len, dy / len)
    let s = r + 0.06
    line(
      (p.at(0) + ex * s, p.at(1) + ey * s), (q.at(0) - ex * s, q.at(1) - ey * s),
      stroke: (paint: farbe, thickness: 0.8pt, dash: if gestrichelt { "dashed" } else { none }),
      mark: (end: ">", scale: 0.55, fill: farbe),
    )
  }
  // Andeutung, dass die Kette weitergeht
  let weiter(p, nach) = {
    line(p, (p.at(0) + 0.35, p.at(1) + nach * 0.45), stroke: (paint: luma(55%), thickness: 0.8pt, dash: "dotted"))
  }

  if modus == "fg" {
    pfeil(pos.a0, pos.b0); pfeil(pos.b0, pos.a1, gestrichelt: true)
    pfeil(pos.a1, pos.b1); pfeil(pos.b1, pos.a2, gestrichelt: true)
    weiter(pos.a2, -1)
    pfeil(pos.c0, pos.d0, gestrichelt: true); pfeil(pos.d0, pos.c1)
    pfeil(pos.c1, pos.d1, gestrichelt: true); pfeil(pos.d1, pos.c2)
    weiter(pos.c2, 1)
  } else {
    // Auf C: h = f. Sonst: h = g⁻¹, also g-Pfeile umgedreht.
    pfeil(pos.a0, pos.b0, farbe: csbrot); pfeil(pos.a1, pos.b1, farbe: csbrot)
    weiter(pos.a2, -1)
    pfeil(pos.d0, pos.c0); pfeil(pos.d1, pos.c1)
    weiter(pos.c2, 1)
  }

  for (n, x, y, name) in k1 + k2 {
    let farbe = if modus == "h" and n in inC { csbrot } else { black }
    circle((x, y), radius: r, fill: farbe, stroke: none)
    let dy = if y == ya { 0.24 } else { -0.24 }
    content((x, y + dy), text(size: 8pt, fill: farbe, name))
  }
})
