# Release Checklist

This project has not been released or shared with external testers yet. Treat
this checklist as the minimum set of technical and product decisions required
before public testing or store submission.

## Decisions Needed From The Owner

- Final app name for Android, iOS, and web.
- Final Android package/application ID, for example `com.company.product`.
- Final iOS bundle identifier.
- Store accounts that will publish the app.
- Whether premium content is a one-time purchase, subscription, or disabled for
  the first test release.
- In-app purchase product IDs for Google Play and App Store.
- Age rating target and content boundaries for party prompts.
- Privacy policy URL and support/contact URL.
- Whether audio assets are fully licensed for commercial release.

## Android Release Blockers

- Replace `com.example.chaos_wheel_party_game` with the final package ID in
  `android/app/build.gradle.kts`.
- Replace the release debug signing config with a real release keystore setup.
- Confirm the app label in `android/app/src/main/AndroidManifest.xml`.
- Confirm billing configuration if in-app purchases remain enabled.
- Build and test an Android App Bundle:

```bash
flutter build appbundle --release
```

## iOS Release Blockers

- Set the final bundle identifier in Xcode.
- Configure signing team, provisioning, and capabilities.
- Configure App Store Connect in-app purchase products if premium remains
  enabled.
- Verify restore purchase behavior.
- Build and archive from Xcode or the Flutter/iOS release pipeline.

## In-App Purchase Readiness

- Define product IDs in stores and code/config.
- Test purchases with sandbox/test accounts.
- Verify purchase restoration.
- Decide whether receipt/server-side validation is required before release.
- Define behavior for failed, cancelled, pending, and refunded purchases.

## Quality Gates

Run these before any test distribution:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Before store upload:

```bash
flutter build appbundle --release
flutter build web
```

## Security And Privacy Review

- Confirm no secrets, API keys, or signing credentials are committed.
- Confirm local storage only contains non-sensitive game settings/state.
- Confirm sharing features do not expose unexpected user data.
- Confirm external links use trusted URLs.
- Confirm the privacy policy matches actual data collection and third-party SDKs.
