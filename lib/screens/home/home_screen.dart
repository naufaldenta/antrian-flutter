import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/dummy_data.dart';
import '../../data/models.dart';
import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../services/reminder_service.dart';
import '../../widgets/common.dart';
import '../../widgets/ticket_card.dart';
import '../poli/poli_list_screen.dart';
import '../profile/privacy_screen.dart';
import '../queue/queue_status_screen.dart';
import '../queue/take_queue_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthService>().current!;
    final queue = context.watch<QueueService>();
    final reminders = context.watch<ReminderService>().upcomingOf(patient.id);
    final active = queue.activeTicketsOf(patient.id);
    final history = queue.historyOf(patient.id);
    final doneVisits = history
        .where((t) => queue.statusOf(t) == TicketStatus.selesai)
        .toList();
    final firstName = patient.name.split(' ').first;

    return IosPage(
      title: 'Ringkasan',
      trailing: GestureDetector(
        onTap: () => onNavigate(4),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.blue.withValues(alpha: 0.15),
          child: Text(
            firstName[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
      children: [
        Text('Selamat datang, $firstName', style: AppText.title3),
        const SizedBox(height: 2),
        Text(Fmt.fullDate(DateTime.now()), style: AppText.subhead),

        SectionHeading(
          'Antrean Aktif',
          action: active.isEmpty ? null : 'Lihat Semua',
          onAction: () => onNavigate(1),
        ),
        if (active.isEmpty)
          SummaryCard(
            icon: CupertinoIcons.tickets_fill,
            color: AppColors.blue,
            category: 'Antrean',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Belum ada antrean aktif', style: AppText.headline),
                const SizedBox(height: 4),
                const Text(
                  'Ambil nomor dari rumah, datang saat giliran hampir tiba.',
                  style: AppText.subhead,
                ),
                const SizedBox(height: 14),
                TintedButton(
                  label: 'Ambil Nomor Antrean',
                  icon: CupertinoIcons.add,
                  onPressed: () => pushPage(context, const TakeQueueScreen()),
                ),
              ],
            ),
          )
        else
          ...active
              .take(2)
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TicketCard(
                    ticket: t,
                    onTap: () =>
                        pushPage(context, QueueStatusScreen(ticketId: t.id)),
                  ),
                ),
              ),

        const SectionHeading('Layanan'),
        IosSection(
          topGap: 0,
          dividerIndent: 58,
          children: [
            IosRow(
              leading: const IconTile(
                CupertinoIcons.add,
                color: AppColors.blue,
              ),
              title: 'Ambil Nomor Antrean',
              subtitle: 'Pilih poli, tanggal, dan dokter',
              onTap: () => pushPage(context, const TakeQueueScreen()),
            ),
            IosRow(
              leading: const IconTile(
                CupertinoIcons.calendar,
                color: AppColors.red,
              ),
              title: 'Poli & Jadwal Dokter',
              subtitle:
                  '${DummyData.polis.length} poli · ${DummyData.doctors.length} tenaga kesehatan',
              onTap: () => pushPage(context, const PoliListScreen()),
            ),
            IosRow(
              leading: const IconTile(
                CupertinoIcons.bell_fill,
                color: AppColors.orange,
              ),
              title: 'Pengingat Kontrol',
              subtitle: 'Jadwal kontrol & minum obat',
              onTap: () => onNavigate(3),
            ),
            IosRow(
              leading: const IconTile(
                CupertinoIcons.hand_raised_fill,
                color: AppColors.indigo,
              ),
              title: 'Privasi & Data',
              subtitle: 'Data apa yang disimpan dan mengapa',
              onTap: () => pushPage(context, const PrivacyScreen()),
            ),
          ],
        ),

        const SectionHeading('Sorotan'),
        if (reminders.isNotEmpty) ...[
          SummaryCard(
            icon: CupertinoIcons.bell_fill,
            color: AppColors.orange,
            category: 'Pengingat',
            trailingText: relativeDay(
              Fmt.dateOnly(reminders.first.dateTime),
              queue.today,
            ),
            onTap: () => onNavigate(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminders.first.title, style: AppText.headline),
                const SizedBox(height: 2),
                BigValue(
                  Fmt.time(reminders.first.dateTime),
                  unit: Fmt.shortDate(reminders.first.dateTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        SummaryCard(
          icon: CupertinoIcons.clock_fill,
          color: AppColors.purple,
          category: 'Kunjungan',
          trailingText: doneVisits.isEmpty
              ? null
              : 'Terakhir ${Fmt.shortDate(doneVisits.first.visitDate)}',
          onTap: () => onNavigate(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BigValue('${doneVisits.length}', unit: 'kunjungan selesai'),
              if (doneVisits.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Terakhir ke ${DummyData.poliById(doneVisits.first.poliId).name}',
                  style: AppText.subhead,
                ),
              ],
            ],
          ),
        ),

        const SectionHeading('Fasilitas'),
        IosSection(
          topGap: 0,
          footer: const Text(
            'Datang 15 menit sebelum perkiraan giliran dan bawa KTP / kartu berobat.',
          ),
          children: const [
            DetailRow(label: 'Nama', value: DummyData.facilityName),
            DetailRow(label: 'Jam layanan', value: 'Senin–Sabtu, 08.00–16.00'),
            DetailRow(label: 'Alamat', value: 'Jl. Kesehatan No. 1 (fiktif)'),
          ],
        ),
        const SimulationNote(),
      ],
    );
  }
}
