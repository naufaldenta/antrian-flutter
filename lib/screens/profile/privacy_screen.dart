import 'package:flutter/cupertino.dart';

import '../../core/theme.dart';
import '../../widgets/common.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _data = [
    (
      CupertinoIcons.creditcard_fill,
      AppColors.blue,
      'NIK',
      'Identitas unik & login',
      'Disamarkan saat ditampilkan',
    ),
    (
      CupertinoIcons.person_fill,
      AppColors.teal,
      'Nama, tanggal lahir, kelamin',
      'Identifikasi pasien di loket & poli',
      'Disimpan lokal di perangkat',
    ),
    (
      CupertinoIcons.phone_fill,
      AppColors.green,
      'Nomor HP',
      'Kontak bila jadwal berubah',
      'Disamarkan saat ditampilkan',
    ),
    (
      CupertinoIcons.house_fill,
      AppColors.orange,
      'Alamat',
      'Administrasi wilayah kerja puskesmas',
      'Disimpan lokal di perangkat',
    ),
    (
      CupertinoIcons.lock_fill,
      AppColors.gray,
      'Password',
      'Melindungi akses akun',
      'Hanya disimpan sebagai hash + salt',
    ),
    (
      CupertinoIcons.text_bubble_fill,
      AppColors.pink,
      'Keluhan singkat',
      'Persiapan layanan oleh petugas',
      'Maksimal 200 karakter',
    ),
    (
      CupertinoIcons.clock_fill,
      AppColors.purple,
      'Riwayat & pengingat',
      'Menampilkan riwayat & jadwal kontrol',
      'Dapat dihapus kapan saja',
    ),
  ];

  static const _protections = [
    (
      CupertinoIcons.device_phone_portrait,
      'Data hanya disimpan di perangkat Anda; prototipe ini tidak mengirim data ke server mana pun.',
    ),
    (
      CupertinoIcons.lock_shield_fill,
      'Password di-hash SHA-256 dengan salt acak dan 1.000 iterasi, tidak pernah disimpan dalam bentuk asli.',
    ),
    (
      CupertinoIcons.timer_fill,
      'Login dikunci 60 detik setelah 5 kali gagal untuk mencegah tebak password.',
    ),
    (
      CupertinoIcons.eye_slash_fill,
      'NIK dan nomor HP disamarkan saat ditampilkan di layar.',
    ),
    (
      CupertinoIcons.slider_horizontal_3,
      'Minimalisasi data: hanya data yang dibutuhkan untuk antrean yang diminta.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IosPage(
      title: 'Privasi & Data',
      large: false,
      children: [
        const SizedBox(height: 24),
        const Center(
          child: IconTile(
            CupertinoIcons.hand_raised_fill,
            color: AppColors.blue,
            size: 64,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Privasi Anda Penting',
          textAlign: TextAlign.center,
          style: AppText.title1,
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'AntreSehat hanya mengumpulkan data yang dibutuhkan untuk pendaftaran '
            'antrean, dan Anda tetap memegang kendali atas data tersebut.',
            textAlign: TextAlign.center,
            style: AppText.subhead,
          ),
        ),
        IosSection(
          header: 'Data yang dikumpulkan',
          dividerIndent: 58,
          children: [
            for (final (icon, color, name, purpose, protection) in _data)
              IosRow(
                leading: IconTile(icon, color: color),
                title: name,
                subtitle: 'Tujuan: $purpose\nPerlindungan: $protection',
              ),
          ],
        ),
        IosSection(
          header: 'Cara data dilindungi',
          dividerIndent: 52,
          children: [
            for (final (icon, text) in _protections)
              IosRow(
                leading: Icon(icon, color: AppColors.blue, size: 24),
                title: text,
              ),
          ],
        ),
        const IosSection(
          header: 'Hak Anda',
          dividerIndent: 52,
          children: [
            IosRow(
              leading: Icon(
                CupertinoIcons.pencil_circle_fill,
                color: AppColors.green,
                size: 26,
              ),
              title: 'Melihat dan memperbarui data kontak di menu Profil.',
            ),
            IosRow(
              leading: Icon(
                CupertinoIcons.trash_circle_fill,
                color: AppColors.red,
                size: 26,
              ),
              title:
                  'Menghapus akun beserta seluruh antrean, riwayat, dan pengingat.',
            ),
            IosRow(
              leading: Icon(
                CupertinoIcons.checkmark_shield_fill,
                color: AppColors.indigo,
                size: 26,
              ),
              title: 'Persetujuan diberikan secara eksplisit saat pendaftaran.',
            ),
          ],
        ),
        const IosSection(
          header: 'Keterbatasan prototipe',
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Aplikasi ini adalah prototipe untuk tugas kuliah. Data puskesmas, dokter, '
                'dan antrean adalah simulasi. Data belum dienkripsi di penyimpanan perangkat '
                'dan belum terhubung ke SIMPUS maupun layanan nasional. Implementasi nyata '
                'wajib memenuhi UU No. 27 Tahun 2022 tentang Pelindungan Data Pribadi, '
                'regulasi rekam medis, serta memakai server aman (HTTPS, enkripsi, kontrol akses).',
                style: AppText.subhead,
              ),
            ),
          ],
        ),
        const SimulationNote(),
      ],
    );
  }
}
