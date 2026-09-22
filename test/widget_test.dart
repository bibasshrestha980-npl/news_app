import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/screens/category_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App starts with onboarding', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(
      find.text("Bringing the world's news\nto your fingertips"),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('News cards handle missing article fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NewsCard(article: {})),
      ),
    );
    expect(find.text('Unknown title'), findsOneWidget);
    expect(find.text('Unknown description'), findsOneWidget);
    await tester.tap(find.byType(NewsCard));
    await tester.pump();
    expect(find.text('No article URL available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
