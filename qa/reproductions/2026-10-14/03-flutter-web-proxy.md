# Flutter web: proxy configuration fails before SDK configuration

- **Finding:** RC-FLUTTER-20261014-001 (existing report, upgraded app verification).
- **Repository / commit:** RevenueCat/purchases-flutter, `2b4b1976cfd08607c0384f5d619672e99e762c32` (10.15.2).
- **Platform:** Flutter web in Chrome 155, Flutter 3.47.7. **Not an iOS/Android finding.**

## Expected / actual
`await Purchases.setProxyURL(url)` should store the proxy URL and complete. The runnable app instead catches `PlatformException(error, Unsupported operation: setProxyURLString not implemented on web platform, null, null)`.

## Reproduce
Build/serve `flutter-app` as documented in the bundle README. Before SDK configuration, click **Run proxy case**. This calls the public API against the unmodified production Flutter plugin; no method-channel replacement or mocked SDK is used.

## Command / result
`node record-web.cjs`: original app reproduces the exception; screenshot/video and raw UI text are under `flutter-proxy.*`.
`node record-web-fixed.cjs`: with the proposed vendor-only patch, the same public call completes successfully (`flutter-proxy-fixed.*`).
The preserved original regression command is `flutter test --platform chrome test/local_boundary/web_boundary_test.dart`: original 4 passed / 10 failed across both findings; temporary patch 14 passed.

## Suggested fix / impact
Accept `setProxyURLString` in the web dispatch table. Invoke shared `setProxyUrl` synchronously; it returns void, not a Promise. Patch: `fixes/flutter-web.patch`.
Web applications cannot complete documented proxy setup before configuration.

## Limits
The app establishes public setter failure and successful completion with the patch. The separate void-to-Promise error was established by the earlier targeted handler test, not independently exposed through the original app's blocked public route. No HTTP traffic was routed through an actual proxy. No native mobile or Wasm behavior is claimed.
