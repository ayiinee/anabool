import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/scan_session.dart';
import '../controllers/scan_controller.dart';
import '../widgets/scan_success_dialog.dart';

class ScanPreviewArguments {
  const ScanPreviewArguments({
    required this.imagePath,
    required this.fromGallery,
  });

  final String imagePath;
  final bool fromGallery;
}

class ScanPreviewPage extends StatefulWidget {
  const ScanPreviewPage({
    required this.arguments,
    super.key,
  });

  final ScanPreviewArguments arguments;

  @override
  State<ScanPreviewPage> createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  late final ScanController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = ScanController.create();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    final session =
        await _scanController.analyzeImage(widget.arguments.imagePath);
    if (!mounted) {
      return;
    }

    if (session == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _scanController.errorMessage ?? 'Unable to analyze this image.',
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _analyzeImage,
            ),
          ),
        );
      return;
    }

    await _showSuccessThenOpenResult(session);
  }

  Future<void> _showSuccessThenOpenResult(ScanSession session) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ScanSuccessDialog(),
    );

    await Future<void>.delayed(const Duration(milliseconds: 950));

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushReplacementNamed(
      RouteConstants.scanResult,
      arguments: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _scanController,
          builder: (context, _) {
            return Column(
              children: [
                _PreviewHeader(
                  title: widget.arguments.fromGallery
                      ? 'Gallery preview'
                      : 'Scan preview',
                  onBackPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: Image.file(
                      File(widget.arguments.imagePath),
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                _PreviewActions(
                  isLoading: _scanController.isLoading,
                  onRetakePressed: () => Navigator.of(context).pop(),
                  onAnalyzePressed: _analyzeImage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 10),
      child: Row(
        children: [
          Material(
            color: AnaboolColors.peach,
            shape: const CircleBorder(),
            child: InkResponse(
              customBorder: const CircleBorder(),
              onTap: onBackPressed,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AnaboolColors.brownDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({
    required this.isLoading,
    required this.onRetakePressed,
    required this.onAnalyzePressed,
  });

  final bool isLoading;
  final VoidCallback onRetakePressed;
  final VoidCallback onAnalyzePressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onRetakePressed,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retake'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AnaboolColors.brown,
                side: const BorderSide(color: AnaboolColors.brown),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: isLoading ? null : onAnalyzePressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.analytics_rounded),
              label: Text(isLoading ? 'Analyzing' : 'Analyze'),
              style: FilledButton.styleFrom(
                backgroundColor: AnaboolColors.brown,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
