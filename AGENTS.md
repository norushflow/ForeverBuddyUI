# Foreverbuddyui

Forever. Einstieg in `Core.lua`, `Layout.lua`, `Units.lua` oder `Progress.lua`. Aktionsleisten, Minimap, Tracking, Chat und Fortschritt nativ lassen. `ActionStorage*.lua` sichert Leisten und Klickzauber je Charakter. `/fbui` zeigt die Hilfe.

- Mit Git-Status, TOC und relevantem Diff beginnen. Bestehende Änderungen erhalten.
- Gezielt mit `./tools/check.sh --quick` prüfen; der ZIP-Bau führt den Volltest aus. Gemeinsame Regeln im übergeordneten `AGENTS.md` beachten.
- SavedVariables, Migrationen, Slash-Befehle und Addon-Unabhängigkeit erhalten. Secret Values sowie geschützte und verbotene Frames wie bisher absichern. Neue dauerhafte Ticker, automatische CVar-Änderungen und Abhängigkeiten brauchen einen Auftrag.
- Release-Ablauf in [DEVELOPMENT.md](DEVELOPMENT.md) nur bei einem Release-Auftrag lesen; vorhandene Workflows nutzen, Prüfungen nicht doppeln.
- Nach jedem abgeschlossenen Testlauf die Antwort mit dem kopierbaren Fedora-Befehl abschließen. Für den Spieltest den Befehl aus `DEVELOPMENT.md` auch nach erfolgreicher Installation angeben.

Das Setup aktualisiert nach sichtbarer Bestätigung ausschließlich das Layout `ForeverBuddyUI`. `EditMode.Exit` verwenden und die Layoutarbeit außerhalb von Blizzards Reset ausführen. Nach bestätigter Layoutaktivierung bietet das Setup einen direkten Klick zum Neuladen der UI außerhalb des Kampfes an. Bei abgelehnten Klickbelegungen kann der Benutzer `/fbui restore` erneut ausführen.
