import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:farmeasy/utils/api_endpoints.dart';

void main() {
  test('API connection test', () async {
    final response = await http.get(Uri.parse(ApiEndpoints.login));
    expect(response.statusCode, isNot(equals(404)));
  });
}
