import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

// Enum untuk merepresentasikan status setiap misi.
enum MissionStatus { locked, unlocked, completed }

// Model untuk data setiap misi.
class Mission {
  final String id;
  final String title;
  final String description;
  final MissionStatus status;
  final String route; // Rute untuk navigasi saat misi dimulai

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.route,
  });
}

// Controller untuk halaman Home.
class HomeController extends GetxController {
  final patientName = "Bapak Budi".obs;

  // ====================== DATA MISI BARU SESUAI PROVIDER ======================
  // Daftar misi ini sekarang mencerminkan 5 latihan berbasis bukti medis.
  final missions = <Mission>[
    Mission(
      id: 'm1', // Sesuai dengan ExerciseProvider
      title: 'Misi 1: Menggapai Apel',
      description: 'Mengangkat lengan lurus ke atas.',
      status: MissionStatus.unlocked, // Misi pertama selalu terbuka
      route: Routes.EXERCISE,
    ),
    Mission(
      id: 'm2', // Sesuai dengan ExerciseProvider
      title: 'Misi 2: Membentangkan Sayap',
      description: 'Mengangkat lengan lurus ke samping.',
      status: MissionStatus.locked, // Terkunci, terbuka setelah m1 selesai
      route: Routes.EXERCISE,
    ),
    Mission(
      id: 'm3', // Sesuai dengan ExerciseProvider
      title: 'Misi 3: Tarik Tambang',
      description: 'Menekuk dan meluruskan siku.',
      status: MissionStatus.locked,
      route: Routes.EXERCISE,
    ),
    Mission(
      id: 'm4', // Sesuai dengan ExerciseProvider
      title: 'Misi 4: Membuka Pintu',
      description: 'Melatih rotasi sendi bahu.',
      status: MissionStatus.locked,
      route: Routes.EXERCISE,
    ),
    Mission(
      id: 'm5', // Sesuai dengan ExerciseProvider
      title: 'Misi 5: Gas Motor',
      description: 'Latihan untuk pergelangan tangan.',
      status: MissionStatus.locked,
      route: Routes.EXERCISE,
    ),
  ].obs;
  // =======================================================================

  String getInitials() {
    if (patientName.value.isEmpty) return '';
    List<String> names = patientName.value.split(" ");
    String initials = "";
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }

  void startMission(Mission mission) {
    if (mission.status != MissionStatus.locked && mission.route.isNotEmpty) {
      Get.toNamed(mission.route, arguments: {'missionId': mission.id});
    } else if (mission.status == MissionStatus.locked) {
      Get.snackbar(
        "Misi Terkunci",
        "Selesaikan misi sebelumnya untuk membuka latihan ini.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// Helper functions untuk visualisasi status misi.
IconData missionStatusToIcon(MissionStatus status) {
  switch (status) {
    case MissionStatus.completed:
      return Icons.check_circle;
    case MissionStatus.unlocked:
      return Icons.rocket_launch;
    case MissionStatus.locked:
      return Icons.lock;
  }
}

Color missionStatusToColor(MissionStatus status) {
  switch (status) {
    case MissionStatus.completed:
      return Colors.green.shade500;
    case MissionStatus.unlocked:
      return Colors.teal.shade400;
    case MissionStatus.locked:
      return Colors.grey.shade400;
  }
}