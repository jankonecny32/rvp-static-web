# Správa obrázků galerie

## Struktura složek

```
img/rvp/
├── tesarske-prace/          # Tesařské práce
│   ├── thumbs/              # Automaticky generované náhledy
│   └── *.jpg                # Originální fotky
├── stavebni-prace/          # Stavební práce
│   ├── thumbs/
│   └── *.jpg
├── fasadni-panely/          # Fasádní panely
│   ├── thumbs/
│   └── *.jpg
├── pro-vase-projekty/       # Pro Vaše projekty
│   ├── thumbs/
│   └── *.jpg
└── uvod/                    # Obrázky pro úvodní carousel (hardcoded)
```

## Přidání nové fotky do galerie

1. **Vložte obrázek** do příslušné složky kategorie (např. `img/rvp/tesarske-prace/nova_fotka.jpg`)

2. **Vygenerujte náhledy** (zmenšené verze pro rychlé načítání):
   ```powershell
   pwsh scripts/generate-thumbnails.ps1
   ```

3. **Aktualizujte manifest** (seznam obrázků pro galerii):
   ```powershell
   pwsh scripts/generate-gallery-manifest.ps1
   ```

4. **Commitněte změny** – nový obrázek, thumb i aktualizovaný `js/gallery-data.js`

### Automatizace přes GitHub Actions

Pokud pushnete změny do složky `img/rvp/`, GitHub Actions automaticky:
- Vygeneruje náhledy
- Aktualizuje manifest
- Commitne výsledek

Workflow: `.github/workflows/gallery-manifest.yml`

## Jak galerie funguje

- **Mřížka** zobrazuje zmenšené náhledy ze složek `thumbs/` (~80–170 KB)
- **Lightbox** (po kliknutí) zobrazí originál v plné kvalitě
- **Lazy loading** – obrázky se načítají až když k nim uživatel doscrolluje
- **Filtrování** – tlačítka nad galerií filtrují podle kategorie

## Skripty

| Skript | Popis |
|--------|-------|
| `scripts/generate-thumbnails.ps1` | Generuje zmenšené náhledy (800px šířka, kvalita 80%) |
| `scripts/generate-gallery-manifest.ps1` | Generuje `js/gallery-data.js` se seznamem obrázků |

Oba skripty používají pouze nástroje dostupné na každém Windows (System.Drawing, PowerShell).

## Poznámky

- Podporované formáty: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.avif`
- Thumby se přegenerují pouze pokud je originál novější než existující thumb
- Složky `thumbs/` se commitují do repozitáře (aby fungovaly na hostingu)
