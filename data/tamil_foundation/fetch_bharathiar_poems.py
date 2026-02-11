#!/usr/bin/env python3
"""
Bharathiar Poems Fetcher
========================
Fetches Bharathiar's poems from Tamil Wikisource (ta.wikisource.org)
These works are in the public domain as Bharathiar died in 1921.

Usage:
    python3 fetch_bharathiar_poems.py

No external dependencies required - uses stdlib only.
"""

import json
import urllib.request
import urllib.parse
import time
import re
from pathlib import Path
from typing import Optional, Dict, List
import ssl


# Tamil Wikisource API endpoint
WIKISOURCE_API = "https://ta.wikisource.org/w/api.php"


def fetch_wikisource_page(page_title: str) -> Optional[str]:
    """Fetch page content from Tamil Wikisource using urllib."""
    params = {
        "action": "query",
        "titles": page_title,
        "prop": "revisions",
        "rvprop": "content",
        "format": "json",
        "rvslots": "main"
    }

    url = f"{WIKISOURCE_API}?{urllib.parse.urlencode(params)}"

    try:
        ctx = ssl.create_default_context()
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "VAZHI-Tamil-Corpus/1.0 (Educational/Research)"}
        )

        with urllib.request.urlopen(req, timeout=30, context=ctx) as response:
            data = json.loads(response.read().decode('utf-8'))

        pages = data.get("query", {}).get("pages", {})
        for page_id, page_data in pages.items():
            if page_id == "-1":
                return None

            revisions = page_data.get("revisions", [])
            if revisions:
                slots = revisions[0].get("slots", {})
                main = slots.get("main", {})
                return main.get("*", "")

        return None

    except Exception as e:
        print(f"  Error fetching {page_title}: {e}")
        return None


def get_all_subpages(prefix: str) -> List[str]:
    """Get all subpages under a given prefix."""
    params = {
        "action": "query",
        "list": "allpages",
        "apprefix": prefix,
        "aplimit": "500",
        "format": "json"
    }

    url = f"{WIKISOURCE_API}?{urllib.parse.urlencode(params)}"

    try:
        ctx = ssl.create_default_context()
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "VAZHI-Tamil-Corpus/1.0 (Educational/Research)"}
        )

        with urllib.request.urlopen(req, timeout=30, context=ctx) as response:
            data = json.loads(response.read().decode('utf-8'))

        pages = data.get("query", {}).get("allpages", [])
        return [p["title"] for p in pages]

    except Exception as e:
        print(f"  Error getting subpages for {prefix}: {e}")
        return []


def extract_poem_text(wiki_content: str) -> str:
    """Extract clean poem text from Wikisource markup."""
    if not wiki_content:
        return ""

    text = wiki_content

    # Remove templates like {{header}}, {{poem}}, etc.
    while '{{' in text:
        new_text = re.sub(r'\{\{[^{}]*\}\}', '', text)
        if new_text == text:
            break
        text = new_text

    # Remove categories
    text = re.sub(r'\[\[Category:[^\]]+\]\]', '', text)
    text = re.sub(r'\[\[பகுப்பு:[^\]]+\]\]', '', text)

    # Remove interwiki links
    text = re.sub(r'\[\[[a-z]+:[^\]]+\]\]', '', text)

    # Remove file/image links
    text = re.sub(r'\[\[(?:File|படிமம்|Image):[^\]]+\]\]', '', text, flags=re.IGNORECASE)

    # Remove internal links but keep the text
    text = re.sub(r'\[\[([^|\]]+\|)?([^\]]+)\]\]', r'\2', text)

    # Remove HTML comments
    text = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)

    # Remove <poem> tags but keep content
    text = re.sub(r'<poem[^>]*>', '', text)
    text = re.sub(r'</poem>', '', text)

    # Remove <section> tags
    text = re.sub(r'<section[^>]*>', '', text)
    text = re.sub(r'</section>', '', text)

    # Remove other HTML tags
    text = re.sub(r'<[^>]+>', '', text)

    # Remove wiki bold/italic markers
    text = re.sub(r"'{2,5}", '', text)

    # Remove wiki headers but keep the text (== Header ==)
    text = re.sub(r'^(=+)\s*([^=]+)\s*\1$', r'\2', text, flags=re.MULTILINE)

    # Remove numbered list markers at the beginning
    text = re.sub(r'^#\s*', '', text, flags=re.MULTILINE)

    # Clean up multiple newlines
    text = re.sub(r'\n{3,}', '\n\n', text)

    # Remove leading/trailing whitespace from each line
    lines = [line.strip() for line in text.split('\n')]
    text = '\n'.join(lines)

    # Strip overall whitespace
    text = text.strip()

    return text


def fetch_collection(prefix: str, category: str, poems: List[Dict], poem_id_start: int) -> int:
    """Fetch all poems from a collection."""
    subpages = get_all_subpages(prefix + "/")

    if not subpages:
        print(f"  No subpages found for {prefix}")
        return poem_id_start

    poem_id = poem_id_start

    for page_title in subpages:
        # Extract a clean title from the page path
        title = page_title.split("/")[-1] if "/" in page_title else page_title

        print(f"  Fetching: {title[:50]}...")

        wiki_content = fetch_wikisource_page(page_title)
        if wiki_content:
            poem_text = extract_poem_text(wiki_content)

            if poem_text and len(poem_text) > 100:
                poems.append({
                    "id": f"bharathi_{poem_id:03d}",
                    "title": title,
                    "category": category,
                    "full_text": poem_text,
                    "source": "Tamil Wikisource",
                    "source_url": f"https://ta.wikisource.org/wiki/{urllib.parse.quote(page_title)}",
                    "author": "சுப்பிரமணிய பாரதி",
                    "author_english": "Subramania Bharathi",
                    "language": "Tamil",
                    "public_domain": True
                })
                poem_id += 1
                print(f"    Added: {len(poem_text)} characters")

        # Be respectful to the server
        time.sleep(0.3)

    return poem_id


def main():
    """Main function to fetch and save poems."""
    print("=" * 60)
    print("Bharathiar Poems Fetcher")
    print("Fetching from Tamil Wikisource (Public Domain)")
    print("=" * 60)

    poems = []
    poem_id = 1

    # Collections to fetch
    collections = [
        ("கண்ணன் பாட்டு", "kannan_pattu"),
        ("பாஞ்சாலி சபதம்", "panchali_sabatham"),
        ("பாரதியாரின் பல்வகைப் பாடல்கள்", "palvakai_paadalgal"),
    ]

    for prefix, category in collections:
        print(f"\n{'='*60}")
        print(f"Fetching {prefix}...")
        print("="*60)
        poem_id = fetch_collection(prefix, category, poems, poem_id)

    # Also fetch the main gnana paadalgal page (it has content)
    print(f"\n{'='*60}")
    print("Fetching ஞானப் பாடல்கள்...")
    print("="*60)

    wiki_content = fetch_wikisource_page("பாரதியாரின் ஞானப் பாடல்கள்")
    if wiki_content:
        poem_text = extract_poem_text(wiki_content)
        if poem_text and len(poem_text) > 100:
            poems.append({
                "id": f"bharathi_{poem_id:03d}",
                "title": "ஞானப் பாடல்கள்",
                "category": "gnana_paadalgal",
                "full_text": poem_text,
                "source": "Tamil Wikisource",
                "source_url": "https://ta.wikisource.org/wiki/பாரதியாரின்_ஞானப்_பாடல்கள்",
                "author": "சுப்பிரமணிய பாரதி",
                "author_english": "Subramania Bharathi",
                "language": "Tamil",
                "public_domain": True
            })
            poem_id += 1
            print(f"  Added ஞானப் பாடல்கள்: {len(poem_text)} characters")

    # Create output
    output = {
        "dataset_info": {
            "name": "Bharathiar Poetry Corpus",
            "description": "Complete poems by Subramania Bharathi (பாரதியார்)",
            "language": "Tamil",
            "author": "Subramania Bharathi (1882-1921)",
            "author_tamil": "சுப்பிரமணிய பாரதி",
            "public_domain_status": "Yes - author died in 1921",
            "source": "Tamil Wikisource (ta.wikisource.org)",
            "total_poems": len(poems),
            "fetched_at": time.strftime("%Y-%m-%d %H:%M:%S")
        },
        "poems": poems
    }

    output_path = Path(__file__).parent / "40_bharathiar_corpus.json"

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print(f"Saved {len(poems)} poems to {output_path}")
    print("=" * 60)

    print("\nPoems by category:")
    categories = {}
    for poem in poems:
        cat = poem["category"]
        categories[cat] = categories.get(cat, 0) + 1

    for cat, count in sorted(categories.items()):
        print(f"  {cat}: {count} poems")

    total_chars = sum(len(p["full_text"]) for p in poems)
    print(f"\nTotal characters: {total_chars:,}")


if __name__ == "__main__":
    main()
