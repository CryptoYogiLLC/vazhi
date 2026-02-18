#!/bin/bash
# 4GB Device Harness Test
#
# Tests llama.cpp inference directly on a 4GB Android device WITHOUT Flutter,
# to isolate whether OOM is caused by model size or Flutter app overhead (~640 MB).
#
# Prerequisites:
#   - Android NDK installed (auto-detected from common paths)
#   - adb connected to target device
#   - Model GGUF file available on the device at /sdcard/Download/
#
# Usage:
#   ./tools/4gb_harness_test.sh <model_filename>
#
# Example:
#   ./tools/4gb_harness_test.sh google_gemma-3-270m-it-Q6_K_L.gguf

set -e

MODEL_FILE="${1:-google_gemma-3-270m-it-Q6_K_L.gguf}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.harness_build"
LLAMA_DIR="$BUILD_DIR/llama.cpp"

# --- Find adb ---
ADB="${ADB:-}"
if [ -z "$ADB" ]; then
    if command -v adb &>/dev/null; then
        ADB="adb"
    elif [ -f "$HOME/Library/Android/sdk/platform-tools/adb" ]; then
        ADB="$HOME/Library/Android/sdk/platform-tools/adb"
    else
        echo "ERROR: adb not found. Install Android SDK platform-tools or set ADB=/path/to/adb."
        exit 1
    fi
fi

echo "================================================"
echo "VAZHI 4GB Harness Test (No Flutter)"
echo "================================================"
echo "Model: $MODEL_FILE"
echo ""

# --- Step 1: Find Android NDK ---
if [ -z "$ANDROID_NDK_HOME" ]; then
    # Auto-detect: pick the latest NDK version available
    NDK_BASE="$HOME/Library/Android/sdk/ndk"
    if [ -d "$NDK_BASE" ]; then
        ANDROID_NDK_HOME=$(ls -d "$NDK_BASE"/* 2>/dev/null | sort -V | tail -1)
        export ANDROID_NDK_HOME
    fi
fi

if [ -z "$ANDROID_NDK_HOME" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "ERROR: Android NDK not found. Set ANDROID_NDK_HOME."
    exit 1
fi
echo "NDK: $ANDROID_NDK_HOME"

# --- Step 2: Check adb connection ---
if ! "$ADB" get-state 1>/dev/null 2>&1; then
    echo "ERROR: No Android device connected via adb."
    exit 1
fi
DEVICE_MODEL=$("$ADB" shell getprop ro.product.model 2>/dev/null | tr -d '\r')
DEVICE_RAM=$("$ADB" shell cat /proc/meminfo 2>/dev/null | grep MemTotal | awk '{print $2}')
echo "Device: $DEVICE_MODEL (${DEVICE_RAM} kB total RAM)"

# --- Step 3: Clone/update llama.cpp ---
mkdir -p "$BUILD_DIR"
if [ ! -d "$LLAMA_DIR" ]; then
    echo ""
    echo "Cloning llama.cpp..."
    git clone --depth 1 https://github.com/ggml-org/llama.cpp.git "$LLAMA_DIR"
else
    echo ""
    echo "Using existing llama.cpp at $LLAMA_DIR"
fi

# --- Step 4: Build llama-cli for Android ARM64 ---
echo ""
echo "Building llama-cli for Android ARM64..."
CMAKE_BUILD="$LLAMA_DIR/build-android-arm64"
mkdir -p "$CMAKE_BUILD"

CMAKE_GENERATOR="Unix Makefiles"
if command -v ninja &>/dev/null; then
    CMAKE_GENERATOR="Ninja"
fi

cmake -S "$LLAMA_DIR" -B "$CMAKE_BUILD" \
    -G "$CMAKE_GENERATOR" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-26 \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_VULKAN=OFF \
    -DGGML_OPENMP=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_TESTS=OFF

cmake --build "$CMAKE_BUILD" --target llama-cli -j$(sysctl -n hw.ncpu)

LLAMA_CLI="$CMAKE_BUILD/bin/llama-cli"
if [ ! -f "$LLAMA_CLI" ]; then
    echo "ERROR: llama-cli not found at $LLAMA_CLI"
    exit 1
fi
echo "Built: $LLAMA_CLI"
echo "Size: $(du -h "$LLAMA_CLI" | cut -f1)"

# --- Step 5: Push binary to device ---
echo ""
echo "Pushing llama-cli to device..."
"$ADB" push "$LLAMA_CLI" /data/local/tmp/llama-cli
"$ADB" shell chmod 755 /data/local/tmp/llama-cli

# --- Step 6: Check if model exists on device ---
# Check /data/local/tmp/ first (pushed via adb), then /sdcard/Download/
MODEL_PATH="/data/local/tmp/$MODEL_FILE"
if ! "$ADB" shell "[ -f '$MODEL_PATH' ]" 2>/dev/null; then
    MODEL_PATH="/sdcard/Download/$MODEL_FILE"
fi
if ! "$ADB" shell "[ -f '$MODEL_PATH' ]" 2>/dev/null; then
    echo ""
    echo "WARNING: Model not found on device."
    echo "Searched: /data/local/tmp/$MODEL_FILE"
    echo "Searched: /sdcard/Download/$MODEL_FILE"
    echo ""
    echo "To proceed, push the model manually:"
    echo "  $ADB push /path/to/$MODEL_FILE /data/local/tmp/"
    echo ""
    echo "Then re-run this script."
    exit 1
fi

# --- Step 7: Capture pre-inference memory state ---
echo ""
echo "=== Pre-Inference Memory State ==="
"$ADB" shell cat /proc/meminfo | head -5
echo ""

# --- Step 8: Run inference ---
echo "=== Running Inference (no Flutter) ==="
echo "Model: $MODEL_PATH"
echo "Prompt: 'வணக்கம்'"
echo "n_ctx=256, n_batch=1, n_predict=32"
echo ""

# Run with timeout and capture output + memory
"$ADB" shell "
    echo '--- Memory before inference ---'
    cat /proc/meminfo | head -5
    echo ''
    echo '--- Starting llama-cli ---'
    /data/local/tmp/llama-cli \
        -m '$MODEL_PATH' \
        -p 'வணக்கம்' \
        -n 32 \
        -c 256 \
        --batch-size 1 \
        --threads 2 \
        --no-display-prompt \
        2>&1
    EXIT_CODE=\$?
    echo ''
    echo '--- Exit code: \$EXIT_CODE ---'
    echo '--- Memory after inference ---'
    cat /proc/meminfo | head -5
" 2>&1 || echo "Process terminated (likely OOM)"

echo ""
echo "=== Post-Inference Memory State ==="
"$ADB" shell cat /proc/meminfo | head -5

echo ""
echo "================================================"
echo "HARNESS TEST COMPLETE"
echo ""
echo "Compare these results with the Flutter app test:"
echo "  - If llama-cli ALSO crashes: OOM is model size, not Flutter"
echo "  - If llama-cli SUCCEEDS: Flutter overhead (~640 MB) is the cause"
echo "  - Check /proc/meminfo MemFree and MemAvailable values"
echo "================================================"
