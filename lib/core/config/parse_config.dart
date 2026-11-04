import 'package:flutter/foundation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract final class ParseConfig {
  static const String applicationId = 'blog-app';
  static const int port = 1337;
  static const String mountPath = '/parse';
  static const String _hostOverride = String.fromEnvironment('PARSE_HOST');
  static const String _androidEmulatorHost = '10.0.2.2';
  static const String _defaultHost = 'localhost';

  static String get host {
    if (_hostOverride.isNotEmpty) {
      return _hostOverride;
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? _androidEmulatorHost
        : _defaultHost;
  }

  static String get serverUrl => 'http://$host:$port$mountPath';

  static String get liveQueryUrl => 'ws://$host:$port$mountPath';

  static Future<void> initialize() async {
    await Parse().initialize(
      applicationId,
      serverUrl,
      liveQueryUrl: liveQueryUrl,
      autoSendSessionId: true,
      debug: false,
      coreStore: await CoreStoreSharedPreferences.getInstance(),
    );
  }
}
