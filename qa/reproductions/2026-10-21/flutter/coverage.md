# SDK review — October 21, 2026

No new defect met the full confirmation requirements. Existing Flutter web attribute failure was freshly reproduced and its fix revalidated on the new upstream baseline.

## Inventory and preserved work

76 public repositories, 76 verified existing clone origins, 21 forks, 3 archived repositories. No missing clones or failures. `hybrid-monetization-workshop` no longer appears in the public inventory; its existing clone was retained. Six direct manyoneek forks were verified and their default branches synchronized without changing fix/evidence branches. All 12 issue/PR destinations were checked; the resolved Flutter proxy pair remains closed, 11 fix PRs remain open, none merged. Ten findings have the exact same upstream source revision as their October 20 real-app/client runs; those earlier runs retain their original date and dependency evidence and were not relabeled as fresh app tests.

## Cordova

Reviewed current 8.2.5 / common 19.14.0 source: configuration defaults and StoreKit override, purchase error/cancellation routing, product change and zero proration values, nullable attribute forwarding, promoted purchase callbacks/self-removal, offerings/products success and error routes, native response helpers, refund error shape, virtual-currency cache miss handling and API parity. Existing suite: **54 pass**. Twelve added production-wrapper boundary tests: complete suite **66 pass**. TypeScript build passes. Native source still contains the two already reported cache/attribute defects; neither was reported again. No new native app run is claimed.

The refund helper checks presence of userCancelled. Current common refund error creation includes that field for cancellation, and omits it on ordinary failures; a fabricated `userCancelled: false` payload is not a supported-path reproduction of a new defect.

## Capacitor

Reviewed current 13.7.4 / common 19.14.0: custom impression option precedence, omitted/null options, empty offerings/packages, presentation/targeting metadata, proxy method/property preservation, native nullable completion and cache wrappers, configuration guards, and callback rejection mapping. Existing suite: **17 pass**. Eight added production-wrapper tests: complete suite **25 pass**. TypeScript compilation passes. The known native null-placement issue is already tracked. No new native app, Android, or live advertising coverage is claimed.

## Flutter

Upstream `1d7bfb424e4596d638c9ac0a53e1ce3e18db16af` adds the AdMob adapter after the previously verified source. The existing attribute fix was merged onto this baseline in an isolated worktree, preserving old branch/source history. New fix SHA: `84c390be27729e0d582672d67288863ceb7c0cf9`.

Freshly built the actual web client twice with the current source and locked dependencies. Online initialization fetched real Test Store customer info and offerings for synthetic users. Offline, the original SDK reports success from all four setters and produces four unhandled rejections. With the fix, the caller catches all four errors and no rejection is unhandled. Proxy configuration succeeds on current upstream. Inspected screenshots, recorded frames, and logs. These are real browser runs, not native-mobile claims.

- Core tests: **196 pass** before and after.
- Focused Chrome boundary regression: **4 pass / 8 fail** before; **12 pass** after. Controlled downstream promises are supplementary test coverage.
- New AdMob adapter: **12 existing tests pass**. Source review covered tracking-state lifetime, load/show placement precedence, callback reinstallation, and reward-verification completion. No live ad network or native AdMob integration was executed.
- Four real app recordings: 35–94 captured source frames, 2.77–10.83 seconds. A visible live clock prevents static two-frame output. Fresh English explainer reuses the unchanged, previously checked narration and replaces app footage and source/date labels.

## Cross-SDK parity

See parity.md for eight pinned SDK/native/shared comparisons. KMP's placement method is on Offerings, so it is a semantic equivalent. Cordova placement/sync/custom-impression gaps remain unconfirmed candidates; the placement documentation excludes Cordova and the support rationale and genuine native integration are unresolved. They were not published as bugs or silently treated as completed feature work.

## Test-scaffolding corrections

Initial added suites failed to compile because the Cordova self-referencing Jest mock lacked a type annotation and Capacitor no-argument mocks inferred empty argument tuples. Corrected test scaffolding; original SDK production source was not changed. Callback fixtures use the actual Cordova `{callbackID}` shape. First Flutter capture used a wrong local asset root and never loaded the app; it is excluded. Re-serving the unchanged builds at separate root URLs produced the valid captures.

Flutter tooling changed analysis_options.yaml files automatically. Those diffs are retained separately and the fresh worktrees' tracked files restored to their recorded revisions. Original clones and older dirty worktrees were left untouched. No schedule change, upstream GitHub write, merge, support request, production purchase, or real-customer interaction occurred.
