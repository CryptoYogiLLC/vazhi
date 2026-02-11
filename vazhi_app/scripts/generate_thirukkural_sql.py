#!/usr/bin/env python3
"""
Generate Thirukkural SQL insert statements from JSON data.
"""

import json
import os

# Paal (section) mappings
PAAL_ENGLISH = {
    "அறத்துப்பால்": "Virtue",
    "பொருட்பால்": "Wealth",
    "காமத்துப்பால்": "Love",
    "இன்பத்துப்பால்": "Love"  # Alternative name
}

def escape_sql(text):
    """Escape single quotes for SQL."""
    if text is None:
        return None
    return text.replace("'", "''")

def generate_sql():
    """Generate SQL INSERT statements for Thirukkural."""

    # Read the JSON corpus
    json_path = os.path.join(
        os.path.dirname(__file__),
        '../../data/tamil_foundation/37_thirukkural_corpus.json'
    )

    with open(json_path, 'r', encoding='utf-8') as f:
        kurals = json.load(f)

    # Generate SQL
    sql_lines = [
        "-- Thirukkural Data",
        "-- All 1,330 verses with Tamil meanings",
        "-- Source: VAZHI Tamil Foundation corpus",
        "",
        "-- Clear existing data",
        "DELETE FROM thirukkural;",
        "",
        "-- Insert Thirukkural verses",
    ]

    for kural in kurals:
        kural_num = kural['kural_number']
        tamil = escape_sql(kural['tamil'])

        # Split verse into two lines (most kurals have two lines separated by space or period)
        verse_parts = tamil.replace('.', '').strip().split(' ')
        mid = len(verse_parts) // 2
        line1 = ' '.join(verse_parts[:mid])
        line2 = ' '.join(verse_parts[mid:])

        meaning_tamil = escape_sql(kural.get('meaning_tamil', ''))
        athikaram = escape_sql(kural['adhikaram'])
        athikaram_num = kural['adhikaram_number']
        paal = escape_sql(kural['section'])
        paal_english = PAAL_ENGLISH.get(kural['section'], 'Virtue')

        # Generate athikaram English (transliteration for now)
        athikaram_english = athikaram  # We'll use Tamil for now

        sql = f"""INSERT INTO thirukkural (kural_number, verse_line1, verse_line2, verse_full, meaning_tamil, meaning_english, athikaram, athikaram_english, athikaram_number, paal, paal_english) VALUES
({kural_num}, '{line1}', '{line2}', '{tamil}', '{meaning_tamil}', NULL, '{athikaram}', '{athikaram_english}', {athikaram_num}, '{paal}', '{paal_english}');"""

        sql_lines.append(sql)

    # Write SQL file
    output_path = os.path.join(
        os.path.dirname(__file__),
        '../lib/database/data/thirukkural.sql'
    )

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"Generated {len(kurals)} Thirukkural INSERT statements")
    print(f"Output: {output_path}")

if __name__ == '__main__':
    generate_sql()
