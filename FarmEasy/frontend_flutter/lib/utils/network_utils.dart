import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'network_exceptions.dart';

class NetworkUtils {
  static HttpClient createDevHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback =
        (cert, host, port) => true; // Bypass for local dev
    return client;
  }

  static Future<String> getRequest(String url,
      {int retries = 3, Duration timeout = const Duration(seconds: 10)}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final client = createDevHttpClient();
        final request = await client.getUrl(Uri.parse(url)).timeout(timeout);
        final response = await request.close();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return await response.transform(utf8.decoder).join();
        } else {
          throw ApiException('API error', response.statusCode);
        }
      } on SocketException {
        if (attempt == retries - 1) {
          throw NetworkException('No internet connection.');
        }
      } on ApiException {
        if (attempt == retries - 1) rethrow;
      } catch (e) {
        if (attempt == retries - 1) throw NetworkException(e.toString());
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw NetworkException('Failed after $retries attempts.');
  }

  static void logRequest(String url,
      {String? method, Map<String, dynamic>? params}) {
    debugPrint('[NETWORK] $method $url');
    if (params != null) debugPrint('[PARAMS] $params');
  }

  static Future<bool> checkConnection(String url) async {
    try {
      await getRequest(url, retries: 1);
      return true;
    } catch (_) {
      return false;
    }
  }
}
