# NursIT Anamnesis App

Diese Flutter-App ermöglicht es, medizinische Anamnesedaten aus einem GPT-generierten Freitext automatisch in strukturierter Form zu extrahieren und anzuzeigen. Die Ergebnisse basieren auf einem FHIR-kompatiblen JSON-Fragebogen und können als CSV-Datei exportiert werden.

## Hauptfunktionen

- **Interviewanalyse per GPT-API**: Verarbeitung eines Interview-Transkripts in Kombination mit einem FHIR-konformen Anamnesebogen.
- **Strukturierte Anzeige**: Darstellung der extrahierten Fragen und Antworten in einer übersichtlichen Liste.
- **CSV-Export**: Export der Daten mit Datum, Uhrzeit und Dateinamenkonvention: `Name_Datum_Uhrzeit_Anamnese.csv`.
- **Responsives UI**: Intuitive Benutzeroberfläche mit Exportfunktion.

## Projektstruktur

```
lib/
├── Views/
│   └── home.dart              // Haupt-UI
├── services/
│   ├── gpt_service.dart       // GPT-Kommunikation
│   └── export_service.dart    // CSV-Exportlogik
├── main.dart                  // App-Startpunkt
assets/
└── .env                       // GPT API-Schlüssel (nicht versioniert)
```

## Voraussetzungen

- Flutter SDK
- OpenAI GPT-4 API Key (als `.env`-Datei im `assets/` Ordner)

## Setup

1. Repository klonen:
   ```
   git clone https://github.com/dein-benutzername/nursit-anamnesis.git
   cd nursit-anamnesis
   ```

2. `.env` Datei erstellen:
   ```env
   OPENAI_API_KEY=dein_api_key
   ```

3. Pakete installieren:
   ```
   flutter pub get
   ```

4. App starten:
   ```
   flutter run
   ```

## Hinweise

- Die `.env`-Datei ist in der `.gitignore` enthalten und muss manuell angelegt werden.

## Lizenz

MIT License
