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
      // No SDK configuration/customer/account. Block any service transport.
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

  test('proxy: public setProxyURL reaches synchronous shared setter', () async {
    await Purchases.setProxyURL('https://proxy.invalid');
    expect(js('qa.Common.proxyUrl')!.dartify(), 'https://proxy.invalid');
  });

  test('proxy: handler does not require a Promise from the void JS setter',
      () async {
    // Diagnostic alias: bypass only the public method-name mismatch, so the
    // second failure in the same proxy path is independently visible.
    await plugin.handleMethodCall(const MethodCall('setProxyURL', {
      'proxyURLString': 'https://proxy.invalid/alias',
    }));
    expect(js('qa.Common.proxyUrl')!.dartify(), 'https://proxy.invalid/alias');
  });

}
