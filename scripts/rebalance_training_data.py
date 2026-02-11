#!/usr/bin/env python3
"""
Training Data Rebalancer

Analyzes and rebalances training data distribution across knowledge packs.
Addresses the Thirukkural skew problem (71% -> 25% target).

Usage:
    python rebalance_training_data.py analyze data/
    python rebalance_training_data.py rebalance data/ output/
"""

import os
import re
import json
import random
import argparse
from pathlib import Path
from typing import Optional
from dataclasses import dataclass
from collections import defaultdict


# Target distribution (percentages)
TARGET_DISTRIBUTION = {
    'culture': 25,      # Was 71% (Thirukkural heavy)
    'govt': 15,         # Government schemes
    'health': 15,       # Healthcare
    'education': 12,    # Education
    'legal': 12,        # Legal rights
    'security': 12,     # Safety/scams
    'dialects': 9,      # Regional dialects
}


@dataclass
class Sample:
    """A training sample."""
    id: str
    instruction: str
    output: str
    pack: str
    category: Optional[str]
    source: Optional[str]
    tamil_percentage: float

    @classmethod
    def from_dict(cls, data: dict, index: int = 0) -> 'Sample':
        output = data.get('output', '')
        return cls(
            id=data.get('id', f'sample_{index}'),
            instruction=data.get('instruction', ''),
            output=output,
            pack=data.get('pack', 'general'),
            category=data.get('category'),
            source=data.get('source'),
            tamil_percentage=calculate_tamil_percentage(output),
        )

    def to_dict(self) -> dict:
        return {
            'id': self.id,
            'instruction': self.instruction,
            'output': self.output,
            'pack': self.pack,
            'category': self.category,
            'source': self.source,
            'metadata': {
                'tamil_percentage': self.tamil_percentage,
            }
        }


def calculate_tamil_percentage(text: str) -> float:
    """Calculate percentage of Tamil characters in text."""
    if not text:
        return 0.0

    tamil_chars = len(re.findall(r'[\u0B80-\u0BFF]', text))
    all_letters = len(re.findall(r'[a-zA-Z\u0B80-\u0BFF]', text))

    if all_letters == 0:
        return 0.0

    return (tamil_chars / all_letters) * 100


def load_samples(data_dir: str) -> list[Sample]:
    """Load all samples from JSON files in directory."""
    samples = []
    data_path = Path(data_dir)

    for json_file in data_path.glob('*.json'):
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            if isinstance(data, list):
                for i, item in enumerate(data):
                    samples.append(Sample.from_dict(item, len(samples)))
            elif isinstance(data, dict):
                samples.append(Sample.from_dict(data, len(samples)))

        except Exception as e:
            print(f"Warning: Could not load {json_file}: {e}")

    return samples


def analyze_distribution(samples: list[Sample]) -> dict:
    """Analyze current distribution of samples."""
    pack_counts = defaultdict(int)
    pack_tamil = defaultdict(list)

    for sample in samples:
        pack = sample.pack or 'general'
        pack_counts[pack] += 1
        pack_tamil[pack].append(sample.tamil_percentage)

    total = len(samples)
    analysis = {
        'total_samples': total,
        'packs': {},
    }

    for pack, count in sorted(pack_counts.items(), key=lambda x: -x[1]):
        percentage = (count / total * 100) if total > 0 else 0
        tamil_avg = sum(pack_tamil[pack]) / len(pack_tamil[pack]) if pack_tamil[pack] else 0

        analysis['packs'][pack] = {
            'count': count,
            'percentage': round(percentage, 1),
            'target': TARGET_DISTRIBUTION.get(pack, 10),
            'tamil_avg': round(tamil_avg, 1),
            'delta': round(percentage - TARGET_DISTRIBUTION.get(pack, 10), 1),
        }

    return analysis


def print_analysis(analysis: dict):
    """Print distribution analysis."""
    print("\n📊 Training Data Distribution Analysis")
    print("=" * 70)
    print(f"Total samples: {analysis['total_samples']}")
    print()
    print(f"{'Pack':<15} {'Count':>8} {'Current%':>10} {'Target%':>10} {'Delta':>8} {'Tamil%':>8}")
    print("-" * 70)

    for pack, stats in analysis['packs'].items():
        delta_str = f"{stats['delta']:+.1f}"
        delta_color = "" if abs(stats['delta']) < 5 else (" ⚠️" if stats['delta'] > 0 else " 📈")
        print(f"{pack:<15} {stats['count']:>8} {stats['percentage']:>9.1f}% {stats['target']:>9}% {delta_str:>8} {stats['tamil_avg']:>7.1f}%{delta_color}")

    print("-" * 70)


def filter_quality_samples(samples: list[Sample], min_tamil: float = 50) -> list[Sample]:
    """Filter samples by quality criteria."""
    return [s for s in samples if s.tamil_percentage >= min_tamil and len(s.output) >= 20]


def rebalance_samples(
    samples: list[Sample],
    target_total: Optional[int] = None,
    min_tamil: float = 50,
) -> list[Sample]:
    """Rebalance samples according to target distribution."""
    # Filter for quality first
    quality_samples = filter_quality_samples(samples, min_tamil)

    # Group by pack
    by_pack = defaultdict(list)
    for sample in quality_samples:
        by_pack[sample.pack or 'general'].append(sample)

    # Calculate target counts
    total = target_total or len(quality_samples)
    target_counts = {}
    for pack, pct in TARGET_DISTRIBUTION.items():
        target_counts[pack] = int(total * pct / 100)

    # Remaining samples go to 'general'
    allocated = sum(target_counts.values())
    if allocated < total:
        target_counts['general'] = target_counts.get('general', 0) + (total - allocated)

    # Sample from each pack
    rebalanced = []
    for pack, target in target_counts.items():
        available = by_pack.get(pack, [])
        if not available:
            print(f"Warning: No samples available for {pack}")
            continue

        if len(available) >= target:
            # Random sample to target count
            selected = random.sample(available, target)
        else:
            # Use all available + repeat to reach target
            selected = available.copy()
            while len(selected) < target:
                selected.extend(random.sample(available, min(target - len(selected), len(available))))

        rebalanced.extend(selected)

    # Shuffle to mix packs
    random.shuffle(rebalanced)

    return rebalanced


def save_samples(samples: list[Sample], output_path: str):
    """Save samples to JSON file."""
    data = [s.to_dict() for s in samples]

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Saved {len(samples)} samples to {output_path}")


def main():
    parser = argparse.ArgumentParser(description='VAZHI Training Data Rebalancer')
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Analyze command
    analyze_parser = subparsers.add_parser('analyze', help='Analyze current distribution')
    analyze_parser.add_argument('data_dir', help='Directory containing training JSON files')

    # Rebalance command
    rebalance_parser = subparsers.add_parser('rebalance', help='Rebalance training data')
    rebalance_parser.add_argument('data_dir', help='Directory containing training JSON files')
    rebalance_parser.add_argument('output', help='Output JSON file path')
    rebalance_parser.add_argument('--total', type=int, help='Target total samples')
    rebalance_parser.add_argument('--min-tamil', type=float, default=50, help='Minimum Tamil percentage')
    rebalance_parser.add_argument('--seed', type=int, default=42, help='Random seed')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    if args.command == 'analyze':
        samples = load_samples(args.data_dir)
        analysis = analyze_distribution(samples)
        print_analysis(analysis)

    elif args.command == 'rebalance':
        random.seed(args.seed)

        print(f"Loading samples from {args.data_dir}...")
        samples = load_samples(args.data_dir)
        print(f"Loaded {len(samples)} samples")

        print("\nBefore rebalancing:")
        print_analysis(analyze_distribution(samples))

        print(f"\nRebalancing (min Tamil: {args.min_tamil}%)...")
        rebalanced = rebalance_samples(
            samples,
            target_total=args.total,
            min_tamil=args.min_tamil,
        )

        print("\nAfter rebalancing:")
        print_analysis(analyze_distribution(rebalanced))

        save_samples(rebalanced, args.output)


if __name__ == '__main__':
    main()
