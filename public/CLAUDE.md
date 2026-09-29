# Document Root — Mason-Templates

Siehe auch die übergeordnete [`CLAUDE.md`](../CLAUDE.md) für den Projektkontext.

## Rendering

Alle `.html`-Dateien hier werden serverseitig via **Perl/Mason** gerendert (nicht statisch). Typischer Aufbau einer Seite:

```
<%init>
  ... Perl-Logik, Objekt-Instanzierung, DB-Zugriffe ...
</%init>
<!DOCTYPE html>
...
<& partials/xyz.html, var => $wert &>   <!-- Component-Call mit Parametern -->
...
%  if (...) {                           <!-- Perl-Kontrollfluss (Zeilen mit führendem %) -->
     <p><% $ausdruck %></p>             <!-- Ausdruck-Interpolation -->
%  }
```

Bei Bedarf kann eine Seite auch live über `http://localhost/...` abgerufen werden, um das tatsächlich gerenderte Resultat zu prüfen (z. B. um komplexe Perl-Logik oder das Zusammenspiel mehrerer Partials zu verifizieren). Das ist in den meisten Fällen nicht nötig — reine Template-Analyse liefert normalerweise sehr gute Resultate — aber in Härtefällen war es in der Vergangenheit sehr hilfreich.

## Tailwind-Hinweis

Die Theme-Seiten laden Tailwind aktuell per Play-CDN (`<script src="https://cdn.tailwindcss.com">`), **nicht** über die lokale Build-Pipeline (`tailwind.config.js` / `src/input.css` → `dist/output.css` via `_update_tailwind.sh`). Utility-Klassen im HTML wirken damit sofort ohne Build-Schritt. Diese Pipeline scheint aktuell nicht in die Theme-Seiten eingebunden — falls das relevant wird, vorher abklären statt anzunehmen, dass ein Build nötig ist.

## Relevante Verzeichnisse für die Theme-Arbeit

- **Top-Level `*.html`** (z. B. `index.html`, `product.html`) — Seiten-Templates des neuen Themes.
- **`partials/`** — wiederverwendbare Theme-Bausteine (Header, Navigation, Produktkarten, Spezifikations-Tabelle etc.).
- **`assets/`, `produkte/`** — Bilder.
- **`stylesheets/`** — CSS aus einer früheren Theme-Generation; Status/Nutzung unklar, vor Verwendung prüfen.

## Zu ignorierende Verzeichnisse (Design-Arbeit)

Diese Ordner gehören **nicht** zum neuen Theme und sollen bei Design-Arbeiten vollständig ignoriert werden:

- **`DataTables-1.9.1/`** — alte Drittanbieter-Bibliothek.
- **`adx-26/`** — unabhängiger Bereich (Admin/Dev-Tools), nicht Teil des Shop-Themes.
- **`node_modules/`** — npm-Abhängigkeiten der Tailwind-Build-Pipeline.

### Weitere Kandidaten

- **`_includes/`** — sehr umfangreich (>400 Dateien): Admin-Dashboards, Bestell-/Zahlungsabwicklung, Newsletter etc. des bestehenden Systems.
- **`custom/algonetic/`** — Mail-Templates, Cronjobs (`jobs/`), PDF-Templates, ältere Layout-Varianten.
- **`lib/`** — jQuery/Bootstrap (Altlasten aus vorherigem Theme).
- **`_foo/`** — scheint ein Sandbox-/Testkopie-Verzeichnis zu sein (spiegelt `partials/`, `parts/`, `index.html`).
