import 'package:http/http.dart' as http;

Future<bool> testBackendConnection() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/health'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));
    return response.statusCode == 200;
  } catch (e) {
    // ignore: avoid_print
    print('Backend connection failed: $e');
    return false;
  }
}
