# Bharathiar Poetry Corpus

## About This Dataset

This dataset contains poems by **Subramania Bharathi (சுப்பிரமணிய பாரதி)** (1882-1921), one of the greatest Tamil poets.

### Public Domain Status

Bharathiar's works are in the **public domain** because:
- He passed away on September 11, 1921
- Under Indian copyright law, works enter public domain 60 years after the author's death
- His works have been in the public domain since 1981

## How to Populate This Dataset

### Option 1: Run the Fetch Script (Recommended)

```bash
cd /Users/chocka/CursorProjects/vazhi/data/tamil_foundation

# Install dependencies
pip install requests beautifulsoup4

# Run the fetcher
python fetch_bharathiar_poems.py
```

This will fetch poems from Tamil Wikisource and populate `40_bharathiar_corpus.json`.

### Option 2: Manual Download from Tamil Wikisource

Visit these pages and copy the text:

1. **Main Collection**: https://ta.wikisource.org/wiki/பாரதியார்_பாடல்கள்
2. **Kannan Pattu**: https://ta.wikisource.org/wiki/கண்ணன்_பாட்டு
3. **Pappa Pattu**: https://ta.wikisource.org/wiki/பாப்பாப்_பாட்டு
4. **National Songs**: https://ta.wikisource.org/wiki/நாட்டுப்_பாடல்கள்_(பாரதியார்)

### Option 3: Project Madurai

Project Madurai has excellent digitized Tamil texts:
- https://www.projectmadurai.org/

Search for "Bharathiar" to find complete collections.

## Poem Categories

| Category | Tamil Name | Description |
|----------|-----------|-------------|
| patriotic | தேசபக்திப் பாடல்கள் | Freedom and patriotic songs |
| kannan_pattu | கண்ணன் பாட்டு | Songs about Krishna |
| pappa_pattu | பாப்பாப் பாட்டு | Children's songs |
| social | சமூகப் பாடல்கள் | Social reform poems |
| philosophical | தத்துவப் பாடல்கள் | Philosophical works |

## Famous Poems Included

### Patriotic Poems (தேசபக்திப் பாடல்கள்)
- அச்சமில்லை அச்சமில்லை (Achamillai - No Fear)
- வந்தே மாதரம் (Vande Mataram)
- எந்தையும் தாயும் மகிழ்ந்து குலாவி
- ஜய ஜய பாரத மாதா

### Kannan Pattu (கண்ணன் பாட்டு)
- நின்னை சரணடைந்தேன் கண்ணம்மா
- சின்னஞ்சிறு கிளியே கண்ணம்மா
- காதலினால் உண்டாம் காமர் இன்பம்

### Pappa Pattu (பாப்பாப் பாட்டு)
- ஓடி விளையாடு பாப்பா
- வெள்ளை நிறத்தொரு பூனை
- நல்ல தமிழ் பாப்பா

### Social Reform
- காக்கை குருவி எங்கள் ஜாதி
- தனி ஒருவனுக்கு உணவில்லை எனில்

## Dataset Format

```json
{
  "id": "bharathi_001",
  "title": "அச்சமில்லை",
  "category": "patriotic",
  "full_text": "...",
  "source": "Tamil Wikisource",
  "source_url": "https://ta.wikisource.org/wiki/...",
  "author": "சுப்பிரமணிய பாரதி",
  "language": "Tamil",
  "public_domain": true
}
```

## Usage in VAZHI

This corpus is used to train the Tamil foundation model with:
- Rich Tamil vocabulary
- Poetic structures and meter
- Classical Tamil expressions
- Cultural and philosophical concepts

## License

Bharathiar's works are in the public domain. The dataset structure and scripts are part of the VAZHI project.
