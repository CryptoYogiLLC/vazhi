#!/usr/bin/env python3
"""Test VAZHI Tamil model locally"""

from llama_cpp import Llama
import sys

MODEL_PATH = "models/gemma-2b-it-tamil-v0.1-alpha.Q4_K_M.gguf"

print("Loading model...")
llm = Llama(
    model_path=MODEL_PATH,
    n_ctx=512,
    n_threads=4,
    n_gpu_layers=99,  # Use Metal GPU
    verbose=False
)
print("Model loaded!")

test_prompts = [
    "தமிழ்நாட்டின் தலைநகரம் எது?",
    "திருக்குறளின் முதல் குறள் என்ன?",
    "வணக்கம், நீங்கள் யார்?",
    "இந்த SMS உண்மையா? 'நீங்கள் lottery வென்றீர்கள், ₹500 அனுப்புங்கள்'",
]

print("\n" + "="*60)
print("VAZHI Tamil Model Test")
print("="*60)

for prompt in test_prompts:
    print(f"\nQ: {prompt}")
    response = llm(
        f"### Instruction:\n{prompt}\n\n### Response:\n",
        max_tokens=150,
        stop=["###", "\n\n"],
        echo=False
    )
    answer = response['choices'][0]['text'].strip()
    print(f"A: {answer}")

print("\n" + "="*60)
print("Test complete!")
