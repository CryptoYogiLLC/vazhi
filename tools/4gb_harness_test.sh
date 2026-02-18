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

echo "================================================"
echo "VAZHI 4GB Harness Test (No Flutter)"
echo "================================================"
echo "Model: $MODEL_FILE"
echo ""

# --- Step 1: Find Android NDK ---
if [ -z "$ANDROID_NDK_HOME" ]; then
    POSSIBLE_NDKS=(
        "$HOME/Library/Android/sdk/ndk/26.3.11579264"
        "$HOME/Library/Android/sdk/ndk/27.0.12077973"
        "$HOME/Library/Android/sdk/ndk/25.1.8937393"
    )
    for ndk in "${POSSIBLE_NDKS[@]}"; do
        if [ -d "$ndk" ]; then
            export ANDROID_NDK_HOME="$ndk"
            break
        fi
    done
fi

if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "ERROR: Android NDK not found. Set ANDROID_NDK_HOME."
    exit 1
fi
echo "NDK: $ANDROID_NDK_HOME"

# --- Step 2: Check adb connection ---
if ! adb get-state 1>/dev/null 2>&1; then
    echo "ERROR: No Android device connected via adb."
    exit 1
fi
DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
DEVICE_RAM=$(adb shell cat /proc/meminfo 2>/dev/null | grep MemTotal | awk '{print $2}')
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

cmake -S "$LLAMA_DIR" -B "$CMAKE_BUILD" \
    -G Ninja \
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
adb push "$LLAMA_CLI" /data/local/tmp/llama-cli
adb shell chmod 755 /data/local/tmp/llama-cli

# --- Step 6: Check if model exists on device ---
MODEL_PATH="/sdcard/Download/$MODEL_FILE"
if ! adb shell "[ -f '$MODEL_PATH' ]" 2>/dev/null; then
    echo ""
    echo "WARNING: Model not found at $MODEL_PATH on device."
    echo "Please download the model to the device first, or specify the correct path."
    echo ""
    echo "The model may be in the app's internal storage instead."
    echo "Trying app data directory..."

    # Try VAZHI app data directory
    APP_MODEL_PATH="/data/data/com.cryptoyogillc.vazhi/app_flutter/$MODEL_FILE"
    if adb shell "run-as com.cryptoyogillc.vazhi test -f '$MODEL_FILE'" 2>/dev/null; then
        echo "Found model in app data. Copying to /data/local/tmp/ ..."
        adb shell "run-as com.cryptoyogillc.vazhi cat '$MODEL_FILE'" > /tmp/model_copy.gguf
        adb push /tmp/model_copy.gguf "/data/local/tmp/$MODEL_FILE"
        MODEL_PATH="/data/local/tmp/$MODEL_FILE"
    else
        echo "Model not found in app data either."
        echo ""
        echo "To proceed, push the model manually:"
        echo "  adb push /path/to/$MODEL_FILE /data/local/tmp/"
        MODEL_PATH="/data/local/tmp/$MODEL_FILE"
        echo ""
        echo "Then re-run this script."
        exit 1
    fi
fi

# --- Step 7: Capture pre-inference memory state ---
echo ""
echo "=== Pre-Inference Memory State ==="
adb shell cat /proc/meminfo | head -5
echo ""

# --- Step 8: Run inference ---
echo "=== Running Inference (no Flutter) ==="
echo "Model: $MODEL_PATH"
echo "Prompt: 'வணக்கம்'"
echo "n_ctx=256, n_batch=1, n_predict=32"
echo ""

# Run with timeout and capture output + memory
adb shell "
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
adb shell cat /proc/meminfo | head -5

echo ""
echo "================================================"
echo "HARNESS TEST COMPLETE"
echo ""
echo "Compare these results with the Flutter app test:"
echo "  - If llama-cli ALSO crashes: OOM is model size, not Flutter"
echo "  - If llama-cli SUCCEEDS: Flutter overhead (~640 MB) is the cause"
echo "  - Check /proc/meminfo MemFree and MemAvailable values"
echo "================================================"
