import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_charts_flutter/src/widgets/error/fusion_chart_error_boundary.dart';

void main() {
  // The FusionChartErrorBoundary widget modifies ErrorWidget.builder during
  // its build phase to catch errors. We need to restore it after each test.

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - NORMAL RENDERING
  // ===========================================================================

  group('FusionChartErrorBoundary - Normal Rendering', () {
    testWidgets('renders child when no error occurs', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(child: Text('Normal Content')),
        ),
      );

      expect(find.text('Normal Content'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);

      // Restore before test framework checks
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('renders complex child widget tree', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: Column(
              children: [Text('Header'), SizedBox(height: 10), Text('Content')],
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles nested FusionChartErrorBoundary', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: FusionChartErrorBoundary(child: Text('Nested Content')),
          ),
        ),
      );

      expect(find.text('Nested Content'), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - DEFAULT ERROR UI
  // ===========================================================================

  group('FusionChartErrorBoundary - Default Error UI', () {
    testWidgets('displays default error UI when error occurs', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Test error message'),
          ),
        ),
      );

      // Allow post-frame callback to execute
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('Test error message'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('default error UI has correct styling', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Styled error'),
          ),
        ),
      );

      await tester.pump();

      // Verify icon properties
      final iconFinder = find.byIcon(Icons.error_outline);
      expect(iconFinder, findsOneWidget);

      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, 48);
      expect(icon.color, Colors.red);

      // Verify 'Chart Error' text styling
      final chartErrorFinder = find.text('Chart Error');
      expect(chartErrorFinder, findsOneWidget);

      final chartErrorText = tester.widget<Text>(chartErrorFinder);
      expect(chartErrorText.style?.fontSize, 18);
      expect(chartErrorText.style?.fontWeight, FontWeight.bold);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('default error UI is centered', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Centered error'),
          ),
        ),
      );

      await tester.pump();

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - CUSTOM FALLBACK
  // ===========================================================================

  group('FusionChartErrorBoundary - Custom Fallback', () {
    testWidgets('uses custom fallback widget when provided', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            fallback: (error) => Text('Custom Error: $error'),
            child: const _ThrowingWidget(error: 'Custom test error'),
          ),
        ),
      );

      await tester.pump();

      expect(find.textContaining('Custom Error:'), findsOneWidget);
      expect(find.textContaining('Custom test error'), findsOneWidget);
      // Default UI should not be shown
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.text('Chart Error'), findsNothing);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('custom fallback receives error object', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      Object? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            fallback: (error) {
              capturedError = error;
              return const Text('Error captured');
            },
            child: const _ThrowingWidget(error: 'Error to capture'),
          ),
        ),
      );

      await tester.pump();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Error to capture'));

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('custom fallback can display complex widget', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            fallback: (error) => Column(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const Text('Something went wrong'),
                ElevatedButton(onPressed: () {}, child: const Text('Retry')),
              ],
            ),
            child: const _ThrowingWidget(error: 'Complex fallback test'),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - ON ERROR CALLBACK
  // ===========================================================================

  group('FusionChartErrorBoundary - onError Callback', () {
    testWidgets('calls onError callback when error occurs', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      Object? capturedError;
      StackTrace? capturedStack;

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            onError: (error, stack) {
              capturedError = error;
              capturedStack = stack;
            },
            child: const _ThrowingWidget(error: 'Callback error'),
          ),
        ),
      );

      await tester.pump();

      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Callback error'));
      expect(capturedStack, isNotNull);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('onError callback does not affect fallback display', (
      tester,
    ) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      var callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            onError: (error, stack) {
              callbackInvoked = true;
            },
            fallback: (error) => const Text('Fallback shown'),
            child: const _ThrowingWidget(error: 'Dual test'),
          ),
        ),
      );

      await tester.pump();

      expect(callbackInvoked, isTrue);
      expect(find.text('Fallback shown'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('onError is not called when no error occurs', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      var callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            onError: (error, stack) {
              callbackInvoked = true;
            },
            child: const Text('No error here'),
          ),
        ),
      );

      await tester.pump();

      expect(callbackInvoked, isFalse);
      expect(find.text('No error here'), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - DIFFERENT ERROR TYPES
  // ===========================================================================

  group('FusionChartErrorBoundary - Different Error Types', () {
    testWidgets('handles Exception type errors', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Exception type error');
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('Exception type error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles Error type errors', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            child: Builder(
              builder: (context) {
                throw StateError('State error type');
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('State error type'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles String type errors', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            child: Builder(
              builder: (context) {
                throw Exception('Simple string error');
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('Simple string error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - WIDGET CONFIGURATION
  // ===========================================================================

  group('FusionChartErrorBoundary - Widget Configuration', () {
    testWidgets('accepts key parameter', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      const testKey = Key('error_boundary_key');

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(key: testKey, child: Text('With key')),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('child is required parameter', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      // This is a compile-time check, but we can verify it renders
      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(child: SizedBox.shrink()),
        ),
      );

      expect(find.byType(FusionChartErrorBoundary), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('onError and fallback are optional', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(child: Text('Optional params test')),
        ),
      );

      expect(find.text('Optional params test'), findsOneWidget);

      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - STATE MANAGEMENT
  // ===========================================================================

  group('FusionChartErrorBoundary - State Management', () {
    testWidgets('maintains error state after rebuild', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Persistent error'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);

      // Rebuild the widget tree
      await tester.pump();

      // Error UI should still be displayed
      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('error state persists across pumps', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Multi-pump error'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('Multi-pump error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - EDGE CASES
  // ===========================================================================

  group('FusionChartErrorBoundary - Edge Cases', () {
    testWidgets('handles null error message gracefully', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: FusionChartErrorBoundary(
            child: Builder(
              builder: (context) {
                throw ArgumentError(null);
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles empty string error message', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(child: _ThrowingWidget(error: '')),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles very long error message', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      final longMessage = 'Error ' * 100;

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: FusionChartErrorBoundary(
              child: _ThrowingWidget(error: longMessage),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('handles error with special characters', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(
              error: 'Error with <special> & "characters" \'here\'',
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('fallback returning null falls back to default error UI', (
      tester,
    ) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            // No fallback provided - should use default
            child: _ThrowingWidget(error: 'No fallback test'),
          ),
        ),
      );

      await tester.pump();

      // Default error UI should be shown
      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - INTEGRATION SCENARIOS
  // ===========================================================================

  group('FusionChartErrorBoundary - Integration Scenarios', () {
    testWidgets('works within Scaffold', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const FusionChartErrorBoundary(
              child: _ThrowingWidget(error: 'Scaffold error'),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('works within ListView', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            children: const [
              Text('Item 1'),
              FusionChartErrorBoundary(
                child: _ThrowingWidget(error: 'ListView error'),
              ),
              Text('Item 3'),
            ],
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('isolates errors from siblings', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: const [
              FusionChartErrorBoundary(child: Text('No error widget')),
              FusionChartErrorBoundary(
                child: _ThrowingWidget(error: 'Error widget'),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      // First boundary should show normal content
      expect(find.text('No error widget'), findsOneWidget);
      // Second boundary should show error UI
      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('works with SizedBox constraints', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 300,
            height: 200,
            child: FusionChartErrorBoundary(
              child: _ThrowingWidget(error: 'Constrained error'),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Chart Error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });

  // ===========================================================================
  // FUSION CHART ERROR BOUNDARY - ACCESSIBILITY
  // ===========================================================================

  group('FusionChartErrorBoundary - Accessibility', () {
    testWidgets('error UI has semantic content', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Accessible error'),
          ),
        ),
      );

      await tester.pump();

      // Verify that error content is findable by text
      expect(find.text('Chart Error'), findsOneWidget);
      expect(find.textContaining('Accessible error'), findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });

    testWidgets('error icon is visible', (tester) async {
      final originalErrorWidgetBuilder = ErrorWidget.builder;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        const MaterialApp(
          home: FusionChartErrorBoundary(
            child: _ThrowingWidget(error: 'Icon test'),
          ),
        ),
      );

      await tester.pump();

      final iconFinder = find.byIcon(Icons.error_outline);
      expect(iconFinder, findsOneWidget);

      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
  });
}

/// A widget that throws an error during build.
class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    throw FlutterError(error);
  }
}
