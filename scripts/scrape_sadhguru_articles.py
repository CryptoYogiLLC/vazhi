#!/usr/bin/env python3
"""
Scrape Tamil articles from Sadhguru website (isha.sadhguru.org).

Two-phase approach:
  Phase 1: Use the CSR API to get all article URLs (fast, paginated JSON)
  Phase 2: Fetch individual articles and extract Tamil content via __NEXT_DATA__

The site uses Next.js with client-side rendering. Article listing is served
by the iso-facade API; article content is embedded in __NEXT_DATA__ JSON.
"""

import argparse
import json
import time
from pathlib import Path
from typing import Dict, List, Optional

import requests
from bs4 import BeautifulSoup


class SadhguruScraper:
    """Scraper for Sadhguru Tamil articles."""

    BASE_URL = "https://isha.sadhguru.org"
    API_URL = "https://iso-facade.sadhguru.org/content/fetchcsr/content"

    HEADERS = {"User-Agent": "Vazhi-DataBot/1.0 (educational; non-commercial)"}

    def __init__(self, output_file: str, resume: bool = False):
        self.output_file = Path(output_file)
        self.resume = resume
        self.articles: List[Dict] = []
        self.seen_urls: set = set()

        if resume and self.output_file.exists():
            with open(self.output_file, "r", encoding="utf-8") as f:
                self.articles = json.load(f)
                self.seen_urls = {a["url"] for a in self.articles}
            print(f"Resuming: loaded {len(self.articles)} existing articles")

    def fetch_article_urls(self, max_articles: Optional[int] = None) -> List[Dict]:
        """Phase 1: Get all article URLs from the CSR API."""
        print("Phase 1: Fetching article URLs from API...")
        all_cards = []
        start = 0
        limit = 50

        while True:
            params = {
                "format": "json",
                "sitesection": "wisdom",
                "slug": "wisdom",
                "lang": "ta",
                "contentType": "article",
                "start": start,
                "limit": limit,
                "sortby": "newest",
            }

            try:
                resp = requests.get(
                    self.API_URL, params=params, headers=self.HEADERS, timeout=30
                )
                resp.raise_for_status()
                data = resp.json()
            except (requests.RequestException, ValueError) as e:
                print(f"  API error at start={start}: {e}")
                break

            posts = data.get("posts", {})
            total = posts.get("totalCount", 0)
            cards = posts.get("cards", [])

            if not cards:
                break

            all_cards.extend(cards)
            print(f"  Fetched {len(all_cards)}/{total} article URLs")

            if max_articles and len(all_cards) >= max_articles:
                all_cards = all_cards[:max_articles]
                break

            start += limit
            if start >= total:
                break

            time.sleep(0.5)

        print(f"  Total article URLs collected: {len(all_cards)}")
        return all_cards

    def extract_article_content(self, url: str) -> Optional[Dict]:
        """Phase 2: Fetch an article page and extract Tamil content."""
        full_url = self.BASE_URL + url if url.startswith("/") else url

        try:
            response = requests.get(full_url, headers=self.HEADERS, timeout=30)
            response.raise_for_status()
        except requests.RequestException as e:
            print(f"    Error: {e}")
            return None

        soup = BeautifulSoup(response.text, "html.parser")
        script = soup.find("script", id="__NEXT_DATA__")
        if not script or not script.string:
            return None

        try:
            data = json.loads(script.string)
            page_data = data["props"]["pageProps"]["pageData"]
        except (json.JSONDecodeError, KeyError):
            return None

        # Extract title
        title_data = page_data.get("title", "")
        if isinstance(title_data, list):
            titles = []
            for item in title_data:
                if isinstance(item, dict) and "value" in item:
                    titles.append(item["value"])
                elif item:
                    titles.append(str(item))
            title = " ".join(titles)
        elif isinstance(title_data, dict) and "value" in title_data:
            title = title_data["value"]
        else:
            title = str(title_data) if title_data else ""

        # Extract body content
        body_list = page_data.get("body", [])
        if not body_list:
            return None

        html_content = body_list[0].get("value", "") if body_list else ""

        # Fix double-encoded UTF-8
        try:
            if isinstance(html_content, str) and "à®" in html_content:
                html_content = html_content.encode("latin-1").decode("utf-8")
        except (UnicodeDecodeError, UnicodeEncodeError):
            pass

        # Parse HTML to text
        content_soup = BeautifulSoup(html_content, "html.parser")
        for tag in content_soup.find_all(["script", "style", "iframe"]):
            tag.decompose()

        paragraphs = content_soup.find_all(["p", "h2", "h3"])
        tamil_text_parts = []
        for para in paragraphs:
            text = para.get_text(strip=True)
            if text and "[photocredit]" not in text and "[SadhguruImage]" not in text:
                tamil_text_parts.append(text)

        tamil_text = "\n\n".join(tamil_text_parts)

        char_count = len(tamil_text)
        word_count = len(tamil_text.split())
        tamil_char_count = sum(1 for c in tamil_text if "\u0B80" <= c <= "\u0BFF")

        if char_count < 200:
            return None

        category = self._infer_category(full_url, title, tamil_text)

        return {
            "url": full_url,
            "title": title,
            "category": category,
            "tamil_text": tamil_text,
            "char_count": char_count,
            "word_count": word_count,
            "tamil_char_count": tamil_char_count,
        }

    def _infer_category(self, url: str, title: str, text: str) -> str:
        """Infer article category from URL, title, and content."""
        url_lower = url.lower()
        title_lower = title.lower()

        if any(
            k in url_lower or k in title_lower
            for k in ["yoga", "meditation", "health", "kulippathu", "udal"]
        ):
            return "health_wellness"
        elif any(
            k in url_lower or k in title_lower
            for k in ["pongal", "deepavali", "festival", "vinayagar", "navaratri"]
        ):
            return "festivals"
        elif any(
            k in url_lower or k in title_lower
            for k in ["food", "diet", "saapadu", "unavu"]
        ):
            return "food_diet"
        elif any(
            k in url_lower or k in title_lower
            for k in ["family", "marriage", "children", "kudumbam", "kalyanam"]
        ):
            return "family"
        elif any(
            k in url_lower or k in title_lower for k in ["youth", "student", "ilaignar"]
        ):
            return "youth"
        elif any(
            k in url_lower or k in title_lower
            for k in ["dharma", "karma", "spirituality", "swadharma", "atma"]
        ):
            return "philosophy"
        elif any(
            k in url_lower or k in title_lower
            for k in [
                "emotion",
                "anger",
                "happiness",
                "peace",
                "pain",
                "fear",
                "kோபம்",
                "bayam",
            ]
        ):
            return "emotions"
        elif any(
            k in url_lower or k in title_lower
            for k in ["culture", "tradition", "temple", "kovil"]
        ):
            return "culture"
        elif any(
            k in url_lower or k in title_lower
            for k in ["success", "motivation", "inspire", "quotes"]
        ):
            return "inspiration"
        else:
            return "daily_life"

    def save_progress(self):
        """Save current progress to output file."""
        with open(self.output_file, "w", encoding="utf-8") as f:
            json.dump(self.articles, f, ensure_ascii=False, indent=2)
        print(f"  Saved {len(self.articles)} articles to {self.output_file}")

    def scrape(self, max_articles: Optional[int] = None):
        """Main scraping loop: API listing then article fetch."""
        # Phase 1: Get all article URLs via API
        cards = self.fetch_article_urls(max_articles)

        # Phase 2: Fetch each article's content
        print(f"\nPhase 2: Fetching {len(cards)} article pages...")
        fetched = 0

        for i, card in enumerate(cards):
            url = card.get("url", "")
            full_url = self.BASE_URL + url if url.startswith("/") else url

            if full_url in self.seen_urls:
                continue

            article = self.extract_article_content(url)
            if article:
                self.articles.append(article)
                self.seen_urls.add(full_url)
                fetched += 1
                print(
                    f"  [{fetched}] {article['title'][:50]} — {article['word_count']}w"
                )

                if fetched % 50 == 0:
                    self.save_progress()
            else:
                print(f"  [skip] {url} — too short or no content")

            time.sleep(1)

        self.save_progress()
        return self.articles


def print_summary(articles: List[Dict]):
    """Print summary statistics."""
    print("\n" + "=" * 80)
    print("SCRAPING SUMMARY")
    print("=" * 80)
    print(f"\nTotal articles scraped: {len(articles)}")

    if not articles:
        return

    long_articles = [a for a in articles if a["word_count"] > 500]
    medium_articles = [a for a in articles if 200 <= a["word_count"] <= 500]

    print(f"  Articles with >500 words: {len(long_articles)}")
    print(f"  Articles with 200-500 words: {len(medium_articles)}")

    avg_words = sum(a["word_count"] for a in articles) / len(articles)
    print(f"  Average word count: {avg_words:.0f}")

    categories = {}
    for article in articles:
        cat = article["category"]
        categories[cat] = categories.get(cat, 0) + 1

    print("\nCategory distribution:")
    for cat, count in sorted(categories.items(), key=lambda x: -x[1]):
        print(f"  {cat}: {count}")


def main():
    parser = argparse.ArgumentParser(description="Scrape Sadhguru Tamil articles")
    parser.add_argument(
        "--max-articles", type=int, help="Maximum number of articles to scrape"
    )
    parser.add_argument(
        "--resume", action="store_true", help="Resume from existing output file"
    )
    parser.add_argument(
        "--output",
        default="/Users/chocka/CursorProjects/vazhi/data/sources/sft/sadhguru-raw/articles.json",
        help="Output JSON file path",
    )

    args = parser.parse_args()

    print("Sadhguru Article Scraper (API + __NEXT_DATA__)")
    print("=" * 80)

    scraper = SadhguruScraper(args.output, args.resume)
    articles = scraper.scrape(max_articles=args.max_articles)
    print_summary(articles)


if __name__ == "__main__":
    main()
