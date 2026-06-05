# Security Review

Review date: 2026-06-05

Scope:

- Static code scan for committed secrets and credentials
- Premium purchase flow
- Local persistence
- Sharing/export behavior
- External links
- Android/iOS permissions and release configuration
- Dependency freshness

This is a code-level review, not a penetration test.

## Summary

No committed API keys, tokens, passwords, private keys, Firebase configs, or
signing credentials were found in the repository during text scanning.

The main security concern is the premium entitlement flow. Premium access is
granted and restored from a local `SharedPreferences` boolean, and purchase
events are trusted without receipt or server-side validation. That is acceptable
only for local prototyping, not for a paid public release.

## Findings

### High: Premium Entitlement Is Client-Side And Tamperable

Files:

- `lib/providers/game_provider.dart`
- `lib/services/premium_purchase_service.dart`

Current behavior:

- Premium ownership is persisted under `chaos_premium_lifetime` in
  `SharedPreferences`.
- `PurchaseStatus.purchased` and `PurchaseStatus.restored` immediately grant
  premium entitlement.
- There is no receipt verification before unlocking premium content.
- There is no backend entitlement record.
- Refunded or revoked purchases are not handled.

Risk:

- A modified app, rooted/debuggable device, emulator, or local storage edit can
  unlock premium features.
- A fake or replayed purchase event could be trusted.
- Refunds/revocations may leave premium enabled locally.

Recommendation:

- Before paid release, verify purchase data before granting entitlement.
- Prefer a backend or a managed entitlement service for paid features.
- Store only a cached entitlement locally, not the source of truth.
- Re-check entitlement on app startup and restore flows.
- If no backend will exist for the first test release, disable IAP/premium
  monetization and treat premium as an internal test feature.

### Medium: Privacy Text Conflicts With Share Behavior

Files:

- `lib/services/app_localization_service.dart`
- `lib/services/share_service.dart`

Current behavior:

- Privacy copy says no data leaves the phone.
- The share report can intentionally send a screenshot and text report through
  other apps.
- Shared report content can include player names and game stats.

Risk:

- The privacy statement is too absolute.
- Users can share player names outside the app, which is expected behavior but
  should be stated clearly.

Recommendation:

- Update privacy text to say the app does not automatically transmit data, but
  users may explicitly share reports through the platform share sheet.
- Consider adding a confirmation or short note before sharing reports if the
  final product targets casual public users.

### Medium: Release Build Uses Debug Signing

File:

- `android/app/build.gradle.kts`

Current behavior:

- Release builds use `signingConfigs.getByName("debug")`.

Risk:

- Not suitable for production distribution.
- Weak release ownership and update-chain hygiene.

Recommendation:

- Configure a proper release keystore.
- Keep keystore files and passwords out of git.
- Use `key.properties` or CI secrets for local/CI signing configuration.

### Medium: Template Package Name And Store Link

Files:

- `android/app/build.gradle.kts`
- `lib/screens/home_screen.dart`

Current behavior:

- Android package ID is `com.example.chaos_wheel_party_game`.
- Rate-app link points to the same template package ID.

Risk:

- Store identity is not final.
- External link will be wrong after publishing unless updated.

Recommendation:

- Decide the final application ID before release.
- Derive store URLs from that final ID or centralize the ID in configuration.

### Low: Share Image Temporary Files Are Not Cleaned Immediately

File:

- `lib/services/share_file_saver_io.dart`

Current behavior:

- Screenshot share files are written to the temporary directory.
- Files use timestamped names and are left for OS temp cleanup.

Risk:

- Shared report images can remain in app temp storage longer than expected.

Recommendation:

- This is low risk because the data is user-initiated share output.
- Consider cleanup after share completion if the platform behavior allows it.

### Low: Dependency Updates Available

Current state:

- `flutter pub outdated` reports newer versions for direct dependencies:
  `audioplayers` and `in_app_purchase`.

Risk:

- No specific vulnerability was confirmed in this review.
- Older package versions can still miss bug fixes.

Recommendation:

- Upgrade dependencies in a separate branch.
- Re-run `flutter analyze`, `flutter test`, and manual IAP/audio smoke tests.

## Positive Notes

- No broad Android permissions were found in the main manifest.
- `INTERNET` is present only in debug/profile manifests for Flutter tooling.
- No analytics, ad SDK, Firebase, Sentry, Supabase, or custom backend API keys
  were found.
- Player names and round stats appear to live in memory unless explicitly
  shared by the user.
- Local persisted settings are limited to app preferences and premium status.

## Recommended Next Steps

1. Decide whether premium/IAP should be disabled for the first public test.
2. If premium remains enabled, design purchase verification before release.
3. Update privacy text to account for explicit user sharing.
4. Configure proper Android release signing.
5. Finalize Android package ID and update store links.
6. Run dependency upgrade/testing in a separate branch.

## Premium Rollout Notes

Current project state:

- The app does not appear to be registered in Google Play Console yet.
- Final Android package ID is not decided.
- Store-side premium product IDs are not created yet.
- Because the store product does not exist yet, the final premium entitlement
  flow cannot be completed today.
- Expected paid features are likely to include Premium and/or No Ads. No Ads may
  also be included inside Premium.

Interim test approach:

- During local/internal gameplay tests, premium features can be enabled for all
  testers or unlocked only in debug/internal builds.
- This should be treated as a test convenience, not as a purchase entitlement.
- Purchase testing should be handled separately once the app and product exist
  in Google Play Console.
- The app should not claim production-ready paid premium until store products,
  test accounts, restore behavior, and entitlement verification are in place.

Important distinction:

- Gameplay testing can run with premium unlocked for everyone.
- Billing testing must still test the real Google Play purchase flow.
- Production premium must not rely on a local boolean as the only source of
  truth.
- Production No Ads / Premium should be granted from store-verified entitlement,
  not from a user-editable local flag.

## Privacy And KVKK Notes

This is not legal advice, but the project should not ignore privacy compliance.

Based on the current code, the app does not appear to automatically transmit
player aliases, analytics, account data, or backend data. That lowers the
privacy risk, but it does not remove all privacy obligations.

Current product assumptions:

- There is no account system.
- Player names are intended as temporary party nicknames / aliases.
- Player aliases should not be persisted after the game session.
- Local settings stored on the device are acceptable.
- Ads are planned but not integrated yet.
- Firebase analytics may be added later.
- Banner/interstitial ads are likely; rewarded ads may be added later.

KVKK-relevant points:

- Player aliases are lower risk if they are temporary nicknames and are not
  persisted or uploaded.
- Player aliases could still become personal data if users enter real names.
- Report sharing should be reviewed. The current code has a share report flow in
  `lib/services/share_service.dart`; if this feature remains, shared content may
  include aliases and game stats.
- App settings and premium status are stored locally on the device.
- If Firebase, ads, crash reporting, remote config, or backend services are
  added later, the privacy review must be repeated.
- Rewarded ads need extra care if they grant in-game benefits. Rewards should be
  limited to low-value gameplay benefits unless server-side verification is
  added.

Minimum practical requirement before public release:

- Prepare a clear privacy policy / aydinlatma text.
- Say that the app does not automatically upload player aliases or game stats.
- Say that users can explicitly share reports through the device share sheet.
- Say what is stored locally.
- Say which third-party services are used, such as Google Play Billing and any
- future Firebase/AdMob/ads SDK.
- Fill Google Play Data safety accurately.

KVKK official guidance emphasizes that users must be informed about who
processes personal data, for what purpose, legal basis, transfer recipients,
collection method, and data subject rights. Google Play also requires developers
to disclose app data collection/sharing practices in the Data safety section.
