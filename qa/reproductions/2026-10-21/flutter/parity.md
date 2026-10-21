# API parity review — October 21, 2026

Source comparison, not executed native integration. Public names were traced to wrappers and shared/native implementations; KMP uses model methods where other SDKs use singleton methods.

| SDK | Placement lookup | Attribute sync + offerings | Cached virtual currencies | Custom paywall impression |
|---|---|---|---|---|
| [purchases-ios](https://github.com/RevenueCat/purchases-ios/tree/be8143db92c960682ce2c7e99c226b8f775f3fbb) | Offerings.currentOffering(forPlacement:) | Present | Present | Present |
| [purchases-hybrid-common](https://github.com/RevenueCat/purchases-hybrid-common/tree/466bddb7170d6cef064c347c1c270817dc1617fe) | Present | Present | Present | Present |
| [react-native-purchases](https://github.com/RevenueCat/react-native-purchases/tree/c656a4274c6203c1c7d73c7a345307d2c1966a64) | Present | Present | Present | Present |
| [purchases-flutter](https://github.com/RevenueCat/purchases-flutter/tree/1d7bfb424e4596d638c9ac0a53e1ce3e18db16af) | Present | Present | Present | Present |
| [purchases-capacitor](https://github.com/RevenueCat/purchases-capacitor/tree/59927eeb5e8a8dc2ce904f20c1e6dc7c14308947) | Present | Present | Present | Present |
| [purchases-unity](https://github.com/RevenueCat/purchases-unity/tree/2eaa88667723db36ab745ed0abc41322b1ba3d21) | Present | Present | Present | Present |
| [purchases-kmp](https://github.com/RevenueCat/purchases-kmp/tree/0327678a5ddca1b8b1dc4bdd6ed2f020ea26c84e) | Offerings.getCurrentOfferingForPlacement() | Present | Present | Present |
| [cordova-plugin-purchases](https://github.com/RevenueCat/cordova-plugin-purchases/tree/f83961e065b9bf09684c2fda0156ce4564173881) | Not exposed; omitted from documented support list | No equivalent established | Present; known iOS cache defect already reported | No equivalent established |

## Contracts and limits

- Cordova and Capacitor now pin PurchasesHybridCommon **19.14.0**. Capacitor TypeScript internals also pin 19.14.0. The Flutter browser bundle is 19.14.0; app Dart package resolution is preserved in its lockfile.
- The official [placement support table](https://www.revenuecat.com/docs/tools/targeting/placements), checked October 21, lists iOS 4.38.0+, Android 7.7.0+, React Native 7.23.0+, Flutter 6.22.0+, Capacitor 7.5.0+, Unity 6.9.0+, and web 0.8.0+. Cordova is absent. That omission establishes documented support scope, not the reason for the gap. No claim that the absence is intentional was established.
- Cordova getOfferings provides the current/default offering, not placement selection or a synchronized attribute-dependent offerings refresh. Direct native shared APIs are not an equivalent public Cordova API. These are parity candidates, not confirmed published findings: the intended support policy and a genuine native integration for the proposed additive APIs remain unverified.
- KMP placement lookup is implemented on Offerings; its absence on Purchases is not a missing API. Unity exposes the four compared capabilities. Neither received device/runtime verification in this run.
- Existing nullable placement and cache defects retain their separate repository fingerprints. Source presence is not evidence of correct runtime behavior.
- React Native web custom paywall impression explicitly rejects unsupported use. Capacitor web is a documented mock fallback; neither is claimed as native feature parity proof.

## Exact revisions

- purchases-ios: `be8143db92c960682ce2c7e99c226b8f775f3fbb`
- purchases-hybrid-common: `466bddb7170d6cef064c347c1c270817dc1617fe`
- react-native-purchases: `c656a4274c6203c1c7d73c7a345307d2c1966a64`
- purchases-flutter: `1d7bfb424e4596d638c9ac0a53e1ce3e18db16af`
- purchases-capacitor: `59927eeb5e8a8dc2ce904f20c1e6dc7c14308947`
- purchases-unity: `2eaa88667723db36ab745ed0abc41322b1ba3d21`
- purchases-kmp: `0327678a5ddca1b8b1dc4bdd6ed2f020ea26c84e`
- cordova-plugin-purchases: `f83961e065b9bf09684c2fda0156ce4564173881`
