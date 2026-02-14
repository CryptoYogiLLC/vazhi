#!/usr/bin/env python3
"""Upload Dataset v5.0 to HuggingFace."""

from huggingface_hub import HfApi
import json

api = HfApi()
repo_id = "CryptoYogi/vazhi-tamil-sft-v5_0"

# Create the repo
try:
    api.create_repo(repo_id, repo_type="dataset", private=False)
    print(f"Created repo: {repo_id}")
except Exception as e:
    print(f"Repo exists or error: {e}")

base = "/Users/chocka/CursorProjects/vazhi/data/curated"

# Upload all 3 files
for fname in [
    "vazhi-tamil-sft-v5_0-train.json",
    "vazhi-tamil-sft-v5_0-eval.json",
    "vazhi-tamil-sft-v5_0-full.json",
]:
    path = f"{base}/{fname}"
    api.upload_file(
        path_or_fileobj=path, path_in_repo=fname, repo_id=repo_id, repo_type="dataset"
    )
    print(f"Uploaded: {fname}")

# Create and upload README
with open(f"{base}/vazhi-tamil-sft-v5_0-full.json") as f:
    data = json.load(f)

buckets = {}
for item in data:
    b = item["bucket"]
    buckets[b] = buckets.get(b, 0) + 1

readme_lines = [
    "---",
    "language:",
    "- ta",
    "license: cc-by-sa-4.0",
    "task_categories:",
    "- text-generation",
    "tags:",
    "- tamil",
    "- sft",
    "- chatml",
    "- vazhi",
    "size_categories:",
    "- 1K<n<10K",
    "---",
    "",
    "# VAZHI Tamil SFT Dataset v5.0",
    "",
    "Tamil-first SFT dataset for the VAZHI project - a free, offline Tamil AI assistant.",
    "",
    "## Dataset Stats",
    "",
    "| Split | Samples |",
    "|-------|---------|",
    "| Train | 5,119 |",
    "| Eval | 569 |",
    "| **Total** | **5,688** |",
    "",
    "## Bucket Distribution",
    "",
    "| Source | Count | % |",
    "|--------|-------|---|",
]

for b, c in sorted(buckets.items(), key=lambda x: -x[1]):
    pct = c / len(data) * 100
    readme_lines.append(f"| {b} | {c} | {pct:.1f}% |")

readme_lines.extend(
    [
        "",
        "## Key Improvements over v4.1",
        "",
        "- **100% Tamil responses** (v4.1 had 75.8% garbage English)",
        "- **Short responses**: avg 42 words (v4.1 had 200-1000 word MT essays)",
        "- **Authentic Tamil sources**: Sadhguru articles restructured into Q&A (not machine-translated)",
        "- **Domain-relevant**: Tamil Nadu focused content",
        "- **Clean 5.7K samples** (v4.1 had 13K padded with garbage)",
        "- **Thirukkural in Q&A format only** (no verbatim recitation that could cause parroting)",
        "",
        "## Data Sources",
        "",
        "1. **Vazhi-packs v5** (2,961): 6 domain packs (healthcare, education, legal, govt, security, culture) with Tamil responses",
        "2. **IndicAlign safety** (1,800): Tamil safety refusals from HHRLHF_T + Toxic_Matrix",
        "3. **Sadhguru Q&A** (615): High-quality Tamil Q&A restructured from isha.sadhguru.org Tamil articles",
        "4. **Thirukkural Q&A** (168): Interpretive Q&A about Thirukkural verses (no verbatim)",
        "5. **Handcrafted** (120): Product voice - greetings, refusals, brevity, guardrails",
        "6. **General** (24): Numbers, weather, health basics",
        "",
        "## Format",
        "",
        "ChatML format with Tamil system prompt. Each sample has:",
        "- `text`: Full ChatML-formatted conversation",
        "- `bucket`: Source category",
        "- `source`: Original data source",
        "- `category`: Content category",
        "",
        "## Quality Metrics",
        "",
        "- Tamil char % avg: 82.7%",
        "- Word count avg: 42 words",
        "- Word count range: 2-142 words",
    ]
)

readme = "\n".join(readme_lines) + "\n"

readme_path = f"{base}/README.md"
with open(readme_path, "w") as f:
    f.write(readme)

api.upload_file(
    path_or_fileobj=readme_path,
    path_in_repo="README.md",
    repo_id=repo_id,
    repo_type="dataset",
)
print("Uploaded: README.md")
print(f"\nDataset live at: https://huggingface.co/datasets/{repo_id}")
