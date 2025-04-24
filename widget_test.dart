//widget_test.dart
//04/23/2025
//Cristian Rodriguez
//verifies the app's functionality by simulating user interactions such as entering a name, selecting it, navigating to the flashcard screen, and verifying the correct display of flashcard content.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart';

void main() {
  testWidgets('Flashcard functionality test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpanishLearningApp());

    // Verify the title
    expect(find.text('Spanish Learning App'), findsOneWidget);

    // Enter name and press select
    await tester.enterText(find.byType(TextField), 'Cristian');
    await tester.tap(find.byType(ElevatedButton)); // Tap 'Select'

    await tester.pumpAndSettle();

    // Verify flashcards button
    expect(find.text('Flashcards'), findsOneWidget);

    // Tap flashcards button and go to flashcards screen
    await tester.tap(find.text('Flashcards'));
    await tester.pumpAndSettle();

    // Verify the flashcard text
    expect(find.text('Flashcard: Hola'), findsOneWidget);
  });
}
