# Entwicklung und Release

Arbeitsstand ist dieses Git-Repository. Projektregeln: [AGENTS.md](AGENTS.md).
Benötigt werden LuaJIT, zip und unzip.

- `./tools/check.sh`: TOC-Dateipfade, Lua-Syntax und Funktionstests prüfen.
- `./tools/package.sh`: geprüftes Installations-ZIP unter `dist/` erstellen. Bestehende gleichnamige Pakete werden nicht überschrieben.
- Version in TOC, README und internen Versionsmeldungen abgleichen.
- Geprüften Stand nach `main` übertragen. Ein Tag passend zur TOC (`v1.0.11`) startet die Veröffentlichung für WowUp.
- Vor dem Tag `RELEASE_NOTES.md` ersetzen. Erste Zeile `# vX.Y.Z` passend zur TOC-Version, danach englische Markdown-Stichpunkte nur für dieses Release. Die Historie bleibt in `CHANGELOG.md`.
- GitHub verwendet `RELEASE_NOTES.md` direkt. Für CurseForge denselben Tag nach erfolgreichem GitHub-Workflow mit dem Packager und der eingecheckten `.pkgmeta` veröffentlichen. Bei einem manuellen ZIP-Upload den Inhalt derselben Datei als Markdown einfügen.

Das ZIP enthält Laufzeitdateien, Medien und aktuelle Herkunftshinweise. Entwicklerdokumentation, Tests und Workflows werden nicht installiert.

## Spielprüfung vor Veröffentlichung

Lokale Tests ersetzen keine Prüfung im Zielclient. Login, gespeicherte Einstellungen, Bedienung, Kampf, Gruppen/Raid und mögliche Taint-Meldungen prüfen.

Vorbereitung am 08.11.2026: lokale Syntax-, TOC- und Funktionstests erfolgreich. Neue Willkommensfenster der UI-Addons benötigen noch eine Sicht- und Bedienprüfung im jeweiligen Client.

Korrektur 08.11.2026: Setup bestätigt die Layoutauswahl außerhalb des Import-Aufrufs und bricht bei Kampf, geöffneter Bearbeitung oder fehlender Bestätigung ohne Reload ab. Regressionsprüfungen decken veraltete Managerdaten, verzögerte Auswahl und Abbruch ab. Die TOC verweist ausdrücklich auf eine mitgelieferte RGBA-TGA-Datei. Erneuter Clienttest erforderlich.

Schnittstellenabgleich: [Blizzard EditModeManager](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_EditMode/Shared/EditModeManager.lua), ImportLayout/MakeNewLayout und SetActiveLayout.

Setupkorrektur: Einmalige Anzeige anhand `welcomeVersion` und `UI.VERSION`; Versionsstand mit TOC abgleichen. Nach ausdrücklichem Setupklick wird ausschließlich `ForeverBuddyUI` per `C_EditMode.SaveLayouts` überschrieben. Der Abschluss führt keinen Reload aus, sondern fordert zur manuellen Eingabe von `/reload` auf. Testfälle: neues Update, gleiche Version, alter Boolean, explizites Öffnen, Überschreiben, Schutz anderer Layouts und kein Reload aus dem Abschluss.

Setupstatus wird in `ForeverbuddyuiCharDB.welcomeVersion` als SavedVariablesPerCharacter gespeichert. Alte accountweite Bestätigungen bleiben ohne Einfluss, damit neue Charaktere nicht übersprungen werden. Tests simulieren zwei Charaktere mit gemeinsamem Accountzustand, Rückkehr und Versionswechsel.

Releasefreigabe am 08.11.2026: Benutzer bestätigt, dass Setup und Korrekturen im Spiel funktionieren. Auflösungshinweis 3440 × 1440 im Setup und auf der GitHub-Seite ergänzt; Dialoghöhe für den zusätzlichen Text angepasst.
