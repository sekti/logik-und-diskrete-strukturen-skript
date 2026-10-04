// Fully vibe coded:

// venn.typ
// Venn-Diagramme für die vier Mengenoperationen (Vereinigung, Schnitt,
// Differenz, Komplement), gezeichnet mit CeTZ.
//
// Die Schnittmenge wird nicht approximiert (z.B. per Transparenz),
// sondern als exakte "Linse" gezeichnet: arc-through() verbindet die
// beiden Schnittpunkte der Kreise jeweils über einen Punkt, der
// garantiert auf dem jeweiligen Kreisbogen und innerhalb der Linse liegt.

#import "@preview/cetz:0.4.2": canvas, draw

#let venn-farbe = rgb(120, 150, 230)

#let venn(mode) = canvas({
  import draw: *
  let r = 1.1
  // Bei "disjunkt" stehen die Kreise so weit auseinander, dass sie sich
  // nicht berühren; dann gibt es keine Schnittpunkte.
  let d = if mode == "disjunkt" { 2*r + 0.5 } else { 1.3 }
  let ca = (-d/2, 0)
  let cb = (d/2, 0)
  let h = if mode == "disjunkt" { 0 } else { calc.sqrt(r*r - (d/2)*(d/2)) }
  let p1 = (0, h)
  let p2 = (0, -h)
  // Punkte auf Kreis A bzw. B in Richtung des jeweils anderen Kreises;
  // liegen garantiert innerhalb der Linse (Schnittmenge).
  let pa = (ca.at(0) + r, 0)
  let pb = (cb.at(0) - r, 0)

  if mode == "vereinigung" {
    circle(ca, radius: r, fill: venn-farbe, stroke: none)
    circle(cb, radius: r, fill: venn-farbe, stroke: none)
  } else if mode == "schnitt" {
    merge-path(fill: venn-farbe, close: true, {
      arc-through(p1, pa, p2)
      arc-through(p2, pb, p1)
    })
  } else if mode == "differenz" {
    circle(ca, radius: r, fill: venn-farbe, stroke: none)
    circle(cb, radius: r, fill: white, stroke: none)
  } else if mode == "komplement" {
    rect((-2.2, -1.5), (2.2, 1.5), fill: venn-farbe, stroke: none)
    circle((0, 0), radius: r, fill: white, stroke: none)
  } else if mode == "disjunkt" {
    // Beide Mengen werden gefüllt; hervorzuheben ist, dass es keinen
    // gemeinsamen Bereich gibt.
    circle(ca, radius: r, stroke: none)
    circle(cb, radius: r, stroke: none)
  }

  if mode == "komplement" {
    rect((-2.2, -1.5), (2.2, 1.5))
    circle((0, 0), radius: r)
    content((0, r * 0.6), [$A$])
    content((-1.9, 1.2), [$U$])
  } else if mode == "teilmenge" {
    // Ein Kreis liegt vollständig im anderen; beide bleiben ungefärbt.
    circle((0, 0), radius: 1.35)
    circle((0, -0.45), radius: 0.62)
    content((0, -0.45), [$A$])
    content((0, 0.85), [$B$])
  } else {
    circle(ca, radius: r)
    circle(cb, radius: r)
    content((ca.at(0) - r * 0.4, r * 0.4), [$A$])
    content((cb.at(0) + r * 0.4, r * 0.4), [$B$])
  }
})
