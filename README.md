# VAZHI (வழி)

**Voluntary AI with Zero-cost Helpful Intelligence**

*The open path to Tamil AI*

---

## What is VAZHI?

VAZHI is an open-source Tamil language LLM designed to run **offline on mobile phones**. It's built by the community, for the community — ensuring Tamil speakers have access to AI tools without depending on paid APIs or Big Tech.

### Core Principles

| Principle | What It Means |
|-----------|---------------|
| **வழி காட்டும்** | Shows the way — guides users with helpful AI |
| **Zero-cost** | Free to use, no API fees, runs on your device |
| **Open source** | Transparent, community-owned, forkable |
| **Tamil-first** | Built natively for Tamil, not translated |

---

## Features

### Base Model (vazhi-base)
- 3B parameter model fine-tuned for Tamil
- Runs offline on mobile devices (~1.7GB quantized)
- Conversational chat, Q&A, translation

### Modular Packs
Download only what you need:

| Pack | Purpose | Training Data | Status |
|------|---------|---------------|--------|
| 🛡️ **Vazhi Kaval** (காவல்) | Scam detection, fraud alerts, cyber safety | 468 pairs | ✅ Data Ready |
| 🏛️ **Vazhi Arasu** (அரசு) | Government schemes & services | 467 pairs | ✅ Data Ready |
| 📚 **Vazhi Kalvi** (கல்வி) | Education assistance, scholarships | 602 pairs | ✅ Data Ready |
| ⚖️ **Vazhi Sattam** (சட்டம்) | Legal rights, RTI, consumer protection | 610 pairs | ✅ Data Ready |

**Total: 2,147 bilingual training pairs** (Pure Tamil + Tanglish)

### Smart Escalation
When questions are too complex, VAZHI transparently offers:
- "This needs expert advice. Want me to ask Gemini/Grok?"
- Links to verified professionals
- Never pretends to know more than it does

---

## Quick Start

### Run Inference (Colab)

```python
# Coming soon - Day 1 notebook
```

### Mobile App

```bash
# Coming soon - Week 2
```

---

## Project Structure

```
vazhi/
├── data/                # Training datasets
├── models/              # Model checkpoints
├── notebooks/           # Colab training notebooks
├── scripts/             # Utility scripts
├── vazhi-packs/         # Modular LoRA packs
│   ├── security/        # Vazhi Kaval
│   ├── legal/           # Vazhi Neethi
│   ├── govt/            # Vazhi Arasu
│   └── education/       # Vazhi Kalvi
└── docs/                # Documentation
```

---

## Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [x] **Data Collection** - 2,147 bilingual pairs across 4 domains ✅
- [ ] Fine-tune base Tamil LLM on Qwen 2.5 3B
- [ ] Quantize for mobile deployment (~1.7GB)
- [ ] Basic mobile app prototype

### Phase 2: Expansion (Months 2-3)
- [x] Security Pack data (468 pairs) ✅
- [x] Government Pack data (467 pairs) ✅
- [x] Education Pack data (602 pairs) ✅
- [x] Legal Pack data (610 pairs) ✅
- [ ] Community contribution guidelines
- [ ] Pack review and curation system
- [ ] iOS and Android apps

### Phase 3: Community (Months 4-6)
- [ ] Open pack submissions
- [ ] Multi-dialect support (Chennai, Madurai, Coimbatore)
- [ ] Voice input/output
- [ ] Offline-first PWA

---

## Contributing

VAZHI is built by the community. We welcome:

- **Data contributions**: Tamil conversations, Q&A pairs, domain-specific content
- **Pack creators**: Build specialized LoRA packs for your expertise area
- **Translators**: Help with documentation in Tamil
- **Testers**: Try the app and report issues

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

---

## Why "VAZHI"?

**வழி** (vazhi) means "path" or "way" in Tamil.

- It **shows the way** — guiding users through complex information
- It's an **open path** — anyone can walk it, contribute to it, fork it
- It's **your path** — runs on your device, owned by the community

**Acronym**: **V**oluntary **A**I with **Z**ero-cost **H**elpful **I**ntelligence

---

## License

MIT License — Free to use, modify, and distribute.

---

## Acknowledgments

- [AI4Bharat](https://ai4bharat.org/) for pioneering Indian language NLP
- [Qwen](https://github.com/QwenLM/Qwen) for excellent multilingual base models
- The Tamil open-source community

---

<p align="center">
  <b>வழி காட்டும் AI — The open path to Tamil AI</b>
</p>
