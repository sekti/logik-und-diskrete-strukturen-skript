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

// Quadrat aus dem Satz „Die Schreibweisen passen zusammen“: Die Bijektionen
// α und β verbinden A und B mit den Mengen {1,…,n} und {1,…,m}.
#let schreibweisenbild() = canvas(length: 1em, {
  import draw: *

  let (links, rechts, oben, unten) = (0, 9, 3.6, 0)
  let pfeil = (end: ">", fill: black, scale: 0.7)
  let doppelpfeil = (start: ">", end: ">", fill: black, scale: 0.7)

  content((links, oben), $A$)
  content((rechts, oben), $B$)
  content((links, unten), ${1,…,n}$)
  content((rechts, unten), ${1,…,m}$)

  line((links + 0.8, oben), (rechts - 0.8, oben), mark: pfeil)
  line((links + 2.4, unten), (rechts - 2.4, unten), mark: pfeil)
  line((links, oben - 0.7), (links, unten + 0.7), mark: doppelpfeil)
  line((rechts, oben - 0.7), (rechts, unten + 0.7), mark: doppelpfeil)

  content(((links + rechts) / 2, oben + 0.6), $f$)
  content(((links + rechts) / 2, unten + 0.6), $ι$)
  content((links - 0.5, (oben + unten) / 2), $α$)
  content((rechts + 0.5, (oben + unten) / 2), $β$)
})

// Cantorsche Paarungsfunktion: Das Paar (a,b) steht an der Stelle (a,b) des
// Gitters und ist mit π(a,b) beschriftet. Die Diagonalen a + b = s werden von
// oben links nach unten rechts durchlaufen; gestrichelt der Sprung zur
// nächsten Diagonale.
#let paarungsbild(diagonalen: 4) = canvas(length: 1em, {
  import draw: *

  let d = 2.4
  let r = 0.6
  let grau = luma(60%)
  let hell = luma(75%)
  let pfeil = (end: ">", fill: black, scale: 0.6)
  let pi(a, b) = calc.quo((a + b) * (a + b + 1), 2) + a

  // Pfeil von Gitterpunkt p nach q, an beiden Enden um r gekürzt.
  let verbinde(p, q, ..stil) = {
    let (x1, y1) = (p.at(0) * d, p.at(1) * d)
    let (x2, y2) = (q.at(0) * d, q.at(1) * d)
    let len = calc.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    let (ex, ey) = ((x2 - x1) / len, (y2 - y1) / len)
    line((x1 + r * ex, y1 + r * ey), (x2 - r * ex, y2 - r * ey), ..stil)
  }

  // Achsen mit Koordinaten
  let ende = (diagonalen + 0.7) * d
  line((-0.9, -0.9), (ende, -0.9), stroke: grau, mark: (end: ">", fill: grau, scale: 0.6))
  line((-0.9, -0.9), (-0.9, ende), stroke: grau, mark: (end: ">", fill: grau, scale: 0.6))
  content((ende + 0.5, -0.9), text(fill: grau, $a$))
  content((-0.9, ende + 0.5), text(fill: grau, $b$))
  for i in range(diagonalen + 1) {
    content((i * d, -1.6), text(fill: grau, size: 0.8em, str(i)))
    content((-1.6, i * d), text(fill: grau, size: 0.8em, str(i)))
  }

  for s in range(diagonalen + 1) {
    for a in range(s + 1) {
      content((a * d, (s - a) * d), $#pi(a, s - a)$)
      if a < s { verbinde((a, s - a), (a + 1, s - a - 1), mark: pfeil) }
    }
    if s < diagonalen {
      verbinde((s, 0), (0, s + 1), stroke: (paint: hell, dash: "dashed"), mark: (end: ">", fill: hell, scale: 0.6))
    }
  }
})

// Aufzählung einer unendlichen Menge M ⊆ ℕ der Größe nach (hier M = ℙ).
// Oben ℕ, unten die Zahlen 0, 1, 2, … im selben Abstand; davon die Elemente
// von M schwarz und mit a_k beschriftet, die übrigen ausgegraut. Pfeile von k
// nach a_k, passend zur Bijektion ℕ → M, k ↦ a_k. Die obere Zeile endet daher
// früher.
#let aufzaehlbild(m: (2, 3, 5, 7, 11, 13), bis: 13) = canvas(length: 1em, {
  import draw: *

  let w = 1.75             // Abstand der Zahlen
  let (yo, yu) = (0, -4.2) // Zeilen
  let hell = luma(72%)
  let pfeil = (end: ">", fill: black, scale: 0.6)

  content((-1.6, yo), $ℕ$)
  content((-1.6, yu), $M$)

  for v in range(bis + 1) {
    let k = m.position(x => x == v)
    if k == none {
      content((v * w, yu), text(fill: hell, str(v)))
    } else {
      content((v * w, yu), str(v))
      content((v * w, yu - 0.95), $a_#k$)
      content((k * w, yo), str(k))
      line((k * w, yo - 0.5), (v * w, yu + 0.55), mark: pfeil)
    }
  }
  content((m.len() * w, yo), $…$)
  content(((bis + 1) * w, yu), $…$)
})

// Der unendliche Baum T mit Knotenmenge {0,1}^*, bis zur Tiefe `tiefe`. Jeder
// Knoten ist mit seinem Wort beschriftet, darunter grau seine Nummer bei
// ebenenweiser Aufzählung. Der Ast `ast` (mindestens tiefe + 1 Einträge) ist fett.
#let binaerbaum(tiefe: 3, ast: (0, 1, 1, 0)) = canvas(length: 1em, {
  import draw: *

  let s = 2.6   // Abstand der Blätter
  let h = 3.4   // Abstand der Ebenen
  let breite = calc.pow(2, tiefe) * s
  let pos(k, j) = ((j + 0.5) * breite / calc.pow(2, k), -k * h)
  let grau = luma(55%)
  let normal = (paint: luma(40%), thickness: 0.6pt)
  let fett = (paint: black, thickness: 1.6pt)

  // Index des Ast-Knotens in Tiefe k
  let astj(k) = range(k).fold(0, (j, i) => 2 * j + ast.at(i))
  let wort(k, j) = if k == 0 { $ε$ } else {
    let b = str(j, base: 2)
    $#("0" * (k - b.len()) + b)$
  }

  for k in range(tiefe + 1) {
    for j in range(calc.pow(2, k)) {
      let (x, y) = pos(k, j)
      content((x, y), wort(k, j))
      content((x, y - 1.0), text(fill: grau, str(calc.pow(2, k) - 1 + j)))
      let aufAst = astj(k) == j
      for b in (0, 1) {
        let istAst = aufAst and ast.at(k) == b
        if k < tiefe {
          let (x2, y2) = pos(k + 1, 2 * j + b)
          line((x + (x2 - x) * 0.2, y - 1.5), (x2, y2 + 0.55),
            stroke: if istAst { fett } else { normal })
        } else {
          // angedeutete Fortsetzung
          let dx = (2 * b - 1) * s / 4
          line((x, y - 1.5), (x + dx, y - 2.6),
            stroke: (..(if istAst { fett } else { normal }), dash: "dotted"))
        }
      }
    }
  }
})

// Das Diagonalargument als Tabelle: Zeile k enthält den Ast p_k, die
// Diagonaleinträge sind hinterlegt, d entsteht durch Umdrehen der Diagonale.
#let diagonaltabelle(aeste: ((0, 1, 1, 0), (1, 1, 0, 1), (0, 0, 0, 1), (1, 0, 1, 1))) = {
  let n = aeste.len()
  let d = range(n).map(k => 1 - aeste.at(k).at(k))
  let hervor(x) = text(fill: farbeA, weight: "bold", str(x))
  table(
    columns: n + 2,
    stroke: none,
    align: center,
    inset: (x: 0.7em, y: 0.4em),
    fill: (x, y) => if x == y and 1 <= y and y <= n { farbeA.transparentize(80%) },
    table.vline(x: 1),
    [], ..range(1, n + 1).map(i => [#i]), $…$,
    table.hline(),
    ..for k in range(n) {
      ($p_#(k + 1)$, ..aeste.at(k).map(str), $…$)
    },
    $⋮$, ..range(n).map(_ => $⋮$), [],
    table.hline(),
    $d$, ..d.map(hervor), $…$,
  )
}
