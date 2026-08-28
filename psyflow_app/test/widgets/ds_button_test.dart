import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/core/design_system/components/ds_button.dart';

void main() {
  group('DSButton Widget Tests', () {
    testWidgets('renders button label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSButton(
              label: 'Entrar na Plataforma',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Entrar na Plataforma'), findsOneWidget);
    });

    testWidgets('triggers onPressed callback when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSButton(
              label: 'Clique Aqui',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clique Aqui'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true and ignores tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSButton(
              label: 'Carregando...',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Carregando...'), findsNothing);

      await tester.tap(find.byType(DSButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('renders leading icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSButton(
              label: 'Adicionar Item',
              leadingIcon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Adicionar Item'), findsOneWidget);
    });
  });
}
