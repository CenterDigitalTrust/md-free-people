import 'dart:async';
import '../core/app_failure.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/capture/capture_service.dart';
import '../core/queue/sync_queue_manager.dart';
import '../core/localization/app_localizations.dart';

/// Uses actual camera frames and Android MediaRecorder; never fabricates media.
class CaptureScreen extends StatefulWidget {
  static bool captureInProgress = false;
  const CaptureScreen({super.key});
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  static const _audio = MethodChannel('org.mdsystem.mdfp/audio');
  CameraController? _camera;
  final _queue = SyncQueueManager();
  String _mode = 'photo';
  String? _deviceId;
  String? _error;
  bool _busy = false;
  bool _recording = false;

  @override
  void initState() {
    // Release camera resources when Android suspends the activity.
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    // A registered ID must exist before it is included in a signed record.
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    CameraController? pending;
    try {
      _deviceId = await _queue.prepareDevice();
      if (!await Permission.camera.request().isGranted) {
        throw const AppFailure('camera_permission');
      }
      await Permission.locationWhenInUse.request();
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw const AppFailure('camera_unavailable');
      pending = CameraController(cameras.first, ResolutionPreset.high,
          enableAudio: _mode == 'video');
      await pending.initialize();
      if (!mounted) {
        await pending.dispose();
        return;
      }
      _camera = pending;
    } catch (error) {
      await pending?.dispose();
      if (mounted) _error = error is AppFailure ? error.key : 'capture_error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Finalize an active recording before disposing its hardware session.
    if (state == AppLifecycleState.inactive && !_busy) {
      _suspend();
    } else if (state == AppLifecycleState.resumed &&
        _camera == null &&
        !_busy) {
      _initialize();
    }
  }

  Future<void> _suspend() async {
    // Native recording errors are surfaced rather than reported as successful.
    if (_recording) await _trigger();
    final camera = _camera;
    _camera = null;
    try {
      await camera?.dispose();
    } catch (error) {
      debugPrint('Camera disposal: $error');
    }
    if (mounted) setState(() {});
  }

  Future<void> _selectMode(String mode) async {
    // Video requires microphone permission and an audio-enabled camera session.
    if (_busy || _recording || mode == _mode) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (mode != 'photo' && !await Permission.microphone.request().isGranted) {
        throw const AppFailure('microphone_permission');
      }
      final description = _camera?.description;
      await _camera?.dispose();
      _camera = null;
      if (mode != 'audio' && description != null) {
        final camera = CameraController(description, ResolutionPreset.high,
            enableAudio: mode == 'video');
        _camera = camera;
        await camera.initialize();
      } else if (mode != 'audio') {
        final cameras = await availableCameras();
        final camera = CameraController(cameras.first, ResolutionPreset.high,
            enableAudio: mode == 'video');
        _camera = camera;
        await camera.initialize();
      }
      _mode = mode;
    } catch (error) {
      _error = error is AppFailure ? error.key : 'capture_error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _trigger() async {
    // Serialize recording transitions so repeated taps cannot corrupt a file.
    if (_busy || _deviceId == null) return;
    CaptureScreen.captureInProgress = true;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      XFile? capture;
      String? audioPath;
      if (_mode == 'photo') {
        final camera = _camera;
        if (camera == null || !camera.value.isInitialized)
          throw const AppFailure('camera_unavailable');
        capture = await camera.takePicture();
      } else if (!_recording) {
        if (_mode == 'video') {
          final camera = _camera;
          if (camera == null) throw const AppFailure('camera_unavailable');
          await camera.startVideoRecording();
        } else {
          final dir = await CaptureService.getEvidenceDirectory();
          await _audio.invokeMethod<void>('start', {
            'path':
                '${dir.path}/MDFP_${DateTime.now().microsecondsSinceEpoch}.m4a',
          });
        }
        _recording = true;
        return;
      } else {
        if (_mode == 'video') {
          capture = await _camera!.stopVideoRecording();
        } else {
          audioPath = await _audio.invokeMethod<String>('stop');
          if (audioPath == null) throw const AppFailure('audio_not_saved');
        }
        _recording = false;
      }
      final dir = await CaptureService.getEvidenceDirectory();
      final ext = _mode == 'photo'
          ? 'jpg'
          : _mode == 'video'
              ? 'mp4'
              : 'm4a';
      final file = audioPath != null
          ? File(audioPath)
          : await File(capture!.path).copy(
              '${dir.path}/MDFP_${DateTime.now().microsecondsSinceEpoch}.$ext');
      final evidence = await CaptureService().processCapturedFile(
          file: file,
          mediaType: _mode == 'photo'
              ? 'image/jpeg'
              : _mode == 'video'
                  ? 'video/mp4'
                  : 'audio/mp4',
          deviceId: _deviceId!);
      await _queue.enqueueEvidence(evidence);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('capture_saved'))));
    } catch (error) {
      _recording = false;
      _error = error is AppFailure ? error.key : 'capture_error';
    } finally {
      CaptureScreen.captureInProgress = _recording;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    // Android also releases the recorder when the activity is destroyed.
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep capture status explicit; GPS accuracy comes only from captured data.
    final loc = AppLocalizations.of(context);
    final camera = _camera;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('nav_capture'))),
      body: SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(loc.translate('capture_network_note'),
                textAlign: TextAlign.center)),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.all(12),
              child: Text(loc.translate(_error!),
                  style: const TextStyle(color: Colors.orange))),
        Expanded(
            child: Center(
                child: _mode == 'audio'
                    ? Icon(_recording ? Icons.mic : Icons.mic_none,
                        size: 96, color: _recording ? Colors.red : Colors.amber)
                    : camera != null && camera.value.isInitialized
                        ? CameraPreview(camera)
                        : TextButton(
                            onPressed: _busy ? null : _initialize,
                            child: Text(loc.translate('connect_camera'))))),
        if (_busy) const LinearProgressIndicator(),
        Wrap(
            spacing: 12,
            children: ['photo', 'video', 'audio']
                .map((mode) => ChoiceChip(
                    label: Text(loc.translate('mode_$mode')),
                    selected: _mode == mode,
                    onSelected:
                        _busy || _recording ? null : (_) => _selectMode(mode)))
                .toList()),
        Padding(
            padding: const EdgeInsets.all(18),
            child: FloatingActionButton(
                tooltip: loc
                    .translate(_recording ? 'stop_capture' : 'start_capture'),
                onPressed: _busy || _deviceId == null ? null : _trigger,
                backgroundColor: Colors.red,
                child:
                    Icon(_recording ? Icons.stop : Icons.fiber_manual_record))),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(loc.translate('capture_footer_note'),
                textAlign: TextAlign.center)),
      ])),
    );
  }
}
