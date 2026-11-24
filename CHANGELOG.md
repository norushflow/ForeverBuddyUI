# Changelog

## 1.0.24

- Use `/fbui groupframes off` to switch to Blizzard party and raid frames or another frame addon. Use `/fbui groupframes on` to restore ForeverBuddyUI frames. The setting applies to all characters and reloads the UI when changed.
- Thanks to elderthorn for the suggestion!

## 1.0.23

- Show combo points above the current enemy nameplate and keep them visible on the player frame.
- Use round nameplate points and Blizzard's rogue class color for rogue combo points.
- Move the native FPS counter to the right of the micro menu.

## 1.0.22

- Detect the game resolution and select the supplied layout for 2560 × 1440 and 1920 × 1080 during setup.
- Offer a reload button after layout activation and report unexpected import errors to the client error handler.
- Align both target aura rows.

## 1.0.21

- Give unit frames and the setup window borderless surfaces with soft edges, and match the raid preview to the live raid frames.
- Show current and maximum resources beneath health on individual unit frames. Keep target of target focused on health with a thin resource strip.
- Use class colors on the target frame for player characters and align target buffs with the name inset.

## 1.0.20

- Reduce redundant health and power queries during unit updates.
- Reuse quest-log fallback results for matching nameplates within each update while keeping individual native tooltips current.
- Reduce group debuff countdown and stack text size while retaining debuff icon dimensions.
- Add Wago project metadata and strengthen release package validation.

## 1.0.19

- Redesign unit frames with the addon’s dark inset and bronze frame style.
- Show matching quest progress beside its world nameplate.

## 1.0.18

- Update the included ForeverBuddyUI Edit Mode layout.
- Keep party frames in sync when players join or leave during combat, and apply deferred layout updates when combat ends.

## 1.0.17

- Anchor quest dialogs and NPC quest lists when they open to prevent a visible jump.

## 1.0.16

- Match the AzerothBuddyUI design across the setup dialog, unit frames, raid preview, footer, equipment overlays, and tooltip frames.
- Use the native WoW nameplate texture for custom health, power, and cast bars, and tint the existing action button borders bronze.
- Keep native controls and per-character action bar and click-binding storage intact.

## 1.0.15

- Update class resource bar geometry only when the segment count changes.
- Read the game clock once per tick and reuse action storage validation data.
- Streamline local checks and make release ZIPs reproducible.

## 1.0.14

- Added German and English localization, with English as the fallback.
- Action bars and native click bindings are saved per character regardless of class, role, specialization, talents or level.
- The first login saves the current layout. Later logins restore it and changes are saved in response to game events.
- Combat, temporary bars and an occupied cursor defer restoration. Rejected writes are checked and previous data is retained. Use `/fbui restore` to retry.

## 1.0.13

- CurseForge-Projekt-ID und Paketkonfiguration ergänzt.

## 1.0.12

- Anzeigenamen in der Addonübersicht und den Fenstern auf **ForeverBuddyUI** vereinheitlicht.

## 1.0.11

- Autorenangabe in der Addonübersicht auf **norushflow** geändert.

## 1.0.10

- Setupfenster zeigt die vorgesehene Layout-Auflösung von 3440 × 1440 Pixeln an.
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
