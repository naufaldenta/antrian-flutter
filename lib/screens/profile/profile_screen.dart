import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/security.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../services/reminder_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_fields.dart';
import 'privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AuthService>().current;
    if (p == null) return const SizedBox.shrink();

    return IosPage(
      title: 'Profil',
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8E8E93), Color(0xFF636366)],
                  ),
                ),
                child: Text(
                  p.name
                      .split(' ')
                      .take(2)
                      .map((w) => w[0])
                      .join()
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(p.name, style: AppText.title2),
              const SizedBox(height: 2),
              const Text(
                'Pasien · Puskesmas Sehat Sentosa',
                style: AppText.subhead,
              ),
            ],
          ),
        ),
        IosSection(
          header: 'Data pasien',
          footer: const Text(
            'NIK dan nomor HP disamarkan untuk melindungi privasi.',
          ),
          children: [
            IosRow(title: 'NIK', value: Security.maskNik(p.nik)),
            IosRow(title: 'Tanggal lahir', value: Fmt.shortDate(p.birthDate)),
            IosRow(
              title: 'Jenis kelamin',
              value: p.gender == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            IosRow(title: 'Nomor HP', value: Security.maskPhone(p.phone)),
            DetailRow(label: 'Alamat', value: p.address),
          ],
        ),
        IosSection(
          header: 'Pengaturan',
          dividerIndent: 58,
          children: [
            IosRow(
              leading: const IconTile(
                CupertinoIcons.pencil,
                color: AppColors.blue,
              ),
              title: 'Ubah Data Kontak',
              onTap: () => showFormSheet(
                context,
                title: 'Ubah Data Kontak',
                builder: (_) => const _EditProfileForm(),
              ),
            ),
            IosRow(
              leading: const IconTile(
                CupertinoIcons.hand_raised_fill,
                color: AppColors.indigo,
              ),
              title: 'Privasi & Keamanan Data',
              onTap: () => pushPage(context, const PrivacyScreen()),
            ),
          ],
        ),
        IosSection(
          children: [
            IosRow(
              title: 'Keluar',
              titleColor: AppColors.blue,
              titleCentered: true,
              showChevron: false,
              onTap: () async {
                final ok = await confirmDialog(
                  context,
                  title: 'Keluar dari akun?',
                  message:
                      'Anda perlu masuk kembali untuk menggunakan aplikasi.',
                  confirmLabel: 'Keluar',
                );
                if (ok && context.mounted) {
                  await context.read<AuthService>().logout();
                }
              },
            ),
          ],
        ),
        IosSection(
          topGap: 16,
          footer: const Text(
            'Menghapus akun, antrean, riwayat, dan pengingat dari perangkat ini.',
          ),
          children: [
            IosRow(
              title: 'Hapus Akun & Semua Data',
              titleColor: AppColors.red,
              titleCentered: true,
              showChevron: false,
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text('AntreSehat versi 1.0', style: AppText.caption),
        ),
        const SimulationNote(),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus akun?',
      message:
          'Akun, antrean, riwayat kunjungan, dan pengingat Anda akan dihapus '
          'permanen dari perangkat ini. Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final auth = context.read<AuthService>();
    final id = auth.current!.id;
    await context.read<QueueService>().removePatientData(id);
    if (!context.mounted) return;
    await context.read<ReminderService>().removePatientData(id);
    await auth.deleteCurrentAccount();
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final p = context.read<AuthService>().current!;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
    _address = TextEditingController(text: p.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthService>().updateProfile(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
    );
    if (!mounted) return;
    Navigator.pop(context);
    showMessage(context, 'Profil diperbarui.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(title: 'Ubah Data Kontak', onSave: _save),
              IosSection(
                topGap: 8,
                children: [
                  IosField(
                    label: 'Nama',
                    controller: _name,
                    validator: Validators.name,
                    labelWidth: 90,
                  ),
                  IosField(
                    label: 'Nomor HP',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    labelWidth: 90,
                  ),
                  IosField(
                    label: 'Alamat',
                    controller: _address,
                    maxLines: 3,
                    validator: Validators.address,
                    labelWidth: 90,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
