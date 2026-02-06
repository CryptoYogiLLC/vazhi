# ADR-007: Free + Donations Monetization Model

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI is an open-source community project serving Tamil speakers. We need a sustainable funding model that:

1. **Keeps the app free** - No barriers for low-income users
2. **Covers costs** - App store fees, hosting, development
3. **Aligns with mission** - Community-owned, not profit-driven
4. **Avoids exploitation** - No predatory monetization

### Cost Structure (Estimated Annual)

| Item | Cost | Notes |
|------|------|-------|
| Apple App Store | $99/year | Developer account |
| Google Play Store | $25 one-time | Lifetime |
| HuggingFace Spaces | $0 | Free tier for MVP |
| Domain (vazhi.app) | $15/year | Optional |
| **Total Year 1** | ~$140 | |
| **Total Year 2+** | ~$115 | |

### Monetization Options Evaluated

| Model | Pros | Cons |
|-------|------|------|
| Completely free | Maximum adoption | No sustainability |
| Freemium | Revenue stream | Excludes poor users |
| Ads | Revenue stream | Degrades UX, data concerns |
| Donations | Keeps free, sustainable | Uncertain income |
| Grants | Large amounts | Competitive, bureaucratic |
| Corporate sponsorship | Stable funding | Potential conflicts |

## Decision

We will adopt a **Free + Donations** model:
- App is 100% free with all features
- Optional donation button for those who want to support
- No ads, no premium tiers, no paywalls

### Implementation

#### In-App Donation Button

```dart
// lib/widgets/donate_button.dart
class DonateButton extends StatelessWidget {
  void _openDonationPage() {
    // Opens external donation page
    launchUrl('https://ko-fi.com/vazhi');
    // Or: 'https://www.buymeacoffee.com/vazhi'
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.favorite, color: Colors.red),
      title: Text('Support VAZHI'),
      subtitle: Text('Help keep VAZHI free for everyone'),
      trailing: Icon(Icons.open_in_new),
      onTap: _openDonationPage,
    );
  }
}
```

#### Settings Screen Placement

```
┌─────────────────────────────────────┐
│  ◀ Settings                         │
├─────────────────────────────────────┤
│                                     │
│  🌐 App Language                    │
│     Tamil                       ▶   │
│                                     │
│  🔊 Voice Settings                  │
│     Voice output, speed         ▶   │
│                                     │
│  💾 Storage                         │
│     Manage downloads            ▶   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ❤️ Support VAZHI                   │
│     Help keep VAZHI free for all    │
│     [Opens donation page]           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ℹ️ About                           │
│     Version, licenses           ▶   │
│                                     │
└─────────────────────────────────────┘
```

### Donation Platform Choice

| Platform | Fees | Payout | UX |
|----------|------|--------|-----|
| **Ko-fi** | 0% (optional tip) | PayPal, Stripe | Simple |
| Buy Me a Coffee | 5% | Stripe | Popular |
| GitHub Sponsors | 0% | Bank | Developer-focused |
| Open Collective | 10% | Bank | Transparent |

**Recommendation**: Ko-fi (0% fees) or GitHub Sponsors (for transparency)

### Donation Messaging

**Tone**: Grateful, not guilt-inducing

✅ Good:
- "VAZHI is free forever. If you find it helpful, consider supporting our volunteer team."
- "Your support helps us improve VAZHI for everyone."

❌ Bad:
- "Donate or we'll shut down!"
- "Only $5 to unlock premium features!"
- Repeated pop-ups asking for donations

### When to Show Donation Option

| Context | Show? | Rationale |
|---------|-------|-----------|
| Settings page | ✅ Always | Non-intrusive, user-initiated |
| About page | ✅ Always | Users exploring app info |
| After positive interaction | ⚠️ Once per month | Gentle reminder |
| App startup | ❌ Never | Annoying, drives users away |
| During chat | ❌ Never | Interrupts core experience |

## Consequences

### Positive
- **100% accessible** - No one excluded by cost
- **Trust building** - Users appreciate no-ads, no-data-selling
- **Mission aligned** - Community project stays community-owned
- **Simple implementation** - External donation page, no payment integration
- **No app store issues** - Donations via website avoid IAP requirements

### Negative
- **Uncertain revenue** - May not cover costs
- **Scaling limits** - Can't hire paid developers
- **Sustainability risk** - Depends on community generosity

### Mitigations
- Keep costs minimal (free tiers, volunteer work)
- Pursue grants from foundations (e.g., Mozilla, Wikimedia)
- Accept corporate sponsorship if non-conflicting
- Build community of volunteer contributors

## Future Funding Options

If donations insufficient:

1. **Grants** - Apply to AI4Bharat, Mozilla Foundation, Google.org
2. **Academic partnerships** - Collaborate with Tamil Nadu universities
3. **Government programs** - Digital India initiatives
4. **Ethical sponsorship** - Non-competing orgs (e.g., Tamil publishers)

## Transparency Commitment

- Publish annual costs publicly
- Show how donations are used
- Open-source all code
- Community governance for major decisions

## Related
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
- [ADR-008: App Store Distribution](008-app-store-distribution.md)
