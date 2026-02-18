"""
Sadhguru Q&A v2 — Direct article-to-QA conversion without LLM agents.

Problem: v1 (multi-agent sonnet) produced 1,001 Q&A pairs that were:
- 35% duplicates (4 blocks of 50x identical generic clichés)
- 41% question-answer echo (copied opening sentence as both Q and A)
- 7% generic motivational content not from Sadhguru
- Only 38% of articles used, answers avg ~300 chars vs 5,500+ char articles

Fix: Use the article text directly as the answer. Sadhguru's articles are
already structured as topic explanations or Q&A — we just need to:
1. Clean artifacts from scraped HTML
2. Extract a natural question from title or opening கேள்வி:
3. Use the actual article text as the answer (one pair per article)

This produces long-form Tamil training data that teaches the model to give
substantive responses, not just short snippets.
"""

import json
import re
from pathlib import Path


def clean_article_text(text: str) -> str:
    """Remove HTML/markdown artifacts from scraped article text."""

    # Remove SadhguruImage tags (case-insensitive, with optional attributes)
    text = re.sub(r"\[/?[Ss]adhguru[Ii]mage[^\]]*\]", "", text)

    # Remove pullquote tags (keep the content between them, case-insensitive)
    text = re.sub(r"\[/?[Pp]ull[Qq]uote\s*\]", "", text)

    # Remove separator tags
    text = re.sub(r"\[[Ss]eparator[^\]]*\]", "", text)

    # Remove photocredit tags
    text = re.sub(r"\[/?[Pp]hoto[Cc]redit[^\]]*\]", "", text)

    # Remove any remaining bracket tags
    text = re.sub(r"\[/?[A-Za-z]+[^\]]*\]", "", text)

    # Remove footnotes section (குறிப்பு: and everything after)
    text = re.sub(r"\n\s*குறிப்பு\s*:.*$", "", text, flags=re.DOTALL)

    # Remove "மேலும் பல கதைகளைக் காண்க" and similar cross-references
    text = re.sub(r"மேலும்\s+பல\s+கதைகளைக்\s+காண்க.*$", "", text, flags=re.DOTALL)

    # Remove URLs
    text = re.sub(r"https?://\S+", "", text)

    # Remove remaining markdown-style links (keep link text)
    text = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", text)

    # Remove lines that are just quoted text markers (single-quoted lines)
    text = re.sub(r"^'[^']+'\s*$", "", text, flags=re.MULTILINE)

    # Clean up excessive whitespace
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"  +", " ", text)
    text = text.strip()

    return text


def extract_question_from_title(title: str) -> str:
    """Extract a Tamil question from the article title."""

    # Remove English parenthetical suffixes like (Swadharma Meaning in Tamil)
    title = re.sub(r"\s*\([^)]*[A-Za-z][^)]*\)", "", title)

    # Remove leading English text patterns like "Pongal Quotes in Tamil:"
    title = re.sub(r"^[A-Za-z\s:]+:\s*", "", title)
    # Also handle "Word Word: Tamil text" pattern
    title = re.sub(
        r"^[A-Za-z]+\s+[A-Za-z]+\s+in\s+Tamil\s*:\s*", "", title, flags=re.IGNORECASE
    )

    title = title.strip()

    # Remove trailing colons
    title = title.rstrip(":").strip()

    return title


def extract_question_from_text(text: str) -> str | None:
    """Extract explicit question from article text starting with கேள்வி:"""

    match = re.match(r"கேள்வி\s*:\s*(.+?)(?:\n\n|\n(?=[^\s]))", text, re.DOTALL)
    if match:
        q = match.group(1).strip()
        # Truncate overly long questions at the first sentence boundary
        if len(q) > 150:
            # Find first sentence ending
            for end_pat in [". ", "? ", "? "]:
                idx = q.find(end_pat)
                if 20 < idx < 150:
                    q = q[: idx + 1]
                    break
            else:
                # No good sentence boundary, truncate at 150
                q = q[:150].rsplit(" ", 1)[0] + "?"
        if len(q) > 10:
            return q

    return None


def create_qa_from_article(article: dict) -> dict | None:
    """Create one Q&A pair from a single article."""

    title = article.get("title", "")
    raw_text = article.get("tamil_text", "")
    url = article.get("url", "")
    category = article.get("category", "general")

    # Clean the text
    text = clean_article_text(raw_text)

    if len(text) < 200:
        return None

    # Extract question
    title_question = extract_question_from_title(title)
    text_question = extract_question_from_text(text)

    # If text starts with கேள்வி:, remove it from the answer text
    if text_question:
        text = re.sub(r"^கேள்வி\s*:.*?\n", "", text, count=1).strip()

    # Prefer the in-text question (more specific), fall back to title
    question = text_question or title_question

    if not question or len(question) < 5:
        return None

    # Truncate overly long questions (some titles are multi-sentence)
    if len(question) > 150:
        # Find a natural break
        for sep in ["? ", "? ", ". ", ", "]:
            idx = question.find(sep)
            if 15 < idx < 150:
                question = question[: idx + 1]
                break
        else:
            question = question[:150].rsplit(" ", 1)[0] + "?"

    # Ensure question ends with ?
    if not question.endswith("?") and not question.endswith("?"):
        question = question + "?"

    return {
        "instruction": question,
        "output": text,
        "source": "sadhguru_article",
        "source_url": url,
        "category": category,
    }


def validate_qa(qa: dict) -> tuple[bool, str]:
    """Validate a Q&A pair meets quality standards. Returns (valid, reason)."""

    q = qa.get("instruction", "")
    a = qa.get("output", "")

    # Minimum lengths
    if len(q) < 10:
        return False, "question_too_short"
    if len(a) < 200:
        return False, "answer_too_short"

    # Check Tamil content (should be mostly Tamil)
    tamil_chars = len(re.findall(r"[\u0B80-\u0BFF]", a))
    total_chars = len(re.findall(r"[^\s\d]", a)) or 1
    tamil_ratio = tamil_chars / total_chars
    if tamil_ratio < 0.5:
        return False, "low_tamil"

    # Check for remaining artifacts
    if re.search(r"\[/?[A-Za-z]", a):
        return False, "has_artifacts"

    return True, "ok"


def main():
    base_dir = Path(__file__).parent.parent

    # Load filtered articles
    articles_path = (
        base_dir / "data/sources/sft/sadhguru-raw/articles_filtered_full.json"
    )
    with open(articles_path) as f:
        articles = json.load(f)

    print(f"Loaded {len(articles)} filtered articles")

    # Generate Q&A pairs
    all_qa = []
    reject_reasons = {}

    for article in articles:
        qa = create_qa_from_article(article)

        if not qa:
            reject_reasons["no_question"] = reject_reasons.get("no_question", 0) + 1
            continue

        valid, reason = validate_qa(qa)
        if valid:
            all_qa.append(qa)
        else:
            reject_reasons[reason] = reject_reasons.get(reason, 0) + 1

    # Dedup by answer text (first 300 chars)
    seen = set()
    deduped = []
    for qa in all_qa:
        key = qa["output"][:300]
        if key not in seen:
            seen.add(key)
            deduped.append(qa)
        else:
            reject_reasons["duplicate"] = reject_reasons.get("duplicate", 0) + 1

    # Stats
    answer_lengths = [len(qa["output"]) for qa in deduped]
    question_lengths = [len(qa["instruction"]) for qa in deduped]
    word_counts = [len(qa["output"].split()) for qa in deduped]

    by_category = {}
    for qa in deduped:
        cat = qa.get("category", "unknown")
        by_category[cat] = by_category.get(cat, 0) + 1

    print("\n=== GENERATION REPORT ===")
    print(f"Input articles: {len(articles)}")
    print(f"Output Q&A pairs: {len(deduped)}")
    print("\nRejections:")
    for reason, count in sorted(reject_reasons.items(), key=lambda x: -x[1]):
        print(f"  {reason}: {count}")

    print(
        f"\nAnswer length (chars): min={min(answer_lengths)}, max={max(answer_lengths)}, avg={sum(answer_lengths)/len(answer_lengths):.0f}, median={sorted(answer_lengths)[len(answer_lengths)//2]}"
    )
    print(
        f"Answer length (words): min={min(word_counts)}, max={max(word_counts)}, avg={sum(word_counts)/len(word_counts):.0f}, median={sorted(word_counts)[len(word_counts)//2]}"
    )
    print(
        f"Question length (chars): min={min(question_lengths)}, max={max(question_lengths)}, avg={sum(question_lengths)/len(question_lengths):.0f}"
    )

    print("\nBy category:")
    for cat, count in sorted(by_category.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")

    # Answer length distribution
    buckets = [
        ("<1K", 0, 1000),
        ("1-3K", 1000, 3000),
        ("3-5K", 3000, 5000),
        ("5-10K", 5000, 10000),
        ("10K+", 10000, 999999),
    ]
    print("\nAnswer length distribution:")
    for label, lo, hi in buckets:
        count = sum(1 for alen in answer_lengths if lo <= alen < hi)
        print(f"  {label}: {count} ({count/len(deduped)*100:.0f}%)")

    # Save output
    output_path = base_dir / "data/sources/sft/sadhguru_qa_v2.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(deduped, f, ensure_ascii=False, indent=2)

    print(f"\nSaved to {output_path}")

    # Show sample pairs
    print("\n=== SAMPLE Q&A PAIRS ===")
    import random

    random.seed(42)
    samples = random.sample(deduped, min(5, len(deduped)))
    for i, qa in enumerate(samples):
        print(f'\n--- Sample {i+1} [{qa["category"]}] ---')
        print(f'Q: {qa["instruction"]}')
        a = qa["output"]
        print(f"A ({len(a)} chars, {len(a.split())} words):")
        print(f"  {a[:400]}")
        print("  ...")
        print(f"  {a[-200:]}")


if __name__ == "__main__":
    main()
