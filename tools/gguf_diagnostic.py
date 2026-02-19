#!/usr/bin/env python3
"""
VAZHI GGUF Forensic Diagnostic — Phase 0 (ADR-014 Hard Gate)

Compares untrimmed vs vocab-trimmed Gemma 3 GGUFs to find why
trimmed models produce English gibberish on 4GB Android.

Tests:
  0. Version pinning
  1. Metadata diff
  2. Special token verification

Usage:
  python3 tools/gguf_diagnostic.py

Requires: gguf (Python library from llama.cpp), llama-cli
"""

import subprocess
import sys
from collections import Counter
from pathlib import Path

from gguf import GGUFReader

GGUF_DIR = Path(__file__).parent / "gguf_test"
UNTRIMMED = GGUF_DIR / "vazhi-v7_1-q4_k_m.gguf"
TRIMMED = GGUF_DIR / "vazhi-v7.1-trimmed-q4_k_m.gguf"

# Critical metadata keys to compare
CRITICAL_KEYS = [
    "general.architecture",
    "general.name",
    "general.file_type",
    "tokenizer.ggml.model",
    "tokenizer.ggml.pre",
    "tokenizer.ggml.bos_token_id",
    "tokenizer.ggml.eos_token_id",
    "tokenizer.ggml.padding_token_id",
    "tokenizer.ggml.add_bos_token",
    "tokenizer.ggml.add_eos_token",
    "tokenizer.chat_template",
]

# Tokens that MUST exist in trimmed model for Gemma 3 chat to work
CRITICAL_TOKENS = [
    "<pad>",
    "<eos>",
    "<bos>",
    "<unk>",
    "<start_of_turn>",
    "<end_of_turn>",
    "<mask>",
]

# Token type names per GGUF spec
TOKEN_TYPE_NAMES = {
    1: "normal",
    2: "unknown",
    3: "control",
    4: "user_defined",
    5: "unused",
    6: "byte",
}


def banner(text: str) -> None:
    sep = "=" * 70
    print(f"\n{sep}")
    print(f"  {text}")
    print(sep)


def load_gguf_metadata(model_path: Path) -> dict:
    """Load GGUF and extract all metadata as {key: value} dict.

    GGUFReader fields have:
      - parts: list of numpy memmap arrays
      - data: indices into parts pointing to the actual values
      - types: list of GGUFValueType enums

    For arrays (tokens, token_type, scores):
      - data has N entries (one per array element)
      - Each parts[data[i]] is a numpy memmap

    For scalars:
      - data has 1 entry
    """
    reader = GGUFReader(str(model_path))
    metadata = {}
    for field in reader.fields.values():
        key = field.name
        parts = field.parts
        data = field.data

        if len(data) == 0:
            continue

        if len(data) > 1:
            # Array field
            values = []
            for idx in data:
                part = parts[idx]
                if hasattr(part, 'dtype'):
                    if part.dtype.kind in ('U', 'S') or part.dtype == 'uint8':
                        # String: decode bytes
                        values.append(part.tobytes().decode('utf-8'))
                    elif part.dtype.kind in ('i', 'u', 'f'):
                        # Numeric: extract scalar
                        values.append(part[0].item() if len(part) == 1 else part.tolist())
                    else:
                        values.append(part.tobytes().decode('utf-8', errors='replace'))
                else:
                    values.append(part)
            metadata[key] = values
        else:
            # Scalar field
            part = parts[data[0]]
            if hasattr(part, 'dtype'):
                if part.dtype.kind in ('i', 'u', 'f'):
                    val = part[0].item() if len(part) == 1 else part.tolist()
                else:
                    val = part.tobytes().decode('utf-8', errors='replace')
            elif hasattr(part, '__len__') and len(part) == 1:
                val = part[0]
                if hasattr(val, 'item'):
                    val = val.item()
            else:
                val = part
            metadata[key] = val

    return metadata


def extract_tokens(metadata: dict) -> tuple[list[str], list[int]]:
    """Extract token list and token_type array from metadata."""
    tokens = metadata.get("tokenizer.ggml.tokens", [])
    types_raw = metadata.get("tokenizer.ggml.token_type", [])
    # Ensure types are plain ints
    types = []
    for t in types_raw:
        if isinstance(t, int):
            types.append(t)
        elif hasattr(t, 'item'):
            types.append(t.item())
        elif isinstance(t, list) and len(t) == 1:
            types.append(int(t[0]))
        else:
            types.append(int(t))
    return tokens, types


def test0_versions() -> None:
    """Test 0: Record tool versions."""
    banner("TEST 0: Version Pinning")

    result = subprocess.run(
        ["llama-cli", "--version"],
        capture_output=True,
        text=True,
    )
    version_line = ""
    for line in (result.stdout + result.stderr).splitlines():
        if "version" in line.lower():
            version_line = line.strip()
            break
    print(f"  llama-cli: {version_line}")

    result = subprocess.run(
        ["python3", "--version"],
        capture_output=True,
        text=True,
    )
    print(f"  python3:   {result.stdout.strip()}")
    print(f"  gguf lib:  GGUFReader from gguf package")
    print(f"  untrimmed: {UNTRIMMED.name} ({UNTRIMMED.stat().st_size / 1e6:.1f} MB)")
    print(f"  trimmed:   {TRIMMED.name} ({TRIMMED.stat().st_size / 1e6:.1f} MB)")


def test1_metadata_diff(meta_u: dict, meta_t: dict) -> bool:
    """Test 1: Compare critical metadata between models."""
    banner("TEST 1: GGUF Metadata Diff")
    all_pass = True

    for key in CRITICAL_KEYS:
        val_u = meta_u.get(key, "<MISSING>")
        val_t = meta_t.get(key, "<MISSING>")

        # Truncate large values for display
        disp_u = str(val_u)[:80]
        disp_t = str(val_t)[:80]

        if val_u == val_t:
            status = "MATCH"
        elif key == "general.name":
            status = "OK (name differs)"
        elif key == "general.file_type":
            status = "OK (quant may differ)"
        elif key == "tokenizer.chat_template":
            if val_u == "<MISSING>" and val_t == "<MISSING>":
                status = "BOTH MISSING (expected for Gemma 3)"
            else:
                status = "MISMATCH"
                all_pass = False
        else:
            status = "*** MISMATCH ***"
            all_pass = False

        print(f"\n  {key}:")
        print(f"    untrimmed: {disp_u}")
        print(f"    trimmed:   {disp_t}")
        print(f"    status:    {status}")

    # Token counts
    tokens_u = meta_u.get("tokenizer.ggml.tokens", [])
    tokens_t = meta_t.get("tokenizer.ggml.tokens", [])
    print(f"\n  Token count:")
    print(f"    untrimmed: {len(tokens_u)}")
    print(f"    trimmed:   {len(tokens_t)}")
    expected = len(tokens_t) < len(tokens_u)
    print(f"    status:    {'OK (trimmed < untrimmed)' if expected else '*** UNEXPECTED ***'}")

    if all_pass:
        print("\n  >>> TEST 1 PASSED: All critical metadata matches")
    else:
        print("\n  >>> TEST 1 FAILED: Metadata mismatches found")
    return all_pass


def test2_special_tokens(meta_u: dict, meta_t: dict) -> bool:
    """Test 2: Verify special tokens in trimmed model."""
    banner("TEST 2: Special Token Verification")

    tokens_u, types_u = extract_tokens(meta_u)
    tokens_t, types_t = extract_tokens(meta_t)

    all_pass = True

    # 2a: Find critical tokens in both models
    print("\n  --- 2a: Critical Token Lookup ---")
    for tok_name in CRITICAL_TOKENS:
        idx_u = tokens_u.index(tok_name) if tok_name in tokens_u else None
        type_u = types_u[idx_u] if idx_u is not None and idx_u < len(types_u) else None

        idx_t = tokens_t.index(tok_name) if tok_name in tokens_t else None
        type_t = types_t[idx_t] if idx_t is not None and idx_t < len(types_t) else None

        missing = idx_t is None
        type_mismatch = (type_u is not None and type_t is not None and type_u != type_t)

        if missing:
            status = "*** MISSING FROM TRIMMED ***"
            all_pass = False
        elif type_mismatch:
            status = (
                f"*** TYPE MISMATCH: untrimmed={TOKEN_TYPE_NAMES.get(type_u, type_u)}, "
                f"trimmed={TOKEN_TYPE_NAMES.get(type_t, type_t)} ***"
            )
            all_pass = False
        else:
            status = "OK"

        type_u_name = TOKEN_TYPE_NAMES.get(type_u, str(type_u)) if type_u is not None else "N/A"
        type_t_name = TOKEN_TYPE_NAMES.get(type_t, str(type_t)) if type_t is not None else "N/A"

        print(f"\n  Token: {tok_name}")
        print(f"    untrimmed: id={idx_u}, type={type_u_name}")
        print(f"    trimmed:   id={idx_t}, type={type_t_name}")
        print(f"    status:    {status}")

    # 2b: Byte-fallback tokens
    print("\n  --- 2b: Byte-Fallback Tokens (<0x00> - <0xFF>) ---")
    byte_tokens_found = 0
    byte_tokens_wrong_type = 0
    for i in range(256):
        tok = f"<0x{i:02X}>"
        if tok in tokens_t:
            byte_tokens_found += 1
            idx = tokens_t.index(tok)
            t = types_t[idx] if idx < len(types_t) else None
            if t != 6:  # byte type
                byte_tokens_wrong_type += 1
                if byte_tokens_wrong_type <= 5:
                    print(f"    {tok}: id={idx}, type={TOKEN_TYPE_NAMES.get(t, t)} (expected byte=6)")

    if byte_tokens_found == 256 and byte_tokens_wrong_type == 0:
        print(f"    All 256 byte tokens present with correct type (byte)")
        print(f"    status: OK")
    else:
        print(f"    Found: {byte_tokens_found}/256, wrong type: {byte_tokens_wrong_type}")
        if byte_tokens_found < 256:
            print(f"    status: *** MISSING BYTE TOKENS ***")
            all_pass = False
        if byte_tokens_wrong_type > 0:
            print(f"    status: *** WRONG BYTE TOKEN TYPES ***")
            all_pass = False

    # 2c: Token type distribution comparison
    print("\n  --- 2c: Token Type Distribution ---")
    counter_u = Counter(types_u)
    counter_t = Counter(types_t)

    print(f"  {'Type':<20} {'Untrimmed':>12} {'Trimmed':>12} {'Delta':>12}")
    print(f"  {'-'*56}")
    all_types = sorted(set(list(counter_u.keys()) + list(counter_t.keys())))
    for t in all_types:
        name = TOKEN_TYPE_NAMES.get(t, f"type_{t}")
        cu = counter_u.get(t, 0)
        ct = counter_t.get(t, 0)
        delta = ct - cu
        print(f"  {name:<20} {cu:>12} {ct:>12} {delta:>+12}")

    # 2d: Verify bos/eos token IDs point to correct tokens
    print("\n  --- 2d: BOS/EOS Token ID Verification ---")
    bos_id_u = meta_u.get("tokenizer.ggml.bos_token_id")
    eos_id_u = meta_u.get("tokenizer.ggml.eos_token_id")
    bos_id_t = meta_t.get("tokenizer.ggml.bos_token_id")
    eos_id_t = meta_t.get("tokenizer.ggml.eos_token_id")

    for label, tok_id, tokens in [
        ("untrimmed BOS", bos_id_u, tokens_u),
        ("untrimmed EOS", eos_id_u, tokens_u),
        ("trimmed BOS", bos_id_t, tokens_t),
        ("trimmed EOS", eos_id_t, tokens_t),
    ]:
        if tok_id is not None and isinstance(tok_id, int) and tok_id < len(tokens):
            print(f"    {label}: id={tok_id} -> '{tokens[tok_id]}'")
        else:
            print(f"    {label}: id={tok_id} -> *** OUT OF RANGE OR MISSING ***")
            all_pass = False

    # 2e: Check if bos/eos IDs in trimmed still point to same token strings
    if (isinstance(bos_id_u, int) and isinstance(bos_id_t, int)):
        bos_tok_u = tokens_u[bos_id_u] if bos_id_u < len(tokens_u) else "OOR"
        bos_tok_t = tokens_t[bos_id_t] if bos_id_t < len(tokens_t) else "OOR"
        if bos_tok_u != bos_tok_t:
            print(f"    *** BOS TOKEN MISMATCH: untrimmed='{bos_tok_u}', trimmed='{bos_tok_t}' ***")
            all_pass = False

    if (isinstance(eos_id_u, int) and isinstance(eos_id_t, int)):
        eos_tok_u = tokens_u[eos_id_u] if eos_id_u < len(tokens_u) else "OOR"
        eos_tok_t = tokens_t[eos_id_t] if eos_id_t < len(tokens_t) else "OOR"
        if eos_tok_u != eos_tok_t:
            print(f"    *** EOS TOKEN MISMATCH: untrimmed='{eos_tok_u}', trimmed='{eos_tok_t}' ***")
            all_pass = False

    # 2f: Look for tokens near <start_of_turn>/<end_of_turn> position
    print("\n  --- 2f: Neighborhood Scan Around Turn Tokens ---")
    for tok_name in ["<start_of_turn>", "<end_of_turn>"]:
        if tok_name in tokens_t:
            idx = tokens_t.index(tok_name)
            start = max(0, idx - 2)
            end = min(len(tokens_t), idx + 3)
            neighbors = []
            for i in range(start, end):
                t = types_t[i] if i < len(types_t) else "?"
                marker = " <--" if i == idx else ""
                neighbors.append(f"      [{i}] '{tokens_t[i]}' type={TOKEN_TYPE_NAMES.get(t, t)}{marker}")
            print(f"  {tok_name} neighborhood in trimmed (id={idx}):")
            print("\n".join(neighbors))
        else:
            print(f"  {tok_name}: NOT FOUND in trimmed model")

    if all_pass:
        print("\n  >>> TEST 2 PASSED: All special tokens verified")
    else:
        print("\n  >>> TEST 2 FAILED: Token issues found")
    return all_pass


def main() -> None:
    print("VAZHI GGUF Forensic Diagnostic — Phase 0")
    print("ADR-014 Hard Gate: Trimmed GGUF must match HF behavior")

    for f in [UNTRIMMED, TRIMMED]:
        if not f.exists():
            print(f"ERROR: Model not found: {f}")
            sys.exit(1)

    # Test 0: Versions
    test0_versions()

    # Load GGUF metadata via GGUFReader
    banner("Loading GGUF metadata via GGUFReader...")
    print(f"  Reading {UNTRIMMED.name}...")
    meta_u = load_gguf_metadata(UNTRIMMED)
    print(f"  Reading {TRIMMED.name}...")
    meta_t = load_gguf_metadata(TRIMMED)
    print("  Done.")

    # Test 1: Metadata diff
    pass1 = test1_metadata_diff(meta_u, meta_t)

    # Test 2: Special tokens
    pass2 = test2_special_tokens(meta_u, meta_t)

    # Summary
    banner("DIAGNOSTIC SUMMARY")
    print(f"  Test 0 (Versions):       RECORDED")
    print(f"  Test 1 (Metadata):       {'PASS' if pass1 else 'FAIL'}")
    print(f"  Test 2 (Special Tokens): {'PASS' if pass2 else 'FAIL'}")
    print()

    if pass1 and pass2:
        print("  All metadata/token tests PASSED.")
        print("  Proceed to Test 3 (deterministic decode) and Test 4 (tokenization).")
    else:
        print("  *** FAILURES DETECTED — root cause likely in metadata/tokens ***")
        print("  Fix GGUF conversion before proceeding to decode tests.")

    sys.exit(0 if (pass1 and pass2) else 1)


if __name__ == "__main__":
    main()
