import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management_app/main.dart';
import 'package:visitor_management_app/providers/visitor_provider.dart';

void main() {
  testWidgets('VisitorApp launches and renders Visitor Desk dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => VisitorProvider(),
          ),
        ],
        child: const VisitorApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Visitor Desk'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Visitors'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
  });
}
