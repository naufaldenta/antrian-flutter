import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';
import '../queue/take_queue_screen.dart';

class PoliListScreen extends StatelessWidget {
  const PoliListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    return IosPage(
      title: 'Poli & Jadwal',
      children: [
        IosSection(
          topGap: 8,
          dividerIndent: 58,
          footer: const Text(
            'Ketuk poli untuk melihat jadwal praktik dan sisa kuota.',
          ),
          children: [
            for (final poli in DummyData.polis)
              IosRow(
                leading: IconTile(poli.icon, color: poli.color),
                title: poli.name,
                subtitle: () {
                  final open = DummyData.doctorsOf(poli.id)
                      .where(
                        (d) =>
                            queue.doctorUnavailableReason(d, queue.today) ==
                            null,
                      )
                      .length;
                  return open > 0
                      ? '$open dokter tersedia hari ini'
                      : 'Tidak ada layanan hari ini';
                }(),
                onTap: () => pushPage(context, PoliDetailScreen(poli: poli)),
              ),
          ],
        ),
      ],
    );
  }
}

class PoliDetailScreen extends StatelessWidget {
  const PoliDetailScreen({super.key, required this.poli});

  final Poli poli;

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final today = queue.today;

    return IosPage(
      title: poli.name,
      large: false,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              IconTile(poli.icon, color: poli.color, size: 56),
              const SizedBox(height: 10),
              Text(poli.name, style: AppText.title2),
              const SizedBox(height: 4),
              Text(
                poli.description,
                textAlign: TextAlign.center,
                style: AppText.subhead,
              ),
              const SizedBox(height: 10),
              Text(
                '± ${poli.avgServiceMinutes} menit per pasien',
                style: AppText.footnote.copyWith(
                  color: poli.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (final d in DummyData.doctorsOf(poli.id))
          () {
            final reason = queue.doctorUnavailableReason(d, today);
            return IosSection(
              header: d.name,
              children: [
                IosRow(title: 'Hari praktik', value: Fmt.days(d.days)),
                IosRow(title: 'Jam', value: '${d.startTime}–${d.endTime}'),
                IosRow(title: 'Kuota harian', value: '${d.dailyQuota} pasien'),
                IosRow(
                  title: 'Hari ini',
                  value:
                      reason ??
                      'Sisa ${queue.remainingQuota(d.id, today)} kuota',
                  trailing: Icon(
                    reason == null
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.xmark_circle_fill,
                    color: reason == null ? AppColors.green : AppColors.red,
                    size: 20,
                  ),
                ),
              ],
            );
          }(),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Ambil Antrean di Poli Ini',
          icon: CupertinoIcons.tickets_fill,
          color: poli.color,
          onPressed: () =>
              pushPage(context, TakeQueueScreen(initialPoliId: poli.id)),
        ),
      ],
    );
  }
}
