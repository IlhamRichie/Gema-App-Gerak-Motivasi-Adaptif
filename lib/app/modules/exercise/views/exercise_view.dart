import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/exercise_controller.dart';
import '../pose_painter.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Obx(() => AppBar(
              backgroundColor: Colors.black.withOpacity(0.35),
              elevation: 0,
              title: Text(
                controller.currentConfig.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Get.back(),
              ),
            )),
      ),
      body: Obx(() {
        if (!controller.isCameraInitialized.value ||
            controller.cameraController == null ||
            !controller.cameraController!.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraAndPainter(context),
            _buildGameAndUIOverlay(size),
            if (controller.showInstructions.value)
              _buildInstructionOverlay(),
            if (!controller.isReady.value && !controller.showInstructions.value)
              _buildCountdownOverlay(),
          ],
        );
      }),
    );
  }

  // ========================= CAMERA + PAINTER ===========================
  Widget _buildCameraAndPainter(BuildContext context) {
    final previewSize = controller.cameraController!.value.previewSize!;
    final screenSize = MediaQuery.of(context).size;

    // Rasio skala supaya keypoints tidak meleset dari tubuh
    final scaleX = screenSize.width / previewSize.height;
    final scaleY = screenSize.height / previewSize.width;

    return Transform.scale(
      scale: scaleX > scaleY ? scaleX : scaleY,
      child: Center(
        child: AspectRatio(
          aspectRatio:
              controller.cameraController!.value.aspectRatio, // perbaikan rasio
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller.cameraController!),
              CustomPaint(
                painter: PosePainter(
                  keypoints: controller.output.value,
                  imageSize: previewSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= GAME OVERLAY ===============================
  Widget _buildGameAndUIOverlay(Size size) {
    return Stack(
      children: [
        // Lapisan semi-transparan
        Container(color: Colors.black.withOpacity(0.25)),

        // Elemen permainan
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: size.height * 0.15),
            child: Image.asset('assets/nest.png', width: 100),
          ),
        ),
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              bottom: 50 + (size.height * 0.6 * controller.gameProgress.value),
              left: (size.width / 2) - 35,
              child: Image.asset(
                'assets/${controller.currentConfig.gameAsset}.png',
                width: 70,
              ),
            )),

        // UI tambahan (skor dan instruksi)
        SafeArea(
          child: Stack(
            children: [
              // BORDER FEEDBACK
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 6,
                        color: controller.feedbackBorderColor.value,
                      ),
                    ),
                  )),

              // Skor Repetisi
              Positioned(
                top: 90,
                right: 20,
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.repetitionCount.value} / ${controller.currentConfig.targetRepetitions}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ),

              // GIF instruksi
              Positioned(
                bottom: 30,
                right: 20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.tealAccent, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      controller.currentConfig.instructionGif,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================= INSTRUCTION OVERLAY =========================
  Widget _buildInstructionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: Colors.amber, size: 80),
              const SizedBox(height: 24),
              const Text('Persiapan Latihan',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _buildInstructionRow(Icons.phone_android_rounded,
                  'Posisikan ponsel di atas meja, setinggi dada Anda.'),
              _buildInstructionRow(Icons.camera_alt_outlined,
                  'Pastikan seluruh tubuh bagian atas Anda terlihat jelas di kamera.'),
              _buildInstructionRow(Icons.highlight_off_rounded,
                  'Hindari sumber cahaya yang kuat dari belakang Anda.'),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text('Mulai Latihan',
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => controller.startExerciseSequence(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Text(
          controller.countdownValue.value.toString(),
          style: const TextStyle(
            fontSize: 150,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
