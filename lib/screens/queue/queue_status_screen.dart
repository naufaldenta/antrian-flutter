import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final ticket = queue.byId(ticketId);
    if (ticket == null) {
      return const IosPage(
        title: 'Status Antrean',
        large: false,
        children: [
          EmptyState(
            icon: CupertinoIcons.search,
            title: 'Antrean Tidak Ditemukan',
            message: 'Data antrean mungkin sudah dihapus.',
          ),
        ],
      );
    }

    final poli = DummyData.poliById(ticket.poliId);
    final doctor = DummyData.doctorById(ticket.doctorId);
    final status = queue.statusOf(ticket);
    final statusColor = AppTheme.statusColor(status);
    final isToday = Fmt.sameDay(ticket.visitDate, queue.today);
    final serving = queue.servingNumber(ticket.doctorId);
    final ahead = queue.peopleAhead(ticket);
    final canCancel =
        status == TicketStatus.terjadwal || status == TicketStatus.menunggu;
    final progress = isToday
        ? (serving / ticket.number).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return IosPage(
      title: 'Status Antrean',
      large: false,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconTile(poli.icon, color: poli.color, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(poli.name, style: AppText.headline),
                        Text(
                          relativeDay(ticket.visitDate, queue.today),
                          style: AppText.footnote,
                        ),
                      ],
                    ),
                  ),
                  StatusPill(status),
                ],
              ),
              const SizedBox(height: 18),
              const Text('NOMOR ANTREAN ANDA', style: AppText.footnote),
              const SizedBox(height: 2),
              Text(
                Fmt.queueNumber(poli.code, ticket.number),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color:
                      status == TicketStatus.selesai ||
                          status == TicketStatus.dibatalkan
                      ? AppColors.gray
                      : poli.color,
                  height: 1.1,
                ),
              ),
              if (isToday && status == TicketStatus.menunggu) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: poli.color,
                    backgroundColor: poli.color.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Dilayani ${Fmt.queueNumber(poli.code, serving)}',
                      style: AppText.caption,
                    ),
                    const Spacer(),
                    Text(
                      'Diperbarui tiap ${queue.tickInterval.inSeconds} detik',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        if (isToday && status == TicketStatus.menunggu) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: CupertinoIcons.speaker_2_fill,
                  color: AppColors.green,
                  label: 'Dilayani',
                  value: Fmt.queueNumber(poli.code, serving),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  icon: CupertinoIcons.person_3_fill,
                  color: AppColors.orange,
                  label: 'Di depan',
                  value: '$ahead',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  icon: CupertinoIcons.timer,
                  color: AppColors.indigo,
                  label: 'Estimasi',
                  value: Fmt.duration(
                    queue.estimatedWaitMinutes(ticket),
                  ).replaceAll('± ', ''),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),
        if (status == TicketStatus.dipanggil)
          Callout(
            color: statusColor,
            icon: CupertinoIcons.speaker_3_fill,
            text:
                'Nomor Anda sedang dipanggil. Silakan menuju ruang ${poli.name}.',
          ),
        if (status == TicketStatus.selesai)
          const Callout(
            color: AppColors.green,
            icon: CupertinoIcons.checkmark_seal_fill,
            text:
                'Kunjungan selesai dan tersimpan di Riwayat. Semoga lekas sembuh!',
          ),
        if (status == TicketStatus.dibatalkan)
          const Callout(
            color: AppColors.red,
            icon: CupertinoIcons.xmark_circle_fill,
            text: 'Antrean ini telah dibatalkan.',
          ),
        if (status == TicketStatus.terjadwal)
          Callout(
            color: statusColor,
            icon: CupertinoIcons.calendar_badge_plus,
            text:
                'Terjadwal ${Fmt.fullDate(ticket.visitDate)}. Ada ${ticket.number - 1} '
                'pendaftar sebelum Anda. Status dipantau langsung pada hari kunjungan.',
          ),

        IosSection(
          header: 'Detail Kunjungan',
          children: [
            DetailRow(label: 'Dokter', value: doctor.name),
            DetailRow(label: 'Tanggal', value: Fmt.fullDate(ticket.visitDate)),
            DetailRow(
              label: 'Jam praktik',
              value: '${doctor.startTime}–${doctor.endTime}',
            ),
            DetailRow(label: 'Keluhan', value: ticket.complaint),
            DetailRow(
              label: 'Didaftarkan',
              value:
                  '${Fmt.shortDate(ticket.createdAt)}, ${Fmt.time(ticket.createdAt)}',
            ),
          ],
        ),

        if (isToday &&
            (status == TicketStatus.menunggu ||
                status == TicketStatus.dipanggil))
          IosSection(
            header: 'Mode Demo',
            footer: const Text(
              'Memajukan antrean secara manual untuk presentasi.',
            ),
            children: [
              IosRow(
                leading: const IconTile(
                  CupertinoIcons.forward_fill,
                  color: AppColors.gray,
                ),
                title: status == TicketStatus.dipanggil
                    ? 'Selesaikan pemeriksaan'
                    : 'Panggil nomor berikutnya',
                titleColor: AppColors.blue,
                showChevron: false,
                onTap: () => queue.advanceDoctor(ticket.doctorId),
              ),
            ],
          ),

        if (canCancel)
          IosSection(
            children: [
              IosRow(
                title: 'Batalkan Antrean',
                titleColor: AppColors.red,
                titleCentered: true,
                showChevron: false,
                onTap: () => _cancel(context, ticket),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _cancel(BuildContext context, Ticket ticket) async {
    final ok = await confirmDialog(
      context,
      title: 'Batalkan antrean?',
      message:
          'Nomor yang dibatalkan tidak dapat dipulihkan. '
          'Anda perlu mengambil nomor baru jika ingin berkunjung.',
      confirmLabel: 'Batalkan',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final error = await context.read<QueueService>().cancelTicket(ticket.id);
    if (!context.mounted) return;
    showMessage(
      context,
      error ?? 'Antrean berhasil dibatalkan.',
      error: error != null,
    );
    if (error == null) Navigator.pop(context);
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.title2),
          ),
        ],
      ),
    );
  }
}
