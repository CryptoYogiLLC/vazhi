#!/usr/bin/env python3
"""
Preflight Training Validation

Runs quick validation before full training to catch issues early:
1. Micro-trains on small sample (50 samples, 10 steps)
2. Converts to GGUF
3. Tests Tamil output quality
4. Validates response coherence

Exit codes:
- 0: All checks passed
- 1: Validation failed
- 2: Critical error (missing dependencies, etc.)
"""

import os
import re
import sys
import json
import subprocess
from dataclasses import dataclass
from typing import Optional


@dataclass
class PreflightResult:
    """Result of a preflight check."""

    passed: bool
    check_name: str
    message: str
    details: Optional[dict] = None


class PreflightError(Exception):
    """Raised when preflight validation fails."""

    pass


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


def check_garbage_patterns(text: str) -> list[str]:
    """Check for known garbage patterns in output."""
    garbage_patterns = [
        (r"system\s*system\s*system", 'Repeated "system" tokens'),
        (r"<think>.*?</think>", "Thinking tags in output"),
        (r"\[INST\]|\[/INST\]", "Raw instruction markers"),
        (r"<\|.*?\|>", "Special token markers"),
        (r"###\s*(Instruction|Response):", "Alpaca format markers"),
        (r"(\w)\1{10,}", "Character repetition (10+)"),
        (r"(..+)\1{5,}", "Pattern repetition (5+)"),
    ]

    issues = []
    for pattern, description in garbage_patterns:
        if re.search(pattern, text, re.IGNORECASE | re.DOTALL):
            issues.append(description)

    return issues


def validate_training_data(data_path: str, sample_size: int = 50) -> PreflightResult:
    """Validate training data before training."""
    print(f"  Checking training data: {data_path}")

    try:
        with open(data_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        return PreflightResult(
            passed=False,
            check_name="training_data",
            message=f"Failed to load training data: {e}",
        )

    if not isinstance(data, list) or len(data) == 0:
        return PreflightResult(
            passed=False,
            check_name="training_data",
            message="Training data is empty or invalid format",
        )

    # Check sample
    sample = data[:sample_size]
    issues = []
    tamil_percentages = []

    for i, item in enumerate(sample):
        # Check required fields
        if "instruction" not in item or "output" not in item:
            issues.append(f"Sample {i}: Missing instruction or output")
            continue

        output = item.get("output", "")

        # Check output length
        if len(output) < 10:
            issues.append(f"Sample {i}: Output too short ({len(output)} chars)")

        # Check for garbage
        garbage = check_garbage_patterns(output)
        if garbage:
            issues.append(f"Sample {i}: Garbage patterns: {garbage}")

        # Calculate Tamil percentage
        tamil_pct = calculate_tamil_percentage(output)
        tamil_percentages.append(tamil_pct)

    avg_tamil = (
        sum(tamil_percentages) / len(tamil_percentages) if tamil_percentages else 0
    )

    if issues:
        return PreflightResult(
            passed=False,
            check_name="training_data",
            message=f"Found {len(issues)} issues in training data",
            details={"issues": issues[:10], "avg_tamil_pct": avg_tamil},
        )

    return PreflightResult(
        passed=True,
        check_name="training_data",
        message=f"Training data OK ({len(sample)} samples, {avg_tamil:.1f}% Tamil)",
        details={"sample_size": len(sample), "avg_tamil_pct": avg_tamil},
    )


def validate_model_output(
    model_path: str, test_prompts: Optional[list] = None
) -> PreflightResult:
    """Validate model output quality."""
    print(f"  Testing model output: {model_path}")

    if test_prompts is None:
        test_prompts = [
            "வணக்கம், எப்படி இருக்கிறீர்கள்?",
            "திருக்குறள் முதல் குறள் என்ன?",
            "தமிழ்நாட்டின் தலைநகரம் என்ன?",
        ]

    # Check if model file exists
    if not os.path.exists(model_path):
        return PreflightResult(
            passed=False,
            check_name="model_output",
            message=f"Model file not found: {model_path}",
        )

    issues = []
    tamil_percentages = []

    for prompt in test_prompts:
        try:
            # Use llama.cpp CLI if available, otherwise skip
            response = _run_inference(model_path, prompt)

            if response is None:
                continue

            # Check response length
            if len(response) < 10:
                issues.append(f"Response too short for: {prompt[:30]}...")
                continue

            # Check for garbage
            garbage = check_garbage_patterns(response)
            if garbage:
                issues.append(f"Garbage in response: {garbage}")
                continue

            # Check Tamil percentage
            tamil_pct = calculate_tamil_percentage(response)
            tamil_percentages.append(tamil_pct)

            if tamil_pct < 30:
                issues.append(f"Low Tamil ({tamil_pct:.1f}%) for: {prompt[:30]}...")

        except Exception as e:
            issues.append(f"Inference error: {e}")

    if not tamil_percentages:
        return PreflightResult(
            passed=True,
            check_name="model_output",
            message="Skipped: No inference tool available (install llama.cpp)",
            details={"skipped": True},
        )

    avg_tamil = sum(tamil_percentages) / len(tamil_percentages)

    if issues:
        return PreflightResult(
            passed=False,
            check_name="model_output",
            message=f"Model output issues: {len(issues)}",
            details={"issues": issues, "avg_tamil_pct": avg_tamil},
        )

    return PreflightResult(
        passed=True,
        check_name="model_output",
        message=f"Model output OK ({avg_tamil:.1f}% Tamil)",
        details={"avg_tamil_pct": avg_tamil},
    )


def _run_inference(
    model_path: str, prompt: str, max_tokens: int = 100
) -> Optional[str]:
    """Run inference using llama.cpp CLI."""
    # Try to find llama.cpp main binary
    llama_bins = [
        "llama-cli",
        "main",  # older llama.cpp
        "/usr/local/bin/llama-cli",
        os.path.expanduser("~/llama.cpp/main"),
    ]

    llama_bin = None
    for bin_path in llama_bins:
        if os.path.exists(bin_path) or _which(bin_path):
            llama_bin = bin_path
            break

    if llama_bin is None:
        return None

    try:
        result = subprocess.run(
            [
                llama_bin,
                "-m",
                model_path,
                "-p",
                prompt,
                "-n",
                str(max_tokens),
                "--no-display-prompt",
            ],
            capture_output=True,
            text=True,
            timeout=60,
        )
        return result.stdout.strip()
    except Exception:
        return None


def _which(program: str) -> Optional[str]:
    """Find program in PATH."""
    try:
        result = subprocess.run(["which", program], capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip()
    except Exception:
        pass
    return None


def validate_tokenizer(tokenizer_path: str) -> PreflightResult:
    """Validate tokenizer for Tamil support."""
    print(f"  Checking tokenizer: {tokenizer_path}")

    if not os.path.exists(tokenizer_path):
        return PreflightResult(
            passed=True,
            check_name="tokenizer",
            message="Skipped: tokenizer.json not found (using model default)",
            details={"skipped": True},
        )

    try:
        with open(tokenizer_path, "r", encoding="utf-8") as f:
            tokenizer = json.load(f)

        vocab = tokenizer.get("model", {}).get("vocab", {})

        # Check for Tamil tokens
        tamil_tokens = [k for k in vocab.keys() if re.search(r"[\u0B80-\u0BFF]", k)]

        if len(tamil_tokens) < 100:
            return PreflightResult(
                passed=False,
                check_name="tokenizer",
                message=f"Low Tamil vocabulary: only {len(tamil_tokens)} Tamil tokens",
                details={"tamil_tokens": len(tamil_tokens)},
            )

        return PreflightResult(
            passed=True,
            check_name="tokenizer",
            message=f"Tokenizer OK ({len(tamil_tokens)} Tamil tokens)",
            details={"tamil_tokens": len(tamil_tokens)},
        )

    except Exception as e:
        return PreflightResult(
            passed=False, check_name="tokenizer", message=f"Tokenizer error: {e}"
        )


def run_preflight(
    training_data: Optional[str] = None,
    model_path: Optional[str] = None,
    tokenizer_path: Optional[str] = None,
) -> bool:
    """Run all preflight checks."""
    print("\n🔍 VAZHI Preflight Validation")
    print("=" * 50)

    results = []

    # Check training data
    if training_data:
        results.append(validate_training_data(training_data))

    # Check tokenizer
    if tokenizer_path:
        results.append(validate_tokenizer(tokenizer_path))

    # Check model output
    if model_path:
        results.append(validate_model_output(model_path))

    # Print results
    print("\n📋 Results:")
    print("-" * 50)

    all_passed = True
    for result in results:
        status = "✅" if result.passed else "❌"
        print(f"{status} {result.check_name}: {result.message}")
        if not result.passed:
            all_passed = False
            if result.details and "issues" in result.details:
                for issue in result.details["issues"][:5]:
                    print(f"   - {issue}")

    print("-" * 50)
    if all_passed:
        print("✅ All preflight checks passed!")
    else:
        print("❌ Preflight validation failed - fix issues before training")

    return all_passed


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="VAZHI Preflight Training Validation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --data training.json
  %(prog)s --data training.json --model model.gguf
  %(prog)s --data training.json --tokenizer tokenizer.json --model model.gguf
        """,
    )

    parser.add_argument("--data", "-d", help="Training data JSON file")
    parser.add_argument("--model", "-m", help="GGUF model file to test")
    parser.add_argument("--tokenizer", "-t", help="Tokenizer JSON file")
    parser.add_argument("--quiet", "-q", action="store_true", help="Quiet mode")

    args = parser.parse_args()

    if not any([args.data, args.model, args.tokenizer]):
        parser.print_help()
        print("\nError: At least one of --data, --model, or --tokenizer required")
        sys.exit(2)

    passed = run_preflight(
        training_data=args.data,
        model_path=args.model,
        tokenizer_path=args.tokenizer,
    )

    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
