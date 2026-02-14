#!/usr/bin/env python3
"""
Sadhguru Article Filter Agent for VAZHI
Reclassifies and filters scraped Tamil articles from isha.sadhguru.org
"""

import json
from collections import defaultdict
from typing import Dict, List, Set


# Tamil keyword mapping for category classification
CATEGORY_KEYWORDS = {
    "health_wellness": {
        "tamil": [
            "யோகா",
            "தியானம",
            "குளியல்",
            "உடல்",
            "தூக்கம்",
            "மூச்சு",
            "உடற்பயிற்சி",
            "மன",
            "சுவாச",
        ],
        "english": [
            "yoga",
            "meditation",
            "bath",
            "body",
            "sleep",
            "breath",
            "exercise",
            "mental",
            "stress",
        ],
    },
    "food_diet": {
        "tamil": ["உணவு", "சாப்பிடு", "உண்ணா", "நீர்", "சமைய", "பசி", "வயிறு"],
        "english": [
            "food",
            "eat",
            "fast",
            "water",
            "cook",
            "nutrition",
            "diet",
            "hunger",
        ],
    },
    "festivals": {
        "tamil": [
            "பொங்கல்",
            "தீபாவளி",
            "நவராத்திரி",
            "விநாயகர்",
            "சதுர்த்தி",
            "புத்தாண்டு",
            "விழா",
            "பண்டிகை",
        ],
        "english": [
            "pongal",
            "deepavali",
            "diwali",
            "navaratri",
            "vinayagar",
            "chaturthi",
            "new year",
            "sankranti",
            "festival",
        ],
    },
    "family": {
        "tamil": [
            "கல்யாணம்",
            "திருமண",
            "குழந்தை",
            "பெற்றோர்",
            "உறவு",
            "காதல்",
            "மனைவி",
            "கணவன்",
            "மகன்",
            "மகள்",
        ],
        "english": [
            "marriage",
            "wedding",
            "children",
            "parent",
            "relationship",
            "love",
            "wife",
            "husband",
            "son",
            "daughter",
        ],
    },
    "philosophy": {
        "tamil": [
            "தர்மம்",
            "கர்மா",
            "ஆன்மா",
            "மோட்ச",
            "பக்தி",
            "சிவன்",
            "கடவுள்",
            "ஆன்மீக",
            "உணர்வு",
        ],
        "english": [
            "dharma",
            "karma",
            "atma",
            "moksha",
            "soul",
            "bhakti",
            "shiva",
            "god",
            "spiritual",
            "consciousness",
            "devotion",
        ],
    },
    "emotions": {
        "tamil": [
            "கோபம்",
            "பயம்",
            "மகிழ்ச்சி",
            "அமைதி",
            "துன்பம்",
            "சந்தோஷ",
            "தனிமை",
            "அழுத்த",
        ],
        "english": [
            "anger",
            "fear",
            "happiness",
            "peace",
            "suffering",
            "joy",
            "depression",
            "loneliness",
            "emotion",
        ],
    },
    "culture": {
        "tamil": ["தமிழ்", "கோவில்", "பண்பாடு", "பாரம்பரிய", "வரலாறு", "இலக்கிய", "கலாச்சார"],
        "english": [
            "tamil",
            "temple",
            "culture",
            "tradition",
            "custom",
            "history",
            "literature",
            "heritage",
        ],
    },
    "youth": {
        "tamil": ["மாணவர்", "இளைஞர்", "கல்வி", "படிப்பு", "தொழில்", "பல்கலை"],
        "english": [
            "student",
            "youth",
            "education",
            "career",
            "college",
            "study",
            "university",
        ],
    },
    "inspiration": {
        "tamil": ["வெற்றி", "உந்துதல்", "மாற்றம்", "நோக்கம்", "அர்த்த"],
        "english": [
            "success",
            "motivation",
            "transformation",
            "purpose",
            "meaning",
            "inspire",
            "achieve",
        ],
    },
}

# Tier definitions
TIER_1 = {"health_wellness", "food_diet", "festivals", "daily_life", "family"}
TIER_2 = {"culture", "emotions", "youth", "inspiration"}
TIER_3 = {"philosophy"}

TIER_WORD_THRESHOLDS = {
    1: 0,  # Take all that pass quality
    2: 300,  # Require > 300 words
    3: 500,  # Require > 500 words
}


def classify_article(title: str, text_preview: str, current_category: str) -> str:
    """
    Reclassify article based on title and first 200 chars of content.
    Returns the most appropriate category.
    """
    # Combine title and preview for analysis
    content = (title + " " + text_preview[:200]).lower()

    # Score each category
    scores = defaultdict(int)

    for category, keywords in CATEGORY_KEYWORDS.items():
        for tamil_kw in keywords["tamil"]:
            if tamil_kw.lower() in content:
                scores[category] += 2  # Weight Tamil keywords higher
        for english_kw in keywords["english"]:
            if english_kw.lower() in content:
                scores[category] += 1

    # Return highest scoring category, or "daily_life" if no matches
    if not scores:
        return "daily_life"

    return max(scores.items(), key=lambda x: x[1])[0]


def calculate_tamil_percentage(article: Dict) -> float:
    """Calculate percentage of Tamil characters in the article."""
    if article["char_count"] == 0:
        return 0.0
    return (article["tamil_char_count"] / article["char_count"]) * 100


def is_duplicate(article: Dict, seen_titles: Set[str], seen_texts: List[str]) -> bool:
    """Check if article is a duplicate based on title or text overlap."""
    # Check exact title match
    title_lower = article["title"].lower().strip()
    if title_lower in seen_titles:
        return True

    # Check text similarity (simple approach: first 200 chars)
    text_sample = article["tamil_text"][:200].lower().strip()
    for existing_sample in seen_texts:
        # Calculate overlap ratio (simple Jaccard-like)
        set_a = set(text_sample.split())
        set_b = set(existing_sample.split())
        if not set_a or not set_b:
            continue
        overlap = len(set_a & set_b) / len(set_a | set_b)
        if overlap > 0.9:
            return True

    return False


def get_tier(category: str) -> int:
    """Get tier number for a category."""
    if category in TIER_1:
        return 1
    elif category in TIER_2:
        return 2
    elif category in TIER_3:
        return 3
    else:
        return 1  # Default to tier 1


def should_include_article(article: Dict, category: str) -> tuple[bool, str]:
    """
    Determine if article should be included based on tier and quality rules.
    Returns (should_include, rejection_reason)
    """
    # Quality check: minimum 200 Tamil chars
    if article["tamil_char_count"] < 200:
        return False, "too_short"

    # Quality check: minimum 30% Tamil content
    tamil_pct = calculate_tamil_percentage(article)
    if tamil_pct < 30:
        return False, "low_tamil"

    # Tier-based word count filtering
    tier = get_tier(category)
    threshold = TIER_WORD_THRESHOLDS[tier]

    if article["word_count"] <= threshold:
        return False, "tier_filtered"

    return True, ""


def main():
    input_path = "/Users/chocka/CursorProjects/vazhi/data/sources/sft/sadhguru-raw/articles_full.json"
    output_path = "/Users/chocka/CursorProjects/vazhi/data/sources/sft/sadhguru-raw/articles_filtered_full.json"
    report_path = "/Users/chocka/CursorProjects/vazhi/data/sources/sft/sadhguru-raw/filter_report.json"

    print("Loading articles...")
    with open(input_path, "r", encoding="utf-8") as f:
        articles = json.load(f)

    print(f"Loaded {len(articles)} articles")

    # Track stats
    stats = {
        "input_count": len(articles),
        "removed": {"too_short": 0, "low_tamil": 0, "duplicate": 0, "tier_filtered": 0},
        "category_distribution": defaultdict(int),
        "tier_breakdown": {"tier1": 0, "tier2": 0, "tier3": 0},
    }

    filtered_articles = []
    seen_titles = set()
    seen_text_samples = []

    print("\nProcessing articles...")
    for i, article in enumerate(articles, 1):
        if i % 100 == 0:
            print(f"  Processed {i}/{len(articles)}...")

        # Step 1: Reclassify
        new_category = classify_article(
            article["title"], article["tamil_text"], article["category"]
        )
        article["category"] = new_category

        # Step 2: Check for duplicates
        if is_duplicate(article, seen_titles, seen_text_samples):
            stats["removed"]["duplicate"] += 1
            continue

        # Step 3: Quality and tier filtering
        should_include, rejection_reason = should_include_article(article, new_category)

        if not should_include:
            stats["removed"][rejection_reason] += 1
            continue

        # Article passed all filters
        filtered_articles.append(article)
        seen_titles.add(article["title"].lower().strip())
        seen_text_samples.append(article["tamil_text"][:200].lower().strip())

        # Update stats
        stats["category_distribution"][new_category] += 1
        tier = get_tier(new_category)
        stats["tier_breakdown"][f"tier{tier}"] += 1

    # Calculate final stats
    stats["output_count"] = len(filtered_articles)

    if filtered_articles:
        total_words = sum(a["word_count"] for a in filtered_articles)
        stats["avg_word_count"] = round(total_words / len(filtered_articles))
    else:
        stats["avg_word_count"] = 0

    # Convert defaultdict to regular dict for JSON serialization
    stats["category_distribution"] = dict(stats["category_distribution"])

    # Write filtered articles
    print(f"\nWriting {len(filtered_articles)} filtered articles...")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(filtered_articles, f, ensure_ascii=False, indent=2)

    # Write report
    print("Writing filter report...")
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(stats, f, ensure_ascii=False, indent=2)

    # Print summary
    print("\n" + "=" * 60)
    print("FILTERING COMPLETE")
    print("=" * 60)
    print(f"Input articles:     {stats['input_count']}")
    print(f"Output articles:    {stats['output_count']}")
    print(
        f"Removal rate:       {((1 - stats['output_count']/stats['input_count'])*100):.1f}%"
    )
    print("\nRemoval reasons:")
    for reason, count in stats["removed"].items():
        print(f"  {reason:20s}: {count:4d}")
    print(f"\nAverage word count: {stats['avg_word_count']}")
    print("\nTier breakdown:")
    for tier, count in sorted(stats["tier_breakdown"].items()):
        print(f"  {tier}: {count}")
    print("\nCategory distribution:")
    for category, count in sorted(
        stats["category_distribution"].items(), key=lambda x: -x[1]
    ):
        tier = get_tier(category)
        print(f"  {category:20s}: {count:4d} (tier {tier})")
    print("\nFiles written:")
    print(f"  {output_path}")
    print(f"  {report_path}")
    print("=" * 60)


if __name__ == "__main__":
    main()
