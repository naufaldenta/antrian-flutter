import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_fields.dart';
import '../profile/privacy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nik = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'L';
  bool _consent = false;
  bool _showPassword = false;
  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    for (final c in [_nik, _name, _phone, _address, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await pickDateTime(
      context,
      title: 'Tanggal Lahir',
      initial: _birthDate ?? DateTime(now.year - 25, 1, 1),
      minimum: DateTime(now.year - 120),
      maximum: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    final birthError = Validators.birthDate(_birthDate);
    if (!formOk || birthError != null) {
      showMessage(
        context,
        'Periksa kembali data yang ditandai merah.',
        error: true,
      );
      return;
    }
    if (!_consent) {
      showMessage(
        context,
        'Aktifkan persetujuan kebijakan privasi untuk mendaftar.',
        error: true,
      );
      return;
    }
    setState(() => _loading = true);
    final error = await context.read<AuthService>().register(
      nik: _nik.text,
      name: _name.text,
      birthDate: _birthDate!,
      gender: _gender,
      phone: _phone.text,
      address: _address.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final birthError = _submitted ? Validators.birthDate(_birthDate) : null;

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: IosPage(
        title: 'Pasien Baru',
        large: false,
        previousPageTitle: 'Masuk',
        children: [
          IosSection(
            header: 'Identitas',
            footer: const Text(
              'Gunakan NIK fiktif. Jangan memasukkan NIK asli.',
            ),
            children: [
              IosField(
                label: 'NIK',
                controller: _nik,
                placeholder: '16 digit',
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.nik,
              ),
              IosField(
                label: 'Nama',
                controller: _name,
                placeholder: 'Nama lengkap',
                textCapitalization: TextCapitalization.words,
                validator: Validators.name,
              ),
              IosRow(
                title: 'Tanggal lahir',
                value: _birthDate == null
                    ? 'Pilih'
                    : Fmt.shortDate(_birthDate!),
                onTap: _pickBirthDate,
              ),
              if (birthError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    birthError,
                    style: AppText.footnote.copyWith(color: AppColors.red),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Kelamin', style: AppText.body),
                    ),
                    Expanded(
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _gender,
                        children: const {
                          'L': Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Laki-laki'),
                          ),
                          'P': Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Perempuan'),
                          ),
                        },
                        onValueChanged: (v) =>
                            setState(() => _gender = v ?? 'L'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IosSection(
            header: 'Kontak',
            children: [
              IosField(
                label: 'Nomor HP',
                controller: _phone,
                placeholder: '081234567890',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
                ],
                validator: Validators.phone,
              ),
              IosField(
                label: 'Alamat',
                controller: _address,
                placeholder: 'Jalan, RT/RW, kelurahan',
                maxLength: 150,
                maxLines: 3,
                validator: Validators.address,
              ),
            ],
          ),
          IosSection(
            header: 'Keamanan akun',
            footer: const Text(
              'Minimal 8 karakter, kombinasi huruf dan angka.',
            ),
            children: [
              IosField(
                label: 'Password',
                controller: _password,
                placeholder: 'Buat password',
                obscureText: !_showPassword,
                validator: Validators.password,
              ),
              IosField(
                label: 'Ulangi',
                controller: _confirm,
                placeholder: 'Ulangi password',
                obscureText: !_showPassword,
                validator: Validators.confirmPassword(() => _password.text),
              ),
              IosRow(
                title: 'Tampilkan password',
                trailing: CupertinoSwitch(
                  value: _showPassword,
                  activeTrackColor: AppColors.green,
                  onChanged: (v) => setState(() => _showPassword = v),
                ),
              ),
            ],
          ),
          IosSection(
            header: 'Persetujuan',
            children: [
              IosRow(
                title: 'Saya menyetujui Kebijakan Privasi',
                subtitle: 'Data dipakai hanya untuk layanan antrean.',
                trailing: CupertinoSwitch(
                  value: _consent,
                  activeTrackColor: AppColors.green,
                  onChanged: (v) => setState(() => _consent = v),
                ),
              ),
              IosRow(
                leading: const IconTile(
                  CupertinoIcons.hand_raised_fill,
                  color: AppColors.blue,
                ),
                title: 'Baca Kebijakan Privasi',
                onTap: () => pushPage(context, const PrivacyScreen()),
              ),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Daftar', loading: _loading, onPressed: _submit),
          const SimulationNote(),
        ],
      ),
    );
  }
}
