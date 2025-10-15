// Enum untuk mendefinisikan sendi mana yang akan dilacak.
// Ini membuat kode lebih mudah dibaca daripada menggunakan angka indeks langsung.
enum BodyPart {
  nose, leftEye, rightEye, leftEar, rightEar,
  leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist,
  leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle
}

// Model ini berisi SEMUA informasi yang dibutuhkan 'ExerciseEngine'
// untuk menjalankan satu sesi latihan spesifik.
class ExerciseConfig {
  final String id;
  final String name;
  final String instructionGif;
  final String gameAsset; // misal: 'bird', 'star', 'rocket'

  // Sendi mana yang membentuk sudut yang akan kita ukur.
  final BodyPart joint1;
  final BodyPart joint2; // Titik pusat sudut
  final BodyPart joint3;

  // Target sudut untuk setiap state.
  final double angleThresholdUp;
  final double angleThresholdDown;
  final int targetRepetitions;

  ExerciseConfig({
    required this.id,
    required this.name,
    required this.instructionGif,
    required this.gameAsset,
    required this.joint1,
    required this.joint2,
    required this.joint3,
    required this.angleThresholdUp,
    required this.angleThresholdDown,
    required this.targetRepetitions,
  });
}