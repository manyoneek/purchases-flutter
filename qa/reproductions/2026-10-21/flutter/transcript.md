# The Future succeeds before the request fails

https://github.com/manyoneek/purchases-flutter/pull/4

Flutter web attribute setters can report success before the underlying update finishes. When that update fails, the caller never receives the error.

The app first configures the real Test Store, then the browser goes offline. All four setter futures report success, while their JavaScript promises reject separately.

The shared setters return promises. The Dart web handlers discard them, so their futures complete immediately and lose the asynchronous failures.

The fix awaits and converts each JavaScript promise. The returned future now represents the actual operation and propagates its rejection to the caller.

In the same offline scenario, all four calls now report caught errors with no unhandled rejections. All twelve focused Chrome checks pass. This defect is specific to the web implementation.
