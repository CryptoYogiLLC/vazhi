# ADR-004: HuggingFace Spaces as VAZHI Lite Backend

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI Lite requires a cloud backend to serve LLM inference for users who cannot download the full model. Requirements:

1. **Cost**: Free or very low cost (community project)
2. **Reliability**: Reasonable uptime for user queries
3. **Latency**: 5-10 seconds acceptable for responses
4. **Scalability**: Handle initial user base (100s of concurrent users)
5. **Ease of deployment**: Simple to set up and maintain

### Options Evaluated

| Platform | Cost | GPU | Latency | Setup |
|----------|------|-----|---------|-------|
| HuggingFace Spaces (Free) | $0 | CPU / Free GPU | 5-15s | Easy |
| HuggingFace Spaces (Pro) | $9/mo | Dedicated GPU | 2-5s | Easy |
| Railway | $5-20/mo | CPU only | 10-20s | Medium |
| Render | $7-25/mo | CPU only | 10-20s | Medium |
| Modal | Pay-per-use | GPU | 2-5s | Medium |
| Replicate | Pay-per-use | GPU | 2-5s | Easy |
| AWS Lambda | Pay-per-use | CPU | 15-30s | Complex |

## Decision

We will use **HuggingFace Spaces (Free Tier)** with Gradio as the VAZHI Lite backend.

### Architecture

```
┌─────────────┐     ┌──────────────────────────────────────────┐
│ VAZHI Lite  │────▶│ HuggingFace Spaces                       │
│ Flutter App │     │                                          │
│             │     │  ┌─────────────────────────────────────┐ │
│  HTTP POST  │────▶│  │ Gradio App                          │ │
│  /api/chat  │     │  │                                     │ │
│             │◀────│  │ - Load Qwen 2.5 3B + VAZHI LoRA     │ │
│  JSON resp  │     │  │ - 4-bit quantization                │ │
│             │     │  │ - Accept prompt, return response    │ │
└─────────────┘     │  └─────────────────────────────────────┘ │
                    │                                          │
                    │  Hardware: Free CPU or community GPU     │
                    └──────────────────────────────────────────┘
```

### Gradio Implementation

```python
# app.py - HuggingFace Spaces
import gradio as gr
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import torch

# Load model with LoRA adapter
base_model = AutoModelForCausalLM.from_pretrained(
    "Qwen/Qwen2.5-3B-Instruct",
    torch_dtype=torch.float16,
    device_map="auto",
    load_in_4bit=True
)
model = PeftModel.from_pretrained(base_model, "CryptoYogiLLC/vazhi-lora")
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen2.5-3B-Instruct")

def chat(message: str, pack: str = "general") -> str:
    prompt = f"""<|im_start|>system
நீங்கள் VAZHI (வழி), தமிழ் மக்களுக்கான AI உதவியாளர்.
<|im_end|>
<|im_start|>user
{message}<|im_end|>
<|im_start|>assistant
"""
    inputs = tokenizer(prompt, return_tensors="pt").to(model.device)
    outputs = model.generate(**inputs, max_new_tokens=512, temperature=0.7)
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    # Extract assistant response
    if "<|im_start|>assistant" in response:
        response = response.split("<|im_start|>assistant")[-1].strip()
    return response

# Gradio interface with API
demo = gr.Interface(
    fn=chat,
    inputs=[
        gr.Textbox(label="Message"),
        gr.Dropdown(["general", "security", "government", "education",
                     "legal", "healthcare", "culture"], label="Pack")
    ],
    outputs=gr.Textbox(label="Response"),
    title="VAZHI API",
    api_name="chat"
)

demo.launch()
```

### Flutter Client

```dart
// lib/services/vazhi_api_service.dart
class VazhiApiService {
  static const String baseUrl =
    "https://cryptoyogillc-vazhi.hf.space/api/chat";

  Future<String> chat(String message, {String pack = "general"}) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": [message, pack]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"][0];
    } else {
      throw Exception("API error: ${response.statusCode}");
    }
  }
}
```

## Consequences

### Positive
- **Zero cost** - Free tier sufficient for MVP
- **Easy deployment** - Git push to deploy
- **Built-in UI** - Gradio provides testing interface
- **API included** - Gradio automatically creates REST API
- **Community GPU** - Can get free GPU time from HF community
- **Model hosting** - Models already on HuggingFace Hub

### Negative
- **Cold starts** - First request after idle can take 30-60s
- **Rate limits** - Free tier has usage limits
- **Shared resources** - Performance varies with platform load
- **No SLA** - Not suitable for production-critical apps

### Mitigations
- Keep Space warm with periodic pings from monitoring
- Show "warming up" message to users on cold start
- Upgrade to HF Pro ($9/mo) if usage grows
- Move to dedicated GPU (Modal/Replicate) for production

## Upgrade Path

| Stage | Platform | Cost | Trigger |
|-------|----------|------|---------|
| MVP | HF Spaces Free | $0 | Initial launch |
| Growth | HF Spaces Pro | $9/mo | >100 daily users |
| Scale | Modal / Replicate | ~$50/mo | >1000 daily users |
| Enterprise | Dedicated GPU | ~$200/mo | Revenue / grants |

## Alternatives Considered

### Railway/Render (CPU)
- Pros: More reliable, persistent
- Cons: CPU-only inference is 10-20s, costs $5-20/mo
- Rejected: HF Spaces has better free tier with GPU potential

### Modal (Pay-per-use GPU)
- Pros: Fast GPU inference, pay only for usage
- Cons: Requires payment setup, complex pricing
- Rejected: Overhead for community project MVP

### Self-hosted
- Pros: Full control
- Cons: Expensive, maintenance burden
- Rejected: Not appropriate for volunteer-run project

## Related
- [ADR-001: Hybrid App Strategy](001-hybrid-app-strategy.md)
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
