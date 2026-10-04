/*
  Weggelassen:
  - Noethersche Induktion
  - Wohlordnung
  - Wohldefiniertheit der Ackermannfunktion
  - Ideale
  - Characterisierung von Normalteilern
  - Definition: lim sup, lim inf
  - Satz der lim sup, lim inf, lim mit O-Notation verknüpft
  - Freie Gruppe
*/


/*
  Notizen nach dem Gespräch mit Manfred (umgesetzt):
  - Sachen mit komplexen Zahlen weglassen
  - Sachen mit Polynomen weglassen
  - Induktion vorziehen
  - Logik später machen
  - es gab eine Evaluation, aber die wird unter Verschluss gehalten
*/

/*
  Diskussion mit Georg (umgesetzt): Graphen als laufendes Beispiel
  - Graphen direkt nach Mengen, noch vor Aussagen und Beweisen
  - Induktion: Blätter und Kantenzahl von Bäumen
  - Relation auf A: Kantenrelation eines gerichteten Graphen
  - Relation A × B: bipartiter Graph
  - Äquivalenzrelation: Erreichbarkeit, Zusammenhangskomponenten, Graphisomorphie
  - Ordnungsrelation: Erreichbarkeit in DAGs
  - Funktionen: Kantengewichte, gewurzelte Bäume
  - Zählen: Kantenzahl, Catalanzahlen (Binärbäume, Klammerausdrücke)
  - Aussagenlogik: Färbbarkeit als SAT-Problem, 2-SAT über Implikationsgraphen
  Abweichungen vom Gespräch:
  - O-Notation bleibt vor der Algebra (Laufzeit des Euklidischen Algorithmus,
    Vorbereitung für Algorithmen und Datenstrukturen). Stattdessen steht die
    Graphentheorie (Eulerkreise, planare Graphen) am Ende und kann entfallen.
  - Abzählbarkeit bleibt in gekürzter Form (Diagonalargument, Ausblick auf
    Unentscheidbarkeit); Cantor-Schröder-Bernstein fällt weg.
  - Statt Sudoku ein kleineres Logikrätsel (Ritter und Schurken).
*/

/*
  Weggelassen (Umstellung 2026, „mehr Graphen, weniger Logik“):
  - Cantor-Schröder-Bernstein (samt Beweis von Julius Kőnig) und Gleichmächtigkeit von ℕ und ℚ
  - Mächtigkeit als Äquivalenzrelation auf Klassen, Kardinalzahlen
  - Auswahlaxiom-Bemerkung (Injektion in einer Richtung existiert immer)
  - Kontinuumshypothese
  - Hilbert-Bus und Hilbert-Flugzeug als eigene Beispiele (Hilbert-Hotel bleibt)
  - Allgemeines Prinzip von Inklusion und Exklusion samt Beweis und Bonferroni-Schranken
    (der Fall zweier Mengen bleibt)
  - Bälle und Fächer (wird Übungsaufgabe), Twelve-Fold Way
  - Prädikatenlogik als formales System: Syntax, Strukturen, Semantik,
    Skolemisierung, Herbrand-Theorie, Algorithmus von Gilmore
  - Kompaktheitssatz (Endlichkeitssatz) der Aussagenlogik
  - Normalteiler, Quotientengruppen, Ideale, Quotientenringe
  - Exkurs „Varianten von Graphen“ (Multigraph, Schleifen, Hypergraph → Übungsaufgabe)
*/

/*
  Weggelassen:
  - Definition |X| < |Y| und |X| ≤ |Y|
  - $f$ surj $⇔ ∃g: f ∘ g$ bij
  - $f$ inj  $⇔ ∃g: g ∘ f$ bij
  - $f$ bij  $⇔ ∃g: g ∘ f = id ∧ f ∘ g = id$ bij
  - Korollar: ∃inj ⇔ ∃surj in Gegenrichtung
*/

- $M_7 := {3·i+5·j | i ∈ ℕ₀, j ∈ ℕ₀}$
  - $M_8 := {1,2,4,7}^C$
  - Es gilt $M_7 = M_8$. Das ist nicht offensichtlich. Das Einsetzen von kleinen Werten für $i$ und $j$ ergibt:
    #let rows = 4
    #let cols = 4
    #table(
      columns: cols + 1,
      stroke: none,
      align: right,
      table.hline(y: 1),
      table.vline(x: 1),
      [*i \\ j*],
      ..range(cols).map(j => [*#j*]),
      ..range(rows)
        .map(i => (
          [*#i*],
          ..range(cols).map(j => [#(3 * i + 5 * j)]),
        ))
        .flatten(),
    )
    Man sieht, dass die Zahlen 1,2,4,7 nicht auftauchen. Weil für $i = 3$ und $j = 3$ bereits größere Zahlen herauskommen, können 1,2,4,7 auch „weiter draußen“ nicht mehr auftauchen.

    Weil die Zahlen 8,9,10 alle auftauchen und mit jeder Zahl auch die um drei größere Zahl auftaucht (indem man $i$ um eins erhöht), können alle Zahlen ab 8 gebildet werden.

// Ein Bisschen zu lang für das Induktionskapitel, lenkt ab. Daher rausgeflogen.
#korollar[
  Jeder zusammenhängende Graph mit $n$ Knoten hat mindestens $n-1$ Kanten.
]

#beweis[
  Sei $G$ ein zusammenhängender Graph mit $n$ Knoten. Wir entfernen Kanten nach folgender Regel: Solange der Graph einen Kreis enthält, entfernen wir eine Kante dieses Kreises. Weil die Kantenzahl dabei in jedem Schritt um 1 sinkt, bricht das Verfahren nach endlich vielen Schritten ab.

  Der Zusammenhang bleibt in jedem Schritt erhalten. Sei dazu ${u,w}$ die entfernte Kante eines Kreises. Der Rest des Kreises ist ein Pfad von $u$ nach $w$, der diese Kante nicht benutzt. Sind nun $x$ und $y$ zwei Knoten, so gibt es vor dem Schritt einen Pfad von $x$ nach $y$; ersetzt man darin die Kante ${u,w}$ (falls sie vorkommt) durch diesen Umweg, so entsteht ein Weg von $x$ nach $y$ ohne die entfernte Kante. Nach @wegPfad gibt es dann auch einen Pfad von $x$ nach $y$.

  Am Ende ist der Graph zusammenhängend und azyklisch, also ein Baum mit $n$ Knoten, und hat nach @baumKanten genau $n-1$ Kanten. Da wir nur Kanten entfernt haben, hatte $G$ mindestens $n-1$ Kanten.
]

// Das ist irgendwie cool, aber nicht so lehrreich wie ich dachte:
#uebung[
  Finden den Fehler in folgendem Induktions"beweis". Wir zeigen, dass für jedes $n ∈ ℕ$: Hat man $n$ Äpfel, so sind alle gleich schwer.
  / IA: Für $n = 1$ ist nichts zu zeigen. ✓
  / IV: Für ein $n > 1$ gelte: Hat man $n-1$ Äpfel, so sind alle gleich schwer.
  / IS: Wir betrachten nun eine Menge von $n$ Äpfel mit Gewichten $w₁,…,w_n$. Nach IV sind die ersten $n-1$ Äpfel gleich schwer. Ebenfalls nach IV sind die letzten $n-1$ jeweils gleich schwer. Es gilt also:
    $
      w₁ = & w₂ = w₃ = … w_(n-2) = w_(n-1) \
           & w₂ = w₃ = … w_(n-2) = w_(n-1) = w_n
    $
    Somit haben alle $n$ Äpfel das Gewichte $w₂$, sind also gleich schwer.
]

#loesung[
  Der Induktionsschritt schlägt für $n = 2$ fehl, weil dann $w_2$ nicht in beiden Gleichungen vorkommt.
]

#uebung[Haufenparadox][
  Finden Sie den Fehler in folgendem Induktions"beweis" …
]


#uebung[
  Sei $k ∈ K$ und sei $p$ ein Präfix#footnote[Ein *Präfix* von $k$ ist ein Anfangsstück von $k$, also eine Zeichenfolge $p$, für die es eine Zeichenfolge $q$ mit $k = p q$ gibt. Sowohl das leere Wort als auch $k$ selbst sind Präfixe von $k$.] von $k$. Seien $o$ und $s$ die Anzahlen öffnender und schließender Klammern in $p$. Dann gilt $o ≥ s$.
]

#loesung[
  Wir führen strukturelle Induktion über den Aufbau von $k$.
  / IA (Regel 1): Ist $k$ das leere Wort, so ist auch $p$ leer. Dann gilt $o = s = 0$.
  / IS (Regel 2): Sei $k = u v$ mit $u,v ∈ K$ und sei $p$ ein Präfix von $k$. Ist $p$ ein Präfix von Zwei Fälle sind möglich.
    - Ist $p$ ein Präfix von $u$, so gilt $o(p) ≥ s(p)$ nach Induktionsvoraussetzung für $u$.
    - Andernfalls hat $p$ die Form $p = u q$ für ein Präfix $q$ von $v$. Dann gilt $o(p) = o(u) + o(q)$ und $s(p) = s(u) + s(q)$. Nach dem Satz ist $o(u) = s(u)$, nach Induktionsvoraussetzung für $v$ ist $o(q) ≥ s(q)$. Zusammen folgt $o(p) ≥ s(p)$.
  / IS (Regel 3): Sei $k = (u)$ mit $u ∈ K$ und sei $p$ ein Präfix von $k$. Drei Fälle sind möglich.
    - Ist $p$ das leere Wort, so gilt $o(p) = 0 = s(p)$.
    - Besteht $p$ aus der öffnenden Klammer gefolgt von einem Präfix $q$ von $u$, so gilt $o(p) = 1 + o(q)$ und $s(p) = s(q)$. Nach Induktionsvoraussetzung für $u$ ist $o(q) ≥ s(q)$ und damit $o(p) ≥ 1 + s(q) > s(p)$.
    - Ist $p = k$, so gilt $o(p) = 1 + o(u)$ und $s(p) = 1 + s(u)$. Nach dem Satz ist $o(u) = s(u)$, also $o(p) = s(p)$.
]



