# Flutter web attribute errors — October 21, 2026

In the real offline app, all four setter Futures report success on upstream. Four network errors then become unhandled JavaScript rejections. The fix makes the caller catch all four errors; no unhandled rejection is observed.

- Upstream: `1d7bfb424e4596d638c9ac0a53e1ce3e18db16af`
- Fix: `84c390be27729e0d582672d67288863ceb7c0cf9` (preserves the previous fix and merges the new upstream AdMob adapter commit)
- Reproduction: Flutter web in managed Chrome; real Test Store initialization and responses, followed by browser offline mode. No injected SDK results. No native-mobile claim.
- Project **SDK Bug Reporter** (`proj602cc762`), app **Test Store** (`app4ca00b430f`): https://app.revenuecat.com/projects/602cc762/apps/app4ca00b430f

## Run the app

Unzip `source.zip`. Supply the dedicated Test Store public SDK key in `app/lib/config.dart`; its value is omitted from this source handoff. The vendored SDK is the exact unmodified upstream revision above.

```sh
cd app
flutter pub get --enforce-lockfile
flutter build web --dart-define=VARIANT=upstream-2026-10-21 --output=../before
cd ..
python3 -m http.server 8902 --bind 127.0.0.1 --directory before
```

Open http://127.0.0.1:8902. Click **Initialize Test Store** and wait for the real customer/offerings response. In Chrome DevTools, switch the network to Offline, then click **Run attribute setters**. Observe four premature successes and four unhandled errors. Restore network access afterward.

To test the fix in the same app:

```sh
cd app/vendor/purchases_flutter
patch -p1 -i ../../../fix.patch
cd ../..
flutter build web --dart-define=VARIANT=fixed-2026-10-21 --output=../fixed
cd ..
python3 -m http.server 8903 --bind 127.0.0.1 --directory fixed
```

Repeat at http://127.0.0.1:8903. All four calls now reach the caller's error handler. The proxy setter succeeds on both builds; that separate historical defect remains fixed upstream.

## Tests

The core suite passes **196 tests** before and after. The focused browser regression runs pass 4 controls and fail 8 completion/error assertions before; all 12 pass after. These browser unit tests use controlled downstream promises and supplement the actual app captures. The new AdMob adapter's 12 existing tests also pass; those are unit tests, not live advertising integration.

Commands and exit codes are in `commands.json` and `test-results/`. Dependency locks are preserved. `source-provenance.json` records the SDK file and artifact hashes. Screenshot and video end frames were visually inspected. The four recordings contain 35–94 browser-rendered source frames, including a visible live clock, rather than two-frame stills. Encoded durations and frame counts are in `video-validation.json`.

## History

Existing issue: https://github.com/manyoneek/purchases-flutter/issues/3

Existing fix: https://github.com/manyoneek/purchases-flutter/pull/4

Introduced with the four web handlers in RevenueCat PR #1413, merged July 28, 2025; first affected source release tag 9.2.0. The previously preserved historical regression is unchanged. This is a current-baseline revalidation, not a new defect.
