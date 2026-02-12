#!/usr/bin/env python3
"""
Training Data Validator

Validates JSON training data files against the VAZHI schema.
Checks for:
- Schema compliance
- Tamil content percentage
- Duplicate detection
- Data quality issues
"""

import json
import sys
import re
from pathlib import Path
from typing import Optional
from dataclasses import dataclass

try:
    from jsonschema import validate, ValidationError
except ImportError:
    print("Error: jsonschema not installed. Run: pip install jsonschema")
    sys.exit(1)


@dataclass
class ValidationResult:
    """Result of validating a single sample."""

    index: int
    id: Optional[str]
    is_valid: bool
    errors: list[str]
    warnings: list[str]
    tamil_percentage: float


def load_schema(schema_path: str = "schemas/training_sample.schema.json") -> dict:
    """Load the JSON schema."""
    with open(schema_path, "r", encoding="utf-8") as f:
        return json.load(f)


def calculate_tamil_percentage(text: str) -> float:
    """Calculate percentage of Tamil characters in text."""
    if not text:
        return 0.0

    # Tamil Unicode range: U+0B80 to U+0BFF
    tamil_chars = len(re.findall(r"[\u0B80-\u0BFF]", text))
    # Count only letters (exclude spaces, numbers, punctuation)
    all_letters = len(re.findall(r"[a-zA-Z\u0B80-\u0BFF]", text))

    if all_letters == 0:
        return 0.0

    return (tamil_chars / all_letters) * 100


def validate_sample(sample: dict, schema: dict, index: int) -> ValidationResult:
    """Validate a single training sample."""
    errors = []
    warnings = []
    sample_id = sample.get("id", f"sample_{index}")

    # Schema validation
    try:
        validate(instance=sample, schema=schema)
    except ValidationError as e:
        errors.append(f"Schema error: {e.message}")

    # Check instruction quality
    instruction = sample.get("instruction", "")
    if len(instruction) < 5:
        errors.append("Instruction too short (< 5 chars)")
    elif len(instruction) < 10:
        warnings.append("Instruction is very short")

    # Check output quality
    output = sample.get("output", "")
    if len(output) < 10:
        errors.append("Output too short (< 10 chars)")
    elif len(output) < 20:
        warnings.append("Output is very short")

    # Calculate Tamil percentage
    tamil_pct = calculate_tamil_percentage(output)

    # Check for garbage patterns
    garbage_patterns = [
        r"system\s*system",
        r"<think>",
        r"</think>",
        r"\[INST\]",
        r"\[/INST\]",
        r"<\|.*?\|>",
        r"###\s*Instruction:",
    ]

    for pattern in garbage_patterns:
        if re.search(pattern, output, re.IGNORECASE):
            errors.append(f"Garbage pattern detected: {pattern}")

    # Check for mostly English when Tamil expected
    if sample.get("pack") in ["culture", "dialects"] and tamil_pct < 30:
        warnings.append(
            f"Low Tamil content ({tamil_pct:.1f}%) for {sample.get('pack')} pack"
        )

    # Check for empty fields that should have content
    if sample.get("pack") and not sample.get("category"):
        warnings.append("Has pack but no category")

    return ValidationResult(
        index=index,
        id=sample_id,
        is_valid=len(errors) == 0,
        errors=errors,
        warnings=warnings,
        tamil_percentage=tamil_pct,
    )


def validate_file(file_path: str, schema: dict) -> tuple[list[ValidationResult], dict]:
    """Validate all samples in a JSON file."""
    results = []
    stats = {
        "total": 0,
        "valid": 0,
        "invalid": 0,
        "warnings": 0,
        "avg_tamil_pct": 0.0,
    }

    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if isinstance(data, dict):
        # Single sample
        data = [data]

    stats["total"] = len(data)
    tamil_pcts = []
    seen_ids = set()

    for i, sample in enumerate(data):
        result = validate_sample(sample, schema, i)
        results.append(result)

        if result.is_valid:
            stats["valid"] += 1
        else:
            stats["invalid"] += 1

        if result.warnings:
            stats["warnings"] += len(result.warnings)

        tamil_pcts.append(result.tamil_percentage)

        # Check for duplicates
        if result.id and result.id in seen_ids:
            result.warnings.append(f"Duplicate ID: {result.id}")
        seen_ids.add(result.id)

    if tamil_pcts:
        stats["avg_tamil_pct"] = sum(tamil_pcts) / len(tamil_pcts)

    return results, stats


def print_report(
    file_path: str, results: list[ValidationResult], stats: dict, verbose: bool = False
):
    """Print validation report."""
    print(f"\n{'='*60}")
    print(f"Validation Report: {file_path}")
    print(f"{'='*60}")

    print("\nSummary:")
    print(f"  Total samples:     {stats['total']}")
    print(
        f"  Valid:             {stats['valid']} ({stats['valid']/stats['total']*100:.1f}%)"
    )
    print(
        f"  Invalid:           {stats['invalid']} ({stats['invalid']/stats['total']*100:.1f}%)"
    )
    print(f"  Warnings:          {stats['warnings']}")
    print(f"  Avg Tamil content: {stats['avg_tamil_pct']:.1f}%")

    # Show errors
    error_results = [r for r in results if not r.is_valid]
    if error_results:
        print(f"\nErrors ({len(error_results)} samples):")
        for r in error_results[:10]:  # Limit to first 10
            print(f"  [{r.index}] {r.id}:")
            for err in r.errors:
                print(f"    ❌ {err}")
        if len(error_results) > 10:
            print(f"  ... and {len(error_results) - 10} more errors")

    # Show warnings if verbose
    if verbose:
        warning_results = [r for r in results if r.warnings]
        if warning_results:
            print(f"\nWarnings ({len(warning_results)} samples):")
            for r in warning_results[:10]:
                print(f"  [{r.index}] {r.id}:")
                for warn in r.warnings:
                    print(f"    ⚠️  {warn}")

    # Tamil distribution
    low_tamil = [r for r in results if r.tamil_percentage < 30]
    medium_tamil = [r for r in results if 30 <= r.tamil_percentage < 70]
    high_tamil = [r for r in results if r.tamil_percentage >= 70]

    print("\nTamil Content Distribution:")
    print(f"  High (≥70%):     {len(high_tamil)} samples")
    print(f"  Medium (30-70%): {len(medium_tamil)} samples")
    print(f"  Low (<30%):      {len(low_tamil)} samples")

    return stats["invalid"] == 0


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Validate VAZHI training data")
    parser.add_argument("files", nargs="+", help="JSON files to validate")
    parser.add_argument(
        "--schema",
        default="schemas/training_sample.schema.json",
        help="Path to JSON schema",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Show warnings and details"
    )
    parser.add_argument(
        "--fail-on-warning",
        action="store_true",
        help="Exit with error if warnings found",
    )

    args = parser.parse_args()

    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    schema_path = project_root / args.schema

    if not schema_path.exists():
        print(f"Error: Schema not found at {schema_path}")
        sys.exit(1)

    schema = load_schema(str(schema_path))

    all_valid = True
    total_warnings = 0

    for file_pattern in args.files:
        # Support glob patterns
        if "*" in file_pattern:
            files = list(project_root.glob(file_pattern))
        else:
            files = [Path(file_pattern)]

        for file_path in files:
            if not file_path.exists():
                print(f"Warning: File not found: {file_path}")
                continue

            results, stats = validate_file(str(file_path), schema)
            is_valid = print_report(str(file_path), results, stats, args.verbose)

            if not is_valid:
                all_valid = False
            total_warnings += stats["warnings"]

    print(f"\n{'='*60}")
    if all_valid:
        print("✅ All files passed validation")
        if total_warnings > 0:
            print(f"⚠️  {total_warnings} total warnings")
            if args.fail_on_warning:
                sys.exit(1)
        sys.exit(0)
    else:
        print("❌ Validation failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
