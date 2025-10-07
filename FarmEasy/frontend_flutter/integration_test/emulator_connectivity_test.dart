import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:farmeasy/main.dart' as app;
import 'package:farmeasy/services/api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app workflow test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final apiService = ApiService();
    final res = await apiService.get('/health');
    expect(res['status'], anyOf('healthy', 'ok'));

    // Optionally continue with UI login flow if the app routes to login by default
    // ... this part can be tailored to your current UI state
  });
}
