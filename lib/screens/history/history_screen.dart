import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'semua';

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<AuthService>().current!.id;
    final queue = context.watch<QueueService>();
    final all = queue.historyOf(patientId);
    final items = switch (_filter) {
      'selesai' =>
        all.where((t) => queue.statusOf(t) == TicketStatus.selesai).toList(),
      'batal' =>
        all.where((t) => queue.statusOf(t) == TicketStatus.dibatalkan).toList(),
      _ => all,
    };
    final doneCount = all
        .where((t) => queue.statusOf(t) == TicketStatus.selesai)
        .length;

    return IosPage(
      title: 'Riwayat',
      children: [
        const SizedBox(height: 4),
        CupertinoSlidingSegmentedControl<String>(
          groupValue: _filter,
          children: const {
            'semua': Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('Semua'),
            ),
            'selesai': Text('Selesai'),
            'batal': Text('Dibatalkan'),
          },
          onValueChanged: (v) => setState(() => _filter = v ?? 'semua'),
        ),
        if (items.isEmpty)
          const EmptyState(
            icon: CupertinoIcons.clock,
            title: 'Belum Ada Riwayat',
            message:
                'Kunjungan yang selesai atau dibatalkan akan muncul di sini.',
          )
        else
          IosSection(
            header: '$doneCount kunjungan selesai',
            dividerIndent: 58,
            children: [
              for (final t in items)
                () {
                  final poli = DummyData.poliById(t.poliId);
                  return IosRow(
                    leading: IconTile(poli.icon, color: poli.color),
                    title: poli.name,
                    subtitle:
                        '${Fmt.shortDate(t.visitDate)} · ${Fmt.queueNumber(poli.code, t.number)}',
                    trailing: StatusPill(queue.statusOf(t)),
                    showChevron: true,
                    onTap: () => _showDetail(context, t, queue.statusOf(t)),
                  );
                }(),
            ],
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, Ticket t, TicketStatus status) {
    final poli = DummyData.poliById(t.poliId);
    final doctor = DummyData.doctorById(t.doctorId);
    showFormSheet(
      context,
      title: 'Detail Kunjungan',
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Detail Kunjungan', style: AppText.headline),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconTile(poli.icon, color: poli.color, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(poli.name, style: AppText.title3),
                        Text(Fmt.fullDate(t.visitDate), style: AppText.subhead),
                      ],
                    ),
                  ),
                  StatusPill(status),
                ],
              ),
              IosSection(
                children: [
                  IosRow(
                    title: 'Nomor antrean',
                    value: Fmt.queueNumber(poli.code, t.number),
                  ),
                  DetailRow(label: 'Dokter', value: doctor.name),
                  DetailRow(label: 'Keluhan', value: t.complaint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
