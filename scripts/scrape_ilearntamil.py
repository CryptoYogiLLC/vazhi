"""
Scrape 32 Tamil conversations from ilearntamil.com.

Each conversation page has dialogue turns in <p> tags containing 3 <span> elements:
- Span 1: Tanglish (romanized Tamil)
- Span 2: English translation
- Span 3: Tamil script

Outputs raw conversations and SFT-formatted pairs.
"""

import json
import re
import subprocess
import time
import urllib.request
from html.parser import HTMLParser
from pathlib import Path


class ConversationParser(HTMLParser):
    """Extract dialogue turns from ilearntamil.com conversation pages."""

    def __init__(self):
        super().__init__()
        self.turns = []
        self.title_tanglish = ""
        self.title_tamil = ""

        # State tracking
        self._in_p = False
        self._in_span = False
        self._current_spans = []
        self._current_span_text = ""
        self._in_title_div = False
        self._title_text = ""
        self._div_depth = 0

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        cls = attrs_dict.get("class", "")

        if tag == "p":
            self._in_p = True
            self._current_spans = []

        if tag == "span" and self._in_p:
            self._in_span = True
            self._current_span_text = ""

        # Track title div (et_pb_text_inner inside first text module)
        if tag == "div" and cls and "et_pb_text_inner" in cls:
            self._in_title_div = True
            self._title_text = ""

    def handle_endtag(self, tag):
        if tag == "span" and self._in_span:
            self._in_span = False
            self._current_spans.append(self._current_span_text.strip())

        if tag == "p" and self._in_p:
            self._in_p = False
            # Check if we have a valid triplet
            if len(self._current_spans) >= 3:
                tamil_text = self._current_spans[2]
                if re.search(r"[\u0B80-\u0BFF]", tamil_text):
                    self.turns.append(
                        {
                            "tanglish": self._current_spans[0],
                            "english": self._current_spans[1],
                            "tamil": tamil_text,
                        }
                    )
            self._current_spans = []

        if tag == "div" and self._in_title_div:
            self._in_title_div = False
            title = self._title_text.strip()
            if len(title) > 5 and re.search(r"[\u0B80-\u0BFF]", title):
                if not self.title_tanglish:  # Only take first match
                    tamil_start = re.search(r"[\u0B80-\u0BFF]", title)
                    if tamil_start:
                        self.title_tanglish = title[: tamil_start.start()].strip()
                        self.title_tamil = title[tamil_start.start() :].strip()
                    else:
                        self.title_tanglish = title

    def handle_data(self, data):
        if self._in_span:
            self._current_span_text += data
        if self._in_title_div:
            self._title_text += data


def parse_br_format(html: str) -> list[dict]:
    """Parse conversations using <strong>/<br> format (pages 22+).

    Format: <p><strong>Speaker</strong>: tanglish<br/>
            <strong>Speaker</strong>: english<br/>
            <strong>தமிழ்</strong>: tamil</p>
    """
    turns = []
    # Find all <p> tags containing <strong> and Tamil text
    p_blocks = re.findall(r"<p>(.*?)</p>", html, re.DOTALL)

    for block in p_blocks:
        if "<strong>" not in block or not re.search(r"[\u0B80-\u0BFF]", block):
            continue

        # Split on <br /> or <br/> or <br>
        parts = re.split(r"<br\s*/?>", block)
        if len(parts) < 3:
            continue

        # Clean HTML tags from each part
        cleaned = []
        for part in parts:
            text = re.sub(r"<[^>]+>", "", part).strip()
            if text:
                cleaned.append(text)

        if len(cleaned) >= 3:
            # Check third part has Tamil
            if re.search(r"[\u0B80-\u0BFF]", cleaned[2]):
                turns.append(
                    {
                        "tanglish": cleaned[0],
                        "english": cleaned[1],
                        "tamil": cleaned[2],
                    }
                )

    return turns


def scrape_conversation(url: str, number: int) -> dict:
    """Scrape a single conversation page."""
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "en-US,en;q=0.9,ta;q=0.8",
                "Referer": "https://ilearntamil.com/32-conversations-in-colloquial-tamil-and-english/",
            },
        )
        with urllib.request.urlopen(req, timeout=30) as resp:  # nosec B310
            html = resp.read().decode("utf-8")

        parser = ConversationParser()
        parser.feed(html)

        turns = parser.turns
        # Fallback: some pages use <strong>/<br> format instead of <span>
        if not turns:
            turns = parse_br_format(html)

        return {
            "number": number,
            "url": url,
            "title_tanglish": parser.title_tanglish,
            "title_tamil": parser.title_tamil,
            "turn_count": len(turns),
            "turns": turns,
        }
    except Exception as e:
        # Fallback: try curl (some pages 403 with urllib but work with curl)
        try:
            result = subprocess.run(
                [
                    "curl",
                    "-s",
                    "-L",
                    "-H",
                    "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                    "-H",
                    "Accept: text/html",
                    url,
                ],
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode == 0 and len(result.stdout) > 1000:
                parser = ConversationParser()
                parser.feed(result.stdout)
                turns = parser.turns or parse_br_format(result.stdout)
                print(f"  (recovered via curl: {len(turns)} turns)")
                return {
                    "number": number,
                    "url": url,
                    "title_tanglish": parser.title_tanglish,
                    "title_tamil": parser.title_tamil,
                    "turn_count": len(turns),
                    "turns": turns,
                }
        except Exception:
            pass

        print(f"  ERROR on conversation {number}: {e}")
        return {
            "number": number,
            "url": url,
            "title_tanglish": "",
            "title_tamil": "",
            "turn_count": 0,
            "turns": [],
            "error": str(e),
        }


# Title overrides for conversations where the Divi text module
# doesn't contain the Tamil title (pages 9, 21-32 use a different layout)
TITLE_OVERRIDES = {
    9: ("Uraiyaadal – Thunimani Kadaiyil", "உரையாடல் – துணிமணி கடையில்"),
    21: ("Uraiyaadal – Aaspaththiriyil", "உரையாடல் – ஆஸ்பத்திரியில்"),
    22: ("Uraiyaadal – Poo Kothhu Vangudhal", "உரையாடல் – பூ கொத்து வாங்குதல்"),
    23: ("Uraiyaadal – Treadmill Vangudhal", "உரையாடல் – ட்ரெட்மில் வாங்குதல்"),
    24: ("Uraiyaadal – Sattai Vangudhal", "உரையாடல் – சட்டை வாங்குதல்"),
    25: ("Uraiyaadal – Kaalnidai Kadaiyil", "உரையாடல் – காலணி கடையில்"),
    26: ("Uraiyaadal – Nanbarkalin Santhippu", "உரையாடல் – நண்பர்களின் சந்திப்பு"),
    27: ("Uraiyaadal – Vakuppuaraiyil", "உரையாடல் – வகுப்பறையில்"),
    28: ("Uraiyaadal – Veettil", "உரையாடல் – வீட்டில்"),
    29: ("Uraiyaadal – Poongaavil", "உரையாடல் – பூங்காவில்"),
    30: ("Uraiyaadal – Veettil", "உரையாடல் – வீட்டில்"),
    31: ("Uraiyaadal – Nanbarkalin Santhippu", "உரையாடல் – நண்பர்களின் சந்திப்பு"),
    32: ("Uraiyaadal – Padippu Patri", "உரையாடல் – படிப்பு பற்றி"),
}


def fixup_conversations(conversations: list[dict]) -> list[dict]:
    """Fill missing titles and retry failed conversations."""
    for conv in conversations:
        num = conv["number"]

        # Apply title overrides for pages with non-standard layouts
        if num in TITLE_OVERRIDES and not conv["title_tanglish"]:
            conv["title_tanglish"], conv["title_tamil"] = TITLE_OVERRIDES[num]

        # Retry failed conversations with a different approach
        if conv.get("error") and conv["turn_count"] == 0:
            print(f"  Retrying conversation {num}...")
            retry = scrape_conversation(conv["url"], num)
            if retry["turn_count"] > 0:
                retry["title_tanglish"] = (
                    conv.get("title_tanglish") or retry["title_tanglish"]
                )
                retry["title_tamil"] = conv.get("title_tamil") or retry["title_tamil"]
                conv.update(retry)
            elif num in TITLE_OVERRIDES:
                conv["title_tanglish"], conv["title_tamil"] = TITLE_OVERRIDES[num]

    return conversations


def format_sft_pairs(conversations: list[dict]) -> list[dict]:
    """Convert raw conversations into SFT training pairs."""
    sft_pairs = []

    for conv in conversations:
        if conv["turn_count"] == 0:
            continue

        tamil_dialogue = "\n".join(t["tamil"] for t in conv["turns"])
        english_dialogue = "\n".join(t["english"] for t in conv["turns"])
        topic = conv["title_tamil"] or conv["title_tanglish"] or "உரையாடல்"

        # Pair 1: Tamil conversation generation
        sft_pairs.append(
            {
                "instruction": f"{topic} - இந்த தலைப்பில் ஒரு உரையாடலை எழுதுங்கள்.",
                "output": tamil_dialogue,
                "source": "ilearntamil",
                "source_url": conv["url"],
                "category": "conversational_tamil",
            }
        )

        # Pair 2: English-to-Tamil translation
        sft_pairs.append(
            {
                "instruction": "பின்வரும் ஆங்கில உரையாடலை தமிழில் மொழிபெயர்க்கவும்:\n\n"
                + english_dialogue,
                "output": tamil_dialogue,
                "source": "ilearntamil",
                "source_url": conv["url"],
                "category": "translation",
            }
        )

    return sft_pairs


def main():
    base_dir = Path(__file__).parent.parent
    output_raw = base_dir / "data/sources/sft/ilearntamil_raw.json"
    output_sft = base_dir / "data/sources/sft/ilearntamil_conversations.json"

    print("Scraping 32 conversations from ilearntamil.com...\n")

    conversations = []
    for i in range(1, 33):
        url = f"https://ilearntamil.com/conversation-practice-in-tamil-and-english-{i}/"
        print(f"  [{i:2d}/32] {url}")
        conv = scrape_conversation(url, i)
        print(f'         → {conv["turn_count"]} turns | {conv["title_tanglish"][:50]}')
        conversations.append(conv)
        time.sleep(0.5)  # Be polite

    # Fixup: fill missing titles, retry failures
    conversations = fixup_conversations(conversations)

    # Stats
    total_turns = sum(c["turn_count"] for c in conversations)
    errors = [c for c in conversations if c.get("error") and c["turn_count"] == 0]

    print("\n=== SCRAPING REPORT ===")
    print(f"Conversations: {len(conversations)}")
    print(f"Total turns: {total_turns}")
    print(f"Errors: {len(errors)}")
    if errors:
        for e in errors:
            print(f'  Conv {e["number"]}: {e["error"]}')

    # Save raw conversations
    with open(output_raw, "w", encoding="utf-8") as f:
        json.dump(conversations, f, ensure_ascii=False, indent=2)
    print(f"\nRaw conversations saved to {output_raw}")

    # Create and save SFT pairs
    sft_pairs = format_sft_pairs(conversations)
    with open(output_sft, "w", encoding="utf-8") as f:
        json.dump(sft_pairs, f, ensure_ascii=False, indent=2)

    print(f"SFT pairs saved to {output_sft}")
    print(
        f'  Conversational Tamil: {sum(1 for p in sft_pairs if p["category"] == "conversational_tamil")}'
    )
    print(
        f'  Translation: {sum(1 for p in sft_pairs if p["category"] == "translation")}'
    )
    print(f"  Total: {len(sft_pairs)}")

    # Show samples
    print("\n=== SAMPLE SFT PAIRS ===")
    for i, pair in enumerate(sft_pairs[:4]):
        print(f'\n--- Sample {i+1} [{pair["category"]}] ---')
        print(f'Q: {pair["instruction"][:120]}')
        print(f'A: {pair["output"][:200]}...')


if __name__ == "__main__":
    main()
