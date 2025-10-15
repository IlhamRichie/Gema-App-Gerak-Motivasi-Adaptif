import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

// Tampilan utama yang menjadi "Peta Petualangan" bagi pengguna.
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan Obx untuk mendengarkan perubahan pada data di controller.
    return Obx(() => Scaffold(
          // Latar belakang dengan gradasi lembut untuk memberikan nuansa menenangkan.
          backgroundColor: const Color(0xFFF0F8FF), // Alice Blue
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                _buildMissionList(),
              ],
            ),
          ),
        ));
  }

  // Widget untuk header yang berisi sapaan personal dan profil.
  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Pagi,',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  controller.patientName.value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
              ],
            ),
            // Avatar pengguna dengan inisial nama.
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal.shade300,
              child: Text(
                controller.getInitials(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun daftar misi dalam format peta/jalur.
  SliverList _buildMissionList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final mission = controller.missions[index];
          // Menambahkan garis vertikal sebagai "jalur" yang menghubungkan misi.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Garis jalur dan penanda checkpoint
                _buildPathConnector(index, controller.missions.length),
                // ================= PERUBAHAN UTAMA ADA DI SINI =================
                // Kartu Misi sekarang menerima fungsi onTap
                Expanded(
                  child: MissionCard(
                    mission: mission,
                    // Saat kartu ditekan, panggil fungsi startMission dari controller
                    onTap: () => controller.startMission(mission),
                  ),
                ),
                // =============================================================
              ],
            ),
          );
        },
        childCount: controller.missions.length,
      ),
    );
  }

  // Widget untuk membuat elemen visual jalur (garis dan titik).
  Widget _buildPathConnector(int index, int total) {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Garis di atas checkpoint (kecuali untuk item pertama)
          Expanded(
            child: Container(
              width: 2,
              color: index == 0 ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
          // Checkpoint (lingkaran)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: missionStatusToColor(controller.missions[index].status),
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
          // Garis di bawah checkpoint (kecuali untuk item terakhir)
          Expanded(
            child: Container(
              width: 2,
              color: index == total - 1
                  ? Colors.transparent
                  : Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget custom untuk menampilkan setiap kartu misi.
class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap; // <- Menambahkan parameter onTap

  const MissionCard({Key? key, required this.mission, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLocked = mission.status == MissionStatus.locked;

    // ================= PERUBAHAN UTAMA LAINNYA ADA DI SINI =================
    // Seluruh kartu dibungkus dengan GestureDetector agar bisa di-tap
    return GestureDetector(
      onTap: isLocked ? null : onTap, // Hanya bisa di-tap jika status tidak 'locked'
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: missionStatusToColor(mission.status).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Ikon yang merepresentasikan status misi.
              Icon(
                missionStatusToIcon(mission.status),
                size: 40,
                color: missionStatusToColor(mission.status),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : const Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? Colors.grey.shade500 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol "Play" sekarang hanya sebagai indikator visual
              if (!isLocked) const SizedBox(width: 10),
              if (!isLocked)
                Icon(
                  Icons.play_circle_fill,
                  size: 44,
                  color: Colors.teal.shade400.withOpacity(0.8),
                )
            ],
          ),
        ),
      ),
    );
    // =======================================================================
  }
}