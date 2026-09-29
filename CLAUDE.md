# ElectroNova / Prismado Shop — Neues Theme

## Projektkontext

Dieses Repository dient der Entwicklung eines **neuen Themes für den Prismado-Shop** (Demo-Branding: "ElectroNova"). Es handelt sich um ein bestehendes, produktives Shop-System (Perl/Mason); das neue Theme entsteht schrittweise innerhalb der lebenden Codebasis, nicht als isoliertes Greenfield-Projekt. Das Ziel ist ein vollständiger und typischer Aufbau eines Shop-Themes mit Startseite mit gekachelten Produkten, Produkte-Detailansicht, Kategorienansichten, Checkout, Profilansicht usw.

## Repo-Struktur (Kurzüberblick)

- **Git-Root:** dieses Verzeichnis (`/home/retos/shop-design-609221/`).
- **Document Root / gerenderte Theme-Templates:** `public/` — siehe [`public/CLAUDE.md`](public/CLAUDE.md) für Details zu Mason-Rendering, Verzeichnis-Rollen und welche Ordner beim Theme-Design ignoriert werden können.
- `themes/` enthält u. a. einen früheren, nicht-getrackten Arbeitsordner (`themes/shop-609221/public/`), der von einem externen Build-/Deploy-Prozess geleert wurde. **Nicht** als Quelle verwenden — massgeblich ist `public/`.

## Tech-Stack

- **Backend-Templating:** Perl/Mason (`<%init>`-Blöcke, `<& partial.html, ... &>`-Component-Calls, `%`-Zeilen für Perl-Kontrollfluss, `<% ... %>` für Ausdrücke).
- **Frontend:** Tailwind CSS. Aktuell wird Tailwind auf den Theme-Seiten per Play-CDN (`<script src="https://cdn.tailwindcss.com">`) geladen, nicht über die lokale Build-Pipeline (siehe `public/CLAUDE.md`) — Utility-Klassen wirken damit sofort ohne Build-Schritt.

## Arbeitsweise / Regeln

- **Niemals eigenständig `git commit` / `git add` / `git push` ausführen.** Der Nutzer prüft und vergleicht Änderungen selbst, bevor er einchecken. Änderungen nur vorschlagen bzw. umsetzen, das Einchecken bleibt beim Nutzer.
- Bei Detailfragen zum gerenderten Ergebnis kann eine Seite via `http://localhost/...` abgerufen werden (siehe `public/CLAUDE.md`), meist reicht aber die Analyse der Templates ohne Rendering.

## Architektur-Prinzipien

Möglichst flexible Aufteilung der wichtigsten Template-"Wrapper" und ihrem Partials, damit ohne viel Zusatzaufwand die Webapplikation mit weiteren Seiten erweitert werden kann.

## Technologie-Entscheidungen

Guter Mix aus Performance und Wartbarkeit. Zurückhaltend mit zusätzlichen <style>...</style>-Anweisungen: Stattdessen nach Möglichkeit Tailwind Kernfunktionen verwenden. Generell lieber HTML statt weitere JavaScript-Programmierung, sollte ein passender HTML-Standard zur Verfügung stehen. Falls der Einsatz externer JavaScript-Bibliotheken Sinn macht, bitte darauf hinweisen und diese eher final einbinden anstatt auf die CDn-Quelle zu verlinken

## Design-Philosophie

Modernes, professionelles Design. Texte müssen gut lesbar sein. Responsiv für Smartphones ist sehr wichtig, aber auch eine optimale Darstellung auf grossen PC-Bildschirmen mit 4K (Ultra HD). Die Zeilen in den HTML-Templates sollen nach Möglichkeit nicht über 120 Zeichen lang werden: Dann auf neue Zeile umbrechen und ggf. einrücken - je nach Hierarchie-Tiefe eines <div>'s. Wichtig: Die Bestehende Kosmetik bei einer Anpassung *nicht* ändern: Wenn eine längere CSS-Anweisung bereits umgebrochen und eingrückt ist, diese nicht auf eine Zeile zurücknehmen.
