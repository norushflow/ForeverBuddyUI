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

Beim ersten Login nach Installation dieses Updates erscheint einmalig pro Account ein Willkommensfenster. **One Button Setup** führt `/fbui on` aus. Schließen überspringt den Dialog; der Befehl bleibt jederzeit verfügbar. Im Kampf wird das Fenster erst nach Kampfende angezeigt.

- `/fbui`: Hilfe anzeigen.
- `/fbui on`: eigenes Layout aktivieren, Aktionsleisten 2–4 einschalten und die mitgelieferte Blizzard-Vorlage auswählen.
- `/fbui off`: eigenes Layout deaktivieren; `/fbui reset`: Positionen zurücksetzen.
- `/fbui layoutstatus`: vorhandene und aktive Blizzard-Layouts ohne Reload anzeigen.

Den Blizzard-Bearbeitungsmodus vor `/fbui on` schließen. Das Layout **ForeverBuddyUI** wird bei Bedarf importiert. Ein vorhandenes Layout und eigene Anpassungen bleiben erhalten; der frühere Name **Foreverbuddyui** wird übernommen. Nach erfolgreicher Aktivierung lädt die Oberfläche neu. Beim Login werden keine Spieloptionen geändert. Position und Größe der Aktionsleisten werden über die Blizzard-UI eingestellt.

## Änderungen und Entwicklung

Die [Versionshistorie](CHANGELOG.md) enthält ausschließlich Änderungen am Addon.
Prüfungen, Paketbau und noch offene Spieltests stehen in [Entwicklung und Release](DEVELOPMENT.md).
