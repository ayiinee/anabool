import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/route_constants.dart';
import '../widgets/camera_scan_overlay.dart';
import '../widgets/scan_qris_button.dart';
import 'scan_preview_page.dart';

class ScanCameraPage extends StatefulWidget {
  const ScanCameraPage({super.key});

  @override
  State<ScanCameraPage> createState() => _ScanCameraPageState();
}

class _ScanCameraPageState extends State<ScanCameraPage> {
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _flashEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera is available.');
      }

      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
        _flashEnabled = false;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = error.description ?? error.code;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _captureImage() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await controller.takePicture();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamed(
        RouteConstants.scanPreview,
        arguments: ScanPreviewArguments(
          imagePath: image.path,
          fromGallery: false,
        ),
      );
    } on CameraException catch (error) {
      _showSnackBar(error.description ?? 'Unable to capture image.');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );

    if (image == null || !mounted) {
      return;
    }

    Navigator.of(context).pushNamed(
      RouteConstants.scanPreview,
      arguments: ScanPreviewArguments(
        imagePath: image.path,
        fromGallery: true,
      ),
    );
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final nextValue = !_flashEnabled;
      await controller
          .setFlashMode(nextValue ? FlashMode.torch : FlashMode.off);
      if (!mounted) {
        return;
      }

      setState(() {
        _flashEnabled = nextValue;
      });
    } on CameraException catch (error) {
      _showSnackBar(error.description ?? 'Flash is not available.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildCameraContent()),
            const Positioned.fill(child: CameraScanOverlay()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Kembali',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ScanControls(
                bottomInset: bottomInset,
                flashEnabled: _flashEnabled,
                isCapturing: _isCapturing,
                onGalleryPressed: _pickFromGallery,
                onFlashPressed: _toggleFlash,
                onCapturePressed: _captureImage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    final controller = _cameraController;

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AnaboolColors.header),
      );
    }

    if (_errorMessage != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return _CameraErrorState(
        message: _errorMessage ?? 'Camera is not available.',
        onRetry: _initializeCamera,
        onGalleryPressed: _pickFromGallery,
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScanControls extends StatelessWidget {
  const _ScanControls({
    required this.bottomInset,
    required this.flashEnabled,
    required this.isCapturing,
    required this.onGalleryPressed,
    required this.onFlashPressed,
    required this.onCapturePressed,
  });

  final double bottomInset;
  final bool flashEnabled;
  final bool isCapturing;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFlashPressed;
  final VoidCallback onCapturePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 92 + bottomInset,
              padding: EdgeInsets.fromLTRB(30, 20, 30, bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ControlButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onPressed: onGalleryPressed,
                  ),
                  _ControlButton(
                    icon: flashEnabled
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    label: 'Flash',
                    active: flashEnabled,
                    onPressed: onFlashPressed,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: ScanQrisButton(
              isLoading: isCapturing,
              onPressed: onCapturePressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AnaboolColors.brown : AnaboolColors.ink;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AnaboolColors.peach,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AnaboolColors.peach,
        shape: const CircleBorder(),
        child: InkResponse(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 22, color: AnaboolColors.brownDark),
          ),
        ),
      ),
    );
  }
}

class _CameraErrorState extends StatelessWidget {
  const _CameraErrorState({
    required this.message,
    required this.onRetry,
    required this.onGalleryPressed,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onGalleryPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_rounded,
              color: AnaboolColors.header,
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              'Camera is unavailable',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
                OutlinedButton.icon(
                  onPressed: onGalleryPressed,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
