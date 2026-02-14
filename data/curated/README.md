---
language:
- ta
license: cc-by-sa-4.0
task_categories:
- text-generation
tags:
- tamil
- sft
- chatml
- vazhi
size_categories:
- 1K<n<10K
---

# VAZHI Tamil SFT Dataset v5.0

Tamil-first SFT dataset for the VAZHI project - a free, offline Tamil AI assistant.

## Dataset Stats

| Split | Samples |
|-------|---------|
| Train | 5,328 |
| Eval | 593 |
| **Total** | **5,921** |

## Bucket Distribution

| Source | Count | % |
|--------|-------|---|
| vazhi_packs | 2,961 | 50.0% |
| safety | 1,800 | 30.4% |
| sadhguru_qa | 848 | 14.3% |
| thirukkural | 168 | 2.8% |
| handcrafted | 120 | 2.0% |
| general | 24 | 0.4% |

## Key Improvements over v4.1

- **100% Tamil responses** (v4.1 had 75.8% garbage English)
- **Short responses**: avg 41 words (v4.1 had 200-1000 word MT essays)
- **Authentic Tamil sources**: Sadhguru articles restructured into Q&A (not machine-translated)
- **Domain-relevant**: Tamil Nadu focused content
- **Clean 5.9K samples** (v4.1 had 13K padded with garbage)
- **Thirukkural in Q&A format only** (no verbatim recitation that could cause parroting)

## Data Sources

1. **Vazhi-packs v5** (2,961): 6 domain packs (healthcare, education, legal, govt, security, culture) with Tamil responses
2. **IndicAlign safety** (1,800): Tamil safety refusals from HHRLHF_T + Toxic_Matrix
3. **Sadhguru Q&A** (848): High-quality Tamil Q&A restructured from isha.sadhguru.org Tamil articles
4. **Thirukkural Q&A** (168): Interpretive Q&A about Thirukkural verses (no verbatim)
5. **Handcrafted** (120): Product voice - greetings, refusals, brevity, guardrails
6. **General** (24): Numbers, weather, health basics

## Format

ChatML format with Tamil system prompt. Each sample has:
- `text`: Full ChatML-formatted conversation
- `bucket`: Source category
- `source`: Original data source
- `category`: Content category

## Quality Metrics

- Tamil char % avg: 85.2%
- Word count avg: 41 words
- Word count range: 2-142 words
