# Current app/client verification

Upstream: `RevenueCat/purchases-flutter` at `2218dec43c5ff7efda1e6bba63f4351a458038f4`. Captured October 20, 2026. 

Latest upstream already passes proxy configuration. All four attribute setters report success while offline and emit unhandled rejections before; after the fix their Futures reject and no unhandled rejection is observed.

[Runnable source and build instructions](source.zip). Extract to a fresh directory and follow its README. Before/fixed captures, exact commands, resolved dependency locks, results and test logs are included here. Historical introducing-commit execution remains separately labeled in the history files.
