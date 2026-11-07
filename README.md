# Foreverbuddyui 1.0.6 – WoW Forever

## Entwicklung unter Linux

Öffne diesen Repository-Ordner in Codex oder starte hier `opencode`. Die Projektregeln stehen in [AGENTS.md](AGENTS.md).

- Fedora-Pakete bei Bedarf installieren mit `sudo dnf install luajit zip unzip`.
- `./tools/check.sh` prüft TOC-Dateipfade, Lua-Syntax und die vorhandenen Funktionstests.
- `./tools/package.sh` erstellt nach grüner Prüfung ein lokales Installations-ZIP unter `dist/`. Entpacke den darin enthaltenen Addon-Ordner zur Prüfung in den passenden WoW-Client und führe `/reload` aus.

### Release für WowUp

Für einen beauftragten Release die Version in der TOC, im README-Titel und in
vorhandenen Versionsmeldungen abgleichen. Den geprüften Stand auf `main` hochladen
und einen passenden Git-Tag setzen, etwa `git tag v1.2.3` und
`git push origin v1.2.3`. Die GitHub Action **WowUp Release** führt die Tests
aus, baut das Installations-ZIP und veröffentlicht es im privaten Repository.
KI-Anweisungen, Entwicklerdokumentation, Tests und Workflow-Dateien bleiben im Repository.
In WowUp den passenden Spielclient auswählen und die Repository-URL importieren.
Der WowUp-Zugriffstoken benötigt Leserechte für dieses Repository.

Eigenständige WoW-Forever-Variante des UI-Addons (ohne ElvUI und ohne
Laufzeitabhängigkeit zu AzerothBuddy). Zuständig für Blizzard-UI-Anordnung:
Fußleiste, Zauberleisten,
Gruppen-/Unitframes und weitere bereits vorhandene UI-Elemente.

## Native Minimap und Chat – 1.0.6

- Minimap-Modul entfernt: keine eigene Form, Größe, Position, Umrandung oder Gebietsüberschrift; Kalender, Uhr, Tracking, Kompass und Buffposition bleiben nativ.
- Erfahrungs-/Rufleisten werden nicht mehr unter die Minimap verschoben oder umgestaltet.
- Keine Chat-Anpassung an Position, Fenstergröße oder Schrift mehr.
- Entfernung der Aktionsleisten-Anpassungen aus dem begonnenen Stand 1.0.5 abgeschlossen und mitgeprüft; Fußzeile/Uhr und eigene Einheitentafeln bleiben erhalten.
- Nach Installation /reload ausführen. Frühere gespeicherte Blizzard-Einstellungen bei Bedarf in den WoW-Optionen bzw. im Bearbeitungsmodus einstellen.
- Prüfung 07.11.2026: 204 Lua-Dateien syntaktisch gültig; Forever-Funktionstests normal/startup-failure/equipment und TOC-Dateipfade erfolgreich. check.sh insgesamt Exit 1 wegen bestehender ZIP-Abweichungen; Forever-Tests separat ausgeführt. Ingame-Prüfung steht aus.

## Blizzard-Aktionsleisten – 1.0.5

- Alle Anpassungen an Aktions-, Formen-/Haltungs- und Begleiterleisten entfernt: Position, Größe, Skin, ausgeblendete Plätze und Seitenanzeige bleiben nativ.
- Keine Leisten-Hooks, Zielwechsel-Timer oder Leisten-/Cooldown-Einstellungsänderungen mehr. /fbui zeigt die Hilfe.
- Die eigene Spieler-Zauberleiste behält ihre Position über einen unabhängigen Anker.
- Nach Installation /reload ausführen, damit alte Hooks und Laufzeitänderungen verschwinden. Gewünschte Leisten im Blizzard-Bearbeitungsmodus und den WoW-Optionen einstellen; früher gespeicherte Blizzard-Einstellungen werden nicht automatisch zurückgesetzt.
- Neue Regressionstests prüfen, dass native Leisten beim Start und bei Layout-/Ziel-/Kampfereignissen unverändert bleiben. Live-Prüfung offen.

## Zielwechsel – 1.0.4 (historisch, ab 1.0.5 entfernt)

- Nach Zielwechseln werden Position, Größe und Skalierung der drei angeordneten Aktionsleisten einmal im nächsten Frame wiederhergestellt.
- Schnelle Zielwechsel werden zusammengefasst; keine Layoutänderung im Kampf. Nach Kampfende greift die bestehende Layoutkorrektur.
- Regressionstests prüfen verzögerte native Layoutänderungen, schnelle Zielwechsel und Kampfgrenzen. Bestätigung im Forever-Client steht aus.

## Eigener Name – 1.0.3

- Addonordner und TOC heißen Foreverbuddyui; gespeicherte Einstellungen: ForeverbuddyuiDB.
- Eigene globale Frame-Namen und Slash-Befehl /fbui verhindern Namensüberschneidungen.
- Keine automatische Übernahme alter Einstellungen; bisherige Versionen bleiben erhalten.
- Im Forever-Client nur diese UI-Variante aktivieren, da beide dieselben Blizzard-Frames anordnen.

## Forever – 1.0.2

- Ziel laut GetBuildInfo-Screenshot: 1.60.1, Build 70790, Interface 16001.
- Vollständige separate Kopie von 1.0.1; Retail-Version bleibt erhalten.
- Fehlende, fehlerhafte oder nicht öffentliche Spezialisierungswerte werden abgefangen.
- Dies ist eine erste Client-Testversion. Vollständige Forever-API-, Optik- und Kampfkompatibilität ist noch nicht im Spiel bestätigt.
- Vorhandenen Ordner Foreverbuddyui im Zielclient vor Installation sichern.

## Installation und Bedienung

- Ordner `Foreverbuddyui` nach `World of Warcraft/_forever_/Interface/AddOns/`
  kopieren; `.toc` muss direkt in `AddOns/Foreverbuddyui/` liegen.
- In WoW aktivieren und `/reload`. `/fbui` zeigt die Hilfe.
  Aktionsleisten werden ausschließlich über die Blizzard-UI eingestellt.
- `/fbui reset`: Layoutpositionen zurücksetzen;
  `/fbui off` / `/fbui on`: eigenes Layout ausschalten/einschalten.
- Die Layoutpositionen verwaltet das Addon; ein manuelles Verschieben über
  Slash-Befehle ist nicht vorgesehen.

## Minimap und Tracking (historisch, ab 1.0.6 entfernt)

- Quadratische Minimap (240 × 240) oben rechts, Kalender oben rechts.
- **Blizzard-Tracking-Symbol oben links:** Original-Frame und Blizzard-Menü,
  Klick- und Tooltip-Verhalten bleiben erhalten. Größe orientiert sich am Kalender.
- Das Symbol nicht über `hideNative(MinimapCluster.Tracking)` ausblenden;
  keine eigene Tracking-Implementierung in AzerothBuddy anlegen.
- Layout-/Skalierungsänderungen und Kampf-/EditMode-Grenzen beachten.

## Formen-/Haltungs- und Begleiterleiste – 1.0.1 (historisch, ab 1.0.5 entfernt)

- Buttons übernehmen Breite/Höhe einschließlich Skalierung von Leiste 4 (MultiBarRightButton1) statt fester 28 × 28 Punkte.
- Bisherige Anker und zwei Punkte Button-Abstand bleiben erhalten; die Gesamtbreite folgt der Buttonanzahl.
- Native Layoutänderungen von Leiste 4 aktualisieren die Größen mit. Kampf- und Fremdframe-Schutz bleiben bestehen.
- Automatische Tests einschließlich abweichender Referenzskalierung erfolgreich; Optik und EditMode im Client noch prüfen.
- check.sh insgesamt Exit 1 wegen vorhandener abweichender Release-ZIPs; keine Archive verändert.

## Projektstand und Prüfung

- **Aktive Basis:** `Foreverbuddyui-1.0.6/Foreverbuddyui/`.
- **Tests:** `TEMP/Foreverbuddyui-1.0.6/tests/` (außerhalb des Addonordners).
- **Prüfung:** von der Projektwurzel `./tools/check.sh` ausführen.
- Am 01.11.2026 meldete der Benutzer: automatisierte Projektprüfung erfolgreich;
  die Tracking-Korrektur funktionierte im WoW-Client vor dem Versionsneustart.
  Umfangreiche Live-Taint-, Kampf-, Klassen- und Raidtests sind dadurch nicht belegt.
- Am 02.11.2026 wurde die manuelle Verschiebefunktion entfernt; die normale
  Layoutpositionierung bleibt unverändert.
- Ein Release-ZIP für 1.0.0 wurde nicht erstellt.
- Designregeln: [UI-REFERENZEN.md](../../UI-REFERENZEN.md).

## Historie

[README-UI-HISTORIE.md](../../docs/README-UI-HISTORIE.md) enthält die früheren
Versionsabschnitte mit ihrem jeweiligen damaligen Stand. Nicht als aktuelle
Aufgabenliste verwenden.
