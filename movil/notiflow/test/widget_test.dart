import 'package:flutter_test/flutter_test.dart';
import 'package:notiflow/main.dart';

void main() {
  testWidgets('loads client login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NotiflowApp(initialRoute: '/login'));

    expect(find.text('Sistema de Tramites'), findsOneWidget);
    expect(find.text('Acceso Cliente'), findsOneWidget);
  });
}
