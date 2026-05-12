# Správa obrázků galerie

## Struktura složek

```
img/rvp/
├── galerie/                 # Všechny fotky galerie
│   ├── thumbs/              # Automaticky generované náhledy
│   └── *.jpg                # Originální fotky
└── uvod/                    # Obrázky pro úvodní carousel (hardcoded)
```

## Přidání nové fotky do galerie

1. **Vložte obrázek** do složky `img/rvp/galerie/` (např. `img/rvp/galerie/nova_fotka.jpg`)

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

- **Mřížka** zobrazuje zmenšené náhledy ze složky `thumbs/` (~80–170 KB)
- **Lightbox** (po kliknutí) zobrazí originál v plné kvalitě
- **Lazy loading** – obrázky se načítají až když k nim uživatel doscrolluje

## Skripty

| Skript | Popis |
|--------|-------|
| `scripts/generate-thumbnails.ps1` | Generuje zmenšené náhledy (800px šířka, kvalita 80%) |
| `scripts/generate-gallery-manifest.ps1` | Generuje `js/gallery-data.js` se seznamem obrázků |

Oba skripty používají pouze nástroje dostupné na každém Windows (System.Drawing, PowerShell).

## Poznámky

- Podporované formáty: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.avif`
- Thumby se přegenerují pouze pokud je originál novější než existující thumb
- Složka `thumbs/` se commituje do repozitáře (aby fungovala na hostingu)
