import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../services/queue_service.dart';
import 'common.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.onTap});

  final Ticket ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final poli = DummyData.poliById(ticket.poliId);
    final doctor = DummyData.doctorById(ticket.doctorId);
    final status = queue.statusOf(ticket);
    final isToday = Fmt.sameDay(ticket.visitDate, queue.today);
    final serving = queue.servingNumber(ticket.doctorId);
    final progress = isToday
        ? (serving / ticket.number).clamp(0.0, 1.0).toDouble()
        : 0.0;

    String detail;
    switch (status) {
      case TicketStatus.menunggu:
        detail =
            '${queue.peopleAhead(ticket)} antrean di depan · '
            '${Fmt.duration(queue.estimatedWaitMinutes(ticket))}';
      case TicketStatus.dipanggil:
        detail = 'Silakan menuju ruang ${poli.name}';
      case TicketStatus.terjadwal:
        detail = 'Jam praktik ${doctor.startTime}–${doctor.endTime}';
      default:
        detail = doctor.name;
    }

    return SummaryCard(
      icon: poli.icon,
      color: poli.color,
      category: poli.name,
      trailingText: relativeDay(ticket.visitDate, queue.today),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: BigValue(
                  Fmt.queueNumber(poli.code, ticket.number),
                  unit: 'nomor Anda',
                ),
              ),
              StatusPill(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(detail, style: AppText.subhead),
          if (isToday && status == TicketStatus.menunggu) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: poli.color,
                backgroundColor: poli.color.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  CupertinoIcons.dot_radiowaves_left_right,
                  size: 13,
                  color: poli.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Sedang dilayani ${Fmt.queueNumber(poli.code, serving)}',
                  style: AppText.footnote,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
