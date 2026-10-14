# Flutter web: attribute futures report success despite real network failure

- **Finding:** RC-FLUTTER-20261014-002 (existing report, upgraded app verification).
- **Repository / commit:** RevenueCat/purchases-flutter, `2b4b1976cfd08607c0384f5d619672e99e762c32` (10.15.2).
- **Platform:** Flutter web in Chrome 155, Flutter 3.47.7. **Not an iOS/Android finding.**

## Expected / actual
The futures returned by `setAttributes`, `setEmail`, `setPhoneNumber` and `setDisplayName` should reflect the underlying JavaScript operation's completion/rejection.
With a genuine SDK instance initialized against the dedicated Test Store, switching Chrome to Offline and calling these methods makes all four public futures report success. Four later browser `unhandledrejection` events carry RevenueCat network error code `"10"` / `Failed to fetch`. The caller's catch blocks never run.

## Reproduce
Build/serve `flutter-app` using the bundle README. Initialize Test Store online; wait for the real customer and offering to load. Set Chrome DevTools Network to Offline. Click **Run attribute setters**. Observe public success and four unhandled network errors. Restore Online afterward.
The app uses actual production Flutter, hybrid mapping, JavaScript SDK, and browser networking. No SDK functions, method channels, promises or responses are substituted. The page only observes browser rejection events.

## Command / result
`node record-web.cjs`: four premature-success results, four unhandled rejections. UI text, screenshots, video and sanitized network events preserved.
`node record-web-fixed.cjs`: same real offline flow with the proposed patch returns four `PlatformException(10, ...)` errors through the public futures and zero unhandled rejections.
Earlier focused test: `flutter test --platform chrome test/local_boundary/web_boundary_test.dart`; combined original 4 passed / 10 failed; temporary fix 14 passed.

## Suggested fix / impact
Await/convert the JavaScript Promise for all four setters and use the existing error mapper. Patch: `fixes/flutter-web.patch`.
Application retry/error handling misses failed attribute updates, and dependent work can proceed before completion.

## Limits
Dedicated synthetic Test Store users only. Offline errors can arise during the setter's prerequisite customer-info request before the attribute write; the evidence proves the setter discards its downstream failure, not a successful server-side update. No native mobile, real-store, physical-device or Wasm behavior is claimed.
