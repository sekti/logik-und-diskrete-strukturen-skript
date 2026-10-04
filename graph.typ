// graph.typ
// Zeichnet kleine Beispielgraphen mit CeTZ.
//
//   knoten:  Dictionary Name -> Position, z.B. ("1": (0, 0.8), "2": (1.1, 0.8))
//   kanten:  Liste von Paaren, z.B. (("1","2"), ("1","3"))
//   markiert: Teilliste von kanten, die hervorgehoben wird (etwa ein Weg oder Kreis)
//
// Die Kanten werden zuerst gezeichnet, die Knoten danach mit weißer Füllung,
// damit die Linien nicht in die Kreise hineinragen.

#import "@preview/cetz:0.4.2": canvas, draw

#let markierfarbe = rgb("#cc0000")

#let graphbild(
  knoten,
  kanten,
  markiert: (),
  radius: 0.2,
  beschriftung: true,
  gerichtet: false,
  bogen: 0.0,
) = canvas({
  import draw: *

  let gleiche-kante(e, f) = if gerichtet {
    e.at(0) == f.at(0) and e.at(1) == f.at(1)
  } else {
    ((e.at(0) == f.at(0) and e.at(1) == f.at(1)) or
     (e.at(0) == f.at(1) and e.at(1) == f.at(0)))
  }

  // Gegenläufige Kanten (u,v) und (v,u) würden übereinanderliegen; sie werden
  // deshalb leicht nach außen gebogen.
  let gegenkante(e) = gerichtet and kanten.any(f =>
    f.at(0) == e.at(1) and f.at(1) == e.at(0))

  for e in kanten {
    for name in e {
      if not knoten.keys().contains(name) {
        panic("graphbild: Die Kante " + repr(e) + " verweist auf den Knoten "
          + repr(name) + ", der nicht in der Knotenliste steht. Vorhanden sind: "
          + repr(knoten.keys()))
      }
    }
    let hervor = markiert.any(f => gleiche-kante(e, f))
    let strich = if hervor { 2pt + markierfarbe } else { 0.8pt + black }
    let a = knoten.at(e.at(0))
    let b = knoten.at(e.at(1))

    if e.at(0) == e.at(1) {
      // Schleife: Kreisbogen über dem Knoten, mit Lücke nach unten.
      let s = radius * 1.15
      arc(
        (a.at(0), a.at(1) + radius + 0.75 * s),
        start: -60deg, stop: 240deg, radius: s, anchor: "origin",
        stroke: strich, mark: (end: ">", scale: 0.6, fill: strich.paint),
      )
    } else if not gerichtet {
      line(a, b, stroke: strich)
    } else {
      // Pfeil am Kreisrand enden lassen, sonst verschwindet die Spitze
      // unter dem Knoten.
      let dx = b.at(0) - a.at(0)
      let dy = b.at(1) - a.at(1)
      let len = calc.sqrt(dx * dx + dy * dy)
      let (ex, ey) = (dx / len, dy / len)
      // Versatz quer zur Kante, falls es die Gegenkante auch gibt
      let v = if gegenkante(e) { calc.max(bogen, 0.12) } else { bogen }
      let (qx, qy) = (-ey * v, ex * v)
      let p1 = (a.at(0) + ex * radius + qx, a.at(1) + ey * radius + qy)
      let p2 = (b.at(0) - ex * radius + qx, b.at(1) - ey * radius + qy)
      line(p1, p2, stroke: strich, mark: (end: ">", scale: 0.6, fill: strich.paint))
    }
  }

  for (name, pos) in knoten.pairs() {
    circle(pos, radius: radius, fill: white, stroke: 0.8pt + black)
    if beschriftung {
      content(pos, text(size: 9pt)[#name])
    }
  }
})

// ---------------------------------------------------------------------------
// Generatoren für die Galerie: Knotenpositionen und Kantenlisten der
// benannten Graphenfamilien. Die Knoten heißen "1", "2", … bzw. beim
// bipartiten Graphen "a1", …, "b1", … .
// ---------------------------------------------------------------------------

#let pfad-knoten(n, abstand: 0.85) = {
  let d = (:)
  for i in range(1, n + 1) { d.insert(str(i), ((i - 1) * abstand, 0)) }
  d
}

#let kreis-knoten(n, r: 0.9, start: 90deg) = {
  let d = (:)
  for i in range(1, n + 1) {
    let phi = start + (i - 1) * 360deg / n
    d.insert(str(i), (r * calc.cos(phi), r * calc.sin(phi)))
  }
  d
}

#let stern-knoten(n, r: 0.9) = {
  let d = ("0": (0, 0))
  for (name, pos) in kreis-knoten(n, r: r).pairs() { d.insert(name, pos) }
  d
}

// Die beiden Seiten stehen links und rechts, nicht oben und unten: So liest
// man eine Relation $R ⊆ A × B$ von links nach rechts.
#let bipartit-knoten(m, n, abstand: 0.62, breite: 1.5) = {
  let d = (:)
  for i in range(1, m + 1) {
    d.insert("a" + str(i), (-breite / 2, ((m + 1) / 2 - i) * abstand))
  }
  for j in range(1, n + 1) {
    d.insert("b" + str(j), (breite / 2, ((n + 1) / 2 - j) * abstand))
  }
  d
}

// Zeichnet eine Relation R ⊆ A × B als zweiseitiges Diagramm: Die Elemente
// von A stehen links, die von B rechts, jedes Paar ist eine Strecke dazwischen.
// Die Elemente werden als Text gesetzt, nicht als Kreise, damit auch Wörter
// hineinpassen.
//
//   links, rechts: Listen von Beschriftungen, z.B. ("Anna", "Ben")
//   paare:         Liste von Paaren daraus, z.B. (("Anna", "rot"),)
#let relationsbild(links, rechts, paare, abstand: 0.6, breite: 2.8, luft: 0.12) = canvas({
  import draw: *

  let pos = (:)
  for (i, a) in links.enumerate() {
    pos.insert(a, (-breite / 2, (links.len() - 1 - 2 * i) * abstand / 2))
  }
  for (j, b) in rechts.enumerate() {
    pos.insert(b, (breite / 2, (rechts.len() - 1 - 2 * j) * abstand / 2))
  }

  for e in paare {
    for name in e {
      if not pos.keys().contains(name) {
        panic("relationsbild: " + repr(name) + " kommt in keiner der beiden Listen vor.")
      }
    }
    let p = pos.at(e.at(0))
    let q = pos.at(e.at(1))
    line((p.at(0) + luft, p.at(1)), (q.at(0) - luft, q.at(1)), stroke: 0.8pt + black)
  }

  for a in links { content(pos.at(a), text(size: 9pt, a), anchor: "east") }
  for b in rechts { content(pos.at(b), text(size: 9pt, b), anchor: "west") }
})

// Aus einer Knotenfolge die Liste der benutzten Kanten machen,
// z.B. folge-kanten(("1","2","3","1")) für den Kreis 1,2,3,1.
#let folge-kanten(folge) = range(0, folge.len() - 1).map(i => (folge.at(i), folge.at(i + 1)))

#let pfad-kanten(n) = range(1, n).map(i => (str(i), str(i + 1)))

#let kreis-kanten(n) = pfad-kanten(n) + ((str(n), "1"),)

#let vollstaendig-kanten(n) = {
  let e = ()
  for i in range(1, n + 1) {
    for j in range(i + 1, n + 1) { e.push((str(i), str(j))) }
  }
  e
}

#let stern-kanten(n) = range(1, n + 1).map(i => ("0", str(i)))

#let bipartit-kanten(m, n) = {
  let e = ()
  for i in range(1, m + 1) {
    for j in range(1, n + 1) { e.push(("a" + str(i), "b" + str(j))) }
  }
  e
}

// ---------------------------------------------------------------------------
// Fertige Bilder der Familien. Hier können Knoten- und Kantenzahl nicht mehr
// auseinanderlaufen; zusätzliche Argumente (etwa beschriftung: false) werden
// an graphbild durchgereicht.
// ---------------------------------------------------------------------------

#let pfadbild(n, ..args) = graphbild(pfad-knoten(n), pfad-kanten(n), ..args)

#let kreisbild(n, ..args) = graphbild(kreis-knoten(n), kreis-kanten(n), ..args)

#let vollstaendigbild(n, ..args) = graphbild(kreis-knoten(n), vollstaendig-kanten(n), ..args)

#let sternbild(n, ..args) = graphbild(stern-knoten(n), stern-kanten(n), ..args)

#let bipartitbild(m, n, ..args) = graphbild(bipartit-knoten(m, n), bipartit-kanten(m, n), ..args)
