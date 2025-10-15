import '../models/exercise_model.dart';

// Kelas ini bertindak sebagai database sementara kita.
// Konfigurasi ini didasarkan pada panduan rehabilitasi stroke (misal: AHA/ASA).
class ExerciseProvider {
  static final Map<String, ExerciseConfig> _exercises = {
    // Misi 1: Mengangkat lengan lurus ke atas.
    'm1': ExerciseConfig(
      id: 'm1',
      name: 'Menggapai Apel',
      instructionGif: 'assets/shoulder_flexion.gif',
      gameAsset: 'star',
      // Mengukur sudut antara siku, bahu, dan pinggul.
      // Target: Lengan lurus di samping badan (mendekati 180 derajat).
      joint1: BodyPart.rightElbow,
      joint2: BodyPart.rightShoulder,
      joint3: BodyPart.rightHip,
      angleThresholdUp: 90, // Target sudut minimal saat lengan diangkat
      angleThresholdDown: 20, // Sudut saat lengan kembali ke bawah
      targetRepetitions: 8,
    ),

    // Misi 2: Mengangkat lengan lurus ke samping.
    'm2': ExerciseConfig(
      id: 'm2',
      name: 'Membentangkan Sayap',
      instructionGif: 'assets/shoulder_abduction.gif',
      gameAsset: 'bird',
      // Mengukur sudut antara siku, bahu, dan bahu sebelahnya.
      // Target: Lengan terangkat lurus ke samping (sekitar 90 derajat).
      joint1: BodyPart.rightElbow,
      joint2: BodyPart.rightShoulder,
      joint3: BodyPart.leftShoulder,
      angleThresholdUp: 80, // Target sudut minimal saat lengan diangkat
      angleThresholdDown: 20, // Sudut saat lengan kembali ke bawah
      targetRepetitions: 8,
    ),

    // Misi 3: Menekuk dan meluruskan siku.
    'm3': ExerciseConfig(
      id: 'm3',
      name: 'Tarik Tambang',
      instructionGif: 'assets/elbow_flexion.gif',
      gameAsset: 'rocket',
      // Mengukur sudut klasik pada siku.
      joint1: BodyPart.rightShoulder,
      joint2: BodyPart.rightElbow,
      joint3: BodyPart.rightWrist,
      angleThresholdUp: 160, // Target saat lengan hampir lurus
      angleThresholdDown: 45, // Target saat lengan menekuk penuh
      targetRepetitions: 10,
    ),

    // Misi 4: Memutar bahu ke luar.
    'm4': ExerciseConfig(
      id: 'm4',
      name: 'Membuka Pintu',
      instructionGif: 'assets/shoulder_rotation.gif',
      gameAsset: 'door', // Anda perlu aset gambar pintu
      // Ini lebih sulit diukur dengan 2D, kita aproksimasi dengan pergerakan pergelangan
      // menjauh dari pinggul, sambil menjaga siku tetap di dekatnya.
      joint1: BodyPart.rightHip,
      joint2: BodyPart.rightElbow,
      joint3: BodyPart.rightWrist,
      angleThresholdUp: 80,  // Sudut saat lengan berotasi keluar
      angleThresholdDown: 20, // Sudut saat lengan kembali ke posisi awal
      targetRepetitions: 10,
    ),

    // Misi 5: Ekstensi pergelangan tangan.
    'm5': ExerciseConfig(
      id: 'm5',
      name: 'Gas Motor',
      instructionGif: 'assets/wrist_extension.gif',
      gameAsset: 'throttle', // Anda perlu aset gambar gas motor
      // Mengukur sudut antara lengan bawah dan punggung tangan.
      // Catatan: MoveNet kurang akurat di tangan, ini adalah 'best effort'.
      joint1: BodyPart.rightElbow,
      joint2: BodyPart.rightWrist,
      // MoveNet tidak punya keypoint jari, jadi kita gunakan aproksimasi.
      // Logika untuk ini mungkin perlu disesuaikan nanti.
      joint3: BodyPart.rightWrist, // Placeholder, logika perlu kustom
      angleThresholdUp: 170, // Pergelangan tangan hampir lurus dengan lengan
      angleThresholdDown: 130, // Pergelangan tangan ditekuk ke atas
      targetRepetitions: 12,
    ),
  };

  static ExerciseConfig? getConfigById(String missionId) {
    return _exercises[missionId];
  }
}
