# ADR-008: App Store Distribution Strategy

## Status
Accepted

## Date
2026-02-05

---

## Context

VAZHI needs to be distributed to users on both Android and iOS. Options include:

1. **Official app stores** - Google Play, Apple App Store
2. **Alternative stores** - F-Droid (Android), direct APK
3. **Web app** - PWA (Progressive Web App)

### Considerations

| Factor | Official Stores | Alternative | Direct APK |
|--------|-----------------|-------------|------------|
| Trust | High | Medium | Low |
| Discoverability | High | Low | None |
| Updates | Automatic | Manual | Manual |
| Security | Reviewed | Varies | Risk of fakes |
| Cost | $25 + $99/yr | Free | Free |

### Security Concern: Impersonation

Direct APK distribution creates risk of:
- Fake VAZHI apps with malware
- Phishing apps stealing user data
- Users can't verify authenticity

This is especially concerning for VAZHI's target audience who may be less tech-savvy.

## Decision

We will distribute through **official app stores** for both platforms:
- **Android**: Google Play Store ($25 one-time)
- **iOS**: Apple App Store ($99/year)
- **Android bonus**: F-Droid (open-source app store, free)

### Distribution Matrix

| Platform | Primary | Secondary | Not Using |
|----------|---------|-----------|-----------|
| Android | Google Play | F-Droid | Direct APK |
| iOS | App Store | - | TestFlight (beta only) |

### Cost Commitment

| Year | Google Play | Apple | Total |
|------|-------------|-------|-------|
| Year 1 | $25 | $99 | $124 |
| Year 2+ | $0 | $99 | $99 |

This is acceptable for a funded community project. Covered by initial project budget.

### F-Droid Inclusion

F-Droid is the open-source app store for Android. Benefits:
- Builds from source (verified open-source)
- No proprietary dependencies
- Trusted by privacy-conscious users
- Free to publish

Requirements:
- App must be fully open-source ✅
- No proprietary dependencies (may need adjustments)
- Metadata in F-Droid format

### App Store Metadata

#### Google Play Listing

```yaml
title: "VAZHI - Tamil AI Assistant"
short_description: "Free Tamil AI chat assistant. Works offline."
full_description: |
  VAZHI (வழி) is a free, open-source Tamil language AI assistant.

  ✨ Features:
  • Chat in Tamil or Tanglish
  • Voice input and output
  • Works offline (Full version)
  • 6 specialized knowledge packs
  • No ads, no data collection

  📚 Knowledge Packs:
  • Security - Scam detection, cyber safety
  • Government - Schemes, services, documents
  • Education - Scholarships, exams, guidance
  • Legal - RTI, consumer rights
  • Healthcare - Hospitals, Siddha medicine
  • Culture - Thirukkural, temples, festivals

  🔒 Privacy First:
  • No account required
  • No data sent to servers (offline mode)
  • Open-source code

  வழி - The open path to Tamil AI

category: Education
content_rating: Everyone
```

#### App Store Connect (iOS)

```yaml
name: "VAZHI - Tamil AI"
subtitle: "Open-source Tamil assistant"
promotional_text: "Free AI chat in Tamil. Voice support. Works offline."
keywords: "tamil,ai,chatbot,assistant,language,india,education,government"
support_url: "https://github.com/CryptoYogiLLC/vazhi"
privacy_policy_url: "https://github.com/CryptoYogiLLC/vazhi/blob/main/PRIVACY.md"
```

## Consequences

### Positive
- **Trust** - Official stores provide legitimacy
- **Security** - App review catches obvious issues
- **Discoverability** - Users find app via store search
- **Auto-updates** - Users get latest version automatically
- **No impersonation** - Only one official VAZHI app

### Negative
- **Cost** - $99/year ongoing for Apple
- **Review delays** - App updates take 1-7 days to approve
- **Store policies** - Must comply with Apple/Google rules
- **Payment requirement** - Need business entity for stores

### Mitigations
- Budget $99/year for Apple developer account
- Plan releases to account for review time
- Review app store guidelines before features
- Use existing LLC (CryptoYogiLLC) for accounts

## App Store Compliance Checklist

### Google Play
- [ ] Privacy policy URL
- [ ] Data safety questionnaire completed
- [ ] Content rating questionnaire
- [ ] Target audience declared
- [ ] Signed APK/AAB

### Apple App Store
- [ ] Privacy policy URL
- [ ] App privacy labels configured
- [ ] Screenshots for all device sizes
- [ ] App review notes (explain offline LLM)
- [ ] Signed with distribution certificate

### Both Stores
- [ ] App icon (1024x1024)
- [ ] Feature graphic (Google) / Preview (Apple)
- [ ] Localized metadata (Tamil + English)
- [ ] Support contact information

## Release Process

```
1. Development complete
   └── Internal testing

2. Beta release
   ├── Google Play: Internal/Closed testing track
   └── iOS: TestFlight

3. Fix beta feedback

4. Production release
   ├── Google Play: Submit to production (1-3 days review)
   └── App Store: Submit for review (1-7 days)

5. Monitor and respond to reviews
```

## Related
- [ADR-007: Free + Donations Monetization](007-free-donations-monetization.md)
- [VAZHI Mobile Architecture](../architecture/VAZHI_MOBILE_ARCHITECTURE.md)
