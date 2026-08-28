import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_up/core/theme/app_theme.dart';
import 'package:muscle_up/features/auth/auth_screen.dart';

void main() {
  Future<void> pumpAuthScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AuthScreen(),
        ),
      ),
    );
  }

  final passwordFieldFinder = find.ancestor(
    of: find.text("Password"),
    matching: find.byType(TextField),
  );

  testWidgets('defaults to Create Account, not a returning-user greeting', (
    tester,
  ) async {
    await pumpAuthScreen(tester);

    expect(find.text("CREATE ACCOUNT"), findsOneWidget);
    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Welcome back"), findsNothing);
    expect(find.text("Continue as Guest"), findsOneWidget);
  });

  testWidgets('switching to Log In hides the name field', (tester) async {
    await pumpAuthScreen(tester);

    await tester.tap(find.text("Log In"));
    await tester.pumpAndSettle();

    expect(find.text("LOG IN"), findsOneWidget);
    expect(find.text("Name"), findsNothing);
    // Email/Password persist across the toggle.
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
  });

  testWidgets(
    'password visibility toggle and hint only appear once the field is focused',
    (tester) async {
      await pumpAuthScreen(tester);

      TextField passwordField() =>
          tester.widget<TextField>(passwordFieldFinder);

      expect(passwordField().obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.text("6+ characters"), findsNothing);

      await tester.tap(passwordFieldFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.text("6+ characters"), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(passwordField().obscureText, isFalse);
    },
  );
}
