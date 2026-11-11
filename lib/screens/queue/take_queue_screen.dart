import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../data/dummy_data.dart';
import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_fields.dart';
import 'queue_status_screen.dart';

class TakeQueueScreen extends StatefulWidget {
  const TakeQueueScreen({super.key, this.initialPoliId});

  final String? initialPoliId;

  @override
  State<TakeQueueScreen> createState() => _TakeQueueScreenState();
}

class _TakeQueueScreenState extends State<TakeQueueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complaint = TextEditingController();
  String? _poliId;
  DateTime? _date;
  String? _doctorId;
  bool _submitted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _poliId = widget.initialPoliId;
    _date = context.read<QueueService>().today;
  }

  @override
  void dispose() {
    _complaint.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (_poliId == null || _date == null || _doctorId == null || !formOk) {
      showMessage(
        context,
        'Lengkapi poli, tanggal, dokter, dan keluhan.',
        error: true,
      );
      return;
    }
    final poli = DummyData.poliById(_poliId!);
    final doctor = DummyData.doctorById(_doctorId!);
    final ok = await confirmDialog(
      context,
      title: 'Konfirmasi Antrean',
      message:
          '${poli.name}\n${doctor.name}\n'
          '${Fmt.fullDate(_date!)} · ${doctor.startTime}–${doctor.endTime}',
      confirmLabel: 'Ambil Nomor',
    );
    if (!ok || !mounted) return;

    setState(() => _loading = true);
    final patientId = context.read<AuthService>().current!.id;
    final (ticket, error) = await context.read<QueueService>().takeTicket(
      patientId: patientId,
      poliId: _poliId!,
      doctorId: _doctorId!,
      date: _date!,
      complaint: _complaint.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    showMessage(
      context,
      'Berhasil! Nomor antrean Anda ${Fmt.queueNumber(poli.code, ticket!.number)}',
    );
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => QueueStatusScreen(ticketId: ticket.id),
      ),
    );
  }

  Widget _errorFooter(String msg) =>
      Text(msg, style: AppText.footnote.copyWith(color: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final dates = queue.bookableDates();

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: IosPage(
        title: 'Ambil Antrean',
        large: false,
        children: [
          IosSection(
            header: '1 · Poli',
            dividerIndent: 58,
            footer: _submitted && _poliId == null
                ? _errorFooter('Poli wajib dipilih')
                : null,
            children: [
              for (final p in DummyData.polis)
                IosRow(
                  leading: IconTile(p.icon, color: p.color),
                  title: p.name,
                  subtitle: '± ${p.avgServiceMinutes} menit / pasien',
                  showChevron: false,
                  trailing: _poliId == p.id
                      ? const Icon(
                          CupertinoIcons.checkmark_alt,
                          color: AppColors.blue,
                        )
                      : null,
                  onTap: () => setState(() {
                    _poliId = p.id;
                    _doctorId = null;
                  }),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 7),
            child: Text('2 · TANGGAL KUNJUNGAN', style: AppText.footnote),
          ),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = dates[i];
                final selected = _date != null && Fmt.sameDay(d, _date!);
                return GestureDetector(
                  onTap: () => setState(() {
                    _date = d;
                    _doctorId = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.blue : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          i == 0 ? 'Hari ini' : Fmt.shortDay(d.weekday),
                          style: AppText.caption.copyWith(
                            color: selected
                                ? Colors.white70
                                : AppColors.secondaryLabel,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.day}',
                          style: AppText.title2.copyWith(
                            color: selected ? Colors.white : AppColors.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          IosSection(
            header: '3 · Dokter / Tenaga Kesehatan',
            dividerIndent: 58,
            footer: _submitted && _poliId != null && _doctorId == null
                ? _errorFooter('Dokter wajib dipilih')
                : null,
            children: _poliId == null
                ? [
                    const IosRow(
                      title: 'Pilih poli terlebih dahulu',
                      titleColor: AppColors.secondaryLabel,
                    ),
                  ]
                : [
                    for (final d in DummyData.doctorsOf(_poliId!))
                      () {
                        final reason = queue.doctorUnavailableReason(d, _date!);
                        final available = reason == null;
                        return IosRow(
                          leading: IconTile(
                            CupertinoIcons.person_fill,
                            color: available ? AppColors.teal : AppColors.gray,
                          ),
                          title: d.name,
                          subtitle: available
                              ? '${d.startTime}–${d.endTime} · sisa kuota ${queue.remainingQuota(d.id, _date!)}'
                              : reason,
                          enabled: available,
                          showChevron: false,
                          trailing: _doctorId == d.id
                              ? const Icon(
                                  CupertinoIcons.checkmark_alt,
                                  color: AppColors.blue,
                                )
                              : null,
                          onTap: () => setState(() => _doctorId = d.id),
                        );
                      }(),
                  ],
          ),

          IosSection(
            header: '4 · Keluhan Singkat',
            footer: const Text(
              'Hanya untuk membantu petugas menyiapkan layanan. '
              'Hindari menulis data sensitif yang tidak perlu.',
            ),
            children: [
              IosTextArea(
                controller: _complaint,
                placeholder: 'Contoh: demam dan batuk sejak 2 hari',
                maxLength: 200,
                validator: Validators.complaint,
              ),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Ambil Nomor Antrean',
            icon: CupertinoIcons.tickets_fill,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
