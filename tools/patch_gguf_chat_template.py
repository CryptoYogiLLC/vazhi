#!/usr/bin/env python3
"""
VAZHI GGUF Chat Template Patcher — Phase 1 Fix (ADR-014)

Adds the Gemma 3 `tokenizer.chat_template` to GGUF files that are missing it.
Uses `gguf-new-metadata --chat-template-config` to create patched copies.

Root cause: Without `tokenizer.chat_template`, llamadart falls back to ChatML
format, which Gemma 3 was never trained on → produces gibberish on Android.

Usage:
  python3 tools/patch_gguf_chat_template.py

Requires: gguf-new-metadata (from llama.cpp), huggingface_hub
"""

import json
import shutil
import subprocess
import sys
from pathlib import Path

from gguf import GGUFReader

GGUF_DIR = Path(__file__).parent / "gguf_test"
TOKENIZER_CONFIG = GGUF_DIR / "tokenizer_config.json"

# All GGUFs to patch (both trimmed and untrimmed lack the template)
GGUF_FILES = [
    "vazhi-v7_1-q4_k_m.gguf",              # untrimmed
    "vazhi-v7.1-trimmed-q4_k_m.gguf",       # trimmed Q4_K_M
    "vazhi-v7.1-trimmed-q3_k_m.gguf",       # trimmed Q3_K_M
    "vazhi-v7.1-trimmed-q2_k.gguf",         # trimmed Q2_K
]


def verify_template_missing(path: Path) -> bool:
    """Check that the GGUF is missing tokenizer.chat_template."""
    reader = GGUFReader(str(path))
    return "tokenizer.chat_template" not in reader.fields


def verify_template_present(path: Path) -> str | None:
    """Check that the GGUF has tokenizer.chat_template and return it."""
    reader = GGUFReader(str(path))
    if "tokenizer.chat_template" not in reader.fields:
        return None
    field = reader.fields["tokenizer.chat_template"]
    parts = field.parts
    data = field.data
    if len(data) == 1:
        part = parts[data[0]]
        return part.tobytes().decode("utf-8", errors="replace")
    return "<array>"


def patch_gguf(input_path: Path, config_path: Path) -> bool:
    """Patch a single GGUF by creating a copy with chat template added."""
    output_path = input_path.with_suffix(".patched.gguf")

    print(f"\n  Patching: {input_path.name}")
    print(f"  Output:   {output_path.name}")

    # Pre-check: template should be missing
    if not verify_template_missing(input_path):
        print(f"  SKIP: {input_path.name} already has tokenizer.chat_template")
        return True

    # Run gguf-new-metadata
    cmd = [
        "gguf-new-metadata",
        "--chat-template-config", str(config_path),
        "--force",
        "--verbose",
        str(input_path),
        str(output_path),
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"  ERROR: gguf-new-metadata failed")
        print(f"  stdout: {result.stdout}")
        print(f"  stderr: {result.stderr}")
        return False

    # Verify output has the template
    template = verify_template_present(output_path)
    if template is None:
        print(f"  ERROR: Patched file still missing chat_template!")
        output_path.unlink(missing_ok=True)
        return False

    # Verify template contains Gemma 3 markers
    if "<start_of_turn>" not in template or "<end_of_turn>" not in template:
        print(f"  ERROR: Template doesn't contain Gemma 3 markers!")
        print(f"  Template preview: {template[:200]}")
        output_path.unlink(missing_ok=True)
        return False

    # Size sanity check — patched should be very close to original
    # (only metadata added, tensors unchanged)
    orig_size = input_path.stat().st_size
    new_size = output_path.stat().st_size
    delta_kb = (new_size - orig_size) / 1024
    print(f"  Size: {orig_size / 1e6:.1f} MB → {new_size / 1e6:.1f} MB (delta: {delta_kb:+.1f} KB)")

    if abs(delta_kb) > 100:  # >100KB difference is suspicious
        print(f"  WARNING: Size difference > 100KB — verify manually")

    # Replace original with patched
    backup_path = input_path.with_suffix(".backup.gguf")
    print(f"  Backing up original to {backup_path.name}")
    shutil.move(str(input_path), str(backup_path))
    shutil.move(str(output_path), str(input_path))
    print(f"  Replaced original with patched version")
    print(f"  Template length: {len(template)} chars")
    print(f"  SUCCESS")

    return True


def main() -> None:
    print("VAZHI GGUF Chat Template Patcher — Phase 1 (ADR-014)")
    print("=" * 60)

    # Verify tokenizer config exists
    if not TOKENIZER_CONFIG.exists():
        print(f"ERROR: {TOKENIZER_CONFIG} not found")
        print("Run: huggingface-cli download google/gemma-3-1b-it tokenizer_config.json")
        sys.exit(1)

    # Verify it contains a chat_template
    with open(TOKENIZER_CONFIG) as f:
        config = json.load(f)
    template = config.get("chat_template")
    if not template:
        print("ERROR: tokenizer_config.json has no chat_template key")
        sys.exit(1)
    print(f"Chat template source: {TOKENIZER_CONFIG.name} ({len(template)} chars)")
    print(f"Template markers: <start_of_turn>={'YES' if '<start_of_turn>' in template else 'NO'}, "
          f"<end_of_turn>={'YES' if '<end_of_turn>' in template else 'NO'}")

    # Patch each GGUF
    results = {}
    for filename in GGUF_FILES:
        path = GGUF_DIR / filename
        if not path.exists():
            print(f"\n  SKIP: {filename} not found")
            results[filename] = "skipped"
            continue
        ok = patch_gguf(path, TOKENIZER_CONFIG)
        results[filename] = "OK" if ok else "FAILED"

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    for filename, status in results.items():
        print(f"  {filename}: {status}")

    failed = sum(1 for s in results.values() if s == "FAILED")
    if failed:
        print(f"\n  {failed} file(s) FAILED — check errors above")
        sys.exit(1)
    else:
        print(f"\n  All files patched successfully!")
        print(f"  Backups saved as *.backup.gguf")
        print(f"\n  Next: Run verification with llama-cli -cnv to confirm Tamil output")
        sys.exit(0)


if __name__ == "__main__":
    main()
