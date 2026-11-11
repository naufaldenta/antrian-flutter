import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_fields.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<AuthService>().current!.id;
    final service = context.watch<ReminderService>();
    final upcoming = service.upcomingOf(patientId);
    final done = service.doneOf(patientId);

    return IosPage(
      title: 'Pengingat',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _openForm(context),
        child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
      ),
      children: [
        if (upcoming.isEmpty && done.isEmpty)
          EmptyState(
            icon: CupertinoIcons.bell,
            title: 'Belum Ada Pengingat',
            message: 'Tambahkan pengingat jadwal kontrol atau minum obat.',
            action: PrimaryButton(
              label: 'Tambah Pengingat',
              icon: CupertinoIcons.add,
              onPressed: () => _openForm(context),
            ),
          )
        else ...[
          IosSection(
            header: 'Akan datang',
            topGap: 8,
            dividerIndent: 52,
            children: upcoming.isEmpty
                ? [
                    const IosRow(
                      title: 'Tidak ada',
                      titleColor: AppColors.secondaryLabel,
                    ),
                  ]
                : [for (final r in upcoming) _ReminderRow(reminder: r)],
          ),
          if (done.isNotEmpty)
            IosSection(
              header: 'Selesai',
              dividerIndent: 52,
              children: [for (final r in done) _ReminderRow(reminder: r)],
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'Geser ke kiri untuk menghapus. Pada prototipe ini pengingat tampil di '
              'dalam aplikasi; notifikasi push direncanakan untuk pengembangan berikutnya.',
              style: AppText.footnote,
            ),
          ),
        ],
      ],
    );
  }

  void _openForm(BuildContext context) => showFormSheet(
    context,
    title: 'Pengingat Baru',
    builder: (_) => const _ReminderForm(),
  );
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReminderService>();
    final now = DateTime.now();
    final isToday = Fmt.sameDay(reminder.dateTime, now);
    final when =
        '${relativeDay(Fmt.dateOnly(reminder.dateTime), Fmt.dateOnly(now))}, '
        '${Fmt.time(reminder.dateTime)}';

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.red,
        child: const Text(
          'Hapus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      confirmDismiss: (_) => confirmDialog(
        context,
        title: 'Hapus pengingat?',
        message: '"${reminder.title}" akan dihapus.',
        confirmLabel: 'Hapus',
        destructive: true,
      ),
      onDismissed: (_) => service.delete(reminder.id),
      child: IosRow(
        leading: GestureDetector(
          onTap: () => service.toggleDone(reminder.id),
          child: Icon(
            reminder.done
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.circle,
            color: reminder.done ? AppColors.orange : AppColors.tertiaryLabel,
            size: 26,
          ),
        ),
        title: reminder.title,
        titleColor: reminder.done ? AppColors.secondaryLabel : null,
        subtitle: reminder.note.isEmpty ? when : '$when\n${reminder.note}',
        trailing: isToday && !reminder.done
            ? const Icon(
                CupertinoIcons.bell_fill,
                color: AppColors.orange,
                size: 18,
              )
            : null,
        showChevron: false,
        onTap: () => service.toggleDone(reminder.id),
      ),
    );
  }
}

class _ReminderForm extends StatefulWidget {
  const _ReminderForm();

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  DateTime? _dateTime;
  String? _timeError;

  static const _presets = [
    (CupertinoIcons.building_2_fill, AppColors.blue, 'Kontrol ke puskesmas'),
    (CupertinoIcons.capsule_fill, AppColors.pink, 'Minum obat'),
    (CupertinoIcons.heart_fill, AppColors.red, 'Cek tekanan darah'),
  ];

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final initial =
        _dateTime ??
        DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
        ).add(const Duration(days: 1));
    final picked = await pickDateTime(
      context,
      title: 'Waktu Pengingat',
      initial: initial,
      minimum: now,
      maximum: now.add(const Duration(days: 365)),
      mode: CupertinoDatePickerMode.dateAndTime,
    );
    if (picked != null) {
      setState(() {
        _dateTime = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    setState(
      () => _timeError = _dateTime == null ? 'Waktu wajib dipilih' : null,
    );
    if (!formOk || _dateTime == null) return;
    final error = await context.read<ReminderService>().add(
      patientId: context.read<AuthService>().current!.id,
      title: _title.text,
      note: _note.text,
      dateTime: _dateTime!,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _timeError = error);
      return;
    }
    Navigator.pop(context);
    showMessage(context, 'Pengingat disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetHeader(title: 'Pengingat Baru', onSave: _save),
              IosSection(
                header: 'Templat cepat',
                topGap: 8,
                dividerIndent: 58,
                children: [
                  for (final (icon, color, label) in _presets)
                    IosRow(
                      leading: IconTile(icon, color: color),
                      title: label,
                      showChevron: false,
                      trailing: _title.text == label
                          ? const Icon(
                              CupertinoIcons.checkmark_alt,
                              color: AppColors.blue,
                            )
                          : null,
                      onTap: () => setState(() => _title.text = label),
                    ),
                ],
              ),
              IosSection(
                header: 'Detail',
                footer: _timeError == null
                    ? null
                    : Text(
                        _timeError!,
                        style: AppText.footnote.copyWith(color: AppColors.red),
                      ),
                children: [
                  IosField(
                    label: 'Judul',
                    controller: _title,
                    placeholder: 'Wajib diisi',
                    labelWidth: 80,
                    validator: (v) =>
                        Validators.requiredText(v, 'Judul', max: 50),
                  ),
                  IosField(
                    label: 'Catatan',
                    controller: _note,
                    placeholder: 'Opsional',
                    maxLength: 120,
                    labelWidth: 80,
                  ),
                  IosRow(
                    title: 'Waktu',
                    value: _dateTime == null
                        ? 'Pilih'
                        : '${Fmt.shortDate(_dateTime!)}, ${Fmt.time(_dateTime!)}',
                    onTap: _pickTime,
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
