# Foreverbuddyui 1.0.10

<p align="center"><img src="branding/icon-400.png" alt="Foreverbuddyui" width="160" height="160"></p>

Eine reduzierte Spieloberfläche mit abgerundeten Einheitentafeln, eigenen Zauberleisten, Klassenressourcen und einer dunklen Fußleiste.

**Client:** WoW Forever · **Interface:** 16001 · **Eigenständig:** keine zusätzlichen Addons erforderlich.

## Funktionen

- Eigene Spieler-, Ziel-, Fokus-, Gruppen- und Raidrahmen.
- Abgerundete Zauberleisten und passend ausgerichtete Klassenressourcen.
- Schwarze Fußleiste und dunkle Aktionsknopf-Ränder.
- Native Minimap, Tracking, Chat sowie Erfahrungs- und Rufleisten.

## Installation

Das Installations-ZIP unter [Releases](https://github.com/norushflow/Foreverbuddyui/releases) herunterladen und den enthaltenen Ordner `Foreverbuddyui` in `Interface/AddOns/` des passenden Spielclients entpacken. Die Datei `Foreverbuddyui.toc` muss direkt in diesem Ordner liegen. Anschließend im Spiel aktivieren und `/reload` ausführen.

Für WowUp die [Repository-Adresse](https://github.com/norushflow/Foreverbuddyui) mit Zugriff auf dieses private Repository importieren und den passenden Spielclient wählen.

## Bedienung

Auf jedem neuen Charakter und nach jedem Versionsupdate erscheint beim nächsten Login einmal pro Charakter das Setupfenster. Schließen überspringt die Einrichtung für diese Version. Im Kampf wartet das Fenster bis zum Kampfende; ein deaktiviertes UI öffnet es nur auf ausdrücklichen Aufruf.

**Vorsicht: Layout wird überschrieben!** Mit **One Button Setup** wird **ForeverBuddyUI** durch die mitgelieferte Vorlage ersetzt und ausgewählt. Eigene Änderungen an diesem Layout gehen verloren. Andere Layouts bleiben erhalten. Der Login und das bloße Öffnen des Fensters verändern keine Layoutdaten.

- `/fbui on`: Setupfenster mit Überschreibwarnung öffnen.
- `/fbui off`: eigenes UI deaktivieren; `/fbui reset`: Positionen zurücksetzen.
- `/fbui layoutstatus`: vorhandene und aktive Blizzard-Layouts anzeigen.
- `/fbui`: Hilfe anzeigen.

Vor dem Setup den Blizzard-Bearbeitungsmodus schließen. Nach erfolgreicher Einrichtung **`/reload` selbst im Chat eingeben**. Das Addon löst aus der verzögerten Prüfung keinen geschützten Reload aus.

## Änderungen und Entwicklung

Die [Versionshistorie](CHANGELOG.md) enthält ausschließlich Änderungen am Addon.
Prüfungen, Paketbau und noch offene Spieltests stehen in [Entwicklung und Release](DEVELOPMENT.md).

Nach diesem Update WoW vollständig neu starten, damit das Icon in der Addonübersicht neu eingelesen wird.

Nach Installation dieses Updates WoW vollständig neu starten, damit die neue charakterbezogene Speicherung geladen wird. Der bisherige accountweite Setupstatus wird nicht übernommen; deshalb erscheint das Fenster auch auf bestehenden Charakteren einmal erneut.
