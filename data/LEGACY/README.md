# Legacy Data (Read-Only Archive)

This directory contains training data from VAZHI's early development (v0.1-v3.6). It is preserved for historical reference but is **no longer used for new dataset construction**.

## Why This Exists

The original `data/tamil_foundation/` directory mixed DAPT corpus files with SFT instruction pairs, which caused training failures (v3.1). ADR-010 restructured the data pipeline to physically separate DAPT and SFT data.

## Contents

- `02_thirukkural.json` — Thirukkural Q&A pairs (historical, high Kural bias)
- `03_numbers_time.json` — Numbers and time Q&A
- `06_health.json` — Health Q&A
- `07_education.json` — Education Q&A
- `09_weather.json` — Weather Q&A
- `10_shopping.json` — Shopping Q&A
- `12_daily_routines.json` — Daily routines Q&A
- `13_emotions.json` — Emotions Q&A
- `14_chennai_dialect.json` — Chennai dialect Q&A
- `15_madurai_dialect.json` — Madurai dialect Q&A
- `16_kongu_dialect.json` — Kongu dialect Q&A
- `31_malaysia_dialect.json` — Malaysia Tamil dialect Q&A
- `32_avvaiyar.json` — Avvaiyar literary Q&A
- `archive/` — Earlier data versions (v02, v03, v04_interim)
- `v04/` — v0.4 regenerated data

## Current Pipeline

New datasets are constructed by the Dataset Factory notebook: `notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`

Source data lives in `data/sources/` (DAPT and SFT separated). See [ADR-010](../docs/adr/010-data-pipeline-architecture.md).
