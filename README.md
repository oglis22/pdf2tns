# PDF2TNS - PDF zu TI-Nspire TNS Konverter

Konvertiert PDF-Dateien in scrollbare, formatierte TNS-Dateien für TI-Nspire Taschenrechner (CX/CAS, OS 4.4+).

## Features

- **Automatische Formatierung**: Headlines in blau/fett, Bullet-Points, nummerierte Listen
- **Scrollbar**: Mit Pfeiltasten ↑ ↓ durch lange Dokumente scrollen
- **Keine proprietäre Software**: 100% Open Source unter Linux
- **Batch-Konvertierung**: Mehrere PDFs auf einmal verarbeiten
- **OS 4.4 kompatibel**: Funktioniert mit TI-Nspire CAS OS 4.4.0.532+

## Voraussetzungen

```bash
# Debian/Ubuntu
sudo apt install poppler-utils python3

# Fedora/RHEL
sudo dnf install poppler-utils python3

# Arch
sudo pacman -S poppler python
```

## Verwendung

### Einzelnes PDF konvertieren

```bash
./pdf2tns.sh ~/Downloads/physik.pdf
```

### Alle PDFs in einem Ordner

```bash
./pdf2tns.sh ~/Documents/pdfs/
```

### Alle PDFs in Downloads

```bash
./pdf2tns.sh --all
```

### Hilfe anzeigen

```bash
./pdf2tns.sh --help
```

## Ordnerstruktur

```
pdf2tns/
├── pdf2tns.sh              # Haupt-Script
├── README.md               # Diese Datei
├── scripts/
│   └── pdf_converter.py    # Python Konverter
├── luna/
│   └── luna                # TNS Datei Generator
└── output/
    └── *.tns               # Fertige TNS-Dateien (hier!)
```

## Ausgabe

Alle konvertierten TNS-Dateien landen in `output/`:

```bash
ls output/
# 01.tns  02.tns  Schwingungen.tns  ...
```

Diese Dateien einfach per USB auf den TI-Nspire kopieren!

## Features der TNS-Dateien

Auf dem Taschenrechner:
- **↑ ↓** - Scrollen
- **Headlines** - Blau und fett formatiert
- **Bullet Points** - Mit • Symbol
- **Scrollbar** - Zeigt Position im Dokument

## Erweiterte Nutzung

### Als Command einbinden

```bash
# Symlink erstellen
sudo ln -s /home/oglis/pdf2tns/pdf2tns.sh /usr/local/bin/pdf2tns

# Dann von überall nutzbar:
pdf2tns datei.pdf
```

### Einzelne PDF mit Python-Script

```bash
python3 scripts/pdf_converter.py input.pdf output/ luna/luna
```

## Wie es funktioniert

1. **pdftotext** extrahiert Text aus PDF
2. **Python** formatiert Text (Headlines, Bullets, etc.)
3. **Luna** erstellt verschlüsselte TNS-Datei
4. Fertig zum Übertragen!

## Limitierungen

- **Nur Text**: Bilder/Formeln werden nicht eingebettet (OS 4.4 Limit)
- **Layout**: Komplexe Layouts werden auf Text reduziert
- **Größe**: Sehr lange PDFs (>600 Zeilen) werden gekürzt

## Tools verwendet

- [Luna](https://github.com/ndless-nspire/Luna) - TNS Datei Generator
- pdftotext (poppler-utils) - PDF Text Extraktion
- Python 3 - Text Formatierung

## Lizenz

Dieses Tool verwendet:
- Luna (Mozilla Public License v1.1)
- Eigene Scripts (frei verwendbar)

## Tipps

### Für bessere Ergebnisse:

- PDFs mit klarem Text (keine Scans)
- Nicht zu komplexe Layouts
- Für Bilder: Original-PDF am Computer ansehen

### Scroll-Probleme beheben:

Falls Scrollen nicht funktioniert, Taschenrechner neu starten.

## Hilfe

### Fehler: "pdftotext not found"

```bash
sudo apt install poppler-utils
```

### Fehler: "Luna not found"

Luna muss kompiliert sein. Falls nicht:

```bash
cd luna
make
```

### TNS-Datei lässt sich nicht öffnen

- Prüfe OS-Version (min. 4.4)
- PDF zu groß/komplex → Kürze das PDF vorher

## Getestet mit

- TI-Nspire CX CAS OS 4.4.0.532
- Debian/Ubuntu Linux
- Python 3.8+

---

