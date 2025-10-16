import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hidden_camera_detector/core/logging/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

class InfraredScanScreen extends StatefulWidget {
  const InfraredScanScreen({super.key});

  @override
  State<InfraredScanScreen> createState() => _InfraredScanScreenState();
}

enum _CameraPermissionState { unknown, granted, denied, permanentlyDenied }

class _InfraredScanScreenState extends State<InfraredScanScreen>
    with WidgetsBindingObserver {
  static const List<double> _highContrastMatrix = <double>[
    1.6,
    1.6,
    1.6,
    0,
    -1.2,
    1.6,
    1.6,
    1.6,
    0,
    -1.2,
    1.6,
    1.6,
    1.6,
    0,
    -1.2,
    0,
    0,
    0,
    1,
    0,
  ];

  CameraController? _controller;
  Future<void>? _initializationFuture;
  CameraDescription? _cameraDescription;
  _CameraPermissionState _permissionState = _CameraPermissionState.unknown;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissionState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeController());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_disposeController());
    } else if (state == AppLifecycleState.resumed) {
      _refreshPermissionState();
    }
  }

  Future<void> _refreshPermissionState() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    final mapped = _mapStatus(status);
    if (mapped == _CameraPermissionState.granted) {
      setState(() {
        _permissionState = mapped;
        _initializationFuture = _initializeCameraController();
      });
    } else {
      setState(() {
        _permissionState = mapped;
        _initializationFuture = null;
        _initializationError = null;
      });
    }
  }

  _CameraPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return _CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return _CameraPermissionState.permanentlyDenied;
    }
    return _CameraPermissionState.denied;
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    final mapped = _mapStatus(status);
    if (mapped == _CameraPermissionState.granted) {
      setState(() {
        _permissionState = mapped;
        _initializationFuture = _initializeCameraController();
      });
    } else {
      setState(() {
        _permissionState = mapped;
        _initializationFuture = null;
      });
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (error, stackTrace) {
        AppLogger.log.warn(
          'Error disposing camera controller',
          data: {'error': error.toString()},
        );
        AppLogger.log.debug(stackTrace.toString());
      }
    }
  }

  Future<void> _initializeCameraController() async {
    try {
      await _disposeController();

      _cameraDescription ??= await _selectCamera();
      final description = _cameraDescription;
      if (description == null) {
        throw CameraException('CameraSelection', 'No suitable camera found.');
      }

      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _initializationError = null;
      });
    } on CameraException catch (error, stackTrace) {
      AppLogger.log.error(
        'Failed to initialize camera',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _initializationError = error.description ?? error.code;
      });
    } catch (error, stackTrace) {
      AppLogger.log.error(
        'Unexpected error while setting up camera',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _initializationError = error.toString();
      });
    }
  }

  Future<CameraDescription?> _selectCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return null;
      }
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
    } catch (error, stackTrace) {
      AppLogger.log.error(
        'Unable to enumerate cameras',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_permissionState) {
      case _CameraPermissionState.granted:
        return _buildCameraPreview();
      case _CameraPermissionState.denied:
        return _PermissionMessage(
          title: 'Enable camera access',
          message:
              'Infrared scanning relies on the camera feed. Grant access to continue.',
          primaryLabel: 'Enable Camera',
          onPrimaryPressed: _requestCameraPermission,
        );
      case _CameraPermissionState.permanentlyDenied:
        return _PermissionMessage(
          title: 'Camera access disabled',
          message:
              'Camera permission was disabled in Settings. Enable it to resume infrared scanning.',
          primaryLabel: 'Open Settings',
          onPrimaryPressed: openAppSettings,
          secondaryLabel: 'Retry',
          onSecondaryPressed: _requestCameraPermission,
        );
      case _CameraPermissionState.unknown:
        return const _LoadingState();
    }
  }

  Widget _buildCameraPreview() {
    final initialization =
        _initializationFuture ?? _initializeCameraController();

    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        if (snapshot.hasError || _initializationError != null) {
          return _ErrorState(
            message: 'Unable to access the camera. Please try again.',
            errorDetails: _initializationError ?? snapshot.error,
            onRetry: _requestCameraPermission,
          );
        }

        final controller = _controller;
        if (controller == null || !controller.value.isInitialized) {
          return _ErrorState(
            message: 'Camera failed to initialize. Please retry.',
            onRetry: _requestCameraPermission,
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Infrared Scan')),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(
                        _highContrastMatrix,
                      ),
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
                const _InstructionsPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PermissionMessage extends StatelessWidget {
  const _PermissionMessage({
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final FutureOr<void> Function() onPrimaryPressed;
  final String? secondaryLabel;
  final FutureOr<void> Function()? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Infrared Scan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
            const Spacer(),
            if (secondaryLabel != null && onSecondaryPressed != null) ...[
              OutlinedButton(
                onPressed: () => onSecondaryPressed?.call(),
                child: Text(secondaryLabel!),
              ),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: () => onPrimaryPressed(),
              child: Text(primaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionsPanel extends StatelessWidget {
  const _InstructionsPanel();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'How to scan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Slowly move your phone around the room. Infrared light sources will appear as bright white dots against the dark background.',
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infrared Scan')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    this.errorDetails,
    required this.onRetry,
  });

  final String message;
  final Object? errorDetails;
  final FutureOr<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Infrared Scan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Camera unavailable', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
            if (errorDetails != null) ...[
              const SizedBox(height: 12),
              Text(
                errorDetails.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: () => onRetry(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
