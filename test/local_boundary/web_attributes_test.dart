@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_flutter/web/purchases_flutter_web.dart';

JSAny? js(String code) =>
    globalContext.callMethod<JSAny?>('eval'.toJS, code.toJS);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final plugin = PurchasesFlutterPlugin();
  const channel = MethodChannel('purchases_flutter');

  setUpAll(() async {
    PurchasesFlutterPlugin.registerWith(webPluginRegistrar);
    expect(
        await plugin.handleMethodCall(const MethodCall('isConfigured')), false);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, plugin.handleMethodCall);
    js(r'''
      globalThis.qa = { unexpectedNetwork: 0 };
      globalThis.fetch = () => { qa.unexpectedNetwork++; throw Error('Network forbidden in local QA'); };
      XMLHttpRequest.prototype.open = function() { qa.unexpectedNetwork++; throw Error('Network forbidden in local QA'); };
      qa.Common = PurchasesHybridMappings.PurchasesCommon;
      qa.originalIsConfigured = qa.Common.isConfigured;
    ''');
  });

  tearDown(() {
    expect(js('qa.unexpectedNetwork')!.dartify(), 0);
    js('qa.Common.isConfigured = qa.originalIsConfigured; qa.Common.instance = null;');
  });

  final setters = <String, Future<void> Function()>{
    'setAttributes': () => Purchases.setAttributes({'color': 'blue'}),
    'setEmail': () => Purchases.setEmail('local@example.invalid'),
    'setPhoneNumber': () => Purchases.setPhoneNumber('5550100'),
    'setDisplayName': () => Purchases.setDisplayName('Local fixture'),
  };
  final expectedArgs = <String, Object>{
    'setAttributes': {'color': 'blue'},
    'setEmail': {r'$email': 'local@example.invalid'},
    'setPhoneNumber': {r'$phoneNumber': '5550100'},
    'setDisplayName': {r'$displayName': 'Local fixture'},
  };

  void arrange() {
    js(r'''
      qa.calls = [];
      qa.nativePromise = new Promise((resolve, reject) => { qa.resolve = resolve; qa.reject = reject; });
      qa.Common.instance = new qa.Common({setAttributes: function(attributes) {
        qa.calls.push(attributes);
        return qa.nativePromise;
      }});
      qa.Common.isConfigured = () => true;
      // Observe rejections without replacing the original promises.
      for (const method of ['setAttributes', 'setEmail', 'setPhoneNumber', 'setDisplayName']) {
        const original = qa.Common.instance[method];
        qa.Common.instance[method] = function(...args) {
          const promise = original.apply(this, args);
          promise.catch(() => {});
          return promise;
        };
      }
    ''');
  }

  for (final entry in setters.entries) {
    test('attributes: ${entry.key} forwards the documented value', () async {
      arrange();
      final future = entry.value();
      await Future<void>.delayed(Duration.zero);
      js('qa.resolve();');
      await future;
      expect(js('qa.calls')!.dartify(), [expectedArgs[entry.key]]);
    });

    test('attributes: ${entry.key} awaits shared Promise completion', () async {
      arrange();
      var completed = false;
      final future = entry.value().then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);
      final completedWhileUnderlyingPending = completed;
      js('qa.resolve();');
      await future;
      expect(completedWhileUnderlyingPending, false,
          reason:
              'Public Future completed while the real mapping Promise was pending');
    });

    test('attributes: ${entry.key} reports shared Promise rejection', () async {
      arrange();
      final outcome = entry
          .value()
          .then<Object?>((_) => null, onError: (Object error) => error);
      await Future<void>.delayed(Duration.zero);
      js("qa.reject(new Error('local attribute failure'));");
      expect(await outcome, isA<PlatformException>(),
          reason:
              'A failed shared-layer attribute update must not report success');
    });
  }
}
