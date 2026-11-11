import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';
import 'queue_status_screen.dart';
import 'take_queue_screen.dart';

class MyQueueScreen extends StatelessWidget {
  const MyQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<AuthService>().current!.id;
    final tickets = context.watch<QueueService>().activeTicketsOf(patientId);
    void openTake() => pushPage(context, const TakeQueueScreen());

    return IosPage(
      title: 'Antrean',
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: openTake,
        child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
      ),
      children: [
        if (tickets.isEmpty)
          EmptyState(
            icon: CupertinoIcons.tickets,
            title: 'Belum Ada Antrean',
            message:
                'Ambil nomor antrean tanpa harus datang pagi-pagi ke puskesmas.',
            action: PrimaryButton(
              label: 'Ambil Nomor Antrean',
              icon: CupertinoIcons.add,
              onPressed: openTake,
            ),
          )
        else ...[
          const SizedBox(height: 8),
          for (final t in tickets)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TicketCard(
                ticket: t,
                onTap: () =>
                    pushPage(context, QueueStatusScreen(ticketId: t.id)),
              ),
            ),
          const SizedBox(height: 6),
          TintedButton(
            label: 'Ambil Antrean Lain',
            icon: CupertinoIcons.add,
            onPressed: openTake,
          ),
        ],
      ],
    );
  }
}
