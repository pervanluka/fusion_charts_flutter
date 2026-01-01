import 'package:flutter/material.dart';

class FusionChartErrorBoundary extends StatefulWidget {
  const FusionChartErrorBoundary({required this.child, super.key, this.onError, this.fallback});

  final Widget child;
  final void Function(Object error, StackTrace stack)? onError;
  final Widget Function(Object error)? fallback;

  @override
  State<FusionChartErrorBoundary> createState() => _FusionChartErrorBoundaryState();
}

class _FusionChartErrorBoundaryState extends State<FusionChartErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(_error!) ?? _buildDefaultError();
    }

    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _error = details.exception;
        });
        widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
      });
      return const SizedBox.shrink();
    };

    return widget.child;
  }

  Widget _buildDefaultError() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Chart Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
