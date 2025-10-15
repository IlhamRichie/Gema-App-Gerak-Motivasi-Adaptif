import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../data/models/exercise_model.dart';
import '../../../data/providers/exercise_provider.dart';
import '../../../routes/app_pages.dart';

// Enum untuk melacak fase gerakan dalam satu repetisi
enum ExerciseStage { down, up }

class ExerciseController extends GetxController {
  // --- Variabel Konfigurasi & Status Misi ---
  late ExerciseConfig currentConfig;
  final String missionId = Get.arguments['missionId'];

  // --- Variabel State untuk UI ---
  final RxBool showInstructions = true.obs;
  final isCameraInitialized = false.obs;
  final Rx<Color> feedbackBorderColor = Colors.transparent.obs;

  // --- Variabel Internal untuk AI & Kamera ---
  var isProcessing = false;
  CameraController? cameraController;
  late CameraDescription frontCamera;
  Interpreter? interpreter;
  final RxList<List<double>> output = RxList<List<double>>([]);
  final int inputSize = 192;

  // --- Variabel Game & Countdown ---
  final RxInt repetitionCount = 0.obs;
  final Rx<ExerciseStage> stage = ExerciseStage.down.obs;
  final RxBool isReady = false.obs;
  final RxInt countdownValue = 3.obs;
  Timer? _countdownTimer;
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxDouble gameProgress = 0.0.obs;

  // =======================================================================
  // BLOK SIKLUS HIDUP (LIFECYCLE)
  // =======================================================================

  @override
  void onInit() {
    super.onInit();
    _setLandscapeMode();

    // 1. Muat konfigurasi latihan berdasarkan ID misi
    final config = ExerciseProvider.getConfigById(missionId);
    if (config == null) {
      Get.snackbar("Error", "Konfigurasi latihan tidak ditemukan!");
      Get.back(); // Kembali ke halaman home jika konfigurasi gagal dimuat
      return;
    }
    currentConfig = config;

    // 2. Lanjutkan proses inisialisasi model dan kamera
    loadModel().then((success) {
      if (success) {
        initializeCamera();
      } else {
        log("GAGAL MEMUAT MODEL AI");
        Get.snackbar("Error", "Gagal memuat model AI.");
      }
    });
  }

  @override
  void onClose() {
    _setPortraitMode(); // Kembalikan ke potret sebelum halaman ditutup
    _countdownTimer?.cancel();
    if (cameraController != null && cameraController!.value.isInitialized) {
      cameraController!.stopImageStream();
      cameraController!.dispose();
    }
    interpreter?.close();
    super.onClose();
  }

  // =======================================================================
  // BLOK KONTROL ALUR LATIHAN
  // =======================================================================

  // Dipanggil oleh tombol "Mulai Latihan" di view
  void startExerciseSequence() {
    showInstructions.value = false;
    startCountdown();
  }

  // Memulai countdown sebelum latihan
  void startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownValue.value > 1) {
        countdownValue.value--;
      } else {
        isReady.value = true;
        timer.cancel();
        startAiProcessing(); // Mulai proses AI setelah countdown selesai
      }
    });
  }

  // Memulai image stream dari kamera untuk diproses oleh model AI
  void startAiProcessing() {
    if (cameraController != null && cameraController!.value.isInitialized) {
      cameraController!.startImageStream((image) {
        if (!isProcessing) {
          isProcessing = true;
          runModelOnFrame(image);
        }
      });
    }
  }

  // =======================================================================
  // BLOK INSIALISASI & PENGATURAN
  // =======================================================================

  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<bool> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/movenet_lightning.tflite');
      log('Model loaded successfully');
      return true;
    } catch (e) {
      log('=== ERROR SAAT LOAD MODEL ===\nError: $e');
      return false;
    }
  }

  Future<void> initializeCamera() async {
    if (await Permission.camera.request().isGranted) {
      final cameras = await availableCameras();
      frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } else {
      Get.snackbar("Error", "Izin kamera diperlukan untuk latihan.");
    }
  }

  // =======================================================================
  // BLOK LOGIKA INTI (AI & GAME)
  // =======================================================================

  void runModelOnFrame(CameraImage image) {
    if (interpreter == null || !cameraController!.value.isInitialized) {
      isProcessing = false;
      return;
    }

    var processedImage = preprocessImage(image);
    if (processedImage == null) {
      isProcessing = false;
      return;
    }
    
    // Proses inferensi model
    var imageBytes = processedImage.getBytes(order: img.ChannelOrder.rgb);
    var inputTensor = imageBytes.buffer.asUint8List();
    var reshapedInput = inputTensor.reshape([1, inputSize, inputSize, 3]);
    var outputBuffer = List.filled(1 * 1 * 17 * 3, 0.0).reshape([1, 1, 17, 3]);
    interpreter!.run(reshapedInput, outputBuffer);

    // Ekstrak keypoints dari output model
    List<List<double>> keypoints = [];
    for (int i = 0; i < 17; i++) {
      double score = outputBuffer[0][0][i][2];
      if (score > 0.3) { // Ambang batas kepercayaan (confidence threshold)
        keypoints.add([outputBuffer[0][0][i][0], outputBuffer[0][0][i][1]]);
      } else {
        keypoints.add([-1.0, -1.0]); // Tandai sebagai tidak terdeteksi
      }
    }
    output.value = keypoints;

    // Jalankan logika game jika keypoints valid
    if (keypoints.length >= 17) {
      final p1 = keypoints[currentConfig.joint1.index];
      final p2 = keypoints[currentConfig.joint2.index];
      final p3 = keypoints[currentConfig.joint3.index];
      double angle = calculateAngle(p1, p2, p3);

      // Perbarui warna umpan balik berdasarkan sudut
      _updateFeedbackColor(angle);

      // Logika state machine untuk menghitung repetisi
      if (stage.value == ExerciseStage.down && angle > currentConfig.angleThresholdUp) {
        repetitionCount.value++;
        stage.value = ExerciseStage.up;
        audioPlayer.play(AssetSource('sounds/correct_beep.mp3'));
        gameProgress.value = repetitionCount.value / currentConfig.targetRepetitions;

        if (repetitionCount.value >= currentConfig.targetRepetitions) {
          cameraController?.stopImageStream();
          Get.offNamed(Routes.RESULT, arguments: {'score': repetitionCount.value});
        }
      } else if (stage.value == ExerciseStage.up && angle < currentConfig.angleThresholdDown) {
        stage.value = ExerciseStage.down;
      }
    }

    isProcessing = false;
  }

  // Menghitung warna umpan balik berdasarkan kedekatan dengan target
  void _updateFeedbackColor(double currentAngle) {
    double targetAngle = stage.value == ExerciseStage.down
        ? currentConfig.angleThresholdUp
        : currentConfig.angleThresholdDown;
    
    double angleDifference = (targetAngle - currentAngle).abs();
    
    const double perfectThreshold = 10.0; // Toleransi untuk warna hijau
    const double goodThreshold = 30.0;   // Toleransi untuk gradasi ke kuning

    if (angleDifference <= perfectThreshold) {
      feedbackBorderColor.value = Colors.greenAccent.withOpacity(0.7);
    } else if (angleDifference <= goodThreshold) {
      double normalizedDiff = (angleDifference - perfectThreshold) / (goodThreshold - perfectThreshold);
      feedbackBorderColor.value = Color.lerp(
        Colors.greenAccent.withOpacity(0.7),
        Colors.amber.withOpacity(0.7),
        normalizedDiff
      )!;
    } else {
      feedbackBorderColor.value = Colors.transparent;
    }
  }

  // =======================================================================
  // BLOK FUNGSI UTILITAS (KALKULASI & PEMROSESAN GAMBAR)
  // =======================================================================

  double calculateAngle(List<double> p1, List<double> p2, List<double> p3) {
    if (p1[0] == -1.0 || p2[0] == -1.0 || p3[0] == -1.0) return 0.0;
    
    final y1 = p1[0], x1 = p1[1];
    final y2 = p2[0], x2 = p2[1];
    final y3 = p3[0], x3 = p3[1];
    
    double angle = (math.atan2(y3 - y2, x3 - x2) - math.atan2(y1 - y2, x1 - x2)) * (180 / math.pi);
    if (angle < 0) angle += 360;
    
    return angle > 180 ? 360 - angle : angle;
  }

  img.Image? preprocessImage(CameraImage cameraImage) {
    // Fungsi ini mengkonversi format YUV420 dari kamera ke format RGB yang bisa dibaca model
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yuv420 = cameraImage.planes;
    if (yuv420.length < 3) return null;

    final yPlane = yuv420[0].bytes;
    final uPlane = yuv420[1].bytes;
    final vPlane = yuv420[2].bytes;
    final yStride = yuv420[0].bytesPerRow;
    final uvStride = yuv420[1].bytesPerRow;
    final uvPixelStride = yuv420[1].bytesPerPixel ?? 1;

    final image = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yStride + x;
        final uvIndex = (y ~/ 2) * uvStride + (x ~/ 2) * uvPixelStride;
        if (yIndex >= yPlane.length || uvIndex >= uPlane.length || uvIndex >= vPlane.length) continue;
        
        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        final r = yValue + 1.13983 * (vValue - 128);
        final g = yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128);
        final b = yValue + 2.03211 * (uValue - 128);

        image.setPixelRgb(x, y, r.toInt().clamp(0, 255), g.toInt().clamp(0, 255), b.toInt().clamp(0, 255));
      }
    }

    final rotatedImage = img.copyRotate(image, angle: -90);
    return img.copyResize(rotatedImage, width: inputSize, height: inputSize);
  }
}