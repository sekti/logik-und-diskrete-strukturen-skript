# Logik und Diskrete Strukturen: Vorlesungsskript

Hier entsteht ein Vorlesungsskript für das Wintersemester 2026/2027 in Stuttgart.

## Verwendung

Die aktuelle PDF-Fassung steht in Ilias. Zum Lesen muss hier also nichts gebaut
werden.

Wer das Skript selbst setzen möchte, braucht [Typst](https://typst.app). Im
geklonten Verzeichnis genügt

    typst compile --input kapitel=alle skript.typ

Statt des Skripts entsteht die Projektionsfassung für die Vorlesung mit

    typst compile --input folien=true --input kapitel=alle skript.typ

Ohne `--input` gelten die Werte von `folienModus` und `nurKapitel` am Anfang
von `skript.typ`; die stellt man im Editor ein. Mit `nurKapitel` wird nur ein
Kapitel gesetzt, was beim Schreiben deutlich schneller ist. Verweise in andere
Kapitel erscheinen dann rot.

## Fehler

Über Hinweise auf Fehler, unklare Stellen und fehlende Erklärungen freue ich
mich. Am liebsten als
[Issue](https://github.com/sekti/logik-und-diskrete-strukturen-skript/issues),
das Ilias-Forum tut es aber auch.
