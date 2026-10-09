// Projektionsfassung (true) oder Skript (false). Der hier gesetzte Wert gilt im
// Editor; auf der Kommandozeile hat „--input folien=true/false“ Vorrang.
#let folienModus = if "folien" in sys.inputs { sys.inputs.folien == "true" } else { false }

// imports
  #import "@preview/ctheorems:2.0.0": *
  #import "venn.typ": venn
  #import "graph.typ": *
  #import "induktion.typ": *
  #import "@preview/cetz:0.4.2" as cetz
  #import "@preview/ratchet:0.0.4": *

// Styling
  #set text(size: 12pt, lang: "de")
  #show: thm-rules.with(qed-symbol: $square$)
  // Spacing des Doppelpunkts (passend für Quantoren)
    #show math.equation: it => {
      show sym.colon: $class("punctuation", colon)$
      it
    }
    // Definitorisches Äquivalenzzeichen “:⇔”. Spacing stimmt sonst nicht
    #let defiff = math.class("relation", $∶arrow.l.r.double$)
  // Index an Pfeilen unten rechts
  #show math.equation: it => {
    show "⇝": math.scripts
    show "↭": math.scripts
    it
  }
  #show link: it => if type(it.dest) == str {
    text(fill: blue)[#it]
  } else {
    it
  }
  #set par(justify: true)
  // Enger Abstand zwischen den Umgebungen auf den Folien. Der Abstand gehört
  // zum Block der Umgebung selbst (siehe blockArgs); eine Hülle per show-Regel
  // würde für ausgeblendete Umgebungen einen leeren Block mit Abstand erzeugen.
  #let folienAbstand = if folienModus { (above: 3pt, below: 3pt) } else { (:) }


// Functionality

  // „#weil“
  #let bogenpfeil(farbe: luma(45%)) = box(baseline: -0.45em, cetz.canvas(length: 1em, {
    cetz.draw.arc-through(
      (0, 0.42), (0.34, 0), (0, -0.42),
      stroke: 0.6pt + farbe,
      mark: (end: ">", scale: 0.4, fill: farbe),
    )
  }))
  #let weil(begruendung, dy: 0.8em, farbe: luma(45%)) = box(height: 0pt,
    move(dy: dy, text(size: 0.8em, fill: farbe)[
      #h(1em) #bogenpfeil(farbe: farbe) #h(0.4em) #begruendung
    ]))

// Unicode:
  #let tiefziffern = (
    "₀": "0",  "₁": "1",  "₂": "2",  "₃": "3",  "₄": "4",  "₅": "5",  "₆": "6",  "₇": "7",  "₈": "8",  "₉": "9",  "₊": "+",  "₋": "-",  "ₙ": "n",
  )
  #let hochziffern = (
    "⁰": "0",  "¹": "1",  "²": "2",  "³": "3",  "⁴": "4",  "⁵": "5",  "⁶": "6",  "⁷": "7",  "⁸": "8",  "⁹": "9",  "⁺": "+",  "⁻": "-",  "ⁿ": "n",
  )
  #show regex("[₀₁₂₃₄₅₆₇₈₉₊₋]+"): m => math.attach(none, br: m.text.clusters().map(c => tiefziffern.at(c)).join())
  #show regex("[⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻]+"): m => math.attach(none, tr: m.text.clusters().map(c => hochziffern.at(c)).join())

// Geometry:
#let pageConfig = if folienModus {
  (
    paper: "a5",
    height: auto,
    numbering: none,
    margin: 1.3cm,
  )
} else {
  (
    paper: "a5",
    numbering: "1",
    margin: (left: 1.3cm, right: 1.3cm, bottom: 2cm, top: 1.6cm),
  )
}
#set page(..pageConfig)

// numbering and environments
#set heading(numbering: "1.1.1")
#show: ratchet.with(
  fig-depth: 2,
  fig-outline: "1.1",
)
#set math.equation(numbering: none)

/////////////////////////////
// Umgebung für Inhalte:
/////////////////////////////
#let makeEnv(name, colour: rgb("#ffffff"), slidesStandard: 1) = {
  let blockArgs = if folienModus {
    (inset: 5pt, fill: colour, radius: 0.3em, ..folienAbstand)
  } else {
    (inset: 0pt)
  }
  let locEnv = thm.with(
    supplement: name,
    counter: "env",
    base-level: 2,
    body-fmt: x => x,
    ..blockArgs,
  )
  if not folienModus {
    // Im Skript werden kurz und slides verworfen.
    return (kurz: none, slides: none, ..args) => locEnv(..args)
  }
  return (kurz: none, slides: slidesStandard, ..args) => {
    // Alle Positionsargumente außer dem letzten, das ist der Inhalt.
    let ohneInhalt = args.pos().slice(0, -1)
    if kurz != none {
      locEnv(..args.named(), ..ohneInhalt, kurz)
    } else if slides == 1 {
      locEnv(..args)
    } else if slides == "titel" {
      locEnv(separator: [], ..args.named(), ..ohneInhalt, [])
    } else if slides == 0 {
      // Die Umgebung wird weiterhin angelegt (Zähler, Nummer, Verweisziel),
      // nur ihre Darstellung ist leer.
      locEnv(fmt: thm => [], ..args)
    } else {
      panic("Unbekannter Wert für slides: " + repr(slides) + ". Erlaubt sind 0, 1 und \"titel\".")
    }
  }
}

// Farben für Folienmodus
#let satzFarbe = rgb("#ddddff")
#let uebungFarbe = rgb("#ffdddd")

// Benannte Umgebungen
#let theorem = makeEnv("Theorem", colour: satzFarbe)
#let satz = makeEnv("Satz", colour: satzFarbe)
#let lemma = makeEnv("Lemma", colour: satzFarbe)
#let definition = makeEnv("Definition", slidesStandard: 1)
#let beispiel = makeEnv("Beispiel", slidesStandard: 0)
#let korollar = makeEnv("Korollar", colour: satzFarbe)
#let uebung = makeEnv("Übung", colour: uebungFarbe)
#let notation = makeEnv("Notation", slidesStandard: 1)
#let konvention = makeEnv("Konvention", slidesStandard: 1)
#let bemerkung = makeEnv("Bemerkung", slidesStandard: 0)
#let beobachtung = makeEnv("Beobachtung", slidesStandard: 1)
#let technik = makeEnv("Technik")

// Beweise tragen keine Nummer
#let makeProofEnv(name, qed: true) = {
  let locEnv = thm.with(
    supplement: name,
    numbering: none,
    title-fmt: emph,
    name-fmt: emph,
    body-fmt: if qed { proof-body-fmt } else { x => x },
    separator: [#h(0.1em):#h(0.2em)],
    ..folienAbstand,
  )
  if not folienModus {
    return (kurz: none, slides: none, ..args) => locEnv(..args)
  }
  return (kurz: none, slides: 0, ..args) => {
    let ohneInhalt = args.pos().slice(0, -1)
    if kurz != none {
      locEnv(..args.named(), ..ohneInhalt, kurz)
    } else if slides == 1 {
      locEnv(..args)
    } else if slides == "titel" {
      locEnv(separator: [], ..args.named(), ..ohneInhalt, [])
    } else if slides == 0 {
      []
    } else {
      panic("Unbekannter Wert für slides: " + repr(slides) + ". Erlaubt sind 0, 1 und \"titel\".")
    }
  }
}

#let loesung = makeProofEnv("Lösung", qed: false)
#let beweis = makeProofEnv("Beweis")
#let begründung = makeProofEnv("Begründung", qed: false)

// Abbildungen können auf Folien deaktiviert werden
#show figure: it => if it.body == metadata("folien-aus") { none } else { it }
#let abbildung(inhalt, slides: 1, kind: image, ..args) = {
  if not folienModus or slides > 0 {
    figure(inhalt, kind: kind, ..args)
  } else {
    // Die Abbildung bleibt als leeres figure-Element erhalten, damit Nummer
    // und Verweisziel stimmen; die Darstellung übernimmt die Regel unten.
    figure(metadata("folien-aus"), kind: kind, outlined: false, ..args)
  }
}

#let skript(block) = {
  if folienModus { [] } else { block }
}
#let folien(block) = {
  if not folienModus { [] } else { block }
}
#let slidebreak() = {
  if folienModus { pagebreak() }
}

// Grenze zwischen dem ausformulierten Teil und den bloßen Stichpunkten
#let stichpunktgrenze = [
  #block(above: 1.8em, below: 1.2em,line(length: 100%, stroke: 2.5pt))
  #align(center)[ENDE DES VORBEREITETEN TEILS (es folgen Stichpunkte)]
  #block(above: 1.2em, below: 1.8em,line(length: 100%, stroke: 2.5pt))
]

// begin{document}

// Titel
#align(center)[
  #text(size: 20pt, weight: "bold")[Logik und Diskrete Strukturen]\
  Universität Stuttgart,
  Wintersemester 2026\
  Dozent: Stefan Walzer\
  #text(size: 16pt)[Vorlesungsskript #if folienModus { [ — Projektionsfassung] }]

]
#v(2em)

#outline()

#slidebreak()
= Vorrede

== Was soll das alles?

#skript[
  Sie haben eine turbulente Zeit erwischt um ein Informatikstudium zu beginnen. Die Informatik ist im Umbruch. Wichtige Aufgaben von der Programmierung bis hin zur Spitzenforschung können ganz oder in Teilen von KI-Systemen übernommen werden. Es ist unklar, wie sich das Feld in den kommenden Jahren wandeln wird.#footnote([Wenn Sie die Perspektive des wohl bekanntesten lebenden Mathematikers interessiert, dann sei Ihnen ein #link("https://www.youtube.com/watch?v=M0--ZH1lOzg", "Wortbeitrag von Terence Tao") zum Thema „Mathematics in the Age of AI“ ans Herz gelegt.])
]

=== Was soll ein Informatikstudium?

#skript[
  Im Informatikstudium lernen Sie informationsverarbeitende Systeme zu verstehen, zu verwenden und zu entwickeln.
  Lange Zeit galt ein Informatikstudium vor allem als Eintrittskarte in die Softwareindustrie. Wie sich das Berufsbild des Informatikers durch KI-Systeme verändert, ist offen.

  Vermutlich werden sich die Anforderungen verschieben: weg vom bloßen Schreiben von Code, hin zum Modellieren von Problemen, und zum Verstehen und Überprüfen von Lösungen.
]

=== Was soll dieses Modul?

#skript[
  Die Informatik bedient sich der Sprache der Mathematik. Auch und gerade dann, wenn KI-Systeme zur Problemlösung eingesetzt werden, ist eine präzise mathematische Ausdrucks- und Denkweise nützlich. Diese soll in dieser Vorlesung vermittelt werden.

  Ohne Anwendungen wären die „Mathematikvokabeln“ dieser Vorlesung sehr trocken. Als wiederkehrendes Anwendungsbeispiel dienen uns Graphen, eine der wichtigsten diskreten Strukturen der Informatik.
]

=== Was soll die Vorlesung?

#skript[
  Wie Sie sich die Inhalte der Vorlesung erarbeiten, ist Ihnen selbst überlassen (eine Anwesenheitspflicht gibt es nicht).

  Mit entsprechender Disziplin können Sie ohne den Besuch der Vorlesung auskommen und stattdessen das Skript oder andere Quellen studieren. Für die meisten dürfte der Vorlesungsbesuch aber gut investierte Zeit sein.

  Ein Gedicht vorgetragen zu bekommen, ist etwas anderes, als es selbst vom Papier zu lesen. In einem ähnlichen Sinne hat ein mathematischer Beweis etwas Performatives: Im Vortrag liegen — gerade an der Tafel — Betonungen und Details, die im Aufschrieb teilweise verloren gehen.
]

== Lernen mit und ohne KI-Systeme

#skript[
  Alex Kontorovich kommentierte auf dem
  #link("https://www.quantamagazine.org/live-from-icm-2026-what-is-math-for-in-the-age-of-ai-20260903/", [International Congress of Mathematicians (September 2026)])
  die Nutzung von KI-Systemen im Studium mit einer Analogie. Sinngemäß sagte er:

  _Einen Gabelstapler zu benutzen, um Paletten zu verladen oder um ein besserer Gabelstaplerfahrer zu werden, ist eine Sache. Wer aber mit dem Gabelstapler ins Fitnessstudio fährt, um Gewichte zu stemmen, verkennt das eigentliche Ziel der Übung._

  In diesem Sinne ist der Umgang mit ChatGPT, Claude und Co. zwar eine wichtige und nützliche Fähigkeit. Er ist aber kein Ersatz für das Verständnis der Inhalte; da hilft nur ernsthaftes und ausdauerndes Training.

  Lassen Sie sich gerne Inhalte zusammenfassen oder mit anderen Worten erklären. Bearbeiten Sie Übungsaufgaben aber selbstständig. Eine KI-generierte Lösung nachzuvollziehen ist zwar besser als nichts, Ihr Verständnis ist dann aber womöglich weniger tief, als Sie denken.
]

== Entstehung dieses Skripts

#skript[
  Skript und Vorlesung basieren auf der gleichnamigen Veranstaltung aus dem Vorjahr, gehalten von Dr. Manfred Kufleitner. Dieses Skript entsteht im Verlauf des Semesters. Dabei kommt auch generative KI zum Einsatz.#footnote([Ich verwende vorwiegend Claude Opus 5. Bewährt hat sich der Ablauf: (1) Ich entscheide mich für Inhalte und verfasse eine Liste von Stichpunkten. (2) Claude formuliert sie aus und erstellt Illustrationen. (3) Ich behalte ein Drittel, überarbeite ein Drittel und werfe ein Drittel weg. (4) Claude findet Fehler und Unstimmigkeiten.])

  Technisch ist das Skript ein #link("https://typst.app/", [Typst])-Dokument. Die zugrundeliegende Textdatei `skript.typ` können Sie in einem beliebigen Texteditor lesen. Mit entsprechender Software wird aus der Textdatei ein PDF-Dokument generiert. Wenn Sie oben `#let slides = true` setzen, entsteht die gekürzte Form, die in der Vorlesung per Beamer angeworfen wird.

  Es gibt ein öffentliches Repository auf #link("https://github.com/sekti/logik-und-diskrete-strukturen-skript", [GitHub]), wo sie alle Dateien finden. Wenn Sie Fehler finden, können Sie diese dort als #link("https://github.com/sekti/logik-und-diskrete-strukturen-skript/issues",[Issues]) melden (alternativ auch persönlich nach der Vorlesung oder über Ilias).
]

#slidebreak()
= Mengen

== Naiver Mengenbegriff

#skript[Die Mengenlehre ist die gemeinsame Sprache der Mathematik und
  Informatik: Zahlen, Graphen, Automaten, Datenbanken — praktisch jedes
  mathematische Objekt wird mengentheoretisch beschrieben. Wir beginnen
  mit einem informellen, sogenannten *naiven* Mengenbegriff, wie ihn Georg
  Cantor Ende des 19. Jahrhunderts formulierte.]

#definition(slides: 1)[Menge nach Cantor][
  Eine *Menge* ist eine Zusammenfassung wohlunterschiedener Objekte unserer
  Anschauung oder unseres Denkens zu einem Ganzen. Die Objekte einer Menge
  $M$ heißen *Elemente* von $M$.
]

#skript[
  Zugehörigkeit zur Menge darf nicht unscharf sein, jedes Objekt gehört zur Menge oder eben nicht.
  "Wohlunterschieden" meint: Für je zwei Objekte muss feststehen, ob sie gleich oder verschieden sind.
  Diese naive Definition ist kein exaktes
  mathematisches Axiom und kann zu Problemen führen (entsprechend unscharf ist auch folgende Übung). Für unsere Zwecke reicht sie dennoch aus.
]

#uebung[
  Welche der folgenden Ausdrücke beschreibt eine Menge?
  + Der Dreck an meinem Schuh.
  + Die Studierenden, die im WS26/27 dieses Modul bestehen.
  + Die großen Fußballspieler.
  + Die natürlichen Zahlen, also 0,1,2,3,….
]

#loesung[
  + ✗ Dreck besteht nicht aus wohlunterschiedenen Einzelobjekten.#footnote[Wenn Sie an Atome denken könnte man entgegnen, dass auf dieser Ebene das Konzept von "Dreck" keinen Sinn mehr ergibt.]
  + ✓ Dies ist eine Menge, obwohl wir sie noch nicht kennen.
  + ✗ Groß ist eine graduelle Eigenschaft.#footnote[Wenn man einen künstlichen Schwellwert für "groß" festlegt, könnte man das Beispiel vielleicht retten.]
  + ✓ Ein wichtiges Beispiel für uns.
]

== Notation

#notation(kurz: [„:=“])[
  Wir schreiben *„A := B“*, um auszudrücken, dass das Symbol $A$ im Folgenden durch den Ausdruck $B$ _definiert_ ist. Dann gilt selbstverständlich auch $A = B$. Der Doppelpunkt weist darauf hin, dass es an der Gleichheit nichts zu hinterfragen gibt.
]

#notation(kurz: [$M = {a,b,c}$, $M = {a,...,b}$, $M = {x | P(x)}$])[
  Eine endliche Menge kann durch Auflisten ihrer Elemente in geschweiften
  Klammern angegeben werden, z.B. $ {1, 2, 3}. $ Reihenfolge und
  Wiederholungen spielen dabei keine Rolle:
  $ {1,2,3} = {3,2,1} = {1,1,2,3}. $
  Für regelmäßige, aber größere Mengen verwendet man auch Auslassungspunkte,
  z.B. $ {4, dots, 10} = {4,5,6,7,8,9,10}. $
  Unendliche Mengen lassen sich häufig ebenso andeuten; etwa wäre
  $ M := {4,5,6, dots} $
  die Menge aller natürlichen Zahlen ab 4. Alternativ beschreibt man eine Menge durch die Angabe einer zuvor definierten Menge und einer zusätzlichen Eigenschaft, etwa:
  $ { n in M | n "ist gerade"} = {4,6,8,dots}. $
  Oder man beschreibt alle Elemente, die aus einem mathematischen Ausdruck herauspurzeln können, wenn man Elemente aus schon definierten Mengen in den Ausdruck einsetzt:
  $ {3⋅n + b | n in M, b in {0,1}} = {12,13,15,16,18,19,dots}. $
]

#notation(kurz: [$∅$])[
  Die *leere Menge* $emptyset := {}$ enthält kein Element.
]

#notation(kurz: [$x∈M, x∉M$])[
  Wir schreiben *$x ∈ M$* für die Aussage „$x$ ist Element der Menge $M$“ und schreiben *$x ∉ M$* für die Aussage „$x$ ist nicht Element der Menge $M$“.
]

#notation(kurz: [$ℕ$, $ℕ₀$, $ℕ⁺$, $ℤ$])[
  Wir definieren
  - die Menge $ℕ := ℕ₀ := {0,1,2,3,…}$ der *natürlichen Zahlen*,
  - die Menge $ℕ⁺ := {1,2,3,…}$ der positiven natürlichen Zahlen, und
  - die Menge $ℤ := {…,-2,-1,0,1,2,…}$ der *ganzen Zahlen*.
]

#bemerkung(slides: 0)[
  Das Symbol $ℕ$ wird nicht einheitlich verwendet und bedeutet je nach Autor dasselbe wie $ℕ₀$ oder dasselbe wie $ℕ⁺$. Wenn wir die Anwesenheit oder Abwesenheit der $0$ betonen wollen schreiben wir explizit $ℕ₀$ oder $ℕ⁺$. Ansonsten schreiben wir $ℕ$ was bei uns die $0$ einschließt.
]

#definition("Vereinigung", kurz: $A ∪ B$)[
  Seien $A$ und $B$ Mengen. Die *Vereinigung* $A union B$ ist die Menge
  aller Elemente, die in $A$ oder in $B$ (oder in beiden) liegen:
  $ A union B := {x | x in A "oder" x in B}. $
]

#abbildung(slides: 0, caption: [Vereinigung $A union B$])[#venn("vereinigung")]

#definition("Schnitt", kurz: $A ∩ B$)[
  Seien $A$ und $B$ Mengen. Der *Schnitt* (oder *Durchschnitt*) $A inter B$
  ist die Menge aller Elemente, die sowohl in $A$ als auch in $B$ liegen:
  $ A inter B := {x | x in A "und" x in B}. $
]
#abbildung(slides: 0, caption: [Schnitt $A inter B$])[#venn("schnitt")]


#definition("Differenz", kurz: $A without B$)[
  Seien $A$ und $B$ Mengen. Die *Differenz* $A without B$ („$A$ ohne $B$“)
  ist die Menge aller Elemente von $A$, die nicht in $B$ liegen:
  $ A without B := {x in A | x in.not B}. $
]

#abbildung(slides: 0, caption: [Differenz $A without B$])[#venn("differenz")]

#definition("Disjunkt", kurz: [$A ∩ B = ∅$])[
  Wir sagen $A$ und $B$ sind *disjunkt*, falls $A ∩ B = ∅$.
]
#abbildung(slides: 0, caption: [Zwei disjunkte Mengen $A$ und $B$])[#venn("disjunkt")]

#notation("Teilmenge", kurz: $A ⊆ B$)[
  Für Mengen $A, B$ schreiben wir $A ⊆ B$ für die Aussage
  „jedes Element von $A$ ist auch ein Element von $B$“.
  Wir sagen dann „$A$ ist *Teilmenge* von $B$“.
]

#abbildung(slides: 0, caption: [$A$ ist Teilmenge von $B$])[#venn("teilmenge")]

#bemerkung[
  Für jede Menge $A$ gilt $∅ ⊆ A$ und $A ⊆ A$.
]

#notation("echte Teilmenge", kurz: [$A ⊊ B$])[
  Für Mengen $A$ und $B$ nennen wir $A$ *echte Teilmenge* von $B$, wenn $A ⊆ B$ und zusätzlich $A ≠ B$ gilt. Wir schreiben dann $A ⊊ B$.
]

#bemerkung($A ⊂ B$)[
  Manche Autoren schreiben für die echte Teilmengenbeziehung $A ⊂ B$ — in Analogie zu $<$ bei Zahlen.
  Andere benutzen $⊂$ synonym zu $⊆$.
]

#definition("Komplement", kurz: $A^C$)[
  Ist eine feste *Grundmenge* $U$ gegeben und ist $A ⊆ U$, so heißt
  $ A^C := U without A $
  das *Komplement* von $A$ (bezüglich $U$).#footnote[Die Schreibweise $A^C$ nennt $U$ nicht; die Grundmenge muss daher aus dem Zusammenhang hervorgehen.]
]

#abbildung(slides: 0, caption: [Komplement $A^C$ bezüglich einer Grundmenge $U$])[#venn("komplement")]

#notation("Kardinalität", kurz: $|A|$)[
  Für eine endliche Menge $A$ schreiben wir $|A|$ für die Anzahl ihrer Elemente und nennen diese Anzahl die *Kardinalität* von $A$.
]

#beispiel(slides: 0)[
  Sei $U := {1,2,3,4,5}$ die Grundmenge, $A := {1,2,3}$ und $B := {3,4}$. Dann ergibt sich:

  #table(
    columns: 2,
    stroke: none,
    table.header[*Sprechweise*][*Schreibweise und Ergebnis*],
    table.hline(),
    [Vereinigung von $A$ und $B$], [$A ∪ B = {1,2,3,4}$],
    [Schnitt von $A$ und $B$], [$A ∩ B = {3}$],
    [Differenz "$A$ ohne $B$"], [$A ∖ B = {1,2}$],
    [Differenz "$B$ ohne $A$"], [$B ∖ A = {4}$],
    [Komplement von $A$], [$A^C = {4,5}$],
    [Kardinalität von $A$], [$|A| = 3$],
  )
]

#bemerkung([Unendliche Mengen], kurz: $|ℕ| = ∞.$)[
  Für eine unendliche Menge $A$ schreiben wir $|A| = ∞$. In @sec:cardinality haben wir mehr dazu zu sagen.
]

#uebung[
  Begründen Sie die Richtigkeit folgender Gleichungen.
  + ${2⋅n | n ∈ ℕ} ∩ {3⋅n | n ∈ ℕ} = {6⋅n | n ∈ ℕ}$
  + ${1,3,5,7,…}^C = {…,-2,-1,0} ∪ {2⋅n | n ∈ ℕ}$\
    wenn das Komplement bezüglich $U := ℤ$ gebildet wird
  + $abs(lr({A ⊆ {1,2,3,4,5} mid(|) |A| = 2}, size: #120%)) = 10$
]
#loesung[
  + Beide Seiten beschreiben die Menge der durch sechs teilbaren natürlichen Zahlen. Hier kommt die Einsicht zum Tragen, dass eine Zahl genau dann durch sechs teilbar ist, wenn sie sowohl durch zwei als auch durch drei teilbar ist (was wir hier ohne Beweis glauben wollen).
  + Auf der linken Seite wird das Komplement der ungeraden natürlichen Zahlen gebildet. Da wir das Komplement in $ℤ$ bilden sollen, sind im Komplement neben den geraden natürlichen Zahlen auch die negativen ganzen Zahlen vertreten. Dass die 0 auf beiden Seiten der Vereinigung auftritt, spielt keine Rolle.
  + Hier werden alle Teilmengen von ${1,2,3,4,5}$ der Größe $2$ zu einer Menge zusammengefasst. Diese sind ${1,2}$, ${1,3}$, ${1,4}$, ${1,5}$, ${2,3}$, ${2,4}$, ${2,5}$, ${3,4}$, ${3,5}$, ${4,5}$. Die Kardinalität dieser Menge ist $10$.
]

#uebung[Spitzfindigkeiten][
  Kommentieren Sie:
  + ${2⋅n | n ∈ ℕ} = {2⋅x | x ∈ ℕ} = {2⋅ξ | ξ ∈ ℕ}$
  + ${n² | n ∈ ℕ} = {n ∈ ℕ | "es gibt ein" k ∈ ℕ "mit" n = k²}$
  + $|{}| = 0$, $|∅| = 0, |{∅}| = 1, |{{},∅,{∅}}| = 2$
]
#loesung[
  + Hier wird jeweils die Menge der geraden Zahlen beschrieben. Wie die Variable heißt, die dabei als Hilfsmittel verwendet wird, spielt keine Rolle.
  + Wir sehen zwei Arten, die Menge der Quadratzahlen zu notieren. Die Perspektive und die Rolle der Variablen $n$ unterscheiden sich. Im ersten Fall nehmen wir jedes $n ∈ ℕ$ her, quadrieren es und sammeln die Ergebnisse auf. Im zweiten Fall nehmen wir jedes $n ∈ ℕ$ her, nehmen es aber nur in die Menge auf, wenn eine andere natürliche Zahl $k$ bezeugt, dass $n$ eine Quadratzahl ist (in dem Fall ist $k$ die Wurzel von $n$).
  + Die leere Menge hat keine Elemente, egal ob man sie "${}$" oder "$∅$" schreibt. Die Menge ${∅}$ hat ein Element, nämlich die leere Menge. Die Menge ${{},∅,{∅}}$ hat zwei Elemente, nämlich ${}$ und ${∅}$. Das vermeitlich dritte Element $∅$ ist identisch mit dem ersten.
]

== Exkurs: Probleme der naiven Mengenlehre

#bemerkung(slides: "titel")[Die Menge aller Mengen?][\
  _“You can define the barber as ‘one who shaves all those, and those only, who do not shave themselves.’ The question is, does the barber shave himself?” — Bertrand Russell 1918_.

  Der naive Mengenbegriff hat das Problem, dass es Beschreibungen von Mengen gibt, die einen inneren Widerspruch enthalten, ähnlich wie das oben abgedruckte Barbierparadoxon.

  Wir definieren

  + Sei $ℳ$ die Menge aller Mengen.\ _Beachte: Da $ℳ$ eine Menge ist, muss $ℳ$ sich selbst enthalten._
  + Sei $R = { m ∈ ℳ | m ∉ m }$.
  + Frage: Gilt $R ∈ R$? Beide Antworten führen auf einen Widerspruch.#footnote[Nach 2 soll $R$ dann und nur dann in die Menge $R$ aufgenommen werden, wenn $R ∉ R$ gilt. Das heißt, es müsste $R ∈ R$ genau dann gelten, wenn $R ∉ R$ gilt.]

  Das Problem wird gelöst, indem Formulierungen wie in 1 für unzulässig erklärt werden: Mengen dürfen nur auf eine bestimmte Art und Weise (gemäß dem Zermelo-Fraenkel-Axiomensystem) gebildet werden. Die Axiome schließen aus, dass Mengen sich selbst enthalten. In dieser Vorlesung werden wir mit der naiven Mengenlehre arbeiten. Die Gefahr, dabei in eine Paradoxie zu laufen, ist gering, wenn man es nicht darauf anlegt.
]<mengeAllerMengen>

#bemerkung(slides: "titel")[Sind Zahlen auch Mengen?][
  Die axiomatische Mengenlehre ist ein bewährtes Fundament der Mathematik. Daher bilden Mathematiker zuweilen auch solche Objekte in der Mengenlehre nach, die viel älter als die Mengenlehre sind, um diese in der Mengenlehre zu _fundieren_.

  Die _Konstruktion_ der natürlichen Zahlen gemäß John von Neumann kommt mit einer Schachtelung von Mengen ausgehend von der leeren Menge aus. Die 0 entspricht ∅, und entspricht die Menge $M$ der Zahl $n$, so entspricht $M ∪ {M}$ der Zahl $n+1$. Dann gilt#footnote[Wir schreiben $hat(=)$ für „entspricht“. Die Vorstellung ist nicht, dass wir die natürlichen Zahlen _definieren_. Die natürlichen Zahlen gibt es bereits. Vielmehr identifizieren wir Mengen, die sich wie die natürlichen Zahlen verhalten.]:
  - $0 hat(=) ∅$
  - $1 hat(=) {∅}$
  - $2 hat(=) {∅,{∅}}$
  - $3 hat(=) {∅,{∅},{∅,{∅}}}$
  - $4 hat(=) {∅,{∅},{∅,{∅}},{∅,{∅},{∅,{∅}}}}$
  - …
  In dieser Vorlesung werden wir die Existenz der Zahlen nicht weiter hinterfragen und auf der Schulmathematik aufbauen. Wir werden aber sehr wohl Konzepte wie Funktionen oder Relationen mengentheoretisch fundieren.
]

#slidebreak()
= Graphen

#skript[
  Graphen sind eine zentrale diskrete Struktur der Informatik: Beispiele sind Straßennetze, Rechnernetze, soziale Netzwerke, Zustandsübergänge eines Automaten oder Dreiecksnetze in der Computergrafik (siehe Beispielabbildungen unten).

  Wir führen Graphen bereits jetzt ein, weil sie uns durch die ganze Vorlesung als Beispielmaterial für andere Konzepte begleiten. Am Ende der Vorlesung folgt ein Abschnitt mit etwas anspruchsvollerer Graphentheorie (dann als Selbstzweck).
]

// Bildquellen (alle Wikimedia Commons, alle gemeinfrei / Public Domain).
// Abgerufen am 24.09.2026.
//
// bilder/Road_map_graph_plain.svg
//   „Road map graph plain.svg“ von Dimitris131, 12.01.2024, 518×367
//   https://commons.wikimedia.org/wiki/File:Road_map_graph_plain.svg
//   Lizenz: gemeinfrei (PD-self)
//
// bilder/Dolphin_triangle_mesh.png
//   „Dolphin triangle mesh.png“ von Chrschn (en:User:Chrschn), 27.03.2007, 634×391
//   https://commons.wikimedia.org/wiki/File:Dolphin_triangle_mesh.png
//   Lizenz: gemeinfrei (PD-self)
//
// bilder/DFAexample.svg
//   „DFAexample.svg“ von Cepheus, 01.10.2006, 500×299
//   https://commons.wikimedia.org/wiki/File:DFAexample.svg
//   Lizenz: gemeinfrei (PD-self)
//
// bilder/AST_binary_tree_arithmetic.svg
//   „AST binary tree arithmetic.svg“ von Emergie, 333×265
//   https://commons.wikimedia.org/wiki/File:AST_binary_tree_arithmetic.svg
//   Lizenz: gemeinfrei (PD-self); basiert auf File:Sorted_binary_tree.svg
//   Bearbeitet: Beschriftungen geändert

#let H = 3cm
#grid(
  columns: 2,
  gutter: 8pt,
  row-gutter: 10pt,
  figure(image("bilder/Road_map_graph_plain.svg", height: H, fit: "contain"), caption: [Straßennetz]),
  figure(image("bilder/Dolphin_triangle_mesh.png", height: H, fit: "contain"), caption: [Dreiecksnetz]),

  [#figure(
    image("bilder/DFAexample.svg", height: H, fit: "contain"),
    caption: [Einfacher endlicher Automat],
  )<endlicherAutomat>],
  figure(
    image("bilder/AST_binary_tree_arithmetic.svg", height: H, fit: "contain"),
    caption: [Syntaxbaum des arithmetischen Ausdrucks 3⋅(2-3)+(2+7)],
  ),
)

== Definition

#definition("Graph", kurz: $G = (V,E)$)[
  Ein *(einfacher, ungerichteter) Graph* ist ein Paar $G = (V,E)$ aus einer endlichen, nichtleeren Menge $V$ von *Knoten* (englisch „vertex“ mit Plural „vertices“) und einer Menge
  $ E ⊆ {{v,w} | v,w ∈ V, v ≠ w} $
  von *Kanten* (englisch „edges“).
]

#konvention(kurz: [$n := |V|$, $m := |E|$])[Knotenzahl, Kantenzahl][
  Wenn wir mit einem Graphen $G = (V,E)$ arbeiten, bezeichnen wir in der Regel mit $n := |V|$ die Knotenzahl und mit $m := |E|$ die Kantenzahl.
]<graph-nm>

#definition("Nachbar, Grad, adjazent, isoliert", slides: "titel")[
  Sei $G = (V,E)$ ein Graph und $v,w ∈ V$. Falls ${v,w} ∈ E$ gilt, nennt man $v$ und $w$ *adjazent* oder *Nachbarn*. Der *Grad* $deg(v)$ von $v$ ist die Anzahl seiner Nachbarn:
  $ deg(v) := |{w ∈ V | {v, w} ∈ E}|. $
  Ein Knoten von Grad 0 heißt *isoliert*.
]

#let gKnoten = (
  "1": (0, 0.9),
  "2": (1.2, 0.9),
  "3": (0.6, 0),
  "4": (2.0, -0.3),
  "5": (3.1, 0.4),
  "6": (4.1, 0.4),
)
#let gKanten = (("1", "2"), ("1", "3"), ("2", "3"), ("3", "4"), ("4", "5"))

#beispiel("Ein Graph", kurz: [$G$ mit $V = {1,…,6}$ und 5 Kanten])[
  Sei $G = (V,E)$ gegeben durch
  $ V := {1,2,3,4,5,6} quad "und" quad E := {{1,2},{1,3},{2,3},{3,4},{4,5}}. $
  Um ihn visuell darzustellen, zeichnen wir einen Kreis (oder Punkt) für jeden Knoten. Für jede Kante ${v,w} ∈ E$ zeichnen wir eine Verbindungslinie zwischen den zugehörigen Kreisen.
  $ #graphbild(gKnoten, gKanten, radius: 0.3) $
  Im Beispiel gilt $n = |V| = 6$ und $m = |E| = 5$. Der Knoten 6 ist isoliert. Die Knoten $1$ und $2$ sind adjazent. Die Knoten $2$ und $4$ sind hingegen nicht adjazent. Eine Tabelle der Knotengrade ist:
  $
    #table(
      columns: 7,
      stroke: none,
      align: center,
      [$v$], [1], [2], [3], [4], [5], [6],
      table.hline(),
      [$deg(v)$], [2], [2], [3], [2], [1], [0],
      table.vline(x: 1),
    )
  $
]<bspgraph>

#bemerkung[
  Unsere Definition fängt nicht alle Details der Beispielbilder oben ein. Nicht vorgesehen haben wir zum Beispiel:
  - Kantenrichtung (Pfeilspitzen)
  - Schlingen (Kanten von einem Knoten zu sich selbst)
  - Knotenbeschriftungen und besonders ausgezeichnete Knoten
  - Kantenbeschriftungen
  - Positionen von Knoten im zweidimensionalen oder dreidimensionalen Raum
  - Verlauf von Kanten in der Ebene
  Für manche dieser Eigenschaften werden wir später in der Vorlesung sehen, wie man sie "nachrüsten" kann.
]

== Galerie einfacher Graphen

// Ein Element der Galerie: Bild fester Höhe mit Unterschrift, aber ohne
// eigene Abbildungsnummer. Die Nummer vergibt die umschließende Abbildung.
#let galeriebild(inhalt, titel, h: 2.4cm) = align(center)[
  #box(height: h, align(horizon, inhalt))
  #v(0.3em, weak: true)
  #text(size: 0.85em, titel)
]

#figure(
  grid(
    columns: 3,
    gutter: 6pt,
    row-gutter: 8pt,
    align: center + top,
    galeriebild(pfadbild(5, beschriftung: false), [Pfad $P_5$]),
    galeriebild(kreisbild(6, beschriftung: false), [Kreis $C_6$]),
    galeriebild(vollstaendigbild(5, beschriftung: false), [vollständiger Graph $K_5$]),

    galeriebild(sternbild(6, beschriftung: false), [Stern $S_6$]),
    galeriebild(bipartitbild(3, 4, beschriftung: false), [vollständiger bipartiter Graph $K_(3,4)$]),
  ),
  kind: image,
  caption: [Einige einfache Graphen],
)<galerie>

#uebung[Definitionen von $P_n$, $C_n$, $S_n$, $K_n$ und $K_(m,n)$][
  Generalisieren Sie die Beispiele aus @galerie.
]<graphengallerie-uebung>

#loesung[
  Mögliche Definitionen (der Form $G = (V,E)$) sind:
  $
    P_n & := ({1,…,n},{{i,i+1} | i ∈ {1,…,n-1}}) \
    C_n & := ({1,…,n},{{i,i+1} | i ∈ {1,…,n-1}} ∪ {{n,1}}) \
    K_n & := ({1,…,n},{{i,j} | i,j ∈ {1,…,n}, i ≠ j}) \
    S_n & := ({0,…,n}, {{0,i} | i ∈ {1,…,n}})
  $
  Für $K_(m,n)$ nehme man beliebige disjunkte Mengen $A$, $B$ mit $|A| = m$ und $|B| = n$ und definiere: $ K_(m,n) := (A ∪ B, {{a,b} | a ∈ A, b ∈ B}) $
  Beachte: Der Graph $K_(m,n)$ hat Knotenzahl $m+n$ und der Graph $S_n$ hat Knotenzahl $n+1$. Der Index zählt hier also nicht die Knoten, anders als bei $P_n$, $C_n$ und $K_n$ und anders als in @graph-nm.

  Die Parameter $n,m$ sind beliebig aus $ℕ⁺$ zu wählen, mit Ausnahme von $C_n$, wo $n = 1$ und $n = 2$ nicht sinnvoll ist.
]

#bemerkung[
  Es kommt bei den Definitionen in @graphengallerie-uebung nicht auf die Wahl der Knotenmenge an, solange die Struktur stimmt.#footnote[Das relevante Konzept von "Graphisomorphie" kommt im Kapitel zu Äquivalenzklassen.]
]

== Wege, Pfade, Kreise, Zusammenhang

#definition[Weg, Pfad, Zyklus, Kreis][
  Gegeben sei ein Graph $G = (V,E)$ und eine Folge $(v₀,…,v_ℓ)$ von Knoten aus $V$ für ein $ℓ ∈ ℕ$, im Folgenden meist in Kurzschreibweise als $v₀ … v_ℓ$. Wir nennen die Knotenfolge *Weg* / *Pfad* / *Zyklus* / *Kreis* unter folgenden Bedingungen.#footnote[Die englischen Bezeichnungen sind in der Literatur einheitlich, die deutschen nicht.]
  #table(
    stroke: none,
    columns: 3,
    [Konzept], [englisch], [Bedingung],
    table.hline(),
    [Weg], [walk], [$∀ i ∈ {0,…,ℓ-1}: {v_i,v_(i+1)} ∈ E$],
    [Pfad], [path], [Weg und $|{v_0,…,v_ℓ}| = ℓ+1$ ],
    [Zyklus], [closed walk], [Weg und $v₀ = v_ℓ$ ],
    [Kreis], [cycle], [Zyklus und $|{v₀,…,v_ℓ}| = ℓ$ und $ℓ ≥ 3$],
  )
  Ein Pfad ist also ein Weg ohne wiederholte Knoten und ein Kreis ein Zyklus, bei dem $v₀ = v_ℓ$ die einzige Wiederholung ist. Die *Länge* eines Wegs/Pfads/Zyklus/Kreises ist die Anzahl der „Schritte“, also $ℓ$.

  Die Bedingung $ℓ ≥ 3$ beim Kreis schließt aus, dass man eine Kante einfach hin und zurück durchläuft: Die Folge $v₀ v₁ v₀$ ist ein Zyklus der Länge 2, aber kein Kreis. Ein Kreis hat also mindestens die Länge 3.
]<wegpfadkreis>

#beispiel[
  Im Graph aus @bspgraph ist enthalten:
  - der Weg $43123$ der Länge 4,
  - der Pfad $5431$ der Länge 3,
  - der Zyklus $123123431$ der Länge 8,
  - der Kreis $1231$ der Länge 3,
  - der Pfad $4$ der Länge 0.
]

#definition("zusammenhängend")[
  Ein Graph $G = (V,E)$ heißt *zusammenhängend*, falls es für alle $v,w ∈ V$ einen Pfad von $v$ nach $w$ gibt.
]

== Bäume

#definition(kurz: [azyklisch $defiff$ keine Kreise.])[azyklisch][
  Ein Graph heißt *azyklisch*, wenn er keine Kreise hat.
]

#definition(kurz: [Baum $colon ⇔$ zusammenhängend & azyklisch])[Baum][
  Ein *Baum* ist ein zusammenhängender azyklischer Graph.
]

#definition(kurz: [Knoten von Grad $1$])[Blatt][
  Ein *Blatt* eines Baumes ist ein Knoten vom Grad 1.
]

#let baumKnoten = (
  "1": (0, 0.9),
  "2": (1.2, 0.9),
  "3": (0.6, 0),
  "4": (2.0, -0.3),
  "5": (3.1, 0.4),
)
#let baumKanten = (("1", "3"), ("2", "3"), ("3", "4"), ("4", "5"))

#abbildung(
  slides: 0,
  graphbild(baumKnoten, baumKanten, radius: 0.3),
  kind: image,
  caption: [Ein Baum mit den Blättern 1, 2 und 5.],
)

#slidebreak()
= Aussagen und Beweise

== Aussagen und Formeln

#definition(kurz: [ein formales oder sprachliches Gebilde, das entweder wahr oder falsch ist.])[Aussage][
  Eine Aussage ist ein formales oder sprachliches Gebilde, das entweder wahr oder falsch ist.
  - „$4 ∈ {2⋅n | n ∈ ℕ}$“ ist eine Aussage. Sie ist wahr.
  - „$7 < 5$“ ist eine Aussage. Sie ist falsch.
  - „Am 12.1.2042 regnet es in Stuttgart.“ ist eine Aussage. Wir wissen derzeit nicht, ob sie wahr oder falsch ist.
]

#skript[
  Aussagen in natürlicher Sprache sind manchmal ungenau. In diesem Abschnitt lernen wir Symbole kennen, die im Folgenden helfen, mathematische Aussagen präzise zu formulieren.
]

#definition(kurz: [Wie formale Aussage, aber oft mit freien Variablen])[Formel][
  Eine *Formel* ist ein Gebilde in dem *Variablen* vorkommen dürfen, deren Werte durch die Formel selbst nicht festgelegt sind. Zum Beispiel ist „$2⋅x+1 ∈ A$“ eine Formel. Werden für die Variablen $x$ und $A$ konkrete Werte eingesetzt (für $x$ eine Zahl und für $A$ eine Menge), dann entsteht eine Aussage, die dann wahr oder falsch ist. Wir sagen, $x$ und $A$ kommen *frei* in der Formel vor.

  Ausdrücke, die keinen Wahrheitswert bezeichnen, sondern etwa eine Zahl, eine Menge oder einen Graphen, heißen *Terme*. Zum Beispiel ist $2⋅x$ ein Term in obiger Formel.
]

=== Formeln mit $∧, ∨, ¬, →, ↔$

#definition("Aussagenlogische Formeln", kurz: [$∧, ∨, ¬, →, ↔$])[
  Eine aussagenlogische Formel ist eine Formel, die aus Variablensymbolen, den aussagenlogischen Verknüpfungen $∧$,$∨$,$→$,$↔$, dem Negationssymbol $¬$, und, wenn nötig, Klammern besteht. Die Variablen heißen auch *Elementaraussagen* und können nur die Werte _wahr_ oder _falsch_ annehmen.
  Die Bedeutung der Symbole $∧$,$∨$,$→$,$↔$,$¬$ ist wie folgt:
  #table(
    columns: 3,
    stroke: none,
    table.header[*Konzept*][*schreibe*][*sprich*],
    table.hline(y: 1),
    [Konjunktion], [$P ∧ Q$], [$P$ und $Q$],
    [Disjunktion], [$P ∨ Q$], [$P$ oder $Q$],
    [Negation], [$¬P$], [nicht $P$],
    [Implikation], [$P → Q$], [wenn $P$ dann $Q$],
    [Äquivalenz], [$P ↔ Q$], [$P$ genau dann, wenn $Q$],
  )
  Anmerkungen zur präzisen Bedeutung:
  / $P ∧ Q$: heißt _sowohl_ $P$ _als auch_ $Q$ ist wahr.
  / $P ∨ Q$: heißt $P$ ist wahr oder $Q$ ist wahr _oder beide sind wahr_.
  / $¬P$: heißt $P$ ist falsch.
  / $P → Q$: ist definiert als $¬P ∨ Q$. Insbesondere ist eine Implikation wahr, wenn die linke Seite falsch ist. Die Verwendung von „wenn-dann“ in der Alltagssprache unterscheidet sich hiervon teilweise. #footnote[
      Marie sagt „Wenn ich diesen Stein loslasse, dann fällt er nach oben“. Marie lässt den Stein nicht los. Ist Maries Aussage wahr? Ein Logiker, der an „$→$“ denkt, könnte zustimmen. Versteht man den Satz als „Wenn ich diesen Stein _losließe_, dann _fiele_ er nach oben“, dann ist der Satz falsch. Was dieser Satz formal bedeutet, ist nicht leicht zu fassen.
    ]
  / $P ↔ Q$: ist definiert als $(P → Q) ∧ (Q → P)$.
]<logischeVerknüpfungen>

#definition(kurz: [])[Wahrheitstabelle][
  Eine *Wahrheitstabelle* für eine aussagenlogische Formel stellt dar, wie sich der Wahrheitswert aus den Wahrheitswerten der Elementaraussagen ergibt. Wir schreiben dabei $0$ für „falsch“ und $1$ für „wahr“.
]

#abbildung(slides: 0, caption: [Wahrheitstabelle für $¬$.])[
  #table(
    columns: 2,
    stroke: none,
    table.header[*$P$*][*$¬P$*],
    table.hline(),
    table.vline(x: 1),
    [0], [1],
    [1], [0],
  )
]

#abbildung(slides: 0, caption: [Wahrheitstabelle für $∧,∨,→,↔$.])[
  #table(
    columns: 6,
    stroke: none,
    table.header[*$P$*][*$Q$*][*$P ∧ Q$*][*$P ∨ Q$*][*$P → Q$*][*$P ↔ Q$*],
    table.hline(),
    table.vline(x: 2),
    [0], [0], [0], [0], [1], [1],
    [0], [1], [0], [1], [1], [0],
    [1], [0], [0], [1], [0], [0],
    [1], [1], [1], [1], [1], [1],
  )
]<wahrheitstabelle-verknüpfungen>

#definition(kurz: [])[Äquivalente Formeln][
  Zwei aussagenlogische Formeln heißen *äquivalent*, wenn sich für jede Belegung der Elementaraussagen mit Wahrheitswerten der selbe Wahrheitswert insgesamt ergibt (mit anderen Worten: wenn die Wahrheitstabellen übereinstimmen).#footnote[In einem späteren Kapitel wird es noch eine formalere Definition geben.]
]

#uebung(kurz: [Zeige: $P ↔ Q$ und $(P ∧ Q) ∨ (¬P ∧ ¬Q)$ sind äquivalent.])[
  Weisen Sie durch Anfertigung einer Wahrheitstabelle nach, dass die Formeln $P ↔ Q$ und $(P ∧ Q) ∨ (¬P ∧ ¬Q)$ äquivalent sind.
]
#loesung[
  Die Wahrheitstabelle für $P ↔ Q$ haben wir schon. Die Wahrheitstabelle für die andere Aussage erhalten wir Schritt für Schritt aus Wahrheitstabellen ihrer Teilformeln.

  #block(breakable: false)[
    #table(
      columns: 5,
      stroke: none,
      align: center,
      table.header[*$P$*][*$Q$*][*$P ∧ Q$*][*$¬P ∧ ¬Q$*][*$(P ∧ Q) ∨ (¬P ∧ ¬Q)$*],
      table.hline(),
      table.vline(x: 2),
      [0], [0], [0], [1], [1],
      [0], [1], [0], [0], [0],
      [1], [0], [0], [0], [0],
      [1], [1], [1], [0], [1],
    )
  ]
  Da die Spalte für $P ↔ Q$ in @wahrheitstabelle-verknüpfungen und die Spalte für $(P ∧ Q) ∨ (¬P ∧ ¬Q)$ hier den gleichen Inhalt haben, sind beide Formeln äquivalent.
]

#uebung(kurz: [Beispiel an der Tafel])[
  Ein Zeuge beschuldigt Paul des Mordes. Wir betrachten die Elementaraussagen:
  / Z: Der Zeuge spricht die Wahrheit.
  / M: Paul ist der Mörder.
  / G: Paul muss ins Gefängnis.
  Formulieren Sie formale Aussagen, die folgenden Äußerungen möglichst nahe kommen.
  + Paul beteuert: „Ich war's nicht.“
  + Der Staatsanwalt fordert: „Mörder müssen ins Gefängnis.“
  + Der Verteidiger fordert: „Wer unschuldig ist, wird freigesprochen.“
  + Journalist A schreibt: „Wenn der Zeuge die Wahrheit sagt, ist Paul der Mörder.“
  + Journalist B schreibt: „Wenn Paul unschuldig ist, hat der Zeuge gelogen.“
  + Journalist C schreibt: „Paul war der Mörder oder der Zeuge lügt.“
]

#loesung[
  + $¬M$
  + $M → G$
  + $¬M → ¬ G$. Diese Aussage ist äquivalent zu $G → M$, denn beide bedeuten nach Definition von „$→$“ dasselbe, nämlich $M ∨ ¬G$.
  + $Z → M$
  + $¬M → ¬Z$
  + $M ∨ ¬Z$

  Die letzten drei Aussagen sind äquivalent. Wir überlegen uns das formal in @kontraposition.
]

#uebung[
  Inwiefern „passt“ $∧$ zu $∩$ und $∨$ zu $∪$?
]
#loesung[
  Für beliebige Mengen $A$ und $B$ gilt
  $
    x ∈ A ∧ x ∈ B "genau dann, wenn" x ∈ A ∩ B\
    x ∈ A ∨ x ∈ B "genau dann, wenn" x ∈ A ∪ B.
  $
]

=== Formeln mit den Quantoren ∀ und ∃

#bemerkung("Formel allgemein")[
  Wir werden die aussagenlogischen Verknüpfungen nun auch außerhalb rein aussagenlogischer Kontexte verwenden. Zum Beispiel könnten wir Formeln betrachten wie $x ∈ A ∧ ¬(2⋅x ∈ A)$ die Arithmetik, Mengenlehre und Aussagenlogik mischen. Zudem brauchen wir *Quantoren*, die wir nun einführen.
]

#notation(kurz: $∀,∃$)[Quantoren $∀,∃$][
  Ist $P$ eine Formel, in der die Variable $x$ frei vorkommt, und $M$ eine Menge von Werten, die man sinnvoll für $x$ einsetzen kann, dann können wir folgende komplexere Formeln bilden.
  #table(
    columns: 3,
    stroke: none,
    table.header[*Konzept*][*schreibe*][*sprich*],
    table.hline(y: 1),
    [Allquantor], [$∀x ∈ M: P$], [für _alle_ $x$ aus $M$ gilt $P$],
    [Existenzquantor], [$∃x ∈ M: P$], [für _mindestens ein_ $x$ aus $M$ gilt $P$],
    [], [$∃!x ∈ M: P$], [für _genau ein_ $x$ aus $M$ gilt $P$],
  )
  Der Ausdruck $∀x ∈ M: P$ meint: Aus $P$ wird eine wahre Aussage, ganz egal welchen Wert aus $M$ man für $x$ einsetzt.
  Analog bedeutet $∃x ∈ M: P$, dass es mindestens ein Element in $M$ gibt, das, wenn man es für $x$ einsetzt, zu einer wahren Aussage führt. Die Variante "$∃!$" wird nur selten verwendet.

  Man sagt, die Variable $x$ wird durch den Quantor *gebunden* und ist entsprechend in der resultierenden Formel nicht mehr frei (der Quantor legt fest, wie die Variable mit Werten zu belegen ist).
]

#uebung[
  Sind folgende Aussagen wahr oder falsch?
  + $∃x ∈ ℕ: 4⋅x = 20$
  + $∃x ∈ ℕ: 4⋅x = 10$
  + $∃x ∈ ℕ: ∀y ∈ ℕ: x > y$
  + $∀y ∈ ℕ: ∃x ∈ ℕ: x > y$
  + $∀x ∈ ℕ: ∃k ∈ ℕ: x = 2⋅k+1 ∨ x = 2⋅k$
]

#loesung[
  + Wahr, wähle $x = 5$.
  + Falsch, keine zulässige Wahl von $x$ ist möglich (beachte: 2,5 $∉ ℕ$).
  + Falsch, gesucht ist eine Zahl $x$, die größer ist als jede andere Zahl. Die gibt es nicht.
  + Wahr. Zu jeder Zahl $y$ lässt sich eine größere Zahl finden, etwa $x := y+1$.
  + Wahr. Für jedes ungerade $x$ gibt es ein $k$, um die linke Seite der Disjunktion zu erfüllen, für jedes gerade $x$ gibt es ein $k$, um die rechte Seite der Disjunktion zu erfüllen.
]

#bemerkung[
  Die dritte und die vierte Aussage der vorherigen Übung zeigen, dass man einen Allquantor und einen Existenzquantor nicht vertauschen darf. Das ist auch in der Alltagssprache so: "Für jeden Topf gibt es einen passenden Deckel." ist etwas anderes als "Es gibt einen Deckel der auf jeden Topf passt".
  Das ist eine häufige Fehlerquelle.
]<quantorenTauschen>

#uebung[Spitzfindigkeiten][
  Sind folgende Aussagen wahr oder falsch?
  + $∀x ∈ ℕ: 1+1=2$
  + $∃x ∈ ∅: 1+1=2$
  + $∀x ∈ ∅: 1+1=3$
]

#loesung[
  Das eigentümliche an diesen Aussagen ist, dass $x$ nicht in der inneren Formel vorkommt und das in 2 und 3 über die leere Menge quantifiziert wird. Man darf solche Formeln trotzdem bilden.
  + Wahr.
  + Falsch (es gibt kein $x$ in der leeren Menge).
  + Wahr ("alle" Elemente aus ∅, wovon es 0 gibt, erfüllen die Formel).

  Wahr. Die Aussage ist komisch, weil $x$ in der inneren Formel "1+1=2" nicht frei vorkommt. Man darf solche Formeln trotzdem bilden, es ist nur ziemlich sinnlos.
]


#uebung[
  Erstellen Sie Formeln, die folgende natürlichsprachliche Aussagen ausdrücken. Die Objekte, über die gesprochen wird, seien eine Zahl $x ∈ ℕ$, ein Graph $G = (V,E)$ und ein Knoten $v₀ ∈ V$. Diese werden frei in der Formel vorkommen.
  + $x$ ist eine Primzahl
  + $G$ enthält ein Dreieck.
  + $v₀$ hat mindestens zwei Nachbarn.
  + Jeder Knoten von $G$ hat einen Nachbarn.
  + $G$ ist vollständig.
  + $G$ hat einen Knoten, der zu allen anderen Knoten benachbart ist.
]<uebung-formeln>

#loesung[
  + $x > 1 ∧ ∀a ∈ ℕ : ∀b ∈ ℕ: x = a ⋅ b → (a = 1 ∨ b = 1)$
  + $∃u ∈ V: ∃v ∈ V: ∃w ∈ V: {u,v} ∈ E ∧ {v,w} ∈ E ∧ {u,w} ∈ E$
  + $∃w₁ ∈ V: ∃w₂ ∈ V: w₁ ≠ w₂ ∧ {v₀,w₁} ∈ E ∧ {v₀,w₂} ∈ E$
  + $∀v ∈ V: ∃w ∈ V: {v,w} ∈ E$
  + $∀v ∈ V: ∀w ∈ V: (v ≠ w → {v,w} ∈ E)$
  + $∃v ∈ V: ∀w ∈ V: (v ≠ w → {v,w} ∈ E)$

  Zu 2: Dass die drei Knoten paarweise verschieden sind, muss nicht gefordert werden. Kanten sind zweielementige Mengen, aus ${u,v} ∈ E$ folgt also bereits $u ≠ v$.

  Zu 5 und 6: Die Bedingung $v ≠ w$ ist dagegen nötig, denn ${v,v}$ ist keine Kante. Ohne sie wären die Formeln für jeden Graphen falsch.
]

=== Rechenregeln für Quantoren und Negation

#skript[
  Die folgenden Regeln benutzen wir im Rest der Vorlesung ständig, meist ohne sie zu erwähnen. Besonders wichtig ist, eine Aussage negieren zu können: Beim indirekten Beweis und beim Widerspruchsbeweis ist die Negation der Ausgangspunkt.
]

#satz("Doppelnegation", kurz: [$¬(¬P)$ ist äquivalent zu $P$])[
  $¬(¬P)$ ist äquivalent zu $P$.
]

#satz("De-Morgansche Regeln")[
  Für alle Aussagen $P$ und $Q$ gilt:
  - $¬(P ∧ Q)$ ist äquivalent zu $¬P ∨ ¬Q$.
  - $¬(P ∨ Q)$ ist äquivalent zu $¬P ∧ ¬Q$.
]

#skript[
  Ein Beweis der De-Morganschen Regeln, etwa mit Wahrheitstabellen, ist möglich aber wenig erhellend. Nützlicher ist es zu erkennen, dass Sie diese Regeln bereits intuitiv beherrschen, sogar in allgemeinerer Form:

  Eine Konjunktion $A ∧ B ∧ C ∧ …$ ("der Mörder ist alt und bärtig und charismatisch und …") ist dann falsch, wenn eine der beteiligten Aussagen falsch ist, also wenn $¬A ∨ ¬B ∨ ¬C ∨ …$ gilt.

  Eine Disjunktion $A ∨ B ∨ C ∨ …$ ("der Mörder war Alice oder Bob oder Carol oder …") ist dann falsch, wenn keine der genannten Möglichkeiten zutrifft, also wenn $¬A ∧ ¬B ∧ ¬C ∧ …$ gilt.
]

#bemerkung[De-Morgan in Worten][
  Beim Negieren einer Konjunktion oder Disjunktion wird die Negation auf alle Terme in der Klammer angewendet, und $∧$ und $∨$ vertauschen ihre Rollen.
]

#satz("Kontraposition", kurz: [$P → Q$ ist äquivalent zu $¬Q → ¬P$])[
  $P → Q$ ist äquivalent zu $¬Q → ¬P$.
]<kontraposition>

#beweis[
  Nach Definition von „$→$“ ist $¬Q → ¬P$ dasselbe wie $¬(¬Q) ∨ ¬P$. Nach dem Satz über die Doppelnegation ist das äquivalent zu $Q ∨ ¬P$. Weil es bei $∨$ nicht auf die Reihenfolge ankommt, ist das äquivalent zu $¬P ∨ Q$, was nach Definition von „$→$“ das gleich ist wie $P → Q$.
]

#bemerkung[
  Achtung: $P → Q$ ist _nicht_ äquivalent zu $Q → P$. Beispiel: „Wenn es regnet, ist die Straße nass“ ist etwas anderes als „Wenn die Straße nass ist, regnet es“.
]

#satz[
  $¬(P → Q)$ ist äquivalent zu $P ∧ ¬Q$.
]

#beweis[
  Nach Definition von „$→$“ ist $¬(P → Q)$ dasselbe wie $¬(¬P ∨ Q)$. Nach der zweiten de-Morganschen Regel ist das äquivalent zu $¬(¬P) ∧ ¬Q$ und nach dem Satz über die Doppelnegation zu $P ∧ ¬Q$.
]

#satz(kurz: [$¬∀ ⇝ ∃¬$ sowie $¬∃ ⇝ ∀¬$])[
  Sei $P$ eine Formel und seien $A, B, M$ Mengen. Dann gilt:
  + $¬ ∀x ∈ M: P$ ist äquivalent zu $∃x ∈ M: ¬ P$
  + $¬ ∃x ∈ M: P$ ist äquivalent zu $∀x ∈ M: ¬ P$
  + $∃x ∈ A: ∃y ∈ B: P$ ist äquivalent zu $∃y ∈ B: ∃x ∈ A: P$
  + $∀x ∈ A: ∀y ∈ B: P$ ist äquivalent zu $∀y ∈ B: ∀x ∈ A: P$
]

#beweis[
  + Eine Allaussage ist falsch genau dann, wenn es ein Gegenbeispiel gibt: _"Alle Studenten bestehen die Prüfung" ist falsch genau dann, wenn es einen Studenten gibt, der die Prüfung nicht besteht._
  + Eine Existenzaussage ist falsch genau dann, wenn für alle Kandidaten die Aussage falsch ist. _"Es gibt einen Studenten der die Prüfung besteht" ist falsch genau dann, wenn alle Studenten die Prüfung nicht bestehen._
  + Beide Formeln besagen, dass es ein $x ∈ A$ und ein $y ∈ B$ gibt, sodass $P$ wahr wird. Auf die Reihenfolge, in der man die Elemente festlegt, kommt es dabei nicht an.
  + Beide Formeln besagen, dass für jede Kombination aus einem $x ∈ A$ und einem $y ∈ B$ die Formel $P$ wahr wird. Die Reihenfolge der Festlegung ist wieder egal. $qedhere$
]

#bemerkung[
  Wir können gleichartige Quantoren zusammenfassen.
  - man schreibt $∃x₁,x₂ ∈ V: …$ für $∃x₁ ∈ V: ∃x₂ ∈ V: …$
  - man schreibt $∀x₁,x₂ ∈ V: …$ für $∀x₁ ∈ V: ∀x₂ ∈ V: …$
]

#uebung[
  Negieren Sie die Aussagen aus @uebung-formeln und formulieren Sie die Negation auch natürlichsprachlich.
]

#loesung[
  Wir ziehen die Negation jeweils mit den obigen Regeln nach innen.
  + $x ≤ 1 ∨ ∃a,b ∈ ℕ: x = a ⋅ b ∧ a ≠ 1 ∧ b ≠ 1$ \
    „$x$ ist höchstens 1 oder lässt sich als Produkt zweier Zahlen schreiben, von denen keine 1 ist.“
  + $∀u,v,w ∈ V: {u,v} ∉ E ∨ {v,w} ∉ E ∨ {u,w} ∉ E$ \
    „Unter je drei Knoten fehlt mindestens eine der drei Kanten.“
  + $∀w₁,w₂ ∈ V: w₁ = w₂ ∨ {v₀,w₁} ∉ E ∨ {v₀,w₂} ∉ E$ \
    „$v₀$ hat höchstens einen Nachbarn.“
  + $∃v ∈ V: ∀w ∈ V: {v,w} ∉ E$ \
    „$G$ hat einen isolierten Knoten.“
  + $∃v,w ∈ V: v ≠ w ∧ {v,w} ∉ E$ \
    „Es gibt zwei verschiedene Knoten, die nicht benachbart sind.“
  + $∀v ∈ V: ∃w ∈ V: v ≠ w ∧ {v,w} ∉ E$ \
    „Zu jedem Knoten gibt es einen anderen Knoten, der nicht sein Nachbar ist.“
]

== Beweise

#definition[Beweis][
  Ein *Beweis* einer Behauptung ist ein Text in natürlicher Sprache, gemischt mit Formeln. Er begründet die Behauptung lückenlos und für den (menschlichen) Leser nachvollziehbar.
  Jeder Schritt darf sich stützen auf die Voraussetzungen der Behauptung, Definitionen, bereits bewiesene Aussagen und Schlüsse, die als offensichtlich gelten dürfen.
]

#bemerkung[Formaler Beweis][
  Ein *formaler Beweis* besteht aus einer Folge von
  Formeln, die jeweils Axiome sind oder durch feste Schlussregeln aus vorherigen Formeln
  entstehen. Ob ein Text ein formaler Beweis ist, kann mechanisch überprüft werden.
  Formale Beweise sind meist erheblich länger und für Menschen weniger erhellend als Beweise in natürlicher Sprache.

  Formale Beweise haben deutlich an Wichtigkeit gewonnen, weil KI-Systeme gut darin geworden sind sie zu schreiben, zum Beispiel in der Sprache #link("https://lean-lang.org/", "Lean").

  In dieser Vorlesung diskutieren wir kein Axiomensystem und führen keine formalen Beweise.
]

#notation(kurz: [$A ⇒ B$, $A ⇔ B$])[Folgerung und Äquivalenz][
  Seien $A$ und $B$ Formeln. Wir schreiben
  $ A ⇒ B, $
  gesprochen „aus $A$ folgt $B$“, für die Behauptung: Bei _jeder Belegung der
  vorkommenden Variablen_, bei der $A$ wahr ist, ist auch $B$ wahr.

  Wir schreiben $A ⇔ B$, wenn sowohl $A ⇒ B$ als auch $B ⇒ A$ gilt und nennen $A$ und $B$ *äquivalent*. Die Gegenteile sind $arrow.r.double.not$ und $arrow.l.r.double.not$.
]

#beispiel[
  Sei $x ∈ ℕ$ eine Variable.
  - Es gilt $x > 2 ⇒ x > 1$, denn jede Zahl größer als 2 ist größer als 1.
  - Es gilt $x > 1 arrow.r.double.not x > 2$: Für $x := 2$ ist die linke Seite wahr und die
    rechte falsch.
  - Die Formel $x > 1 → x > 2$ ist dagegen nicht einfach falsch: Für $x := 1$ ist sie
    wahr, für $x := 2$ ist sie falsch.
]

#bemerkung[Weitere Unterschiede zwischen $→$ und $⇒$][
  Die Unterschiede zwischen $→$ und $⇒$ sind subtil und manche Autoren verwenden $⇒$ für beide Bedeutungen.
  - $A → B$ ist eine Formel (mit Teilformeln $A$ und $B$), während $A ⇒ B$ eine Aussage _über_ die Formeln $A$ und $B$ ist.
  - Wir verwenden die Schreibweise $A ⇒ B ⇒ C$ und auszudrücken das beide Folgerungen $A ⇒ B$ und $B ⇒ C$ gelten. Für $→$ ist der analoger Ausdruck nicht sinnvoll. Schlimmer noch: $(A → B) → C$ und $A → (B → C)$ sind nicht äquivalent.
]

== Beweistechniken

#technik[Beweisstruktur aus Formelstruktur][
  Will man eine Formel beweisen, so kann man sich oft an ihrer Struktur orientieren:

  #table(
    columns: 2,
    stroke: none,
    [zu zeigen], [Beweisstruktur],
    table.hline(),
    [$∀x ∈ M: F$], [Führe eine Variable $x ∈ M$ ein und beweise $F$, ohne weitere Annahmen über $x$ zu treffen.],
    [$A ⊆ B$],[beweise $∀x ∈ A: x ∈ B$],
    [$∃x ∈ M: F$],
    [Definiere $x$ „geschickt“, oft in Abhängigkeit anderer Variablen. Beweise dann, dass für diese Wahl von $x$ sowohl $x ∈ M$ als auch $F$ gelten.],
    [$F ∧ G$], [Beweise $F$ und beweise $G$.],
    [$F → G$], [Nimm $F$ an. Beweise dann $G$.],
    [$F ∨ G$],
    [Verwende, dass $F ∨ G$ und $¬F → G$ äquivalent sind (alternativ auch $¬G → F$). Verwende dann die Technik für die Implikation.],
    [$¬F$], [Negation „reinziehen“ oder Beweis durch Widerspruch (siehe unten).],
  )
]

#technik[Dekonstruktion von Annahmen][
  Hat man eine Formel als _Annahme_ gegeben, so gibt ihre Struktur vor, wie man sie verwenden kann.

  #table(
    columns: 2,
    stroke: none,
    [Annahme], [Verwendung],
    table.hline(),
    [$∀x ∈ M: F$], [Ist bereits ein $x ∈ M$ gegeben, so darf angenommen werden, dass für dieses $x$ auch $F$ gilt.],
    [$∃x ∈ M: F$], [Wir dürfen eine Variable $x ∈ M$ einführen und annehmen, dass $F$ für $x$ gilt.],
    [$F ∧ G$], [Wir dürfen sowohl $F$ als auch $G$ annehmen.],
    [$F → G$], [Gelingt es uns $F$ zu beweisen, so dürfen wir anschließend $G$ annehmen.],
    [$F ∨ G$],
    [Fallunterscheidung: Zeige die Behauptung einmal unter der zusätzlichen Annahme $F$ und einmal unter der zusätzlichen Annahme $G$ (siehe unten).],
  )
]

#skript[
  Im Folgenden lernen wir Argumentationsmuster kennen, die in vielen Beweisen nützlich sind. Das Finden eines Beweises bleibt dennoch eine kreative Aufgabe: Oft ist eine Idee nötig, die sich aus der Struktur der Aussage allein nicht ablesen lässt.
]

=== Einschub: Summen- und Produktzeichen

#notation("Summen- und Produktzeichen", kurz: [$sum$, $product$])[
  Ist $I$ eine Indexmenge und ist für jedes $i ∈ I$ eine Zahl $a_i$ definiert, so schreiben wir
  $
        sum_(i ∈ I) & a_i "für die Summe dieser Zahlen und" \
    product_(i ∈ I) & a_i "für das Produkt dieser Zahlen."
  $
  Ist $I = {k, k+1, …, ℓ}$, so schreiben wir alternativ $sum_(i = k)^ℓ a_i "bzw." product_(i = k)^ℓ a_i$.
]

#beispiel[
  $sum_(i∈{3,4,5}) i² = sum_(i=3)^5 i² = 9 + 16 + 25 = 50$.
]

#notation("Leere Summe, leeres Produkt")[
  Wir vereinbaren $sum_(i ∈ ∅) a_i = 0$ und $product_(i ∈ ∅) a_i = 1$. So ist sichergestellt, dass für disjunkte (möglicherweise leere) Mengen $I$ und $J$ gilt:
  $
    sum_(i ∈ I) a_i + sum_(i ∈ J) a_i = sum_(i ∈ I ∪ J) a_i quad "sowie" quad product_(i ∈ I) a_i ⋅ product_(i ∈ J) a_i = product_(i ∈ I ∪ J) a_i.
  $
]<leeresProdukt>

=== Doppeltes Abzählen

#technik[Doppeltes Abzählen][
  Wir wollen eine Gleichung $a = b$ beweisen. Wir definieren dazu eine Menge $X$ „geschickt“ und zählen ihre Elemente auf zwei Weisen. Ergibt die eine Zählung $|X| = a$ und die andere $|X| = b$, so folgt $a = b$.
]<doppeltesAbzählen>

#satz("Handschlaglemma", kurz: [$sum_(v ∈ V) deg(v) = 2 m$])[
  Sei $G = (V,E)$ ein Graph. Dann gilt
  $ sum_(v ∈ V) deg(v) = 2 ⋅ |E|. $
]<handschlaglemma>

#beweis[
  Sei $X$ die Menge der „Kantenenden“. Einerseits hat jede Kante in $E$ genau zwei Enden, also gilt $|X| = 2⋅|E|$. Andererseits ist jedes Kantenende einem Knoten zugeordnet und die Anzahl der Kantenenden, die einem Knoten $v ∈ V$ zugeordnet sind, ist genau $deg(v)$. Summation über alle Knoten ergibt daher $|X| = sum_(v ∈ V) deg(v)$. Somit ergibt sich die Behauptung nach @doppeltesAbzählen.
]

#bemerkung[Der Name „Handschlaglemma“][
  Auf einer Party schütteln sich einige der Anwesenden die Hände. Zählt man für jede Person, wie viele Hände sie geschüttelt hat, und addiert diese Zahlen, so erhält man das Doppelte der Anzahl der Handschläge. Das Handschlaglemma ist genau diese Aussage für den Graphen, dessen Knoten die Anwesenden sind und dessen Kanten die Handschläge.
]

=== Beweis durch Widerspruch und indirekter Beweis

#technik[Beweis durch Widerspruch][
  Wir wollen eine Aussage $A$ beweisen. Wir nehmen $¬A$ an und leiten einen Widerspruch her. Dann folgt $A$.
]<beweisDurchWiderspruch>

#uebung[
  Es gibt keinen Graphen mit genau 7 Knoten, in dem jeder Knoten Grad 3 hat.
]

#loesung[Beweis durch Widerspruch][
  Die zu beweisende Aussage lässt sich so formulieren:#footnote[Die Schreibweise „$∃"Graph" G = (V,E)$:“ weicht von der Form „$∃ x ∈ M$“ ab, weil es die „Menge aller Graphen“ nicht gibt. Der Quantor funktioniert aber genauso.]
  $
    ¬∃"Graph" G = (V,E): (∀v ∈ V: deg(v) = 3) ∧ |V| = 7.
  $
  Wir nehmen das Gegenteil an. Dann gibt es also einen Graphen $G = (V,E)$, für den gilt:
  $
    (∀v ∈ V: deg(v) = 3) "und" |V| = 7.
  $
  Wir wenden das Handschlaglemma (@handschlaglemma) auf $G$ an und rechnen:
  $
    2⋅|E| = sum_(v ∈ V) deg(v) = sum_(v ∈ V) 3 = |V|⋅3 = 7⋅3 = 21.
  $
  Das kann nicht stimmen, da $2⋅|E|$ gerade ist, 21 dagegen ungerade. Dieser Widerspruch zeigt, dass die Annahme falsch gewesen sein muss. Somit ergibt sich die Behauptung nach @beweisDurchWiderspruch.
]

#bemerkung[
  In der Regel ist es nicht schwierig, einen Widerspruchsbeweis so umzuschreiben, dass kein expliziter Widerspruch auftaucht.
]

#loesung[Direkter Beweis][
  Wieder ist zu zeigen (kurz „z.Z.“):
  $ "z.Z.:" ¬∃"Graph" G = (V,E): (∀v ∈ V: deg(v) = 3) ∧ |V| = 7 $
  Wir ziehen die Negation nach innen:
  $ "z.Z.:" ∀"Graph" G = (V,E): ¬((∀v ∈ V: deg(v) = 3) ∧ |V| = 7) $
  Sei also $G = (V,E)$ ein beliebiger Graph. Wir müssen für diesen Graphen zeigen:
  $ "z.Z.:" ¬((∀v ∈ V: deg(v) = 3) ∧ |V| = 7) $
  Nach der Regel von de Morgan ist das äquivalent zu
  $ "z.Z.:" ¬(∀v ∈ V: deg(v) = 3) ∨ |V| ≠ 7 $
  und nach Definition von $→$ äquivalent zu
  $ "z.Z.:" (∀v ∈ V: deg(v) = 3) → |V| ≠ 7. $
  Um eine Implikation zu zeigen, nehmen wir an, dass die linke Seite gilt, und zeigen die rechte Seite. Wir nehmen also $∀v ∈ V: deg(v) = 3$ an und es ist $|V| ≠ 7$ zu zeigen. Dann ergibt sich nach dem Handschlaglemma (@handschlaglemma):
  $ 2⋅|E| = sum_(v ∈ V) deg(v) = sum_(v ∈ V) 3 = |V|⋅3. $
  Die linke Seite ist gerade, also ist auch $|V|⋅3$ gerade. Weil 3 ungerade ist, muss $|V|$ gerade sein. Damit folgt $|V| ≠ 7$ wie behauptet.
]

#technik[Indirekter Beweis][
  Wir wollen eine Implikation $A ⇒ B$ beweisen. Wir zeigen stattdessen die *Kontraposition* $¬B ⇒ ¬A$. Dann folgt $A ⇒ B$.
]<indirekterBeweis>

#bemerkung[
  In Worten: Um zu zeigen, dass aus der Annahme $A$ die Behauptung $B$ folgt, zeigen wir stattdessen, dass in Fällen, in denen die Behauptung $B$ nicht gilt, die Annahme $A$ verletzt sein muss. Die Technik ist eng verwandt mit einem Beweis durch Widerspruch.
]

#satz[
  Sei $n ∈ ℕ$. Es gilt die Implikation „$n²$ ist gerade“ $⇒$ „$n$ ist gerade“.
]

#beweis[
  Wir zeigen die Kontraposition „$n$ ist ungerade“ $⇒$ „$n²$ ist ungerade“.

  Sei also $n$ ungerade. Dann gilt $n = 2k+1$ für ein $k ∈ ℕ$. Somit
  $ n² = (2k+1)² = 4k² + 4k + 1 = 2⋅(2k²+2k) + 1, $
  also ist $n²$ ungerade. Nach @indirekterBeweis folgt die behauptete Implikation.
]

#bemerkung[
  Hier lohnt sich die Kontraposition, weil „$n$ ist ungerade“ eine leichter zu verwendende Annahme ist als „$n²$ ist gerade“.
]

=== Fallunterscheidung

#technik[Fallunterscheidung][
  Wir wollen eine Aussage $A$ zeigen. Dazu wählen wir Aussagen $F₁,F₂,…,F_k$ für ein $k ∈ ℕ⁺$, die *Fälle*, und zeigen einzeln
  $ F₁ ⇒ A, quad F₂ ⇒ A, quad …, quad F_k ⇒ A. $
  Zudem überprüfen wir, dass die Fälle *erschöpfend* sind, dass also $F₁ ∨ F₂ ∨ … ∨ F_k$ gilt. Dann folgt $A$.
]<fallunterscheidung>

#uebung[Sei $n ∈ ℕ$. Dann endet die Dezimaldarstellung von $n²$ auf 0,1,4,5,6 oder 9.]

#loesung[
  Sei $n ∈ ℕ$ beliebig. Sei $j ∈ {0,1,…,9}$ die letzte Ziffer von $n$. Dann gilt $n = 10⋅a + j$ für ein $a ∈ ℕ$. Ferner gilt:
  $ n² = 100⋅a² + 20⋅a⋅j + j² = 10⋅(10⋅a² + 2⋅a⋅j) + j². $
  Die letzte Ziffer von $n²$ ist also die letzte Ziffer von $j²$.

  Die Fälle $j = 0$, $j = 1$, …, $j = 9$ sind erschöpfend. Wir gehen sie durch:
  #table(
    stroke: none,
    columns: 11,
    [$j$], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9],
    table.hline(),
    table.vline(x: 1),
    [letzte Ziffer von $j²$], [0], [1], [4], [9], [6], [5], [6], [9], [4], [1],
  )
  In jedem der zehn Fälle endet $j²$ (und damit $n²$) auf 0, 1, 4, 5, 6 oder 9 wie behauptet.
]

=== Schubfachprinzip

#technik[Schubfachprinzip][
  Gegeben seien eine endliche Indexmenge $I$, eine endliche Wertemenge $M$ und für jedes $i ∈ I$ ein Element $x_i ∈ M$. Wir wollen zeigen, dass eine Dopplung auftritt, also $∃i,j ∈ I: i ≠ j ∧ x_i = x_j$. Dafür genügt es zu zeigen, dass $|I| > |M|$.
]<schubfachprinzip>

#bemerkung[Zum Namen][
  Eine anschauliche Formulierung ist: Wenn man Objekte auf Schubfächer verteilt und es mehr Objekte als Schubfächer gibt, dann gibt es ein Schubfach, in dem mindestens zwei Objekte landen.

  Der englische Name ist _pigeonhole principle_; dort stellt man sich Tauben vor, die sich in die Löcher eines Taubenschlags setzen.
]

#satz[
  Sei $G = (V,E)$ ein Graph mit $|V| ≥ 2$. Dann gibt es zwei verschiedene Knoten gleichen Grades.
]

#beweis[
  Jeder Knoten hat höchstens $n-1$ Nachbarn, die möglichen Grade sind also $0,1,…,n-1$. Da es ebenso viele Knoten wie mögliche Grade gibt, genügt das Schubfachprinzip zunächst noch nicht. Eine Fallunterscheidung hilft weiter. In beiden Fällen wenden wir das Schubfachprinzip mit der Indexmenge $I = V$ und den Werten $x_v = deg(v)$ an; nur die Wertemenge $M$ ist verschieden.
  / Fall 1\: Kein Knoten von $G$ hat Grad $n-1$.: Für die Knoten aus $V$ kommen also nur Grade aus ${0,1,…,n-2}$ in Frage. Weil $n = |V| > |{0,1,…,n-2}| = n-1$ gilt, haben nach dem Schubfachprinzip zwei verschiedene Knoten den gleichen Grad.
  / Fall 2\: Mindestens ein Knoten von $G$ hat Grad $n-1$.: Ein solcher Knoten ist zu allen anderen Knoten benachbart. Jeder andere Knoten hat also mindestens Grad 1, und wegen $n ≥ 2$ hat auch der Knoten selbst Grad $n-1 ≥ 1$. Es gibt also keinen Knoten von Grad $0$, und für die Knoten aus $V$ kommen nur Grade aus ${1,…,n-1}$ in Frage. Weil $n = |V| > |{1,2,…,n-1}| = n-1$ gilt, haben nach dem Schubfachprinzip zwei verschiedene Knoten den gleichen Grad.#qedhere
]

=== Extremalprinzip

#technik[Extremalprinzip][
  Gegeben sei eine nichtleere Menge $M$. Anstatt ein beliebiges Objekt $x ∈ M$ zu betrachten, lohnt es sich zuweilen, ein extremales Objekt zu betrachten; z.B. das kleinste, größte oder längste. Ein solches Objekt hat oft nützliche Eigenschaften.#footnote[Für potentiell unendliche $M$ ist Vorsicht geboten. So hat eine Menge $M ⊆ ℕ$ nicht notwendigerweise ein größtes Element (garantiert aber ein kleinstes Element, wenn $M ≠ ∅$).]
]<extremalprinzip>

#lemma[Weg ⇒ Pfad][
  Sei $G = (V,E)$ ein Graph und seien $u,v ∈ V$, sodass es einen Weg von $u$ nach $v$ gibt. Dann gibt es auch einen Pfad von $u$ nach $v$.
]<wegPfad>

#beweis[
  Sei $M$ die Menge der Längen der Wege von $u$ nach $v$. Weil $M ≠ ∅$ gibt es nach dem Extremalprinzip eine kleinstes Element von $M$. Entsprechend gibt es einen kürzesten Weg von $u$ nach $v$. Wir zeigen, dass dieser Weg ein Pfad ist.

  Wir nehmen zum Widerspruch an, dies sei nicht der Fall. Dann gibt es einen Knoten $w ∈ V$, der mindestens zweimal auf dem Weg vorkommt, das heißt, der Weg hat die Form $u … w … w … v$. Wenn wir das Zwischenstück $w … w$ durch $w$ ersetzen, erhalten wir einen kürzeren Weg von $u$ nach $v$. Das widerspricht der Wahl des Weges. Also ist der kürzeste Weg von $u$ nach $v$ ein Pfad.
]

#lemma[Bäume haben Blätter][
  Jeder Baum mit mindestens einer Kante hat mindestens zwei Blätter.
]<blattlemma>

#beweis[
  Sei $G = (V,E)$ ein Baum mit mindestens einer Kante. Ein Pfad in $G$ hat Länge höchstens $n-1$ (jeder Knoten darf nur einmal vorkommen), also gibt es eine _größte_ Länge $ℓ$ eines Pfades in $G$ (hier verwenden wir das Extremalprinzip). Sei $v₀ v₁ … v_ℓ$ ein Pfad dieser Länge. Wegen $E ≠ ∅$ gilt $ℓ ≥ 1$ und insbesondere $v₀ ≠ v_ℓ$.

  Wir behaupten, dass $v₀$ und $v_ℓ$ Blätter sind. Wir zeigen das für $v₀$, für $v_ℓ$ folgt es analog.
  $ "z.Z.:" deg(v₀) = 1 $
  Weil $v₀$ zu $v₁$ benachbart ist, gilt $deg(v₀) ≥ 1$. Wir führen die Annahme $deg(v₀) ≥ 2$ zu einem Widerspruch (dann folgt $deg(v₀) = 1$).
  Nach Annahme gibt es also $u ∈ V$ mit $u ≠ v₁$ und ${v₀,u} ∈ E$.
  / Fall 1\: $u$ kommt im Pfad nicht vor.: Dann sind die Knoten $u v₀ v₁ … v_ℓ$ paarweise verschieden und je zwei aufeinanderfolgende benachbart. Also ist $u v₀ … v_ℓ$ ein Pfad der Länge $ℓ+1$. Das widerspricht der Wahl von $v₀ … v_ℓ$ als längstem Pfad.
  / Fall 2\: $u$ kommt im Pfad vor.: Wegen $u ∉ {v₀,v₁}$ gilt $u = v_j$ für ein $j ≥ 2$. Die Folge $v₀ v₁ … v_j v₀$ hat dann mindestens vier Folgeglieder und ist ein Kreis. Das widerspricht der Annahme, dass $G$ ein Baum (und damit azyklisch) ist.

  Beide Fälle sind unmöglich, also gilt $deg(v₀) = 1$.
]

=== Vollständige Induktion

#skript[
  Wir betrachten nun Aussagen, die für alle (oder fast alle) natürlichen Zahlen gelten sollen. Dafür gibt es eine eigene Beweistechnik.
]

#technik[Vollständige Induktion][
  Für jedes $n ∈ ℕ$ sei $A(n)$ eine Aussage und sei $n₀ ∈ ℕ$ ein *Startwert*. Wir wollen zeigen, dass $A(n)$ für alle $n ≥ n₀$ gilt. Dazu zeigen wir zwei Dinge:

  / Induktionsanfang: $A(n₀)$ gilt.
  / Induktionsschritt: Für jedes $n ≥ n₀$ gilt $A(n) ⇒ A(n+1)$.

  Dann folgt $A(n)$ für alle $n ≥ n₀$. Die im Induktionsschritt verwendete Annahme $A(n)$ heißt *Induktionsvoraussetzung*.
]<induktion>

// bilder/Dominoes_falling.jpg
//   „Dominoes falling.jpg“ von Kurt:S, 12.10.2015, Original 6016×4000
//   https://commons.wikimedia.org/wiki/File:Dominoes_falling.jpg
//   ursprünglich https://www.flickr.com/photos/testlab/21496317363/
//   Lizenz: CC BY 2.0 (Namensnennung nötig, kein Share-alike)
//   Bearbeitet: auf 1920 px Breite verkleinert

#let credits(content) = text(size: 0.8em, fill: gray, content)

#abbildung(slides: 0, caption: [
  Die Anschauung zur vollständigen Induktion: Der erste Stein fällt nach Induktionsanfang. Der Induktionsschritt garantiert, dass mit jedem fallenden Stein der folgende Stein ebenfalls fällt.\
  #credits[Foto: Kurt:S, #link("https://commons.wikimedia.org/wiki/File:Dominoes_falling.jpg")[Wikimedia Commons], CC BY 2.0.]
])[#image("bilder/Dominoes_falling.jpg", width: 50%)]<domino>

#bemerkung[Beweisschema][
  Induktionsbeweise schreibt man nach einem mehr oder minder festen Muster auf. Man benennt die Komponenten _Induktionsanfang_ (IA), _Induktionsvorraussetzung_ (IV) und _Induktionsschritt_ (IS) explizit als solche.
]

#satz(kurz: [$sum_(i=1)^n (2i-1) = n²$])[
  Für jedes $n ∈ ℕ⁺$ ist die Summe der ersten $n$ ungeraden Zahlen gleich $n²$. Als Formel:
  $ ∀n ∈ ℕ⁺: sum_(i=1)^n (2i-1) = 1 + 3 + 5 + … + (2n-1) = n². $
]<ungeradeSumme>

#abbildung(slides: 0, caption: [
  Die ersten $n$ ungeraden Zahlen setzen sich zu einem $n × n$-Quadrat zusammen: Der $k$-te Winkel besteht aus $2k-1$ Feldern.
])[#quadratbild()]

#beweis[
  Induktion über $n$ mit Startwert $n₀ = 1$.

  / IA: Für $n = 1$ gilt $sum_(i=1)^1 (2i-1) = 1 = 1²$. ✓
  / IV: Für ein $n ≥ 1$ gelte $sum_(i=1)^(n) (2i-1) = n²$
  / IS: Zu zeigen ist $sum_(i=1)^(n+1) (2i-1) = (n+1)²$. Tatsächlich gilt:
  $
    sum_(i=1)^(n+1) (2i-1) & = sum_(i=1)^n (2i-1) + (2(n+1)-1) \
                           & =^"(IV)" n² + 2n + 1 = (n+1)². qedhere
  $
]

#bemerkung[
  Manchmal ist es bequemer im Induktionsschritt $A(n)$ aus $A(n-1)$ herzuleiten (für alle $n > n₀$), anstatt $A(n+1)$ aus $A(n)$ herzuleiten (für alle $n ≥ n₀$). Da der gewählte Startwert aus dem Induktionsanfang hervorgeht muss man ihn nicht explizit erwähnen.
]

#uebung[Gaußsche Summenformel][
  Zeigen Sie durch vollständige Induktion: Für jedes $n ∈ ℕ⁺$ gilt $sum_(i=1)^n i = (n ⋅ (n+1))/2$.
]<gaussformel>

#loesung[
  Induktion über $n$ mit Schritten der Form "$n-1 ⇝ n$".

  / IA: Für $n = 1$ ist $sum_(i=1)^1 i = 1 = (1 ⋅ 2)/2$. ✓
  / IV: Für ein $n > 1$ gelte $sum_(i=1)^(n-1) i = ((n-1) ⋅ n)/2$.
  / IS: Zu zeigen ist $sum_(i=1)^n i = (n ⋅ (n+1))/2$. Tatsächlich gilt:
  $ sum_(i=1)^n i &= sum_(i=1)^(n-1) i + n   && #weil[letzten Summanden abspalten] \
                  &= ((n-1) ⋅ n)/2 + n       && #weil[Induktionsvoraussetzung] \
                  &= (n² - n + 2n)/2         && #weil[auf einen Bruch bringen] \
                  &= (n ⋅ (n+1))/2.          && $
]

#bemerkung[
  In @ungeradeSumme und @gaussformel könnte man die Induktion auch bei $0$ beginnen lassen. Dabei kommt @leeresProdukt zur Anwendung.
]

#bemerkung[Bezug zum Extremalprinzip][
  Vollständige Induktion lässt sich auf das Extremalprinzip (@extremalprinzip) zurückführen. #footnote[Umgekehrt lässt sich aus der Induktion auch eine Form des Extremalprinzips herleiten, nämlich dass jede nichtleere Teilmenge von $ℕ$ ein kleinstes Element hat.]

  Um im Dominobeispiel aus @domino zu zeigen, dass alle Steine fallen, würde man mit dem Extremalprinzip folgermaßen argumentieren. Wir führen die Annahme, dass nicht alle Steine fallen zu einem Widerspruch. In dem Fall gibt es eine kleinste Zahl $n ∈ ℕ$ sodass der $n$te Stein nicht fällt. Dieser Stein ist aber entweder der erste Stein (und wird direkt angestoßen) oder der vorherige Stein fällt (nach Wahl von $n$). In beiden Fällen erhält man einen Widerspruch, also Fallen alle Steine.
]

#skript[
  Wir wollen noch ein Beispiel für eine Induktionsbeweis auf Graphen zeigen. Eine kleine Vorbereitung ist nötig.
]

#lemma(kurz: [Baum ohne Blatt ist Baum])[
  Sei $G = (V,E)$ ein Baum mit einem Blatt $v ∈ V$ dessen Nachbar $u ∈ V$ ist. Dann ist
  $ G - v := (V ∖ {v}, E ∖ {{u,v}}) $
  ebenfalls ein Baum.
]<blattEntfernen>

#beweis[
  Dass $G-v$ ein Graph ist, ist ziemlich klar.#footnote[Zu prüfen ist, dass $V ∖ {v}$ nicht leer ist und dass jedes Element aus $E ∖ {{u,v}}$ ganz in $V ∖ {v}$ liegt. Beides folgt, weil $v$ ein Blatt von $G$ ist, also Grad 1 hat.]
  Zu prüfen ist, dass $G-v$ zusammenhängend und azyklisch ist.
  / azyklisch: _Intuitiv_: $G$ hat keinen Kreis und durch das _Löschen_ von Knoten und Kanten kann kein Kreis entstehen. _Formaler_: Angenommen $G - v$ hätte einen Kreis. Dieser Kreis wäre auch ein Kreis in $G$ — Widerspruch.
  / zusammenhängend: Seien $x,y ∈ V ∖ {v}$. Wir müssen zeigen, dass es einen Pfad von $x$ nach $y$ in $G - {v}$ gibt. Weil $G$ zusammenhängend ist, gibt es in $G$ einen Pfad von $x$ nach $y$. Dieser Pfad enthält $v$ nicht: Käme $v$ darin vor, so wäre $v$ wegen $x ≠ v$ und $y ≠ v$ ein innerer Knoten des Pfades und hätte damit zwei verschiedene Nachbarn auf dem Pfad, im Widerspruch zu $deg(v) = 1$. Der Pfad liegt also ganz in $G - v$. #qedhere
]
#satz(kurz: [Bäume haben $n-1$ Kanten])[
  Jeder Baum mit $n$ Knoten hat genau $n-1$ Kanten.
]<baumKanten>

#beweis[
  Induktion über die Knotenzahl $n$ mit Schritten der Form "$n-1 ⇝ n$".

  / IA: Kanten sind nur in Graphen mit mindestens zwei Knoten möglich. Also hat ein Baum mit $n = 1$ Knoten genau $n-1 = 0$ Kanten. ✓
  / IV: Für ein $n ≥ 2$ gelte: Jeder Baum mit $n-1$ Knoten hat $n-2$ Kanten.
  / IS: Wir betrachten einen beliebigen Baum $G$ mit $n$ Knoten. Zu zeigen ist, dass er $n-1$ Kanten hat. Weil $G$ zusammenhängend ist und mindestens zwei Knoten hat, hat $G$ mindestens eine Kante. Nach @blattlemma gibt es also ein Blatt $v$. Nach @blattEntfernen ist $G - v$ ein Baum mit $n-1$ Knoten. Nach Induktionsvoraussetzung hat $G-v$ genau $n-2$ Kanten. Der Baum $G$ hat genau eine Kante mehr, nämlich die an $v$, und damit $n-1$ Kanten.#qedhere
]

#technik[Starke Induktion][
  Manchmal ist es nützlich im Induktionsschritt nicht nur einen Schritt zurück zu blicken ("$n-1 ⇝ n$") sondern auf _alle_ vorherigen Schritte ("$(0 ∧ … ∧ n-1) → n$"). Der Beweis hat dann die Form:
  / IA: Zeige, dass $A(n₀)$ gilt.
  / IV: Für ein $n > n₀$ gelte $A(m)$ für _alle_ $m ∈ {n₀,…,n-1}$.
  / IS: Zeige, dass $A(n)$ gilt.
  Diese Form nennt man manchmal *starke Induktion*.
]

#satz[Primfaktorzerlegung][
  Jedes $n ∈ ℕ⁺$ ist ein Produkt von Primzahlen.#footnote[Eine *Primzahl* ist eine natürliche Zahl $p ≥ 2$, deren einzige Teiler $1$ und $p$ sind.]
]

#beweis[
  Starke Induktion über $n$ mit Startwert $n₀ = 1$.
  / IA: $n = 1$ ist das _leere Produkt_, siehe @leeresProdukt. ✓
  / IV: Für ein $n > 1$ gelte, dass jedes $m ∈ {1,…,n-1}$ ein Produkt von Primzahlen ist.
  / IS: Zu zeigen ist, dass $n$ ein Produkt von Primzahlen ist.
    / Fall 1\: $n$ ist eine Primzahl.: $n$ ist das Produkt bestehend aus einem primen Faktor (nämlich $n$).
    / Fall 2\: $n$ ist keine Primzahl.: Dann hat $n$ einen Teiler $a ∈ {2,…,n-1}$. Für $b := n/b$ gilt dann ebenfalls $b in {2,…,n-1}$. Also ist $n = a ⋅ b$ das Produkt zweier kleinerer Zahlen. Nach Induktionsvoraussetzung sind $a$ und $b$ Produkte von Primzahlen, also ist es auch $n = a ⋅ b$.#qedhere
]

#uebung[
  Finden Sie den Fehler in folgendem Induktions"beweis" von $∀n ∈ ℕ: n = n+1$.
  / IV: Für ein $n ≥ 1$ gelte $n = n+1$
  / IS: Zu zeigen ist $n+1 = n+2$. Tatsächlich gilt:
  $ n+1 =^"IV" (n+1)+1 = n+2. $
]
#loesung[
  Der Induktionsanfang fehlt.
]

#bemerkung[Induktion in der Philosophie][
  In der Philosophie und Wissenschaftstheorie ist ein _induktiver Schluss_ ein (problematischer) Schluss von endlich vielen Beobachtungen auf eine allgemeine Regel, etwa
  $
           & "alle Raben, die ich gesehen habe, waren schwarz" \
    ⇒^"?!" & "alle Raben sind schwarz"
  $
  Ein Gegenbegriff ist der (respektable) _deduktive Schluss_.
  Mathematische Induktion ist nicht in einem vergleichbaren Sinne defizitär. Das meint man, wenn man von _vollständiger_ Induktion spricht.
]

=== Strukturelle Induktion

#technik[Strukturelle Induktion][
  Sei $M$ eine Menge, die durch Regeln rekursiv definiert ist: Einige Regeln
  erzeugen Elemente ohne Rückgriff auf andere, die übrigen bauen aus bereits
  vorhandenen Elementen neue. Wir wollen zeigen, dass eine Aussage $A(x)$ für
  alle $x ∈ M$ gilt. Dazu zeigen wir für jede Regel einzeln: Erzeugt die Regel
  aus $x₁,…,x_r ∈ M$ das Element $x$, so folgt $A(x)$ aus $A(x₁),…,A(x_r)$.
  Für Regeln ohne Rückgriff ist das der Induktionsanfang.
]

#definition("Wohlgeformte Klammerausdrücke")[
  Die Menge $K$ der *wohlgeformten Klammerausdrücke* ist rekursiv definiert:
  + Das leere Wort ist in $K$.
  + Sind $u, v ∈ K$, so ist auch $u v ∈ K$ (Hintereinanderschreiben).
  + Ist $u ∈ K$, so ist auch $(u) ∈ K$.
  Implizit: Nichts anderes ist ein wohlgeformter Klammerausdruck.
]

#beispiel[
  $(())()$ ist wohlgeformt, $())($ ist es nicht.
]

#satz[
  Sei $k ∈ K$. Die Anzahl der öffnenden Klammern in $k$ ist gleich der Anzahl der schließenden Klammern in $k$.
]


#beweis[
  Strukturelle Induktion über den Aufbau von $k$.
  / IA (Regel 1): Ist $k$ das leere Wort, so enthält es $0$ öffnende und $0$ schließende Klammern.
  / IS (Regel 2): Wir betrachten $k = u v$ für $u,v ∈ K$. Wir dürfen annehmen, dass $u$ gleich viele öffnende wie schließende Klammern enthält; diese Zahl sei $x_u$. Ebenso dürfen wir annehmen, dass $v$ gleich viele öffnende wie schließende Klammern enthält; diese Zahl sei $x_v$. Die Anzahlen öffnender und schließender Klammern in $k$ sind damit beide $x_u + x_v$ und damit gleich.
  / IS (Regel 3): Wir betrachten $k = (u)$ für $u ∈ K$. Wir dürfen annehmen, dass $u$ gleich viele öffnende wie schließende Klammern enthält; diese Zahl sei $x_u$. Dann enthält $k$ genau $x_u + 1$ öffnende und $x_u + 1$ schließende Klammern, also gleich viele. #qedhere
]

=== Ringschluss

#technik[Ringschluss][
  Wir wollen zeigen, dass Aussagen $A₁, A₂, …, A_k$ zueinander *äquivalent* sind. Wir zeigen dazu den „Ring“
  $ A₁ ⇒ A₂ ⇒ … ⇒ A_k ⇒ A₁. $
  Jede andere Implikation ergibt sich, indem man dem Ring folgt.
]<ringschluss>

#skript[
  Bevor wir einen Ringschluss demonstrieren, beweisen wir zwei Hilfsaussagen. Für einen Graphen $G = (V,E)$ und eine Kante $e = {u,v}$ mit $u, v ∈ V$, $u ≠ v$ schreiben wir
  $ G - e := (V,E ∖ {e}) "und" G + e := (V,E ∪ {e}) $
  für die Graphen, die durch Löschen bzw. Hinzufügen dieser Kante entstehen.
]

#lemma[
  #set enum(numbering: "(1)")
  Sei $G = (V,E)$ ein Graph und sei $e = {u,w} ∈ E$. Dann sind äquivalent:
  + Die Kante $e$ liegt auf einem Kreis von $G$.
  + In $G - e$ gibt es einen Pfad von $u$ nach $w$.
]<kreiskriterium>

#beweis[
  / $(1) ⇒ (2)$.: Den Kreis, auf dem $e$ liegt, können wir so zyklisch verschieben und gegebenenfalls umkehren, dass die Kante $e$ als Letztes von $w$ nach $u$ durchlaufen wird. Also gibt es in $G$ einen Kreis der Form $u v₁ … v_k w u$. Durch Weglassen des letzten Folgenglieds ergibt sich der Pfad $u v₁ … v_k w$. Dieser Pfad verwendet $e$ nicht, liegt also in $G - e$.
  // alt: Sei $v₁,v₂,…,v_k$ ein Kreis, auf dem $e$ liegt. Durch zyklisches Verschieben dürfen wir $u = v₁$ und $w = v₂$ annehmen. Dann ist $v₂,v₃,…,v_k$ eine Folge benachbarter Knoten von $w$ nach $u = v_k$, in der kein Knoten doppelt vorkommt, also ein Pfad. Er benutzt die Kante $e$ nicht: Seine Kanten sind ${v_i,v_(i+1)}$ für $i ∈ {2,…,k-1}$, und wegen $k ≥ 4$ ist $v_(k-1) ≠ v₂$. Rückwärts gelesen ist das ein Pfad von $u$ nach $w$ in $G - e$.
  / $(2) ⇒ (1)$.: Sei $u v₁ … v_k w$ ein Pfad von $u$ nach $w$ in $G-e$.
    Durch Anhängen eines Schritts von $w$ nach $u$ ergibt sich ein Kreis $u v₁ … v_k w u$ in $G$.#footnote[Dass hierbei nicht der Weg $u w u$ herauskommt (der nicht als Kreis zählt), liegt daran, dass $u w$ in $G-e$ kein Pfad ist (die Kante $e$ fehlt dort ja gerade). Damit gilt $k ≥ 1$, es gibt also mindestens einen Zwischenknoten.]#qedhere
]

#lemma[
  Sei $G = (V,E)$ zusammenhängend. Liegt die Kante $e ∈ E$ auf einem Kreis, so ist auch $G - e$ zusammenhängend.
]<kreiskante>

#beweis[
  Sei $e = {u,w}$. Nach @kreiskriterium gibt es in $G - e$ einen Pfad von $u$ nach $w$; wir nennen ihn den _Umweg_.\
  Seien nun $x,y ∈ V$ beliebig. Weil $G$ zusammenhängend ist, gibt es einen Pfad von $x$ nach $y$ in $G$. Ersetzen wir darin die Kante $e$, falls sie vorkommt, durch den Umweg, so erhalten wir einen Weg von $x$ nach $y$ in $G - e$. Nach @wegPfad gibt es dann auch einen Pfad von $x$ nach $y$ in $G - e$.
]

#satz[Charakterisierung von Bäumen][
  #set enum(numbering: "(1)")
  Sei $G = (V,E)$ ein Graph. Dann sind die folgenden vier Aussagen äquivalent.
  + $G$ ist ein Baum.
  + Zwischen je zwei Knoten von $G$ gibt es _genau_ einen Pfad.
  + $G$ ist *minimal zusammenhängend*: $G$ ist zusammenhängend, aber für jede Kante $e ∈ E$ ist $G - e$ nicht zusammenhängend.
  + $G$ ist *maximal azyklisch*: $G$ ist azyklisch, aber für je zwei nicht benachbarte Knoten $u,w$ enthält $G + {u,w}$ einen Kreis.
]<baumkennzeichnung>

#beweis[
  Wir zeigen folgende Implikationen:
  $ (1) ⇒ (2) quad (2) ⇒ (3) quad (3) ⇒ (1) quad (2) ⇒ (4) quad (4) ⇒ (1). $
  Dabei ergeben sich gleich zwei Ringe, nämlich
  $ (1) ⇒ (2) ⇒ (3) ⇒ (1) quad "und" quad (1) ⇒ (2) ⇒ (4) ⇒ (1). $
  Der erste Ring zeigt, dass (1), (2) und (3) äquivalent sind, der zweite, dass (1), (2) und (4) äquivalent sind. Damit sind alle vier Aussagen äquivalent.

  / $(1) ⇒ (2)$.: Weil $G$ ein Baum ist, ist $G$ zusammenhängend, also gibt es zwischen je zwei Knoten _mindestens_ einen Pfad.
    Angenommen, zwischen $x$ und $y$ gäbe es zwei verschiedene Pfade $P$ und $Q$. Dann gibt es eine Kante $e = {u,w}$, die nur auf einem der Pfade liegt. Wir dürfen _ohne Beschränkung der Allgemeinheit_ (o.B.d.A.)#footnote[Siehe folgende Bemerkung.] annehmen, dass sie auf $P$ liegt und in Richtung $u w$ durchlaufen wird.
    In $G - e$ gibt es dann einen Weg von $u$ nach $w$: erst auf $P$ rückwärts bis $x$, dann auf $Q$ bis $y$, dann auf $P$ rückwärts bis $w$. Keines der drei Stücke benutzt $e$. Nach @wegPfad gibt es in $G - e$ also auch einen Pfad von $u$ nach $w$, und nach @kreiskriterium liegt $e$ damit auf einem Kreis von $G$ — im Widerspruch zur Azyklizität.

  / $(2) ⇒ (3)$.: Weil es zwischen je zwei Knoten einen Pfad gibt, ist $G$ zusammenhängend. Sei $e = {u,w} ∈ E$ beliebig. Wir müssen zeigen, dass $G-e$ nicht zusammenhängend ist. Gäbe es in $G - e$ einen Pfad von $u$ nach $w$, so wären dieser und die Folge $u w$ zwei verschiedene Pfade von $u$ nach $w$ in $G$, im Widerspruch zu (2). Also ist $G - e$ nicht zusammenhängend.

  / $(3) ⇒ (1)$.: Zusammenhängend ist $G$ nach Voraussetzung. Angenommen $G$ enthält einen Kreis. Sei $e$ eine Kante auf dem Kreis. Dann ist $G-e$ nach @kreiskante zusammenhängend, im Widerspruch zur Minimalität. Also ist $G$ azyklisch und damit ein Baum.

  / $(2) ⇒ (4)$.: _Azyklisch:_ Läge eine Kante ${u,w}$ auf einem Kreis, so gäbe es nach @kreiskriterium in $G - {u,w}$ einen Pfad von $u$ nach $w$; dieser und die Folge $u w$ wären zwei verschiedene Pfade, im Widerspruch zu (2).\
    _Maximal:_ Seien $u,w$ nicht benachbart. Nach (2) gibt es in $G$ einen Pfad von $u$ nach $w$, und dieser ist auch ein Pfad in $(G + {u,w}) - {u,w}$. Nach @kreiskriterium liegt ${u,w}$ also auf einem Kreis von $G + {u,w}$.

  / $(4) ⇒ (1)$.: Azyklisch ist $G$ nach Voraussetzung. Für den Zusammenhang seien $u,w$ Knoten. Sind sie gleich oder benachbart, so gibt es einen Pfad von $u$ nach $w$. Andernfalls enthält $G + {u,w}$ einen Kreis, weil $G$ maximal azyklisch ist. Dieser benutzt die Kante ${u,w}$, denn sonst wäre er schon ein Kreis in $G$. Nach @kreiskriterium gibt es also in $G$ einen Pfad von $u$ nach $w$.#qedhere
]

#bemerkung[„o.B.d.A.“][
  Die Floskel „ohne Beschränkung der Allgemeinheit“ bedeutet, dass wir eine Annahme treffen, die die allgemeine Gültigkeit des Beweises nicht beeinträchtigt. Im vorliegenden Fall wollen wir, dass $P$ den Pfad bezeichnet, auf dem $e$ vorkommt. Wäre $Q$ dieser Pfad, könnten wir den Beweis dennoch durchführen, bloß mit vertauschten Rollen von $P$ und $Q$. Wichtig ist hier, dass $P$ und $Q$ zuvor noch austauschbar waren. Analog waren $u$ und $w$ zunächst austauschbar, und wir haben uns erst anschließend dazu entschieden, die Bezeichnung $u$ für denjenigen Knoten zu verwenden, der zuerst auf $P$ liegt.
]

#bemerkung[Zwölf zum Preis von fünf][
  Die vierfache Äquivalenz in @baumkennzeichnung ergibt $4 ⋅ 3 = 12$ Implikationen. Explizit beweisen mussten wir nur fünf davon. Ein einziger Ring über alle vier Aussagen hätte noch eine Implikation gespart (dafür wäre eine der Implikationen komplizierter gewesen).
]

#korollar[
  Sei $G$ ein Graph mit $n$ Knoten und $m$ Kanten.
  + Ist $G$ zusammenhängend, so gilt $m ≥ n-1$.
  + Ist $G$ azyklisch, so gilt $m ≤ n-1$.
]<kantenschranken>

#beweis[
  *Zu (1).* Wir entfernen Kanten, solange der Graph zusammenhängend bleibt. Weil die Kantenzahl in jedem Schritt sinkt, endet das Verfahren. Am Ende bleibt ein _minimal_ zusammenhängender Graph. Nach @baumkennzeichnung ist er ein Baum und hat nach @baumKanten genau $n-1$ Kanten. Da nur Kanten entfernt wurden, gilt $m ≥ n-1$.

  *Zu (2).* Wir fügen Kanten hinzu, solange das möglich ist, ohne einen Kreis zu erzeugen. Weil die Kantenzahl in jedem Schritt wächst und die Anzahl möglicher Kanten beschränkt ist, endet das Verfahren. Am Ende steht ein _maximal_ azyklischer Graph. Nach @baumkennzeichnung ist er ein Baum und hat nach @baumKanten genau $n-1$ Kanten. Da nur Kanten hinzugefügt wurden, gilt $m ≤ n-1$.
]

#bemerkung[
  Eine andere Sicht auf die Tatsache, dass Bäume exakt $n-1$ Kanten haben (@baumKanten), ist also diese:
  - Jeder Graph mit _weniger_ Kanten ist nicht zusammenhängend.
  - Jeder Graph mit _mehr_ Kanten ist nicht azyklisch.
]

#slidebreak()
= Relationen und Funktionen

== Aus Mengen größere Mengen bauen

#skript[
  Es folgen weitere grundlegende Definitionen und Schreibweisen.
]

=== Potenzmenge

#definition("Potenzmenge", kurz: $2^A$)[
  Sei $A$ eine Menge. Die *Potenzmenge* $2^A$ von $A$ ist die Menge aller Teilmengen von $A$:#footnote[Manche Autoren schreiben stattdessen $cal(P)(A)$.]
  $ 2^A := {Y | Y ⊆ A}. $
]

#beispiel(kurz: $2^({1,2,3})$)[
  Die Potenzmenge von ${1,2,3}$ ist
  $ 2^({1,2,3}) = {∅, {1}, {2}, {3}, {1,2}, {1,3}, {2,3}, {1,2,3}}. $
  Man beachte, dass $∅$ und ${1,2,3}$ dazugehören. Es gilt $|2^({1,2,3})| = 8 = 2³$, was die Schreibweise motiviert (wir werden später nochmal darauf zurückkommen).
]

=== Kartesische Produkte

#definition("Paar, kartesisches Produkt", kurz: $A × B$)[
  Für zwei Objekte $a$ und $b$ ist $(a,b)$ das (geordnete) *Paar* mit *erster Komponente* $a$ und *zweiter Komponente* $b$. Für $a ≠ b$ sind die Paare $(a,b)$ und $(b,a)$ verschieden. Für Mengen $A$ und $B$ heißt
  $ A × B := {(a,b) | a ∈ A, b ∈ B} $
  das *kartesische Produkt* von $A$ und $B$.
]

#beispiel[Spielkarten][
  Ein Skatblatt entspricht dem kartesischen Produkt
  $ {♥, ♦, ♠, ♣} × {7, 8, 9, 10, "B", "D", "K", "A"} $
  aus vier Farben und acht Werten. Die Herz-Dame ist das Paar $(♥, "D")$. Das Blatt hat $4 ⋅ 8 = 32$ Karten.
]

#satz[
  Für endliche Mengen $A$ und $B$ gilt $|A × B| = |A| ⋅ |B|$.
]<produktgroesse>

#begründung[
  Für jede der $|A|$ Möglichkeiten für die erste Komponente gibt es $|B|$ Möglichkeiten für die zweite, und verschiedene Wahlen liefern verschiedene Paare.#footnote[Um die Aussage zu „beweisen“, müsste man die Konzepte von Multiplikation und Kardinalität genauer fassen, als wir es bislang getan haben. Siehe @sec:cardinality.]
]

#definition("Tupel", kurz: $A_1 × … × A_n$, $A^n$)[
  Für $n$ Objekte $a₁,…,a_n$ nennen wir die Folge $(a₁,…,a_n)$ ein *$n$-Tupel*. Wir schreiben
  $ A_1 × … × A_n := {(a_1,…,a_n) | a_1 ∈ A_1, …, a_n ∈ A_n} $
  für das *kartesische Produkt* von $A₁,…,A_n$.
  Gilt $A_1 = … = A_n = A$, so schreiben wir kurz $A^n$.

  Für $n = 0$ gibt es genau ein Tupel, nämlich das leere Tupel $()$. Es gilt also $A^0 = {()}$. Insbesondere gilt $|A^0| = 1$.
]

#bemerkung[
  Die Begriffe _Tupel_ und _Folge_ sind oft austauschbar, aber nicht immer. Spricht man von Tupeln, so betont man die endliche Länge $n$. Folgen können auch unendlich sein.
]

#bemerkung[
  Die drei Mengen $(A × B) × C$, $A × B × C$ und $A × (B × C)$ sind streng genommen verschieden. Ihre Elemente haben die Formen
  $ ((a,b),c), quad (a,b,c) quad "und" quad (a,(b,c)). $
  Die Unterscheidung ist meist nebensächlich und wird selten sauber getroffen.
]

=== Einschub: Gerichtete Graphen

#definition("Gerichteter Graph", kurz: $E ⊆ V × V$)[
  Ein *gerichteter Graph* ist ein Paar $G = (V,E)$ aus einer endlichen, nichtleeren Menge $V$ von Knoten und einer Menge $E ⊆ V × V$ von *gerichteten Kanten*. Für $(u,v) ∈ E$ sagen wir, die Kante führt *von* $u$ *nach* $v$.
]

#bemerkung[Schlingen][
  Eine gerichtete Kante der Form $(u,u)$ heißt *Schlinge*. Manche Autoren verbieten solche Kanten. Bei ungerichteten Graphen sind sie nach unserer Definition ausgeschlossen, weil Kanten dort zweielementige Mengen sind.
]

#definition("Gerichtete Wege, Pfade, Zyklen, Kreise")[
  Sei $G = (V,E)$ ein gerichteter Graph. Eine Folge $v₀ … v_ℓ$ von Knoten heißt *gerichteter Weg* / *Pfad* / *Zyklus* / *Kreis* unter denselben Bedingungen wie in @wegpfadkreis, mit zwei Änderungen:
  - Statt ${v_i, v_(i+1)} ∈ E$ wird $(v_i, v_(i+1)) ∈ E$ gefordert. Jede Kante muss also in ihrer Richtung durchlaufen werden.
  - Beim Kreis genügt $ℓ ≥ 1$, d.h. Kreise der Form $u v u$ und $u u$ sind erlaubt, wenn die entsprechenden Kanten $(u,v)$ und $(v,u)$ bzw. die Schlinge $(u,u)$ existieren.
]<gerichteteWege>

#let dKnoten = ("1": (0, 1), "2": (1.5, 1), "3": (0.75, 0), "4": (-1.4, 0.35))
#let dKanten = (("1", "2"), ("2", "2"), ("2", "3"), ("3", "1"), ("1", "4"), ("4", "1"))

#beispiel[
  Der gerichtete Graph $G = (V,E)$ mit
  $ V = {1,2,3,4} quad "und" quad E = {(1,2), (2,2), (2,3), (3,1), (1,4), (4,1)} $
  ist in @bspdigraph dargestellt. In ihm sind unter anderem enthalten:
  - der Pfad $1 2 3$ der Länge 2,
  - der Kreis $1 2 3 1$ der Länge 3,
  - der Kreis $1 4 1$ der Länge 2,
  - der Kreis $2 2$ der Länge 1,
  - der Zyklus $1 2 2 3 1 4 1$ der Länge 6.
  Dagegen ist $4 1 3$ _kein_ Weg. Es gilt zwar $(3,1) ∈ E$, aber $(1,3) ∉ E$.
]

#abbildung(slides: 0, caption: [
  Ein gerichteter Graph. Zwischen $1$ und $4$ verlaufen zwei Kanten in entgegengesetzter Richtung, und $(2,2)$ ist eine Schlinge.
])[#graphbild(dKnoten, dKanten, gerichtet: true, radius: 0.22)]<bspdigraph>

=== Vereinigung und Schnitt über eine Indexmenge

#notation("Indizierte Vereinigung und Schnitt", kurz: [$union.big_(i ∈ I) A_i$, $inter.big_(i ∈ I) A_i$])[
  Sei $I$ eine Menge und sei für jedes $i ∈ I$ eine Menge $A_i$ gegeben. Dann schreiben wir
  $ union.big_(i ∈ I) A_i := {x | ∃i ∈ I: x ∈ A_i} $
  für die Vereinigung aller dieser Mengen und
  $ inter.big_(i ∈ I) A_i := {x | ∀i ∈ I: x ∈ A_i} $
  für den Schnitt dieser Mengen.
  Die Menge $I$ heißt *Indexmenge*. Sie darf unendlich sein. Bei der Vereinigung ist auch $I = ∅$ erlaubt (das Ergebnis ist dann $∅$), beim Schnitt nicht#footnote[Jedes $x$ würde die Bedingung der Definition erfüllen. Eine „Menge aller Objekte“ gibt es aber nicht, siehe auch @mengeAllerMengen.].
]

#uebung[
  Interpretieren Sie die folgenden Mengendefinitionen.
  + $A^* := union.big_(n ∈ ℕ) A^n$ für $A = {"a","b","c",…,"z"}$
  + $V^+ := union.big_(n ∈ ℕ⁺) V^n$ für eine Menge $V$
  + $W := {(v₀, … ,v_ℓ) ∈ V^+ | ∀i ∈ {0,…,ℓ-1}: (v_i,v_(i+1)) ∈ E}$ für einen gerichteten Graphen $G = (V,E)$.
]

#loesung[
  + $A^*$ enthält alle Folgen lateinischer Buchstaben beliebiger (endlicher) Länge, zum Beispiel $("a","b","b","a")$, $("w","u","r","s","t")$ und die leere Folge $()$. Die unendliche Folge $("a","a",…)$ ist _nicht_ in $A^*$, denn sie kommt in keiner der Mengen $A⁰$, $A¹$, … vor.
    Man nennt $A^*$ auch die Menge der *Wörter* über dem *Alphabet* $A$ und lässt dann Klammern und Kommas weg, z.B. $"abba" ∈ A^*$.
  + $V^+$ ist die Menge _nicht-leerer_ Folgen mit Komponenten aus $V$.
  + $W$ enthält nicht-leere Folgen von Knoten von $G$. Die Zusatzbedingung drückt aus, dass für je zwei aufeinanderfolgende Knoten die entsprechende Kante in $G$ existiert. Damit ist $W$ die Menge der gerichteten Wege in $G$. Wir lassen die Klammern und Kommas normalerweise weg.
]

#bemerkung[Disjunkte Vereinigung][
  Mengen können Elemente nicht doppelt enthalten. Manchmal will man aber, dass die Vereinigung $A ∪ B$ zwei Kopien eines Elements $x$ enthält, falls $x ∈ A$ und $x ∈ B$ gilt. Man kann sich dann mit der Definition
  $ A union.dot B := (A × {1}) ∪ (B × {2}) $
  behelfen. Ignoriert man für die Paare in $A union.dot B$ die zweite Komponente, so entsteht der gewünschte Effekt.
]<disjunkteVereinigung>

== Relationen Allgemein

#skript[
  Eine Relation hält fest, welche Objekte zueinander in einer bestimmten Beziehung stehen. Funktionen wie „$f(x) = x²$“ und Ordnungsrelationen wie „$≤$“ werden Spezialfälle sein.
]

#definition("Relation", kurz: $R ⊆ A_1 × … × A_k$)[
  Sei $k ∈ ℕ⁺$. Eine *$k$-stellige Relation* ist gegeben durch Mengen $A_1, …, A_k$ sowie eine Teilmenge
  $ R ⊆ A_1 × … × A_k. $
  Im Fall $k = 2$ sprechen wir von einer *binären Relation zwischen $A_1$ und $A_2$*. Siehe auch @relationAufA.
]

#beispiel[Eine dreistellige Relation][
  Eine Datenbank könnte Prüfungsanmeldungen als eine Menge $R$ von Tripeln ablegen mit
  $ R ⊆ "Matrikelnummern" × "Modulnummern" × "Termine". $
  Damit ist $R$ eine $3$-stellige Relation (zwischen Matrikelnummern, Modulnummern und Terminen). Daher der Name _relationale Datenbank_.
]

#bemerkung[Graphische Darstellung einer binären Relation][
  Eine binäre Relation $E ⊆ X × Y$ kann man graphisch darstellen: Für jedes $x ∈ X$ gibt es einen Knoten links, für jedes $y ∈ Y$ einen Knoten rechts und für jedes Element $(x,y) ∈ E$ eine Kante zwischen den entsprechenden Knoten.#footnote[Man könnte fast sagen: Eine binäre Relation _ist_ ein gerichteter Graph $(X ∪ Y, E)$. Probleme dabei: Das geht nur, wenn $X$ und $Y$ disjunkt, endlich und nicht leer sind. Außerdem „vergisst“ der Graph für isolierte Knoten, ob sie nach links oder rechts gehören, was die Relation aber „weiß“.]
]

#beispiel[Kinder und Farben][
  Gegeben seien die Mengen $"Kinder"$ und $"Farben"$ sowie die binäre Relation $"mag" ⊆ "Kinder" × "Farben"$ mit
  $ "Kinder" := {"Anna", "Ben", "Carla"}, quad "Farben" := {"rot", "blau", "grün", "braun"}. $
  $ "mag" := {("Anna","rot"), ("Anna","blau"), ("Ben","blau"), ("Carla","grün")}. $
  Eine graphische Darstellung zeigt @magbild.
]
#abbildung(slides: 0, caption: [
  Beispielrelation „mag“ zwischen Kindern und Farben.
])[#relationsbild(
  ("Anna", "Ben", "Carla"),
  ("rot", "blau", "grün", "braun"),
  (("Anna", "rot"), ("Anna", "blau"), ("Ben", "blau"), ("Carla", "grün")),
)]<magbild>


#definition("Eigenschaften binärer Relationen")[
  Sei $R ⊆ X × Y$ eine binäre Relation. Dann heißt $R$
  #table(
    columns: 2,
    stroke: none,
    align: (right,left),
    column-gutter: 0.8em,
    [*linkstotal*], [$∀x ∈ X: ∃y ∈ Y: (x,y) ∈ R$,],
    [*rechtstotal*], [$∀y ∈ Y: ∃x ∈ X: (x,y) ∈ R$,],
    [*rechtseindeutig*], [$∀x ∈ X: ∀y,y' ∈ Y:$\ $quad quad ((x,y) ∈ R ∧ (x,y') ∈ R) → y = y'$,],
    [*linkseindeutig*], [$∀y ∈ Y: ∀x,x' ∈ X:$\ $quad quad ((x,y) ∈ R ∧ (x',y) ∈ R) → x = x'$.],
  )
]<relationseigenschaften>

#bemerkung[
  Intuitiv gesprochen und auf die Graphik bezogen bedeuten die Begriffe:
  #table(
    columns: 2,
    stroke: none,
    align: (right,left),
    column-gutter: 0.8em,
    [*linkstotal*], [links je _mindestens_ eine Kante],
    [*rechtstotal*], [rechts je _mindestens_ eine Kante],
    [*rechtseindeutig*], [links je _höchstens_ eine Kante],
    [*linkseindeutig*], [rechts je _höchstens_ eine Kante],
  )
  In @magbild kann man direkt ablesen: „mag“ ist linkstotal, erfüllt aber keine der anderen Eigenschaften.
]

== Funktionen

#definition[Funktion][
  Eine binäre Relation $f ⊆ X × Y$ zwischen zwei Mengen $X$ und $Y$ heißt *Funktion* (auch *Abbildung*), wenn sie linkstotal und rechtseindeutig ist.

  In diesem Fall schreiben wir $f : X → Y$. Wir nennen $X$ den *Definitionsbereich* und $Y$ den *Wertebereich*. Etwas unsauber nennen wir auch $f$ allein eine Funktion, falls $X$ und $Y$ aus dem Kontext hervorgehen.#footnote[Siehe @einschränkung-auf-bild.]
]

=== Notationen und Begriffe

#satz[
  Sei $f : X → Y$ eine Funktion. Dann gibt es zu jedem $x ∈ X$ genau ein $y ∈ Y$ mit $(x,y) ∈ f$.
]<eindeutigerFunktionswert>
#beweis[
  Sei $x ∈ X$. Die Linkstotalität liefert ein $y ∈ Y$ mit $(x,y) ∈ f$. Für jedes $y' ∈ Y$ mit $(x,y') ∈ f$ gilt nach Rechtseindeutigkeit, dass $y = y'$ ist. Das zeigt die Eindeutigkeit.
]

#definition[Argument $x$ und Funktionswert $f(x)$][
  Für eine Funktion $f : X → Y$ und $x ∈ X$ schreiben wir $f(x)$ für das nach @eindeutigerFunktionswert eindeutige $y ∈ Y$ mit $(x,y) ∈ f$. Wir sagen, $y$ ist der *Funktionswert* zum *Argument* $x$.
]

#notation[$x ↦ f(x)$][
  Häufig gibt man eine Funktion durch eine Rechenvorschrift an, etwa
  $ f: ℤ → ℕ, quad x ↦ x². $
  Gemeint ist hier $f ⊆ ℤ × ℕ$ mit $f = {(x,x²) | x ∈ ℤ}$.
]

#definition("Bild und Urbild", kurz: [$f(A)$, $f^(-1)(B)$])[
  Sei $f: X → Y$ eine Funktion. Für $A ⊆ X$ heißt
  $ f(A) := {f(a) | a ∈ A} ⊆ Y $
  das *Bild* von $A$ unter $f$. Für $B ⊆ Y$ heißt
  $ f^(-1)(B) := {x ∈ X | f(x) ∈ B} ⊆ X $
  das *Urbild* von $B$ unter $f$. Die Menge $f(X)$ heißt kurz das *Bild von $f$*.
]

#beispiel[
  Für $f: ℤ → ℕ$, $x ↦ x²$ gilt
  $ f({1,2,3}) = {1,4,9}, quad f^(-1)({4}) = {-2,2}, quad f^(-1)({3}) = ∅. $
  Das Bild von $f$ ist die Menge der Quadratzahlen.
]

#notation("Menge aller Funktionen", kurz: [$Y^X$])[
  Für Mengen $X$ und $Y$ schreiben wir $Y^X$ oder $(X → Y)$ für die Menge aller Funktionen von $X$ nach $Y$.
]

#satz[
  Für endliche Mengen $X$ und $Y$ gilt $|Y^X| = |Y|^(|X|)$.
]<funktionenanzahl>

#begründung[
  Eine Funktion $f: X → Y$ ist durch die Wahl der Funktionswerte jedes einzelnen $x ∈ X$ festgelegt. Für jedes gibt es unabhängig von den anderen $|Y|$ Möglichkeiten, also $|Y|^(|X|)$ Möglichkeiten insgesamt.
]

#definition("Verkettung", kurz: [$g ∘ f$])[
  Seien $f: X → Y$ und $g: Y → Z$ Funktionen. Die *Verkettung* oder *Komposition* $g ∘ f$, gesprochen „$g$ nach $f$“, ist die Funktion
  $ g ∘ f : X → Z, quad x ↦ g(f(x)). $
]

=== Injektiv, surjektiv, bijektiv

#definition[injektiv, surjektiv, bijektiv][
  Eine Funktion heißt
  / injektiv: wenn sie linkseindeutig ist,
  / surjektiv: wenn sie rechtstotal ist,
  / bijektiv: wenn sie sowohl injektiv als auch surjektiv ist.

  Gleichwertige und in der Praxis gebräuchlichere Formulierungen liefern @injdef und @surjkompakt.
]<def-inj-surj-bij>

#let kinder = ("Anna", "Ben", "Cem")
#let fktbild(farben, paare) = relationsbild(kinder, farben, paare, abstand: 0.52, breite: 1.5)
#let fallbild(bild, titel) = align(center)[
  #box(height: 1.9cm, align(horizon, bild))
  #v(0.2em, weak: true)
  #text(size: 0.85em, titel)
]

#abbildung(slides: 0, caption: [
  Vier Möglichkeiten bzgl. @def-inj-surj-bij.
])[#grid(
  columns: 2,
  gutter: 8pt,
  row-gutter: 10pt,
  align: center + top,
  fallbild(
    fktbild(("rot", "blau", "grün"), (("Anna","rot"), ("Ben","rot"), ("Cem","blau"))),
    [#strike[injektiv], #strike[surjektiv]],
  ),
  fallbild(
    fktbild(("rot", "blau", "grün", "braun"), (("Anna","rot"), ("Ben","blau"), ("Cem","grün"))),
    [injektiv, #strike[surjektiv]],
  ),
  fallbild(
    fktbild(("rot", "blau"), (("Anna","rot"), ("Ben","rot"), ("Cem","blau"))),
    [#strike[injektiv], surjektiv],
  ),
  fallbild(
    fktbild(("rot", "blau", "grün"), (("Anna","rot"), ("Ben","blau"), ("Cem","grün"))),
    [injektiv, surjektiv],
  ),
)]<injsurjbild>

#bemerkung[
  Für jede Funktion $f : X → Y$ ist die Funktion $f : X → f(X)$ surjektiv. Die zweite Funktion verwendet dieselbe Menge $f$ von Paaren, schränkt aber den Wertebereich auf das Bild $f(X)$ ein, also auf die Werte, die tatsächlich angenommen werden. Der Wertebereich gehört deshalb zur Angabe einer Funktion dazu.
]<einschränkung-auf-bild>

#satz[Injektivität in Funktionsschreibweise][
  Eine Funktion $f : X → Y$ ist genau dann injektiv, wenn gilt
  $ ∀x,x' ∈ X: (f(x) = f(x') → x = x'). $
]<injdef>
#beweis[
  Nach Definition ist $f : X → Y$ genau dann injektiv, wenn sie linkseindeutig ist, also:
  $ ∀y ∈ Y: ∀x,x' ∈ X: ((x,y) ∈ f ∧ (x',y) ∈ f) → x = x'. $
  Wir formen die Bedingung äquivalent um. Mit Funktionsschreibweise lautet sie:
  $ ∀y ∈ Y: ∀x,x' ∈ X: (f(x) = y ∧ f(x') = y) → x = x'. $
  Für Tripel $(y,x,x')$ mit $f(x) ≠ y$ ist die linke Seite der Implikation falsch und damit die Implikation insgesamt wahr. Damit ist die Formel genau dann wahr, wenn sie für alle Tripel mit $y = f(x)$ wahr ist. Die Formel ist damit äquivalent zu
  $ ∀x,x' ∈ X: (f(x) = f(x) ∧ f(x') = f(x)) → x = x'. $
  Entfernt man die triviale Bedingung $f(x) = f(x)$, so ergibt sich die einfachere Bedingung des Satzes.
]

#satz[Surjektivität in Funktionsschreibweise][
  #set enum(numbering: "(1)")
  Sei $f : X → Y$ eine Funktion. Dann sind äquivalent:
  + $f$ ist surjektiv
  + $Y ⊆ f(X)$
  + $Y = f(X)$.
]<surjkompakt>
#beweis[
  Wir formen die Bedingung der Rechtstotalität äquivalent um.
  $
       &∀y ∈ Y: ∃x ∈ X: (x,y) ∈ f\
    ⇔ &∀y ∈ Y: ∃x ∈ X: y = f(x)\
    ⇔ &∀y ∈ Y: y ∈ {f(x) | x ∈ X}\
    ⇔ &∀y ∈ Y: y ∈ f(X)\
    ⇔ &Y ⊆ f(X)\
    ⇔ &Y ⊆ f(X) ∧ f(X) ⊆ Y \
    ⇔ &Y = f(X)
  $
  Die Bedingung $f(X) ⊆ Y$ durften wir deshalb dazuerfinden, weil sie für jedes $f : X → Y$ gilt.
]

#satz[
  #set enum(numbering: "(1)")
  Seien $f: X → Y$ und $g: Y → Z$ Funktionen.
  + Sind $f$ und $g$ injektiv, so ist auch $g ∘ f$ injektiv.
  + Sind $f$ und $g$ surjektiv, so ist auch $g ∘ f$ surjektiv.
]<verkettungInjSurj>

#beweis[
  #set enum(numbering: "(1)")
  + Wir rechnen die Bedingung aus @injdef für $g ∘ f$ nach. Seien $x,x' ∈ X$ mit $(g ∘ f)(x) = (g ∘ f)(x')$, also $g(f(x)) = g(f(x'))$. Weil $g$ injektiv ist, folgt $f(x) = f(x')$, und weil $f$ injektiv ist, folgt $x = x'$.
  + Wir rechnen die Rechtstotalität von $g ∘ f$ nach. Sei $z ∈ Z$. Weil $g$ surjektiv ist, gibt es ein $y ∈ Y$ mit $g(y) = z$. Weil $f$ surjektiv ist, gibt es ein $x ∈ X$ mit $f(x) = y$. Damit gilt $(g ∘ f)(x) = g(f(x)) = g(y) = z$.#qedhere
]

#korollar[
  Sind $f$ und $g$ bijektiv, so ist auch $g ∘ f$ bijektiv.
]

#bemerkung[
  Die Umkehrungen gelten nicht.
  Sei $f : {1} → {1,2}$ mit $f(1) = 1$ und $g : {1,2} → {1}$ mit $g(1) = g(2) = 1$, dann ist $g ∘ f : {1} → {1}$ bijektiv, obwohl $f$ nicht surjektiv und $g$ nicht injektiv ist.
]

#satz[
  #set enum(numbering: "(1)")
  Sei $X$ eine endliche Menge und $f: X → X$ eine Funktion. Dann sind äquivalent:
  + $f$ ist injektiv,
  + $f$ ist surjektiv,
  + $f(X) = X$.
]<endlichInjSurj>

#beweis[
  Die Äquivalenz von (2) und (3) ist ein Spezialfall von @surjkompakt. Ferner gilt:
  $ f "ist injektiv" ⇔ |f(X)| = |X| ⇔ f(X) = X $
  Die erste Äquivalenz benutzt, dass die Elemente $f(x)$ für $x ∈ X$ genau dann paarweise verschieden sind, wenn sie eine Menge der Größe $|X|$ bilden. Die zweite Äquivalenz verwendet $f(X) ⊆ X$ und dass eine Teilmenge von $X$ mit $|X|$ Elementen bereits ganz $X$ sein muss.
]

#bemerkung[
  Für unendliche Mengen ist der Satz falsch. Beispiele für eine injektive aber nicht surjektive Funktion $f$ sowie eine surjektive aber nicht injektive Funktion $g$ sind
  $ 
    f: ℕ → ℕ, " " n ↦ n+1 "und" g : ℕ → ℕ, " " n ↦ cases(0 &"falls" n = 0, n-1 &"falls" n > 0.)
  $
]

=== Die Umkehrfunktion

#definition("Umkehrrelation", kurz: $R^(-1)$)[
  Sei $R ⊆ X × Y$ eine binäre Relation. Die *Umkehrrelation* ist
  $ R^(-1) := {(y,x) | (x,y) ∈ R} ⊆ Y × X. $
]

#satz[
  Sei $f: X → Y$ eine Funktion. Dann ist $f^(-1)$ genau dann eine Funktion von $Y$ nach $X$, wenn $f$ bijektiv ist.
]<umkehrfunktion>

#beweis[
  $
       & f "ist bijektiv" && #weil[Def. bij]\
    ⇔ & f "ist surjektiv und injektiv"  && #weil[Def. inj & surj]\
    ⇔ & f "ist rechtstotal und linkseindeutig" && #weil[links und rechts tauschen]\
    ⇔ & f^(-1) "ist linkstotal und rechtseindeutig" && #weil[Def. Funktion]\
    ⇔ & f^(-1) "ist Funktion".#qedhere
  $
]

#definition[Identitätsfunktion][
  Für eine Menge $X$ ist die *Identität* auf $X$ die Funktion
  $ id_X : X → X, quad x ↦ x. $
]

#notation("Umkehrfunktion", kurz: $f^(-1)$)[
  Ist $f: X → Y$ bijektiv, so heißt die Funktion $f^(-1): Y → X$ die *Umkehrfunktion* von $f$. Es gilt
  $ f^(-1) ∘ f = id_X quad "und" quad f ∘ f^(-1) = id_Y. $
]

#bemerkung[
  Die Schreibweise $f^(-1)$ wird in zwei Bedeutungen benutzt: für das Urbild $f^(-1)(B)$ einer _Menge_ $B ⊆ Y$ und für die Umkehrfunktion. Das Urbild gibt es für jede Funktion, die Umkehrfunktion nur für bijektive. Welche Bedeutung gemeint ist, erkennt man am Argument.
]

=== Funktionen höherer Ordnung

#skript[
  Es ist möglich, dass Funktionen andere Funktionen als Argument bekommen oder als Wert liefern. Solche Funktionen heißen *Funktionen höherer Ordnung*; in der Programmierung ist das nicht selten.
]

#beispiel[Eine Funktion verdoppeln][
  Die Funktion
  $ "doppelt": (ℕ → ℕ) → (ℕ → ℕ), quad g ↦ (n ↦ 2 ⋅ g(n)) $
  nimmt eine Funktion entgegen und liefert eine Funktion. Ist etwa $g$ die Funktion $n ↦ n²$, so ist $"doppelt"(g)$ die Funktion $n ↦ 2 ⋅ n²$.

  In TypeScript:
  ```ts
  const doppelt =
    (g: (n: number) => number) =>
    (n: number) => 2 * g(n);
  ```
]

#beispiel[Filtern][
  Die Funktion
  $ "filter": & (2^ℕ × (ℕ → {"wahr", "falsch"})) → 2^ℕ,\
              & (M,f) ↦ {x ∈ M | f(x) = "wahr" } $
  nimmt eine Menge $M$ und eine Funktion $f$ entgegen und liefert die Teilmenge derjenigen Elemente von $M$, die $f$ auf „wahr“ abbildet. In TypeScript (für Arrays statt Mengen) kann man etwas Ähnliches machen:
  ```ts
  [7, 3, 1, 5].filter(n => n > 3)   // [7, 5]
  ```
]

#bemerkung[
  Man kann natürlich weiter schachteln und Funktionen betrachten, die Funktionen höherer Ordnung verarbeiten. Das wird nur schnell verwirrend.
]

== Relationen auf einer Menge
<relationenAufEinerMenge>

#notation("Infixschreibweise", kurz: $a R b$)[
  Ist $R ⊆ X × Y$ eine binäre Relation, so schreiben wir statt $(a,b) ∈ R$ auch $a R b$, zum Beispiel $3 ≤ 5$ statt $(3,5) ∈ "≤"$.
]

#definition[Relation auf _einer_ Menge][
  Ist $A$ eine Menge und $R ⊆ A × A$ eine binäre Relation, so nennen wir $R$ eine *Relation auf $A$*.
]<relationAufA>

#beispiel[
  Einige Relationen auf einer Menge kennen wir bereits.
  #table(
    columns: 4,
    stroke: none,
    column-gutter: 0.8em,
    align: (left, center, center, left),
    [Relation], [auf], [Symbol], [Beispiele],
    table.hline(),
    [Teilbarkeit], [$ℕ$], [$divides$], [$5 divides 15$, $3 divides.not 8$, $10 divides 0$],
    [kleiner], [$ℤ$], [$<$], [$5 < 7$, $-4 lt.not -4$],
    [kleiner-gleich], [$ℤ$], [$≤$], [$5 ≤ 7$, $-4 ≤ -4$],
    [Gleichheit], [$ℕ$], [$=$], [$7 = 7$, $8 ≠ 7$],
    [Teilmenge], [$2^({1,…,9})$], [$⊆$], [${4,5} ⊆ {3,4,5,7}$],
  )
  Genauer ist die Teilbarkeitsrelation wie folgt definiert. Für $a, b ∈ ℕ$ gilt
  $ a divides b defiff ∃k ∈ ℕ: a⋅k = b. $
]<bspRelationen>

#bemerkung[Ist „$=$“ eine Relation?][
  Für jede Menge $A$ ist die Gleichheit auf $A$ die Relation ${(a,a) | a ∈ A} ⊆ A × A$.

  Eine Gleichheit „an sich“ für beliebige Objekte ist keine Relation in unserem Sinne: Die Gesamtheit aller Paare $(a,a)$ für beliebige Objekte $a$ ist keine Menge. Siehe @mengeAllerMengen. Ähnliches gilt für „$∈$“ und „$⊆$“.
]

#definition[Eigenschaften von Relationen][
  Sei $A$ eine Menge und $R$ eine Relation auf $A$. Dann heißt $R$
  #table(
    columns: 2,
    stroke: none,
    align: (right, left),
    [*reflexiv*], [falls $∀a ∈ A: a R a$,],
    [*irreflexiv*], [falls $∀a ∈ A: ¬(a R a)$,],
    [*symmetrisch*], [falls $∀a,b ∈ A: a R b → b R a$,],
    [*antisymmetrisch*], [falls $∀a,b ∈ A: (a R b ∧ b R a) → a = b$,],
    [*transitiv*], [falls $∀a,b,c ∈ A: (a R b ∧ b R c) → a R c$,],
    [*total*], [falls $∀a,b ∈ A: a R b ∨ b R a$.],
  )
]<relationseigenschaftenA>

#uebung[
  Betrachten Sie die Relationen aus @bspRelationen und darüber hinaus die Relation $V$ auf der Menge der Menschen, wobei $m₁ V m₂$ genau dann gelte, wenn $m₁$ ein Elternteil oder ein Kind von $m₂$ ist.

  Stellen Sie tabellarisch dar, welche der Relationen welche Eigenschaften aus @relationseigenschaftenA haben.
]<uebEigenschaften>

#loesung[
  #align(center, text(size: 0.85em, table(
    columns: 7,
    stroke: none,
    align: (left, center, center, center, center, center, center),
    column-gutter: 0.5em,
    [], [refl.], [irrefl.], [symm.], [antis.], [trans.], [total],
    table.hline(),
    [$divides$ auf $ℕ$], [✓], [–], [–], [✓], [✓], [–],
    [$<$ auf $ℤ$], [–], [✓], [–], [✓], [✓], [–],
    [$≤$ auf $ℤ$], [✓], [–], [–], [✓], [✓], [✓],
    [$=$ auf $ℕ$], [✓], [–], [✓], [✓], [✓], [–],
    [$⊆$ auf $2^({1,…,9})$], [✓], [–], [–], [✓], [✓], [–],
    [$V$ auf Menschen], [–], [✓], [✓], [–], [–], [–],
  )))
]

#beobachtung[Eigenschaften im Bild][
  Ist $E$ eine Relation auf $V$, so ist $G = (V,E)$ ein gerichteter Graph (potentiell mit Schlingen) und umgekehrt (in beiden Fällen ist nur $E ⊆ V × V$ gefordert).#footnote[Man spricht daher auch von der _Kantenrelation_ eines Graphen.]
]

#uebung[Relationseigenschaften graphisch][
  Formulieren Sie die Eigenschaften reflexiv, irreflexiv, symmetrisch, antisymmetrisch, transitiv, total einer Relation $E$ auf $V$ als Eigenschaften des Graphen $G = (V,E)$.
]
#loesung[
  #table(
    columns: 2,
    stroke: none,
    align: (right, left),
    [*reflexiv*], [an jedem Knoten liegt eine Schlinge,],
    [*irreflexiv*], [es gibt keine Schlinge,],
    [*symmetrisch*], [zu jeder Kante $(u,v)$ gibt es die Gegenkante $(v,u)$,],
    [*antisymmetrisch*], [verschiedene Knoten $u ≠ v$ sind durch höchstens eine Kante verbunden,],
    [*transitiv*], [gibt es einen Weg $u v w$, so gibt es auch die direkte Kante $(u,w)$,],
    [*total*], [je zwei Knoten $u$ und $v$ sind durch $(u,v)$ oder $(v,u)$ verbunden; für $u = v$ heißt das, dass an jedem Knoten eine Schlinge liegt.],
  )
]

#uebung[
  Welche Relationen lassen sich durch einen _ungerichteten_ Graphen darstellen?
]

#loesung[
  Wir können ungerichtete Graphen als gerichteten Graphen auffassen, wobei eine Kante ${u,v}$ den gerichteten Kanten $(u,v)$ und $(v,u)$ entspricht. Die Kantenrelation ist also notwendig symmetrisch. Weil wir keine Schlingen zugelassen haben, ist sie außerdem irreflexiv. Ungerichtete Graphen mit Knotenmenge $V$ entsprechen also genau den irreflexiven, symmetrischen Relationen auf $V$.
]

== Ordnungsrelationen

#definition[Quasi-, Halb- und Totalordnung][
  Sei $A$ eine Menge und $≼$ eine Relation auf $A$. Wir nennen $≼$ eine
  #table(
    columns: 2,
    stroke: none,
    align: (right, left),
    [Begriff], [Anforderungen an $≼$],
    table.hline(),
    [*Quasiordnung*], [reflexiv, transitiv],
    [*Halbordnung*], [reflexiv, transitiv, antisymmetrisch],
    [*Totalordnung*], [reflexiv, transitiv, antisymmetrisch, total],
  )
  Zwei Elemente $a,b ∈ A$ heißen *vergleichbar*, falls $a ≼ b$ oder $b ≼ a$ oder $a = b$ gilt, andernfalls *unvergleichbar*.#footnote[Eine Halbordnung ist also genau dann eine Totalordnung, wenn je zwei Elemente vergleichbar sind.]
]<ordnungen>

#uebung[
  Um welche Art von Ordnung handelt es sich jeweils?
  + $≤$ auf $ℕ$,
  + $<$ auf $ℕ$,
  + $⊆$ auf $2^ℕ$,
  + $divides$ auf $ℕ$,
  + $R$ auf $2^({1,…,9})$ mit $X R Y defiff |X| ≤ |Y|$.
]<uebOrdnungen>

#loesung[
  Die Eigenschaften lassen sich leicht prüfen:
  #align(center, text(size: 0.85em, table(
    columns: 6,
    stroke: none,
    align: (left, center, center, center, center, left),
    column-gutter: 0.5em,
    [], [refl.], [trans.], [antis.], [total], [stärkster erfüllter Begriff],
    table.hline(),
    [$≤$ auf $ℕ$], [✓], [✓], [✓], [✓], [Totalordnung],
    [$<$ auf $ℕ$], [–], [✓], [✓], [–], [keine Ordnung#footnote[Man nennt $<$ eine *strikte Totalordnung*, mit den Anforderungen _irreflexiv_, _transitiv_ und _total_. Es gibt auch den Begriff der *strikten Halbordnung*, mit den Anforderungen _irreflexiv_ und _transitiv_. Die Unterschiede zu den nicht-strikten Varianten sind mathematisch uninteressant.]],
    [$⊆$ auf $2^ℕ$], [✓], [✓], [✓], [–], [Halbordnung],
    [$divides$ auf $ℕ$], [✓], [✓], [✓], [–], [Halbordnung],
    [$R$ auf $2^({1,…,9})$], [✓], [✓], [–], [✓], [Quasiordnung],
  )))
  Wir begründen nur die überraschenden Einträge:
  - „$<$“ ist antisymmetrisch, weil die Prämisse $a < b ∧ b < a$ der Implikation unerfüllbar ist.
  - „$⊆$“ ist nicht total, weil ${1}$ und ${2}$ unvergleichbar sind.
  - „$divides$“ ist nicht total, weil $2$ und $3$ unvergleichbar sind.
  - „$divides$“ ist auf $ℕ$ antisymmetrisch: Für $a,b ∈ ℕ⁺$ folgt aus $a divides b$ und $b divides a$ schon $a = b$. Zur Null: $0 divides b$ erzwingt $b = 0$.
  - $R$ ist nicht antisymmetrisch, denn ${1} R {2}$ und ${2} R {1}$, aber ${1} ≠ {2}$.
]

=== Erreichbarkeit in gerichteten Graphen

#definition("Erreichbarkeit in gerichteten Graphen", kurz: $u ⇝_G v$)[
  Sei $G = (V,E)$ ein gerichteter Graph und seien $u,v ∈ V$. Wir schreiben
  $ u ⇝_G v defiff "es gibt einen gerichteten Weg von" u "nach" v $
  und sagen dann, $v$ ist von $u$ aus *erreichbar*. Ist $G$ aus dem Zusammenhang klar, schreiben wir nur $u ⇝ v$.
]<erreichbarkeitgerichtet>

#satz[
  Für jeden gerichteten Graphen $G = (V,E)$ ist $⇝_G$ eine Quasiordnung auf $V$.
]<erreichbarkeitQuasi>

#beweis[
  / Reflexivität: Sei $v ∈ V$. Die einelementige Folge $v$ ist ein gerichteter Weg der Länge $ℓ = 0$ von $v$ nach $v$. Er bezeugt $v ⇝ v$.
  / Transitivität: Gelte $u ⇝ v$ und $v ⇝ w$. Zu zeigen ist $u ⇝ w$. Für $u = v$ oder $v = w$ ist das trivial. Andernfalls gibt es einen gerichteten Weg $u x₁ … x_k v$ von $u$ nach $v$ (mit $k ∈ ℕ$) und einen gerichteten Weg $v y₁ … y_ℓ w$ von $v$ nach $w$ (mit $ℓ ∈ ℕ$). Durch Zusammensetzen ergibt sich ein gerichteter Weg $u x₁ … x_k v y₁ … y_ℓ w$ von $u$ nach $w$. Somit gilt $u ⇝ w$.#qedhere
]

#definition[Azyklisch, DAG][
  Ein gerichteter Graph ohne gerichtete Kreise heißt *azyklisch* oder *directed acyclic graph* (kurz *DAG*).
]<dag>

#lemma[
  Sei $G = (V,E)$ ein gerichteter Graph. Wenn $G$ einen gerichteten Zyklus positiver Länge enthält, dann enthält $G$ auch einen gerichteten Kreis.
]<zyklusGibtKreis>

#beweis[
  Sei $v₀ v₁ … v_k$ ein gerichteter Zyklus mit kürzester positiver Länge $k > 0$ (wir verwenden das Extremalprinzip, siehe @extremalprinzip). Wir behaupten, dass er ein Kreis ist, dass also $v₀ = v_k$ die einzige Wiederholung ist. Andernfalls gäbe es nämlich $0 ≤ i < j ≤ k$ mit $v_i = v_j$ und $(i,j) ≠ (0,k)$. Dann wäre $v_i … v_j$ ein gerichteter Zyklus der Länge $j - i$ mit $1 ≤ j - i < k$, im Widerspruch zur Wahl von $k$. Also ist $v₀ … v_k$ ein gerichteter Kreis.
]

#satz[
  Wenn $G = (V,E)$ ein DAG ist, so ist $⇝_G$ eine Halbordnung auf $V$.
]<dagHalbordnung>

#beweis[
  Nach @erreichbarkeitQuasi ist $⇝_G$ eine Quasiordnung. Zu zeigen bleibt die Antisymmetrie. Wir zeigen die Kontraposition: Ist $⇝_G$ nicht antisymmetrisch, so hat $G$ einen gerichteten Kreis.

  Sei also $⇝_G$ nicht antisymmetrisch. Dann gibt es $u,v ∈ V$ mit $u ≠ v$, $u ⇝ v$ sowie $v ⇝ u$. Es ergeben sich also gerichtete Wege von $u$ nach $v$ sowie von $v$ nach $u$. Hängen wir sie zusammen, ergibt sich ein gerichteter Zyklus der Länge mindestens $2$. Nach @zyklusGibtKreis enthält $G$ also einen gerichteten Kreis.
]

#uebung[
  Zeigen Sie: Die Umkehrung von @dagHalbordnung gilt nicht (aus spitzfindigen Gründen).
]

#loesung[
  Nehmen wir einen beliebigen DAG (dessen Erreichbarkeitsrelation also eine Halbordnung ist) und fügen Schlingen hinzu, so ist der resultierende Graph kein DAG mehr. Die Erreichbarkeitsrelation ist aber immer noch die gleiche, also immer noch eine Halbordnung.
]

#beispiel[Abhängigkeiten][
  Ein DAG drückt häufig zeitliche oder logische Abhängigkeiten aus. Ein Beispiel ist @modulDag. Ein gerichteter Kreis wäre eine zirkuläre Abhängigkeit und damit problematisch.
]

#abbildung(slides: 0, caption: [
  Einige Informatikmodule. Eine Kante von $a$ nach $b$ bedeutet, dass $b$ auf den Inhalten von $a$ aufbaut.
])[#textgraphbild(
  (
    "PSE": (-2.0, 3.0), "LDS": (2.0, 3.0),
    "DSA": (-2.0, 1.5), "FSB": (2.0, 1.5),
    "PPR": (-2.0, 0.0), "KTA": (2.0, 0.0),
  ),
  (
    ("PSE", "DSA"), ("LDS", "DSA"), ("LDS", "FSB"),
    ("DSA", "PPR"), ("DSA", "KTA"), ("FSB", "KTA"),
    ("LDS", "PPR"),
  ),
  beschriftung: (
    "PSE": [Programmierung und\ Software-Entwicklung (PSE)],
    "LDS": [Logik & Diskrete\ Strukturen (LDS)],
    "DSA": [Datenstrukturen und\ Algorithmen (DSA)],
    "FSB": [Formale Sprachen &\ Berechenbarkeit (FSB)],
    "PPR": [Programmierprojekt (PPR)],
    "KTA": [Komplexitätstheorie\ & Algorithmik (KTA)],
  ),
  gerichtet: true,
)]<modulDag>

#bemerkung[Topologische Sortierung][
  Eine *topologische Sortierung* einer Halbordnung $≼$ auf einer endlichen Menge $A$ ist eine Totalordnung $⊑$ auf $A$ mit $"≼" ⊆ "⊑"$ (d.h. aus $a ≼ b$ folgt $a ⊑ b$). Ist $≼$ die Erreichbarkeitsrelation in @modulDag, so entspricht $⊑$ einer Reihenfolge, in der man die Module belegen kann, also z.B.
  $ "LDS" ⊑ "FSB" ⊑ "PSE" ⊑ "DSA" ⊑ "PPR" ⊑ "KTA". $
  Wie man eine solche Reihenfolge findet, ist Thema der Vorlesung Datenstrukturen und Algorithmen.
]

#bemerkung[Hasse-Diagramm][
  Eine sparsame visuelle Darstellung einer Halbordnung $≼$ auf einer endlichen Menge ist das *Hasse-Diagramm* — ein bestimmter gerichteter Graph. Eine Kante $(a,b)$ drückt $a ≼ b$ aus. Man lässt aber alle Kanten weg, die sich aus Reflexivität und Transitivität automatisch ergeben. Die Richtung der Kanten ist implizit von unten nach oben. Die Erreichbarkeitsrelation ist genau $≼$.
]

#abbildung(slides: 0, caption: [
  Hasse-Diagramm der Teilmengenrelation $⊆$ auf $2^({1,2,3})$.
])[#textgraphbild(
  (
    "e": (0, 0),
    "a": (-1.3, 1.1), "b": (0, 1.1), "c": (1.3, 1.1),
    "ab": (-1.3, 2.2), "ac": (0, 2.2), "bc": (1.3, 2.2),
    "abc": (0, 3.3),
  ),
  (
    ("e", "a"), ("e", "b"), ("e", "c"),
    ("a", "ab"), ("a", "ac"), ("b", "ab"), ("b", "bc"), ("c", "ac"), ("c", "bc"),
    ("ab", "abc"), ("ac", "abc"), ("bc", "abc"),
  ),
  beschriftung: (
    "e": $∅$,
    "a": ${1}$, "b": ${2}$, "c": ${3}$,
    "ab": ${1,2}$, "ac": ${1,3}$, "bc": ${2,3}$,
    "abc": ${1,2,3}$,
  ),
)]<hasseTeilmengen>

#abbildung(slides: 0, caption: [
  Hasse-Diagramm der Teilbarkeitsrelation $divides$ auf ${0,1,…,12}$. Wegen $a ⋅ 0 = 0$ gilt $a divides 0$ für jedes $a$; die $0$ ist also das größte Element.
])[#textgraphbild(
  (
    "1": (0, 0),
    "2": (-2.1, 1.3), "5": (-1.0, 1.3), "3": (0.5, 1.3), "7": (1.9, 1.3), "11": (2.8, 1.3),
    "4": (-2.5, 2.6), "10": (-1.3, 2.6), "6": (0.0, 2.6), "9": (1.0, 2.6),
    "8": (-2.5, 3.9), "12": (-1.2, 3.9),
    "0": (0.3, 5.3),
  ),
  (
    ("1", "2"), ("1", "3"), ("1", "5"), ("1", "7"), ("1", "11"),
    ("2", "4"), ("2", "6"), ("2", "10"),
    ("3", "6"), ("3", "9"),
    ("5", "10"),
    ("4", "8"), ("4", "12"), ("6", "12"),
    ("7", "0"), ("8", "0"), ("9", "0"), ("10", "0"), ("11", "0"), ("12", "0"),
  ),
)]<hasseTeiler>

#stichpunktgrenze

== Äquivalenzrelationen

- Äquivalenzrelation intuitiv:
  - Relaxierung von Gleichheit (Gleichheit "bis auf")
  - Ignorieren von unwesentlicher Information
    - Menge von Worten {Müßiggang,müßiggang,Muessiggang,Lückenbüßer, LUECKENBUESSER, maßlos}
    - Es treten nur drei _Äquivalenzklassen_ von Wörtern _modulo_ Großschreibung und Umlauten auf. _Repräsentanten_ der Klassen sind MUESSIGGANG, LUECKENBUESSER und MASSLOS.
  - Abbildung mit Beispielen:
    - Zwei kongruente Dreiecke
    - Zwei einfache isomorphe Graphen mit Knoten 1,2,3,4 bzw. A,B,C,D

- Definition: Äquivalenzrelation
- Notation [a] Äquivalenzklasse von a. a ist ein Repräsentant der Klasse (jedes andere a' ∈ [a] ist das auch). Projektion π.
- Def: Partition
- Bild: Partition der Grundmenge
- Satz Sei A eine Menge. Jede Partition von A entspricht genau einer Äquivalenzrelation auf A und umgekehrt
  - z.Z: a ∈ [a] und [a] ∩ [b] ≠ ∅ ⇒ [a] = [b]
- Notation: A / R "modulo" für Menge der Äquivalenzklassen (Quotientenmenge), also die Partition.
- Uebung: Sei P = ℤ × ℕ⁺ und (z₁,n₁) ~ (z₂,n₂) defiff z₁n₂ = z₂n₁. Beweise: ~ ist eine Äquivalenzrelation. Argumentiere: P / ~ entspricht der Menge ℚ der rationalen Zahlen.
- Loesung: ...
- Satz: $R$ ist genau dann eine Äquivalenzrelation auf $X$, wenn es eine Menge $Y$ und ein $f : X → Y$ gibt mit $a R b ⟺ f(a) = f(b)$. Die Klassen sind dann die nichtleeren Urbilder $f^(-1)({y})$.
- Satz: Sei n ∈ ℕ und x ~ y gdw x und y den selben Rest beim Teilen durch n lassen. Dann ist ~ eine Äquivalenzrelation mit n Äquivalenzklassen.
- Beweis: Der Rest, den x lässt, ist eine eindeutige Zahl zwischen 0 und n-1, ist also eine Funktion der Zahl. Dann Satz von eben anwenden.
- Bemerkung: Das Beispiel wird uns später noch viel beschäftigen.

=== Zusammenhangskomponenten

#definition("Erreichbarkeit in ungerichteten Graphen")[
  Sei $G = (V,E)$ ein ungerichteter Graph. Für $v,w ∈ V$ schreiben wir $v ↭_G w$, falls es einen Weg von $v$ nach $w$ gibt. Wenn klar ist, welcher Graph gemeint ist, lassen wir den Index weg.
]<erreichbarkeitungerichtet>

#satz[
  Für jeden ungerichteten Graphen $G = (V,E)$ ist $↭_G$ eine Äquivalenzrelation auf $V$.
]
- Beweis: Reflexivität (Weg der Länge 0), Symmetrie (Weg umdrehen), Transitivität (Wege aneinanderhängen).

#definition("Zusammenhangskomponente")[
  Die Elemente von $V \/ ↭_G$, also die Äquivalenzklassen, heißen *Zusammenhangskomponenten* von $G$.
]

- Abbildung mit einem Graphen. Die Bildunterschrift listet die Zusammenhangskomponenten auf.
- Bemerkung: $G$ ist zusammenhängend genau dann, wenn es genau eine Äquivalenzklasse bzgl. $↭_G$ gibt.
- Definition und Satz: Sei $G = (V,E)$ ein gerichteter Graph. Dann ist $⇝ ∩ ⇝^(-1)$ eine Äquivalenzrelation. Die Äquivalenzklassen heißen *starke Zusammenhangskomponenten*.

=== Graphisomorphie

#definition("Graphisomorphismus", kurz: $G_1 ≅ G_2$)[
  Seien $G_1 = (V_1,E_1)$ und $G_2 = (V_2,E_2)$ Graphen. Ein *Isomorphismus* von $G_1$ nach $G_2$ ist eine bijektive Abbildung $φ: V_1 → V_2$ mit
  $ ∀v,w ∈ V_1: quad {v,w} ∈ E_1 ⇔ {φ(v),φ(w)} ∈ E_2. $
  Wir schreiben $G_1 ≅ G_2$, falls ein solcher Isomorphismus existiert, und nennen $G_1$ und $G_2$ dann *isomorph*.
]

- Idee: Isomorphe Graphen sind „derselbe Graph mit anderen Knotennamen“. Alle Eigenschaften eines Graphen, die sich ohne Rückgriff auf die Knotennamen formulieren lassen, gelten offensichtlich genauso für jeden isomorphen Graphen. Gibt es Wege oder Kreise gewisser Länge, Knoten von bestimmten Graden usw., dann gibt es sie auch im isomorphen Graphen. 
- Beispiel: Das Sechseck mit seinen drei langen Diagonalen ist isomorph zu $K_(3,3)$ (Isomorphismus angeben).
- Beispiel: Petersen-Graph ist nicht isomorph zum Fünfecksprisma. Das Fünfecksprisma enthält einen Kreis der Länge 4, der Petersen-Graph nicht.

#satz[
  Sei $𝒢 := {(V,E) | (V,E) "ist Graph mit" V ⊆ ℕ }$.
  Isomorphie $≅$ ist eine Äquivalenzrelation auf $𝒢$.
]
- Beweis: Identität, Umkehrabbildung und Komposition von Isomorphismen.
- Bemerkung: Grund der Einschränkung. „Alle Graphen überhaupt“ bilden wie „alle Mengen“ keine Menge.

#definition("Unbeschrifteter Graph")[
  Ein *unbeschrifteter Graph* (englisch „unlabeled graph“) ist eine Äquivalenzklasse bezüglich Isomorphie, also ein Element von
  $ 𝒢 \/ ≅. $
]

- Sprechweise: Wir sagen dann „der Graph“ und meinen seine Isomorphieklasse. Genau das tun wir beim Zeichnen ohne Knotennamen und in der Graphengalerie: $P_4$, $C_6$ oder $K_5$ bezeichnen Isomorphieklassen.
- Bemerkung: Ob zwei gegebene Graphen isomorph sind, ist algorithmisch überraschend schwer. Für die Anzahl der unbeschrifteten Graphen mit $n$ Knoten gibt es keine einfache Formel. (Beschriftete Graphen sind leicht zu zählen, siehe Kapitel „Zählen“.)
- Übung: Bestimmen Sie alle unbeschrifteten Graphen mit 4 Knoten und 3 Kanten. Wie viele beschriftete Graphen mit Knotenmenge ${1,2,3,4}$ und $3$ Kanten gibt es jeweils in einer Klasse?

#slidebreak()
= Exkurs: Abzählbarkeit
<sec:cardinality>

#skript[
  Bisher haben wir $|A|$ nur für endliche Mengen erklärt. Für unendliche Mengen brauchen wir einen Vergleich, der ohne Zählen funktioniert: Zwei Mengen sind gleich groß, wenn sich ihre Elemente paarweise einander zuordnen lassen. Das führt zu einem überraschenden Ergebnis, das für die Informatik grundlegend ist: Es gibt mehr Probleme als Programme.
]

- Def: $|A| = |B| defiff$ es gibt eine Bijektion $A → B$; $|A| ≤ |B| defiff$ es gibt eine Injektion $A → B$.
- Def: $A$ ist *abzählbar*, falls $|A| ≤ |ℕ|$, sonst *überabzählbar*.
- Bemerkung: Anschaulich heißt abzählbar, dass man die Elemente in einer (endlichen oder unendlichen) Liste aufzählen kann.

- Def: $A$ hat Mächtigkeit $n ∈ ℕ$ gdw. $A$ Bijektion zu ${1,…,n}$ hat.
- Frage: Ist klar, dass es keine Bijektion zwischen ${1}$ und ${1,2}$ gibt?
- Skript: Das ist durchaus nützlich, besser verwendbar als die naive Definition (die offensichtlich Äquivalent ist)

#satz(kurz: $|A ∪ B| = |A| + |B| - |A ∩ B|$)[
  Für endliche Mengen $A$ und $B$ gilt $|A ∪ B| = |A| + |B| - |A ∩ B|$.
]
- Satz: $A ⊆ B ⇔ |A ∪ B| = |A|$
- Beweis: Bild; oder jedes Element von $A$ und jedes Element von $B$ bekommt 1 €.
- Beispiel
- Bemerkung: Der Fall mit drei Mengen (Bild) und die allgemeine Formel für $k$ Mengen. Beides ohne Beweis; die allgemeine Formel ist Stoff für eine weiterführende Vorlesung.

== Cantors Diagonalargument

- Beispiel (Hilberts Hotel): $|ℕ| = |ℕ₀|$, obwohl $ℕ ⊊ ℕ₀$. Bei unendlichen Mengen kann eine echte Teilmenge gleich groß sein.
- Übung: $ℤ$ ist abzählbar.
- Satz: $ℕ × ℕ$ ist abzählbar (Cantorsche Paarung oder $(a,b) ↦ 2^a 3^b$).
- Korollar: Die Menge $ℕ^*$ aller endlichen Folgen natürlicher Zahlen ist abzählbar.
  - Korollar: Es gibt nur abzählbar viele Python-Programme (ein Programm ist eine endliche Zeichenfolge).
- Satz (Cantors Diagonalargument): Die Menge $2^ℕ$ aller Teilmengen von $ℕ$ ist überabzählbar.
  - Beweis über Diagonalisierung: Zu jeder Aufzählung konstruieren wir eine Menge, die nicht in der Aufzählung vorkommt.
  - Gleichwertige Sicht: Die Menge ${0,1}^ℕ$ der unendlichen 0-1-Folgen ist überabzählbar.
- Korollar: Es gibt eine Teilmenge von $ℕ$, die kein Computerprogramm aufzählt. Denn es gibt nur abzählbar viele Programme, aber überabzählbar viele Teilmengen von $ℕ$.
  - Ausblick: Es gibt also unentscheidbare _Probleme_, das heißt solche, die von keinem Algorithmus gelöst werden. Dass es _interessante_ unentscheidbare Probleme gibt (etwa das Halteproblem), ist Inhalt einer zukünftigen Vorlesung über Formale Sprachen und Berechenbarkeit.
- Bemerkung: Allgemeiner gilt $|M| < |2^M|$ für jede Menge $M$ (ohne Beweis).
- Bemerkung: Auch $ℝ$ ist überabzählbar. Das Diagonalargument über Dezimaldarstellungen ist etwas unsauber, weil verschiedene Dezimaldarstellungen dieselbe Zahl bezeichnen können ($0{,}999… = 1$).

#slidebreak()
= Zählen und Abschätzen
- Bemerkung: Summen- und Produktzeichen haben wir im Kapitel über Mengen eingeführt.
- Technik: Gleichmächtigkeit durch Bijektion zeigen
  - Beispiel: Kardinalität der Potenzmenge.
  /* War vorher bei Funktionen
  #bemerkung[
    Damit erklärt sich die Schreibweise $2^A$ für die Potenzmenge. Fasst man die Zahl $2$ als die Menge ${0,1}$ auf, so ist $2^A$ die Menge aller Funktionen von $A$ nach ${0,1}$. Eine solche Funktion hält für jedes Element fest, ob es dazugehört oder nicht — und beschreibt damit genau eine Teilmenge von $A$. Nach @funktionenanzahl gibt es davon $2^(|A|)$ Stück.
  ]*/
  - Beispiel: Anzahl Injektionen
    - Korollar: Keine Injektionen wenn Bildbereich kleiner als Definitionsbereich
    - Korollar: Anzahl der Permutationen
- Schubfachprinzip als Satz

== Binomialkoeffizienten

- Mengenwertige Binomialkoeffizienten
  - Definition, auch für k < 0 und k > n
- Satz: Größe des Binomialkoeffizienten für endliche Mengen.
- Notation: Normale Binomialkoeffizienten
- Beispiel: Die Kantenmenge eines Graphen lässt sich jetzt bequem als $E ⊆ binom(V, 2)$ schreiben.
  - Korollar: $m ≤ binom(n, 2) = n(n-1)/2$ (die in „Graphen“ angekündigte Schranke).
  - Korollar: Es gibt $2^binom(n, 2)$ Graphen mit Knotenmenge ${1,…,n}$.
  - Bemerkung: Unbeschriftete Graphen (also Isomorphieklassen) zu zählen ist dagegen schwer; siehe die Bemerkung im Abschnitt über Graphisomorphie.
- Satz n choose k = n choose n-k
  - Komplementbildung / Bijektion
- Additionssatz wie bei Kufleitner
  - Rechnen
  - Kombinatorische Interpretation
  - *nicht* die Polynommethode
- Binomialsatz
  - Zählen
  - Bijektivität
  - *nicht* die Polynommethode
  - Korollar $sum_(k = 0)^n binom(n, k) = 2^n$
- Stars-and-Bars
- Multinomialkoeffizienten
  - Satz: schreibbar als Produkt von Binomialkoeffizienten
    - Beweis 1: Rechnen
    - Beweis 2: Bijektion

== Catalanzahlen

/*
Wollen wir hier Binärbäume haben?
=== Gewurzelte Bäume

#definition("Gewurzelter Baum")[
  Ein *gewurzelter Baum* ist ein Baum $T = (V,E)$ zusammen mit einem ausgezeichneten Knoten $r ∈ V$, der *Wurzel*.
]

- Def: Für $v ≠ r$ ist der *Vorgänger* (oder *Elternknoten*) $p(v)$ der erste Knoten auf dem eindeutigen einfachen Weg von $v$ zur Wurzel. Das ergibt eine Funktion $p: V ∖ {r} → V$.
- Def: *Kinder* von $v$ sind die Knoten in $p^(-1)({v})$, also das Urbild von $v$ unter $p$.
- Def: *Tiefe* eines Knotens: Länge des Weges zur Wurzel; *Höhe* des Baumes: maximale Tiefe.
- Bemerkung: Blätter sind hier die Knoten ohne Kinder. Achtung: Die Wurzel kann Grad 1 haben und ist trotzdem kein Blatt in diesem Sinne.
- Bemerkung: Dass der Weg zur Wurzel eindeutig ist, haben wir bei den Beweistechniken gezeigt.
- Beispiel: Dateisystem, Syntaxbaum eines arithmetischen Ausdrucks, Suchbaum.

#definition("Geordneter Baum, Binärbaum")[
  In einem *geordneten Baum* ist zusätzlich für jeden Knoten eine Reihenfolge seiner Kinder festgelegt. Ein *Binärbaum* ist rekursiv definiert: Ein Binärbaum ist entweder leer oder besteht aus einer Wurzel mit einem linken und einem rechten Binärbaum als Teilbäumen.
]

- Bemerkung: Hier kommt es auf die Reihenfolge an: Die beiden Binärbäume mit Wurzel und einem Kind (links bzw. rechts) sind verschieden, obwohl sie als Graphen isomorph sind.
- Bemerkung: Die rekursive Definition passt zur strukturellen Induktion und zu rekursiven Datentypen in der Programmierung.
- Ausblick: Die Anzahl der Binärbäume mit $n$ Knoten sind die Catalanzahlen (Kapitel „Zählen“).
*/

- Def: $C_n :=$ Anzahl der Binärbäume mit $n$ Knoten.
  - Kleine Werte von Hand: $C_0 = 1$, $C_1 = 1$, $C_2 = 2$, $C_3 = 5$.
- Satz (Rekursion): $C_(n+1) = sum_(i=0)^n C_i ⋅ C_(n-i)$.
  - Beweis: Fallunterscheidung nach der Größe $i$ des linken Teilbaums. Die rekursive Definition der Binärbäume liefert direkt eine Bijektion.
- Satz (Bijektion): Es gibt genauso viele korrekte Klammerausdrücke mit $n$ Klammerpaaren wie Binärbäume mit $n$ Knoten.
  - Beweis: Bijektion angeben; Rückrichtung über die rekursive Struktur.
  - Bemerkung: Beide Objekte kennen wir schon: Klammerausdrücke aus der strukturellen Induktion, Binärbäume aus dem Kapitel über Funktionen.
- Weitere Beispiele (jeweils Bijektion zu einem der obigen Objekte):
  - Gitterwege von $(0,0)$ nach $(n,n)$, die nie oberhalb der Diagonale verlaufen (Dyck-Pfade)
  - Triangulierungen eines konvexen Polygons
- Satz (geschlossene Formel): $C_n = 1/(n+1) binom(2n, n)$.
  - Bemerkung: Der Beweis (etwa mit dem Spiegelungsprinzip) ist optional; die Formel lässt sich per Induktion aus der Rekursion bestätigen.
- Bemerkung: $C_n$ zählt *geordnete* Bäume, nicht Isomorphieklassen von Bäumen. Bei Binärbäumen sind linkes und rechtes Kind unterscheidbar; als Graphen wären viele dieser Bäume isomorph.


#definition("Korrekte Klammerausdrücke")[
  Die Menge $K$ der *korrekten Klammerausdrücke* ist rekursiv definiert:
  + Das leere Wort ist in $K$.
  + Sind $u, v ∈ K$, so ist auch $u v ∈ K$ (Hintereinanderschreiben).
  + Ist $u ∈ K$, so ist auch $(u) ∈ K$.
]

- Beispiel: $(())()$ ist korrekt, $())($ nicht.
//- Satz: In jedem korrekten Klammerausdruck ist die Anzahl der öffnenden gleich der Anzahl der schließenden Klammern.
//- Beweis: Strukturelle Induktion über den Aufbau; ein Fall pro Regel.
//- Übung: Zeigen Sie per struktureller Induktion, dass in jedem Präfix eines korrekten Klammerausdrucks mindestens so viele öffnende wie schließende Klammern vorkommen.
- Anzahl Klammerausdrücke mit Catalanzahlen.

#slidebreak()
= Asymptotisches Wachstum

- Motivation für die Informatik
  - Geogebra und rauszoomen
  - Idee: „konstanten egal“ und „kleine Eingaben egal“
  - Welche Kompromisse bedeutet das

== O-Notation

- Terme werden als Funktionen interpretiert (mit Variable n).

=== O-Notation intuitiv

- Was denken Informatiker, wenn sie O-Notation lesen?

=== O-Notation als Äquivalenzrelation

- Θ ist Äquivalenzrelation auf Funktionen

=== O-Notation als Ordnungsrelation

- Def: O-Notation (seltener: Landau-Notation / Bachmann-Landau Notation)
- Bemerkung: keine totale Ordnung
- Notation: n³ statt (n ↦ n³)
- viele Beispiele
- Rechenregeln: f + g = O(max(f,g))
- Bemerkung: Verwendung in der Praxis

== Einige konkrete Wachstumsabschätzungen

- [siehe Manfred:20]
- Gaussformel per Induktion oder Bild
- geometrische Reihe
- harmonische Reihe: $H_n ∈ Θ(log n)$
  - Beweis elementar durch Gruppieren der Summanden in Blöcke zwischen zwei Zweierpotenzen.
- Fakultät: $(n/2)^(n/2) ≤ n! ≤ n^n$, also $log(n!) ∈ Θ(n log n)$
  - Bemerkung: Stirling-Formel ohne Beweis.
  - Bemerkung: $log(n!) ∈ Θ(n log n)$ ist die Schranke, die man beim Sortieren wiedersieht.
- Übung: mittlerer Binomialkoeffizient, $2^n/n ≤ binom(n, floor(n/2)) ≤ 2^n$

#slidebreak()
= Algebraische Strukturen

- Motivation: Verallgemeinerungen von Zahlen
  - Welche Eigenschaften haben welche Konsequenzen, was wenn diese Eigenschaften fehlen?
  - Können wir die zahlenähnlichen Strukturen klassifizieren?
  - Beispiele in Python: Stringkonkatenation, Modulorechnung mod 2^32, Floatingpoint Zahlen, max, min.
    - Bemerkung: Floatingpoint-Addition ist nicht assoziativ — ein Beispiel dafür, dass Rechenregeln nicht selbstverständlich sind.
- Laufendes Beispiel: Zahlen modulo n ∈ ℕ.
  - Notation

== Operationen

- Def: Verknüpfung / Operation und Schreibweise
- Def Eigenschaften von Operationen
  - assoziativ
  - kommutativ
  - idempotent
  - distributiv
- Def: neutrales Element
- Def: inverses Element
- Beispiele: Tabelle mit Operationen und ✓ oder ✗
  - eventuell Mengen mit ∪
  - (andere Beispiele, die auch später kommen)

== Monoide und Gruppen

- Def Strukturen als Tabelle
  - Halbgruppe
  - Monoid (sächlich)
  - Gruppe
- Beispiele, etwa:
  - ∪ auf Mengen
  - max / min auf ℕ
  - max / min auf ℕ ∪ {∞}
  - ⋅/+ auf ℕ₀
  - ∘ für Bijektionen auf A:
      - Für jede Funktion $f: A → B$ gilt $f ∘ id_A = f = id_B ∘ f$.
  - Zahlen Modulo n
  - Freies Monoid (Stringkonkatenation)
  - irgendwas mit Symmetrien, z.B. das Tetraeder, S₄
- Satz: Eindeutigkeit neutrales Element
- Satz: Eindeutigkeit inverses Element

== Untergruppen und Nebenklassen

- [siehe Manfreds Notizen, Nr.17]
- Unterstrukturen (Notation "≤" einführen?)
  - Übung: Positiv- und Negativbeispiele unterscheiden.
- Erzeugnis
  - Bemerkung: Wenn X ⊆ S dann ist X Untergruppe wenn $<X> = X$
- Nebenklasse und Modulo
  - Hauptbeispiel: $a + n ℤ$ ergibt die Modulorechnung!
  - Nichtabelsches Beispiel: $S_3$ (Symmetrien des Dreiecks) mit einer Untergruppe der Ordnung 2
  - Ordnung und Orbit
- Satz von Lagrange
  - $a^n = 1 ⇔ "ord"(a) | n$
  - $a^(|G|) = 1$

== Ringe und Körper

- [siehe Manfreds Notizen]
- Definitionen als Tabelle?
  - Ring
  - Körper
- Beispiele
  - Ring: Ganze Zahlen mit ⋅ und + (nicht ℕ)
  - ℤ/nℤ ist Ring.
  - Nullring?
  - Körper: ℚ, ℝ
  - Körper: $ℤ/2ℤ$, also ${0,1}$ mit $1 + 1 = 0$
  - Bemerkung: Polynomringe nur erwähnen, nicht ausführen.

== Morphismen
- Homomorphismen, Isomorphismen
  - viele Beispiele!
    - n ↦ 2n ist Monoid Homomorphismus auf ℕ
    - z ↦ -z auf ℤ (kommt drauf an ob für +,⋅ als Ring oder Gruppe)
- ℤ → ℤₙ ist Ringhomomorphismus
  - Korollar: Wenn am Ende modulo gerechnet wird, darf man jederzeit modulo rechnen ohne das Gesamtergebnis zufälschen.
- Bemerkung: Den Graphisomorphismus kennen wir schon. Auch dort ist ein Isomorphismus eine Bijektion, welche die Struktur erhält.

== Modulo Rechnung

- Teilbarkeit, Rest, Kongruenz modulo n
- Wohldefiniertheit der Addition und Multiplikation.
  - Als Technik? Definition einer Funktion auf Äquivalenzklassen durch Definition auf Repräsentanten.
- Euklidischer Algorithmus
  - Satz: Korrektheit
  - Satz: Laufzeit (hier brauchen wir die O-Notation)
- Lemma von Bezout, Erweiterter Euklidischer Algorithmus
- Satz: $(ℤ/n ℤ)^*= {k + n ℤ | "ggT"(k,n) = 1}$
  - Korollar: $ℤ/(p ℤ)$ ist Körper genau dann, wenn $p$ prim ist.
  - Bemerkung: Inverse modulo $n$ berechnet man mit dem erweiterten Euklidischen Algorithmus.
- Kleiner Satz von Fermat
  - Beweis mit dem Satz von Lagrange: „Element hoch Gruppenordnung ist 1“.
- Chinesischer Restsatz
  - Sicht als Ringisomorphismus: $ℤ/(k ℓ)ℤ ≅ ℤ/k ℤ × ℤ/ℓ ℤ$ für teilerfremde $k, ℓ$
  - Lösen simultaner Kongruenzen als Algorithmus

== Exkurs: Das RSA-Kryptosystem

- [Manfred: VL 20]
- Initialisierung, Verschlüsseln, Entschlüsseln; kleines Zahlenbeispiel
- Korrektheit mit kleinem Fermat und chinesischem Restsatz
- Bemerkung: Warum ist das sicher? Faktorisieren gilt als schwer. Das ist eine Annahme, kein Satz.

#slidebreak()
= Aussagenlogik

#skript[
  Junktoren, Wahrheitstafeln und die de-Morganschen Regeln kennen wir schon aus dem Kapitel „Aussagen und Beweise“. Dort war die Logik Werkzeug: eine Sprache, in der wir mathematische Aussagen präzise hinschreiben. Jetzt machen wir die Logik selbst zum Gegenstand: Formeln sind Objekte, über die wir Sätze beweisen.

  Das ist nicht nur Selbstzweck. Die Aussagenlogik ist die einfachste Beschreibungssprache, in der man Probleme so formulieren kann, dass ein Programm sie löst. SAT-Solver sind in der Praxis erstaunlich gut, und viele Probleme lassen sich als Erfüllbarkeitsproblem schreiben.
]

== Exkurs: Färbungen von Graphen

#definition("Färbung")[
  Sei $G = (V,E)$ ein Graph und $k ∈ ℕ$. Eine *$k$-Färbung* von $G$ ist eine Funktion $c: V → {1,…,k}$. Sie heißt *zulässig*, falls benachbarte Knoten verschiedene Farben haben, also
  $ ∀ {v,w} ∈ E: c(v) ≠ c(w). $
  $G$ heißt *$k$-färbbar*, falls eine zulässige $k$-Färbung existiert.
]

- Beispiele: Landkarten, Klausurtermine ohne Überschneidung, Registerzuweisung im Compiler, Frequenzvergabe im Mobilfunk.
- Beobachtung: $K_n$ braucht $n$ Farben. Ein Graph ist 1-färbbar genau dann, wenn er keine Kanten hat.

#definition("bipartit")[
  Ein Graph $G = (V,E)$ heißt *bipartit*, falls sich $V$ so in zwei disjunkte Mengen $A$ und $B$ mit $V = A ∪ B$ zerlegen lässt, dass jede Kante einen Knoten in $A$ und einen Knoten in $B$ hat, also
  $ E ⊆ {{a,b} | a ∈ A, b ∈ B}. $
]

/*
Das hier kam vom Relationskapitel wo es um bipartite Graphen mit fester Bipartition ging. Hier ist die Abgrenzung zu ungerichteten Graphen, die bipartit sind.
#bemerkung[Der zugrunde liegende ungerichtete Graph][
  Aus einem bipartiten Graphen $(A,B,E)$ mit fester Bipartition erhält man einen ungerichteten Graphen, indem man die Richtung vergisst. Sind $A$ und $B$ disjunkt, so leistet das
  $ (A ∪ B, {{a,b} | (a,b) ∈ E}). $
  Im Allgemeinen muss man die beiden Seiten erst auseinanderhalten und benutzt dafür die disjunkte Vereinigung aus @disjunkteVereinigung:
  $ (A union.dot B, {{(a,1),(b,2)} | (a,b) ∈ E}). $
  Der so entstehende Graph ist bipartit im Sinne der Definition oben.

  Die Rückrichtung ist dagegen nicht eindeutig. Dem ungerichteten Graphen zu @magbild sieht man nicht mehr an, dass „braun“ auf die rechte Seite gehört — an „braun“ liegt ja gar keine Kante. Ein bipartiter Graph lässt im Allgemeinen mehrere Bipartitionen zu; welche gemeint ist, gehört bei der Schreibweise $(A,B,E)$ zu den Daten und bei $(V,E)$ nicht.
]*/


#satz(kurz: [bipartit $⇔$ 2-färbbar])[
  Ein Graph ist genau dann bipartit, wenn er 2-färbbar ist.
]

- Beweis: Die beiden Farbklassen sind gerade die Mengen $A$ und $B$ der Bipartition.

#satz(kurz: [bipartit $⇔$ keine ungeraden Kreise])[
  Ein Graph ist genau dann bipartit, wenn er keinen Kreis ungerader Länge enthält.
]

- Beweis „⇒“: Entlang eines Kreises wechselt die Farbe bei jeder Kante; nach ungerade vielen Schritten ist man bei der anderen Farbe, also nicht am Ausgangsknoten.
- Beweis „⇐“: OE $G$ zusammenhängend (sonst komponentenweise). Wähle $v_0 ∈ V$ und färbe jeden Knoten nach der Parität seines Abstands zu $v_0$. Hätte eine Kante zwei gleichfarbige Enden, so erhielte man einen Kreis ungerader Länge.
- Bemerkung: 2-Färbbarkeit ist also leicht zu prüfen. Für $k ≥ 3$ ist die Frage nach $k$-Färbbarkeit dagegen schwer (NP-vollständig); genau deshalb ist sie ein gutes Beispiel für die Modellierung als SAT-Problem.

== Syntax

- Def: Atomare Formeln (Variablen), Junktoren, Klammern
- Def: Formel, rekursiv definiert
  - Bemerkung: Das ist dieselbe Art rekursiver Definition wie bei den Klammerausdrücken und den Binärbäumen.
- Def: Teilformel; Syntaxbaum einer Formel
  - Bemerkung: Der Syntaxbaum ist ein geordneter gewurzelter Baum.
- Abkürzende Schreibweisen: $and.big$, $or.big$, Klammern weglassen

== Semantik

- Def: Belegung; passende Belegung
- Def: Auswertung einer Formel unter einer Belegung (rekursiv über den Formelaufbau)
- Def: $𝒜 ⊨ F$, Modell
- Def: erfüllbar, unerfüllbar, allgemeingültig (Tautologie)
- Satz: $F$ allgemeingültig $⇔ ¬F$ unerfüllbar
- Wahrheitstafeln
- Def: Semantische Äquivalenz $F ≡ G$
  - Satz: $≡$ ist eine Äquivalenzrelation (Rückbezug auf das Kapitel über Relationen)
  - Satz: $F ≡ G ⇔ ⊨ (F ↔ G)$
- Bemerkung: Jetzt können wir die frühere Unterscheidung von $→$ und $⇒$ nachtragen: $⇒$ war informell „aus $A$ folgt $B$“; präzise gefasst ist das $⊨ (A → B)$.
- Satz: Rechenregeln (Idempotenz, Kommutativität, Assoziativität, Distributivität, de Morgan, Kontraposition, Doppelnegation)
  - Bemerkung: Die de-Morganschen Regeln haben wir früher benutzt; jetzt sind sie ein Satz über Formeln mit Beweis per Wahrheitstafel.
- Satz (Ersetzbarkeitstheorem): $F ≡ G$ $⇒$ $H(F) ≡ H(G)$ für jeden Kontext $H$
  - Beweis durch strukturelle Induktion über den Formelaufbau.
  - Bemerkung: Das ist der Satz, der das „Ersetzen von Teilformeln“ rechtfertigt, das wir vorher schon gemacht haben.

== Normalformen

- Def: Literal, KNF, DNF
- Satz: Zu jeder Formel gibt es äquivalente Formeln in KNF und in DNF
  - Beweis mit de Morgan, Distributivität und Ersetzbarkeitstheorem
- Bemerkung: KNF und DNF lassen sich aus der Wahrheitstafel ablesen
- Bemerkung: Die Umformung kann die Formel exponentiell größer machen

== Modellierung und Erfüllbarkeit

- Idee: Ein Problem in eine Formel übersetzen, sodass die Modelle der Formel genau den Lösungen entsprechen.
- Beispiel: $k$-Färbbarkeit eines Graphen
  - Variablen $x_(v,i)$ für „Knoten $v$ hat Farbe $i$“
  - Klauseln: jeder Knoten hat mindestens eine Farbe; benachbarte Knoten haben nicht dieselbe Farbe
  - Übung: Formulieren Sie zusätzlich „jeder Knoten hat höchstens eine Farbe“. Warum ist das für die Korrektheit nicht nötig?
- Beispiel: Ein kleines Logikrätsel (Ritter und Schurken nach Raymond Smullyan: Ritter sagen stets die Wahrheit, Schurken lügen stets).
  - Übung: 4 Damen auf dem $4 × 4$-Schachbrett
- Bemerkung: SAT-Solver in der Praxis; Bezug zur Einführung in die Informatik (Solver auf der Kommandozeile aufrufen)
- Ausblick: SAT ist NP-vollständig. Was das heißt, ist Inhalt einer späteren Vorlesung.

== Exkurs: 2-SAT

#skript[
  Erfüllbarkeit ist im Allgemeinen schwer. Beschränkt man sich auf Klauseln mit zwei Literalen, wird das Problem leicht — und der Grund dafür sind gerichtete Graphen.
]

- Def: 2-KNF, also KNF mit höchstens zwei Literalen pro Klausel
- Idee: Die Klausel $a ∨ b$ ist äquivalent zu $¬a → b$ und zu $¬b → a$.
- Def: Implikationsgraph
  - Knoten: alle Literale
  - Kanten: für jede Klausel $a ∨ b$ die gerichteten Kanten $¬a → b$ und $¬b → a$
- Satz: Eine 2-KNF ist unerfüllbar genau dann, wenn es eine Variable $x$ gibt, sodass im Implikationsgraphen $x$ von $¬x$ und $¬x$ von $x$ erreichbar ist.
  - Beweis „⇐“: Aus einer erfüllenden Belegung folgt, dass entlang gerichteter Kanten aus wahren Literalen wieder wahre Literale werden. Ein solcher Zyklus erzwingt dann $x$ und $¬x$ gleichzeitig.
  - Beweis „⇒“: nur Skizze (Belegung entlang der Erreichbarkeit konstruieren).
- Bemerkung: Erreichbarkeit in gerichteten Graphen kennen wir aus dem Kapitel über Relationen; die Bedingung besagt, dass $x$ und $¬x$ in derselben starken Zusammenhangskomponente liegen.
- Korollar: 2-Färbbarkeit lässt sich als 2-SAT-Problem schreiben und ist damit leicht entscheidbar. Das passt zum Satz über bipartite Graphen.
- Bemerkung: Für drei Literale pro Klausel (3-SAT) ist keine solche Methode bekannt; 3-SAT ist NP-vollständig.

- Bemerkung: Prädikatenlogik als formales System (Strukturen, Semantik, Normalformen) behandeln wir nicht. Wer Formeln mit $∀$ und $∃$ nur zum Aufschreiben mathematischer Aussagen braucht, hat das Nötige im Kapitel „Aussagen und Beweise“ gesehen.

== Ausblick: Prädikatenlogik

- Begriff eines Modells, Universum usw.
- Manfreds Wunsch umsetzen, dass Studenten folgendes verstehen:
  - $∀x:∃y: x > y$ ist wahr auf ℤ und falsch auf ℕ.
  - $∀x:∃y: P(x,y)$ ist wahr auf $ℤ$ wenn $P$ als $>$ interpretiert wird.
  - $∀x:∃y: P(x,y) ∨ ¬ P(x,y)$ ist wahr in jeder Interpretation.

#slidebreak()
= Graphentheorie

#skript[
  Zum Abschluss beweisen wir zwei klassische Sätze über Graphen. Beide stammen von Euler, und beide sind gute Beispiele dafür, wie man mit den Techniken dieser Vorlesung (Induktion, doppeltes Abzählen, Widerspruch) zu überraschenden Ergebnissen kommt.
]

== Spannbäume und Charakterisierung von Bäumen

- Falls nötig: Definition Teilgraph, vermutlich aber verzichbar:
#definition("Teilgraph", kurz: $G_1 ⊆ G_2$)[
  Seien $G_1 = (V_1,E_1)$ und $G_2 = (V_2,E_2)$ Graphen. Wir schreiben $G_1 ⊆ G_2$ und nennen $G_1$ einen *Teilgraphen* von $G_2$, falls $V_1 ⊆ V_2$ und $E_1 ⊆ E_2$.

  Für $W ⊆ V$ heißt
  $ G[W] := (W, {e ∈ E | e ⊆ W}) $
  der von $W$ *induzierte Teilgraph*.
]

- Beispiel: Bild mit $G$, $G[W]$ und einem Teilgraphen, der nicht induziert ist.


- Def: Spannbaum
- Satz: Jeder zusammenhängende Graph hat einen Spannbaum
  - Beweis: Kanten aus Kreisen entfernen, solange es Kreise gibt.

== Eulerkreise

- Def: Eulerkreis, eulerscher Graph
- Motivation: Königsberger Brückenproblem
- Satz: Ein zusammenhängender Graph ist eulersch genau dann, wenn alle Knoten geraden Grad haben.
  - Beweisrichtung „⇒“ mit dem Handschlag-Argument (Betreten und Verlassen)
  - Beweisrichtung „⇐“ über einen längsten Weg, der keine Kante wiederholt (Extremalprinzip)
- Übung: Eulerpfad (Start und Ziel dürfen verschieden sein); genau 0 oder 2 Knoten ungeraden Grades
- Bemerkung (Ausblick): Der Hamiltonkreis (jeder Knoten genau einmal) sieht ähnlich aus, ist aber schwer (NP-vollständig). Ähnlich aussehende Probleme können sehr unterschiedlich schwer sein.

== Planare Graphen

- Def: Planarer / (seltener: plättbarer) Graph
- Def: Einbettung, ebener Graph
- Def: Facette
- Bemerkung: Einbettung in die Ebene und auf die Kugeloberfläche sind gleichwertig (ohne Beweis, mit Bild).
- Allgemeine Eulerformel: n - m + f = 1 + z (Manfred:22)
  - Beweis: Induktion über $m$ mit Fallunterscheidung, ob die Kante auf einem Kreis liegt.
- Korollar: Eulerformel für zusammenhängende Graphen: $n - m + f = 2$
- Maximale Kantenzahl planarer Graphen ist 3n-6 = O(n) für n ≥ 3
  - Beweis durch doppeltes Abzählen der Kantenseiten
  - Korollar: Es gibt einen Knoten von Grad ≤ 5
  - Korollar: Sechsfarbensatz (Induktion über $n$; Anknüpfung an die Färbungen aus dem Logikkapitel)
  - Bemerkung: Fünf-Farben-Satz und Vierfarbensatz
- Satz: Planar und bipartit mit $n ≥ 3$ $⇒ m ≤ 2n - 4$
- Korollar: K₅ nicht planar, K₃,₃ nicht planar.
- Eulerscher Polyeder Satz
  - Tabelle von Knoten, Kanten, Facettenzahl mit den platonischen Körpern und einem Fußball
  - Beispiel mit Ikosaeder durchrechnen: W20, Kanten sind 20⋅5 / 2, Knoten sind ...
- Satz: Kuratowski (subtil anders als Wagner), ohne Beweis
  - Animation: Petersen-Graph enthält eine Unterteilung von K₃,₃: https://de.wikipedia.org/wiki/Planarer_Graph#/media/Datei:Kuratowski.gif
- Bemerkung: Dieses Kapitel steht am Ende, damit klar ist, was bei Zeitmangel entfallen kann.



