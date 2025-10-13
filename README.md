# GEMA - Gerak Motivasi Adaptif

**"Setiap Gerakan Bergema Menjadi Harapan."**

GEMA adalah sebuah prototipe aplikasi fisioterapi digital berbasis Android yang dirancang untuk mengubah proses rehabilitasi pasca-stroke yang monoton menjadi sebuah pengalaman yang interaktif, memotivasi, dan memberdayakan.

-----

## 📖 Latar Belakang

Rehabilitasi pasca-stroke di rumah adalah kunci pemulihan, namun sering kali gagal karena pasien kehilangan motivasi akibat latihan yang repetitif dan membosankan. Pasien tidak mendapatkan umpan balik instan, merasa tidak yakin dengan kebenaran gerakannya, dan akhirnya berhenti berlatih.

**GEMA** hadir sebagai solusi. Dengan memanfaatkan gamifikasi dan teknologi *computer vision*, kami mengubah latihan wajib menjadi misi permainan yang menarik. Aplikasi ini memberikan skor, umpan balik *real-time*, dan visualisasi progres untuk mengembalikan "Gema" semangat pasien dalam setiap gerakan mereka.

## ✨ Fitur Utama (MVP)

  * **🎮 Sesi Latihan Gamifikasi:** Latihan fisioterapi untuk ekstremitas atas disajikan dalam bentuk "misi" interaktif yang menantang dan menyenangkan.
  * **👁️ Deteksi Gerakan Real-Time:** Menggunakan kamera ponsel dan model AI (MoveNet), GEMA menganalisis gerakan pengguna secara langsung di perangkat, tanpa merekam atau mengirim video ke server, untuk menjaga privasi sepenuhnya.
  * **🏆 Umpan Balik Instan & Sistem Skor:** Pengguna langsung mendapatkan umpan balik visual, audio, dan skor untuk setiap gerakan yang benar, memberikan rasa pencapaian yang kuat.
  * **📊 Pelacakan Progres Visual:** Sebuah dasbor sederhana dengan kalender aktivitas dan grafik mingguan untuk menunjukkan konsistensi dan kemajuan latihan, membuktikan bahwa setiap usaha tidak sia-sia.
  * **🔑 Login Aman & Mudah:** Integrasi dengan Google Sign-In untuk proses masuk yang cepat, familiar, dan aman.

## 🛠️ Teknologi yang Digunakan (Tech Stack)

Proyek ini dibangun menggunakan tumpukan teknologi modern yang berfokus pada kecepatan pengembangan dan skalabilitas.

  * **Framework Aplikasi:** [Flutter](https://flutter.dev/) - Untuk membangun aplikasi Android yang indah dan berperforma tinggi dari satu basis kode.
  * **State Management:** [GetX](https://pub.dev/packages/get) - Untuk manajemen state, dependensi, dan navigasi yang efisien.
  * **Backend & Database:** [Firebase](https://firebase.google.com/)
      * **Firestore:** Sebagai database NoSQL untuk menyimpan data progres pengguna.
      * **Firebase Authentication:** Untuk menangani proses otentikasi pengguna melalui Google Sign-In.
  * **Computer Vision:** [TensorFlow Lite](https://www.tensorflow.org/lite) - Untuk menjalankan model Machine Learning secara efisien di perangkat mobile.
      * **Model:** [MoveNet.Lightning](https://www.google.com/search?q=https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/float16/4) - Model deteksi pose yang dioptimalkan untuk kecepatan dan akurasi *real-time*.

## 🚀 Memulai Proyek (Getting Started)

Berikut adalah panduan untuk menyiapkan dan menjalankan proyek ini di lingkungan pengembangan lokal Anda.

### Prasyarat

Pastikan Anda sudah menginstal perangkat lunak berikut:

  * [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.x atau lebih baru)
  * [Android Studio](https://developer.android.com/studio) atau [Visual Studio Code](https://code.visualstudio.com/)
  * Emulator Android atau perangkat Android fisik (API Level 24+)

### Instalasi & Konfigurasi

1.  **Clone Repositori**

    ```sh
    git clone https://github.com/IlhamRichie/Gema-App-Gerak-Motivasi-Adaptif.git
    cd gema-project
    ```

2.  **Instal Dependensi Flutter**

    ```sh
    flutter pub get
    ```

3.  **Konfigurasi Firebase**

      * Buat proyek baru di [Firebase Console](https://console.firebase.google.com/).
      * Tambahkan aplikasi Android ke proyek Firebase Anda.
      * Unduh file `google-services.json` dan letakkan di dalam direktori `android/app/`.
      * Di Firebase Console, aktifkan layanan **Authentication (Google Sign-In)** dan **Firestore Database**.

4.  **Jalankan Aplikasi**
    Pastikan emulator Anda berjalan atau perangkat Anda terhubung, lalu jalankan perintah berikut:

    ```sh
    flutter run
    ```

## 📂 Struktur Proyek (Project Structure)

Proyek ini menggunakan pola arsitektur yang dihasilkan oleh `get_cli` untuk mengorganisir kode secara modular dan rapi.

```
lib/
├── app/
│   ├── data/               # Model, provider, dan repository (opsional)
│   ├── modules/            # Direktori utama untuk semua fitur/modul
│   │   └── home/           # Contoh sebuah modul (misal: home)
│   │       ├── bindings/     # Menghubungkan dependencies ke view
│   │       │   └── home_binding.dart
│   │       ├── controllers/  # Logika bisnis dan state management
│   │       │   └── home_controller.dart
│   │       └── views/        # Tampilan UI (halaman/widget)
│   │           └── home_view.dart
│   └── routes/             # Definisi dan pengelolaan rute navigasi
│       ├── app_pages.dart    # Daftar semua halaman/rute
│       └── app_routes.dart   # Nama-nama konstanta untuk rute
└── main.dart               # Titik masuk utama aplikasi
```

## 📄 Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file `LICENSE` untuk detailnya.

-----

Dibuat dengan ❤️ untuk memberikan harapan baru bagi para pejuang pasca-stroke.