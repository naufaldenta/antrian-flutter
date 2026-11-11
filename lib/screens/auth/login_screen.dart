import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common.dart';
import '../../widgets/form_fields.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nik = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nik.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await context.read<AuthService>().login(
      _nik.text,
      _password.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  void _fillDemo() {
    _nik.text = DummyData.demoNik;
    _password.text = DummyData.demoPassword;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo()),
                    const SizedBox(height: 18),
                    const Text(
                      'AntreSehat',
                      textAlign: TextAlign.center,
                      style: AppText.largeTitle,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Daftar dan pantau antrean puskesmas\ntanpa harus menunggu di loket.',
                      textAlign: TextAlign.center,
                      style: AppText.subhead,
                    ),
                    IosSection(
                      topGap: 30,
                      children: [
                        IosField(
                          label: 'NIK',
                          controller: _nik,
                          placeholder: '16 digit',
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: Validators.nik,
                          textInputAction: TextInputAction.next,
                          labelWidth: 90,
                        ),
                        IosField(
                          label: 'Password',
                          controller: _password,
                          placeholder: 'Wajib diisi',
                          obscureText: !_showPassword,
                          validator: (v) =>
                              (v ?? '').isEmpty ? 'Password wajib diisi' : null,
                          onSubmitted: (_) => _submit(),
                          labelWidth: 90,
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
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Callout(
                        color: AppColors.red,
                        icon: CupertinoIcons.exclamationmark_circle_fill,
                        text: _error!,
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Masuk',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    TintedButton(
                      label: 'Daftar sebagai Pasien Baru',
                      onPressed: () =>
                          pushPage(context, const RegisterScreen()),
                    ),
                    const SizedBox(height: 18),
                    CupertinoButton(
                      onPressed: _fillDemo,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.play_circle, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Gunakan akun demo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SimulationNote(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
