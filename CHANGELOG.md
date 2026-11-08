# Changelog

## 1.0.10

- Setupfenster erscheint auf jedem neuen Charakter und nach jedem Versionsupdate erneut und lässt sich über `/fbui on` öffnen.
- „One Button Setup“ warnt vor dem Überschreiben und ersetzt das Layout **ForeverBuddyUI** durch die mitgelieferte Vorlage.
- Geschützten Reload aus der verzögerten Setupprüfung entfernt; nach erfolgreicher Einrichtung wird zum manuellen `/reload` aufgefordert.
- Tatsächliche Layoutauswahl wird bestätigt; Kampf und fehlgeschlagene Auswahl werden abgefangen.
- Icon in der Addonübersicht im spielgeeigneten TGA-Format ergänzt.
- Korrigierte Forever-Vorlage mit verankerter Haupt- und Zusatzleiste ergänzt.

## 1.0.9

- Eigene Spieler-Zauberleiste mit 296 × 22 Pixeln wieder aktiviert und um 6 Pixel abgesenkt.
- Native Spieler-Zauberleiste bleibt auch bei Zauberstart und Animationen ausgeblendet.
- Klassenressourcen beginnen 8 Pixel innerhalb der linken Spielerrahmenkante.

## 1.0.8

- Layoutimport und Auswahl verwenden die Layoutnummern des Blizzard-Menüs.
- Der bisherige Layoutname wird ohne erneuten Import übernommen.
- `/fbui layoutstatus` zeigt den Layoutstatus ohne Reload.

## 1.0.7

- Abgerundete Einheitentafeln sowie Ziel-, Fokus- und Boss-Zauberleisten hinzugefügt.
- Dunkle Aktionsknopf-Ränder, schwarzer Footer und Aktivierung der Leisten 2–4 über `/fbui on` hinzugefügt.
- Native Gruppenrahmen behalten ihre Blizzard-Hierarchie; Bearbeitungsmodus-Hooks werden addonintern verwaltet.
- Eigene und native Spieler-Zauberleiste ausgeblendet; Gruppenpositionen bleiben erhalten.

## 1.0.6

- Eigene Minimap-, Tracking- und Chat-Anpassungen entfernt.
- Erfahrungs- und Rufleisten bleiben nativ.

## 1.0.5

- Eigene Anordnung von Aktions-, Formen-, Haltungs- und Begleiterleisten entfernt.
- Automatische Leisten- und Cooldown-Einstellungsänderungen entfernt.
- Spieler-Zauberleiste verwendet einen unabhängigen Layoutanker.

## 1.0.4

- Aktionsleisten nach Zielwechseln verzögert neu angeordnet; im Kampf ausgesetzt.

## 1.0.3

- Eigener Addonname, eigene gespeicherte Einstellungen und `/fbui` eingeführt.

## 1.0.2

- Forever-Variante für Interface 16001 eingeführt.
- Fehlende oder nicht öffentliche Spezialisierungswerte werden abgefangen.

## 1.0.1

- Formen-, Haltungs- und Begleiterbuttons an Größe und Skalierung von Aktionsleiste 4 angepasst.
