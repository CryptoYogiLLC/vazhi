# VAZHI Privacy Policy

**Last Updated: February 11, 2026**

## Overview

VAZHI (வழி) is a free, offline Tamil AI assistant. Your privacy is our core design principle. We built VAZHI to work without collecting your data.

## Data Collection

**We do NOT collect:**
- Personal information (name, email, phone)
- Chat messages or queries
- Location data
- Device identifiers
- Usage analytics or telemetry
- Browsing or search history

## How VAZHI Works

- **Offline-first**: VAZHI processes queries on your device using a local database and optional AI model
- **No accounts required**: No sign-up, no login, no user profiles
- **No cloud processing**: Your queries are never sent to external servers
- **No ads**: VAZHI has no advertising and no ad tracking
- **No third-party analytics**: We do not use Google Analytics, Firebase Analytics, or any tracking SDK

## Data Stored on Your Device

VAZHI stores the following data **locally on your device only**:

- **Chat history**: Your conversation history is stored in encrypted local storage (Hive with AES encryption). This data never leaves your device.
- **User preferences**: Language selection and settings are stored locally.
- **Downloaded AI model**: If you choose to download the optional AI model, it is stored on your device for offline inference.

You can delete all local data at any time by clearing the app data or uninstalling the app.

## Permissions

VAZHI requests the following permissions:

- **Internet**: Required for optional AI model download and app updates. Not used for data collection.
- **Microphone**: Required only for voice input feature (Tamil speech-to-text). Audio is processed on-device and is never recorded or transmitted.
- **Speech Recognition**: Required for converting speech to text on-device.
- **Storage**: Required for storing the optional AI model file on your device.

## Third-Party Services

VAZHI does not integrate with any third-party analytics, advertising, or data collection services.

If you choose to download the AI model, the download is served from HuggingFace (huggingface.co). HuggingFace's own privacy policy applies to the download connection only. No personal data is shared with HuggingFace.

## Children's Privacy

VAZHI does not knowingly collect any personal information from children. The app does not require age verification because it does not collect personal data from any user.

## Security

- Local chat data is encrypted using AES cipher with keys stored in platform-secure storage (Keychain on iOS, EncryptedSharedPreferences on Android)
- All user inputs are sanitized to prevent injection attacks
- Model downloads are verified with SHA256 checksums
- External URLs are restricted to an allowlist

## Changes to This Policy

We may update this privacy policy from time to time. Any changes will be reflected in the "Last Updated" date above and included in app updates.

## Contact

For privacy questions or concerns:

- GitHub: https://github.com/CryptoYogiLLC/vazhi
- Email: privacy@vazhi.app

## Open Source

VAZHI is open source. You can verify our privacy claims by reviewing the source code at https://github.com/CryptoYogiLLC/vazhi.
