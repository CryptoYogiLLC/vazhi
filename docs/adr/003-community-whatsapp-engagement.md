# ADR-003: Community Engagement via WhatsApp

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI needs mechanisms for:
1. **User feedback** - Bug reports, incorrect answers, suggestions
2. **Community content creation** - Crowdsourced Q&A pairs for training
3. **Support** - Help users with app issues

### Target Audience Constraints
- Tamil Nadu users are not on Discord or GitHub
- WhatsApp penetration: 95%+ of smartphone users
- Facebook is common but declining among youth
- Telegram is less popular in Tamil Nadu

### Options Evaluated

| Platform | Reach | Ease of Use | Content Organization |
|----------|-------|-------------|---------------------|
| WhatsApp | 95%+ | Excellent | Poor |
| Facebook Group | 70% | Good | Medium |
| Telegram | 30% | Good | Good |
| Custom Web Portal | 100% (via app) | Medium | Excellent |
| Discord | <5% | Poor | Excellent |

## Decision

We will use **WhatsApp** as the primary community engagement platform, with in-app feedback forms for structured data collection.

### Implementation

#### 1. User Feedback (In-App + WhatsApp)

```dart
// In-app feedback form
class FeedbackForm {
  String category;      // Bug / Wrong Answer / Suggestion / Other
  String description;
  String? conversationContext;  // Optional: include recent chat

  void submit() {
    // 1. Save locally (works offline)
    // 2. Sync to backend when online
    // 3. Offer "Send via WhatsApp" option
  }

  void sendViaWhatsApp() {
    final message = Uri.encodeComponent(
      "VAZHI Feedback\n"
      "Category: $category\n"
      "Issue: $description"
    );
    launchUrl("https://wa.me/91XXXXXXXXXX?text=$message");
  }
}
```

#### 2. Community Content Creation (WhatsApp Group)

- **Group Name**: "VAZHI Contributors - வழி பங்களிப்பாளர்கள்"
- **Purpose**: Submit Q&A pairs, discuss training data, share domain knowledge
- **Moderation**: Admins curate submissions into training data
- **Format**: Simple template for submissions

```
📝 New Q&A Submission

Pack: [Security/Government/Education/Legal/Healthcare/Culture]

கேள்வி (Question):
[Tamil or Tanglish question here]

பதில் (Answer):
[Tamil or Tanglish answer here]

Source: [Optional: where did you learn this?]
```

#### 3. Support Channel

- VAZHI WhatsApp Business number for support queries
- Auto-reply with common solutions
- Human follow-up for complex issues

## Consequences

### Positive
- **Maximum reach** - WhatsApp is ubiquitous in Tamil Nadu
- **Zero friction** - Users already know how to use it
- **Works offline** - In-app form saves locally, syncs later
- **Low cost** - WhatsApp Business is free
- **Trust** - Users trust WhatsApp for communication

### Negative
- **Content organization** - WhatsApp groups are chaotic
- **Searchability** - Hard to find past discussions
- **Moderation overhead** - Need active admins to curate content
- **No structured data** - Submissions need manual processing

### Mitigations
- In-app form provides structured feedback (category, description)
- WhatsApp group rules and templates for organized submissions
- Weekly curation sessions to process community contributions
- Future: Web portal for better organization when community grows

## Alternatives Considered

### Discord
- Pros: Excellent organization, channels, search
- Cons: <5% adoption in Tamil Nadu, intimidating for non-tech users
- Rejected: Target audience doesn't use Discord

### Custom Web Portal
- Pros: Perfect organization, structured submissions
- Cons: Development effort, requires internet, another login
- Rejected: Phase 2 consideration, too much for MVP

### Facebook Group
- Pros: Good reach, better organization than WhatsApp
- Cons: Algorithm limits reach, declining youth usage
- Rejected: WhatsApp has higher engagement

### Telegram
- Pros: Better organization than WhatsApp, channels feature
- Cons: Lower adoption in Tamil Nadu compared to WhatsApp
- Rejected: Fewer users would participate

## Future Evolution

When community reaches 500+ active contributors, consider:
1. **Simple web portal** for structured Q&A submissions
2. **Telegram channel** for announcements (one-way)
3. **GitHub discussions** for technical contributors

## Related
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
