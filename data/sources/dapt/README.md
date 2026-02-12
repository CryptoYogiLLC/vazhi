# DAPT Corpus Files

**DAPT (Domain-Adaptive Pre-Training) data only. NOT for SFT.**

These files contain raw Tamil literary text for continued pretraining. They must NEVER be mixed with ChatML instruction pairs in SFT training — doing so caused the v3.1 "systemsystemsystem..." failure.

## Files

| File | Content | Source |
|------|---------|--------|
| `36_silapathikaram_corpus.json` | Silapathikaram literary text | Public domain Tamil literature |
| `37_thirukkural_corpus.json` | Thirukkural raw verse text | Public domain |
| `38_sangam_corpus.json` | Sangam literature corpus | Public domain |
| `39_aathichoodi_corpus.json` | Aathichoodi text | Public domain |
| `40_bharathiar_corpus.json` | Bharathiar poetry | Public domain |

## Usage

These files are consumed by the DAPT stage of training (if needed). The Dataset Factory notebook (`notebooks/Vazhi_Dataset_Factory_v4_0.ipynb`) does NOT include these — they are only used if a Micro-DAPT stage is added before SFT.

See [ADR-010](../../docs/adr/010-data-pipeline-architecture.md) for the full data pipeline architecture.
