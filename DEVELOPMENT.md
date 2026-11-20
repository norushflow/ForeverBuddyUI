# Entwicklung und Release

- Entwicklung: `./tools/check.sh --quick`, gezielt auch `--quick -- PFAD …`. `--full` ergänzt Paket- und Versionsdaten; `--debug` nur bei Bedarf.
- Lokales ZIP bei Bedarf: `./tools/release.sh --output-dir VERZEICHNIS` (enthält den Volltest; benötigt Bash, LuaJIT, zip/unzip). Keine zusätzliche Vollprüfung vor dem Bau. Persönliche Expressway-Dateien bleiben lokal.
- Spieltest bei Codeänderungen: Login, gespeicherte Einstellungen und betroffene Funktionen; bei UI auch Kampf/Taint. Bereits bestätigte Tests desselben Codes übernehmen. Nach Installation `/reload`:

```bash
cd /mnt/UserData/Dokumente/ChatGPT/wow_addon && ./tools/spieltest.sh Foreverbuddyui
```

## Release

Nur auf ausdrücklichen Auftrag; fehlgeschlagene Prüfungen sperren die Veröffentlichung.

1. Remote prüfen; Version in TOC/README setzen. Englisches `## X.Y.Z` in `CHANGELOG.md`, gleicher Text unter `# vX.Y.Z` in `RELEASE_NOTES.md`. Änderungen committen und auf `main` pushen.
2. `gh workflow run wowup-release.yml --ref main --repo norushflow/ForeverBuddyUI`. Der Workflow prüft, baut, verifiziert das ZIP und veröffentlicht samt Tag. Erfolg, richtigen Commit und ZIP einmal bestätigen; kein paralleler lokaler Release-Bau.
3. CurseForge: Webhook-Datei einschließlich ausstehender Dateien prüfen. Nur wenn sie fehlt und kein Upload läuft, dasselbe GitHub-ZIP mit Markdown-Release-Notizen, passender Spielversion und Kanal **Release** hochladen. **In Prüfung** melden, ohne auf Moderation zu warten.
4. Wago: Projekt und fehlende Version prüfen, dann einmal `wago-release.yml` mit `tag=<Tag>`, `dry_run=false`, `confirm_new=<Tag>` starten. GitHub, CurseForge und Wago getrennt kurz melden.

Wago: Secret `WAGO_API_TOKEN`, Variable `WAGO_PROJECT_ID` passend zur TOC. Trockenlauf bleibt Standard, ist bei unveränderter, geprüfter Einrichtung nicht zusätzlich nötig. Unklarer Upload: erst Plattform prüfen; `recover_status_id` nur bei nachweislich fehlender Version. Niemals blind wiederholen.
