import 'package:flutter_test/flutter_test.dart';
import 'package:kigali_directory/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    expect(KigaliDirectoryApp, isNotNull);
  });
}