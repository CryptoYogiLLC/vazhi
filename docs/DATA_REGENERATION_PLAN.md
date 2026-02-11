# VAZHI Training Data Regeneration Plan

## Problem Statement

Current training data (v0.2) has critical issues:
- **74% of outputs are English** despite Tamil/Tanglish labels
- **60% of "pure_tamil" items are <30% actual Tamil**
- Model learns: "Tamil question → English answer"
- Culture pack hallucinates instead of citing

## Goals

1. **Language Consistency**: Tamil Q → Tamil A, Tanglish Q → Tanglish A
2. **Actual Tamil Content**: Real Tamil responses, not English with Tamil labels
3. **Citation Format for Culture**: Factual content quoted, not generated
4. **Quality Assurance**: Validation before training

---

## Language Policy

### Three Response Modes

| Mode | When to Use | Example |
|------|-------------|---------|
| **Pure Tamil** | Traditional topics, culture, formal govt | முழு தமிழில் பதில் |
| **Tanglish** | Modern topics, tech, casual queries | Mixed like "NEET exam-க்கு prepare பண்ணுங்க" |
| **Bilingual** | Technical terms + Tamil explanation | "RTI (தகவல் அறியும் உரிமை) மூலம்..." |

### Technical Terms Handling

```
English Term → Tamil Equivalent (keep English in parentheses first time)
- Ayurveda → ஆயுர்வேதம்
- Back pain → முதுகு வலி
- Hospital → மருத்துவமனை
- Application → விண்ணப்பம்
- Certificate → சான்றிதழ்
- Download → பதிவிறக்கம்
- Website → இணையதளம்
- Online → இணையவழி
```

---

## Pack-Specific Guidelines

### 1. Security Pack (vazhi_kaval) - 429 samples

**Language**: Tanglish (since scams come in mixed language)

**Format**:
```
Q: இது scam message-ஆ? "Your account will be blocked..."
A: ஆம், இது scam!

🚨 அடையாளங்கள்:
• "Urgent" என்று பயமுறுத்துவது
• Bank details கேட்பது
• Unknown link அனுப்புவது

✅ செய்ய வேண்டியது:
• Link-ஐ click செய்யாதீர்கள்
• Bank-ஐ நேரடியாக தொடர்பு கொள்ளுங்கள்
• 1930 (Cyber Crime Helpline) அழைக்கவும்
```

### 2. Government Pack (vazhi_arasu) - 426 samples

**Language**: Tamil with English proper nouns

**Format**:
```
Q: Ration card எப்படி வாங்குவது?

A: ரேஷன் கார்டு பெறும் வழிமுறை:

📋 தேவையான ஆவணங்கள்:
• ஆதார் அட்டை
• குடும்ப உறுப்பினர் புகைப்படங்கள்
• முகவரி சான்று

📍 விண்ணப்பிக்கும் முறை:
1. tnpds.gov.in இணையதளம் செல்லவும்
2. "புதிய விண்ணப்பம்" தேர்வு செய்யவும்
3. விவரங்களை நிரப்பவும்
4. ஆவணங்களை பதிவேற்றவும்

⏱️ காலம்: 15-30 நாட்கள்
💰 கட்டணம்: இலவசம்
```

### 3. Education Pack (vazhi_kalvi) - 532 samples

**Language**: Tanglish (education system uses English terms)

**Format**:
```
Q: NEET-க்கு எப்படி prepare பண்றது?

A: NEET தயாரிப்பு வழிகாட்டி:

📚 பாடத்திட்டம்:
• Physics - இயற்பியல் (45 கேள்விகள்)
• Chemistry - வேதியியல் (45 கேள்விகள்)
• Biology - உயிரியல் (90 கேள்விகள்)

📖 படிக்க வேண்டிய புத்தகங்கள்:
• NCERT 11th & 12th (மிக முக்கியம்!)
• Previous year question papers

🆓 இலவச வளங்கள்:
• neet.nta.nic.in - அதிகாரப்பூர்வ தளம்
• YouTube: Physics Wallah Tamil
```

### 4. Legal Pack (vazhi_sattam) - 558 samples

**Language**: Tamil with English legal terms (first mention with Tamil)

**Format**:
```
Q: RTI எப்படி போடுவது?

A: RTI (தகவல் அறியும் உரிமை) விண்ணப்பம்:

📜 RTI Act 2005 - எந்த அரசு அலுவலகத்திலிருந்தும் தகவல் பெறலாம்.

📝 விண்ணப்பிக்கும் முறை:
1. rtionline.gov.in செல்லவும்
2. கேள்வியை தெளிவாக எழுதவும்
3. ₹10 கட்டணம் செலுத்தவும்

⏱️ பதில் வரும் காலம்: 30 நாட்களுக்குள்
📞 ஆட்சேபனை: முதல் மேல்முறையீட்டு அதிகாரி (First Appellate Authority)
```

### 5. Healthcare Pack (vazhi_maruthuvam) - 401 samples

**Language**: Tamil (traditional medicine has Tamil terms)

**Format**:
```
Q: சித்த மருத்துவத்தில் சளிக்கு என்ன மருந்து?

A: சளி நீக்கும் சித்த மருந்துகள்:

🌿 வீட்டு வைத்தியம்:
• துளசி கஷாயம் - துளசி இலை + தண்ணீர் கொதிக்க வைக்கவும்
• சுக்கு மல்லி காபி - சுக்கு + மல்லி + ஏலக்காய்
• கற்பூரவல்லி இலை சாறு

💊 சித்த மருந்துகள்:
• நிலவேம்பு குடிநீர் (NIS Tambaram கிடைக்கும்)
• திப்பிலி சூரணம்

🏥 அரசு சித்த மருத்துவமனைகள் - இலவச சிகிச்சை
```

### 6. Culture Pack (vazhi_panpaadu) - 516 samples

**Language**: Pure Tamil

**CRITICAL**: Format as CITATIONS, not generations

**Format for Thirukkural**:
```
Q: திருக்குறளின் முதல் குறள் என்ன?

A: 📖 திருக்குறள் - கடவுள் வாழ்த்து அதிகாரம், குறள் 1:

"அகர முதல எழுத்தெல்லாம் ஆதி
பகவன் முதற்றே உலகு."

📜 பொருள்:
எழுத்துக்கள் எல்லாம் அகரத்தை (அ) முதலாகக் கொண்டவை. அதுபோல் உலகம் முழுவதும் ஆதிபகவனை (இறைவனை) முதலாகக் கொண்டது.

✍️ ஆசிரியர்: திருவள்ளுவர்
📚 அதிகாரம்: கடவுள் வாழ்த்து (அறத்துப்பால்)
```

**Format for Siddhars**:
```
Q: 18 சித்தர்கள் யார்?

A: 📚 பதினெண் சித்தர்கள்:

சித்தர்கள் தமிழகத்தின் ஞானிகள், மருத்துவர்கள், யோகிகள்.

🔢 பதினெண் சித்தர் பட்டியல்:
1. அகத்தியர் - சித்தர்களின் தலைவர்
2. திருமூலர் - திருமந்திரம் ஆசிரியர்
3. போகர் - பழனி முருகன் சிலை படைத்தவர்
4. புலிப்பாணி
5. இடைக்காடர்
[... complete list ...]

📖 சித்தர்களின் பங்களிப்பு:
• சித்த மருத்துவம்
• யோகா & பிராணாயாமம்
• ரசவாதம்
• ஆன்மீக இலக்கியம்
```

---

## Regeneration Process

### Phase 1: Audit & Categorize (Day 1)

```python
# Categorize existing samples
for sample in training_data:
    tamil_pct = calculate_tamil_percentage(sample['output'])

    if tamil_pct > 70:
        keep_as_is.append(sample)  # Good Tamil content
    elif tamil_pct > 30:
        needs_review.append(sample)  # Partial Tamil, review
    else:
        needs_regeneration.append(sample)  # Mostly English, regenerate
```

**Expected breakdown:**
- Keep as-is: ~385 samples (13.5%)
- Needs review: ~355 samples (12.4%)
- Needs regeneration: ~2,122 samples (74.1%)

### Phase 2: Template Creation (Day 1)

Create response templates for each pack with proper Tamil structure.

### Phase 3: LLM-Assisted Regeneration (Day 2-3)

Use Claude to regenerate English responses in proper Tamil:

```python
prompt = f"""
Convert this English response to Tamil following these rules:
1. Use actual Tamil words, not transliteration
2. Keep proper nouns/website names in English
3. Use Tamil numbers where natural
4. Follow the template structure below

Original Q: {question}
Original A (English): {english_answer}

Template:
{pack_template}

Provide Tamil response:
"""
```

### Phase 4: Culture Pack Special Handling (Day 2)

For Thirukkural and Siddhars:
1. Source authentic Tamil texts
2. Format as citations with quotation marks
3. Add source attribution
4. Multiple question variations per kural

### Phase 5: Quality Validation (Day 3)

```python
def validate_sample(sample):
    checks = {
        'tamil_percentage': calculate_tamil_percentage(sample['output']) > 60,
        'has_structure': bool(re.search(r'[•📍📚🔢]', sample['output'])),
        'not_empty': len(sample['output']) > 100,
        'no_hallucination': not contains_made_up_kurals(sample),  # For culture
    }
    return all(checks.values())
```

### Phase 6: Training Data Assembly (Day 4)

1. Combine validated samples
2. Balance across packs
3. Shuffle and split (90/10)
4. Final quality check

---

## File Structure

```
data/
├── v02/                      # Current (problematic)
│   ├── vazhi_train_v02.json
│   └── vazhi_val_v02.json
├── v04/                      # Regenerated
│   ├── raw/
│   │   ├── security_tamil.json
│   │   ├── government_tamil.json
│   │   ├── education_tamil.json
│   │   ├── legal_tamil.json
│   │   ├── healthcare_tamil.json
│   │   └── culture_tamil.json
│   ├── validated/
│   │   └── [validated samples]
│   ├── vazhi_train_v04.json
│   └── vazhi_val_v04.json
└── templates/
    └── pack_templates.json
```

---

## Success Metrics

| Metric | v0.2 (Current) | v0.4 (Target) |
|--------|----------------|---------------|
| Outputs >70% Tamil | 13.5% | >70% |
| Outputs <30% Tamil | 74.1% | <10% |
| Culture accuracy | ~0% | >90% |
| Thirukkural exact match | 0/3 | 3/3 |

---

## Timeline

| Day | Task | Output |
|-----|------|--------|
| Day 1 | Audit + Templates | Categorized samples, templates |
| Day 2 | Regenerate Security, Govt, Education | ~1,400 samples |
| Day 3 | Regenerate Legal, Healthcare, Culture | ~1,400 samples |
| Day 4 | Validate + Assemble | v0.4 training data |
| Day 5 | Train + Test | v0.4 model |

---

## Questions to Decide

1. **Technical terms**: Always translate or keep English with Tamil explanation?
2. **Tanglish ratio**: What % English is acceptable in Tanglish mode?
3. **Culture sources**: Use existing kurals from our data or source fresh from authoritative texts?
4. **Sample count**: Keep ~3,000 or expand to 5,000+?

---

## Next Steps

1. [ ] Decide on language policy questions above
2. [ ] Create pack templates
3. [ ] Set up regeneration pipeline
4. [ ] Begin Phase 1 audit
