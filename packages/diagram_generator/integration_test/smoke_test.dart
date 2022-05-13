import 'package:diagram_generator/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test - app runs on device', (WidgetTester tester) async {
    const app.SmokeTestApp();
  });
}