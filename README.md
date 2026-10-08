# Logik und Diskrete Strukturen: Vorlesungsskript

Hier entsteht ein Vorlesungsskript für das Wintersemester 2026/2027 in Stuttgart.

## Verwendung

Die aktuelle PDF-Fassung steht in Ilias. Zum Lesen muss hier also nichts gebaut
werden.

Wer das Skript selbst setzen möchte, braucht [Typst](https://typst.app). Im
geklonten Verzeichnis genügt

    typst compile skript.typ

Statt des Skripts entsteht die Projektionsfassung für die Vorlesung mit

    typst compile --input folien=true skript.typ

Ohne `--input` gilt der Wert von `folienModus` aus der ersten Zeile von
`skript.typ`; den stellt man im Editor ein.

## Fehler

Über Hinweise auf Fehler, unklare Stellen und fehlende Erklärungen freue ich
mich. Am liebsten als
[Issue](https://github.com/sekti/logik-und-diskrete-strukturen-skript/issues),
das Ilias-Forum tut es aber auch.
