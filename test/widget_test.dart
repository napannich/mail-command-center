import 'package:flutter_test/flutter_test.dart';
import 'package:mail_command_center/main.dart';

void main() {
  testWidgets('app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MailApp());
    expect(find.text('MAIL COMMAND CENTER'), findsOneWidget);
  });
}
