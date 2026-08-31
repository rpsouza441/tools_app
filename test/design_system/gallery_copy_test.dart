import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tools_app/theme/theme.dart';

import 'design_system_gallery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Object?> clipboardData;

  setUp(() {
    clipboardData = <String, Object?>{'text': 'sentinel-not-hash'};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardData = Map<String, Object?>.from(
              call.arguments as Map<dynamic, dynamic>,
            );
            return null;
          }
          if (call.method == 'Clipboard.getData') {
            return clipboardData;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets(
    'gallery copy writes the displayed hash to the real clipboard before confirming',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: const Scaffold(body: DesignSystemGallery()),
        ),
      );

      await tester.ensureVisible(find.byTooltip('Copiar Hash SHA-256'));
      await tester.tap(find.byTooltip('Copiar Hash SHA-256'));
      // Do not pumpAndSettle: the gallery includes an indeterminate
      // CircularProgressIndicator in the loading status panel.
      await tester.pump();
      await tester.pump();

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, 'abc123def456');
      expect(find.text('Hash SHA-256 copiado'), findsOneWidget);
    },
  );
}
