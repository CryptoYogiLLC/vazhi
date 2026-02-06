# VAZHI - Day 3: LoRA Fine-tuning Setup
# Run this in Google Colab with GPU runtime (T4 or better, A100 recommended)

# ============================================================
# CELL 1: Install Dependencies
# ============================================================
"""
!pip install unsloth
!pip install --no-deps trl peft accelerate bitsandbytes
!pip install datasets
"""

# ============================================================
# CELL 2: Upload Training Data
# ============================================================
"""
# Option A: Upload from local machine
from google.colab import files
uploaded = files.upload()  # Upload vazhi_train.json and vazhi_val.json

# Option B: Clone from GitHub (if data is in repo)
# !git clone https://github.com/CryptoYogiLLC/vazhi.git
# Training data will be in vazhi/data/
"""

# ============================================================
# CELL 3: Load Model with Unsloth
# ============================================================
"""
from unsloth import FastLanguageModel
import torch

# Load Qwen 2.5 3B with 4-bit quantization
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="Qwen/Qwen2.5-3B-Instruct",
    max_seq_length=2048,
    dtype=None,  # Auto-detect
    load_in_4bit=True,  # Use 4-bit quantization to save memory
)

print("Model loaded successfully!")
print(f"Model parameters: {model.num_parameters():,}")
"""

# ============================================================
# CELL 4: Configure LoRA Adapters
# ============================================================
"""
model = FastLanguageModel.get_peft_model(
    model,
    r=16,  # LoRA rank - higher = more capacity but slower
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                    "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,  # 0 is optimized
    bias="none",
    use_gradient_checkpointing="unsloth",  # Saves memory
    random_state=42,
)

print("LoRA adapters configured!")
"""

# ============================================================
# CELL 5: Define Tamil Chat Template
# ============================================================
"""
# VAZHI Tamil chat template
VAZHI_TEMPLATE = '''<|im_start|>system
நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர். தமிழிலும் Tanglish-லும் தெளிவாகவும் உதவியாகவும் பதிலளியுங்கள். நீங்கள் security, government services, education, legal rights, healthcare, மற்றும் Tamil culture பற்றி அறிவுள்ளவர்.
<|im_end|>
<|im_start|>user
{instruction}<|im_end|>
<|im_start|>assistant
{output}<|im_end|>'''

def format_prompt(example):
    return VAZHI_TEMPLATE.format(
        instruction=example["instruction"],
        output=example["output"]
    )

# Test the template
test_example = {
    "instruction": "RTI என்றால் என்ன?",
    "output": "RTI = Right to Information Act 2005. இது government information பெறும் உரிமை."
}
print("Sample formatted prompt:")
print(format_prompt(test_example))
"""

# ============================================================
# CELL 6: Load Training Data
# ============================================================
"""
from datasets import load_dataset
import json

# Load the training data
# If uploaded via files.upload():
with open("vazhi_train.json", "r") as f:
    train_data = json.load(f)
with open("vazhi_val.json", "r") as f:
    val_data = json.load(f)

# Or if cloned from GitHub:
# with open("vazhi/data/vazhi_train.json", "r") as f:
#     train_data = json.load(f)
# with open("vazhi/data/vazhi_val.json", "r") as f:
#     val_data = json.load(f)

print(f"Training samples: {len(train_data)}")
print(f"Validation samples: {len(val_data)}")

# Convert to HuggingFace dataset format
from datasets import Dataset

train_dataset = Dataset.from_list(train_data)
val_dataset = Dataset.from_list(val_data)

print(f"\\nSample entry:")
print(train_dataset[0])
"""

# ============================================================
# CELL 7: Configure Training Arguments
# ============================================================
"""
from transformers import TrainingArguments
from trl import SFTTrainer

training_args = TrainingArguments(
    # Output
    output_dir="./vazhi-base-lora",

    # Training hyperparameters
    num_train_epochs=3,
    per_device_train_batch_size=2,
    gradient_accumulation_steps=4,  # Effective batch size = 2 * 4 = 8

    # Learning rate
    learning_rate=2e-4,
    warmup_steps=50,

    # Optimization
    optim="adamw_8bit",
    weight_decay=0.01,
    fp16=not torch.cuda.is_bf16_supported(),
    bf16=torch.cuda.is_bf16_supported(),

    # Logging
    logging_steps=10,

    # Checkpointing (IMPORTANT for resume)
    save_steps=200,
    save_total_limit=3,

    # Evaluation
    eval_strategy="steps",
    eval_steps=200,

    # Misc
    seed=42,
    report_to="none",  # Disable wandb
)

print("Training arguments configured!")
print(f"Effective batch size: {training_args.per_device_train_batch_size * training_args.gradient_accumulation_steps}")
print(f"Epochs: {training_args.num_train_epochs}")
print(f"Checkpoints every: {training_args.save_steps} steps")
"""

# ============================================================
# CELL 8: Create Trainer
# ============================================================
"""
trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=train_dataset,
    eval_dataset=val_dataset,
    formatting_func=format_prompt,
    max_seq_length=2048,
    args=training_args,
    packing=False,  # Don't pack multiple samples
)

print("Trainer created!")
print(f"Training samples: {len(train_dataset)}")
print(f"Steps per epoch: {len(train_dataset) // (training_args.per_device_train_batch_size * training_args.gradient_accumulation_steps)}")
"""

# ============================================================
# CELL 9: Start Training!
# ============================================================
"""
print("=" * 50)
print("VAZHI Training Starting!")
print("=" * 50)
print(f"Training {len(train_dataset)} samples for {training_args.num_train_epochs} epochs")
print(f"Checkpoints will be saved every {training_args.save_steps} steps")
print("=" * 50)

# Train!
trainer_stats = trainer.train()

print("\\n" + "=" * 50)
print("Training Complete!")
print("=" * 50)
print(f"Total training time: {trainer_stats.metrics['train_runtime']:.2f} seconds")
print(f"Samples per second: {trainer_stats.metrics['train_samples_per_second']:.2f}")
"""

# ============================================================
# CELL 10: Save the Model
# ============================================================
"""
# Save the LoRA adapter
model.save_pretrained("vazhi-base-lora-final")
tokenizer.save_pretrained("vazhi-base-lora-final")

print("Model saved to vazhi-base-lora-final/")

# Download the model files
from google.colab import files
import shutil

# Zip the model folder
shutil.make_archive("vazhi-base-lora-final", 'zip', "vazhi-base-lora-final")

# Download
files.download("vazhi-base-lora-final.zip")
print("Model downloaded!")
"""

# ============================================================
# CELL 11: Test the Fine-tuned Model
# ============================================================
"""
# Enable inference mode
FastLanguageModel.for_inference(model)

def vazhi_chat(user_message):
    prompt = f'''<|im_start|>system
நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
<|im_end|>
<|im_start|>user
{user_message}<|im_end|>
<|im_start|>assistant
'''
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    outputs = model.generate(
        **inputs,
        max_new_tokens=256,
        temperature=0.7,
        do_sample=True,
        pad_token_id=tokenizer.eos_token_id,
    )
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    # Extract assistant response
    if "<|im_start|>assistant" in response:
        response = response.split("<|im_start|>assistant")[-1].strip()
    return response

# Test cases
test_questions = [
    "RTI என்றால் என்ன?",
    "Scam message-ஐ எப்படி identify பண்றது?",
    "திருக்குறளின் முதல் குறள் என்ன?",
    "CMCHIS card எப்படி apply பண்றது?",
    "12th படிச்சாச்சு, engineering-க்கு என்ன options?",
]

print("=" * 50)
print("VAZHI Model Test")
print("=" * 50)

for q in test_questions:
    print(f"\\nQ: {q}")
    print(f"A: {vazhi_chat(q)}")
    print("-" * 40)
"""

# ============================================================
# OPTIONAL: Resume from Checkpoint
# ============================================================
"""
# If training was interrupted, resume from last checkpoint:
# trainer.train(resume_from_checkpoint=True)

# Or specify a specific checkpoint:
# trainer.train(resume_from_checkpoint="./vazhi-base-lora/checkpoint-400")
"""
