import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import './flutter-widgets-text.dart';

void main() {
  testWidgets('SelectableAutoLinkText renders a widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          'Dart packages https://pub.dev',
        ),
      ),
    );

    final selectableAutoLinkTextFinder = find.byType(SelectableAutoLinkText);
    expect(selectableAutoLinkTextFinder, findsOneWidget);
  });

  testWidgets('onTap is called on tap', (tester) async {
    var onTapCallCount = 0;
    var onLongPressCallCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          'https://pub.dev',
          onTap: (_) => onTapCallCount++,
          onLongPress: (_) => onLongPressCallCount++,
        ),
      ),
    );

    await tester.tap(find.text('https://pub.dev'));
    expect(onTapCallCount, 1);
    expect(onLongPressCallCount, 0);
  });

  testWidgets('onLongPress is called on longPress', (tester) async {
    var onTapCallCount = 0;
    var onLongPressCallCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          'https://pub.dev',
          onTap: (_) => onTapCallCount++,
          onLongPress: (_) => onLongPressCallCount++,
        ),
      ),
    );

    await tester.longPress(find.text('https://pub.dev'));
    expect(onTapCallCount, 0);
    expect(onLongPressCallCount, 1);
  });

  testWidgets('toolbar with COPY will be shown on double tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          'Text',
        ),
      ),
    );

    final Offset textOffset = textOffsetToPosition(tester, 1);
    await tester.tapAt(textOffset);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(textOffset);
    await tester.pumpAndSettle();

    expect(find.text('CUT'), findsNothing);
    expect(find.text('COPY'), findsOneWidget);
    expect(find.text('PASTE'), findsNothing);
    expect(find.text('SELECT ALL'), findsNothing);
  });

  testWidgets('toolbar with SELECT ALL will be shown on long press',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          'Text',
        ),
      ),
    );

    await tester.longPress(find.text('Text'));
    await tester.pumpAndSettle();

    expect(find.text('CUT'), findsNothing);
    expect(find.text('COPY'), findsNothing);
    expect(find.text('PASTE'), findsNothing);
    expect(find.text('SELECT ALL'), findsOneWidget);
  });

  testWidgets('onTransformDisplayLink is called for each url',
      (WidgetTester tester) async {
    var onTransformDisplayLinkCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SelectableAutoLinkText(
          '''
Dart packages https://pub.dev
Using packages https://flutter.dev/docs/development/packages-and-plugins/using-packages''',
          onTransformDisplayLink: (s) {
            onTransformDisplayLinkCount++;
            return LinkAttribute(s);
          },
        ),
      ),
    );

    expect(onTransformDisplayLinkCount, 2);
  });

  testWidgets('AutoLinkUtils.shrinkUrl shortens URL',
      (WidgetTester tester) async {
    const longURL =
        'https://github.com/miyakeryo/flutter_selectable_autolink_text';
    const shortenedURL = 'github.com/miyakeryo/flutter_…';
    final linkAttribute = AutoLinkUtils.shrinkUrl(longURL);

    expect(linkAttribute.text, shortenedURL);
  });

  testWidgets(
      'AutoLinkUtils.shrinkUrl does nothing if an invalid URL is provided',
      (WidgetTester tester) async {
    // Chosen to trigger a [FormatException]
    // Copied from https://github.com/dart-lang/sdk/blob/master/tests/corelib_2/uri_test.dart
    const iAmNotAURL = '_:';
    final linkAttribute = AutoLinkUtils.shrinkUrl(iAmNotAURL);

    expect(linkAttribute.text, iAmNotAURL);
  });
}
