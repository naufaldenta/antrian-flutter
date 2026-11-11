import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/queue_service.dart';
import '../../widgets/common.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../queue/my_queue_screen.dart';
import '../reminder/reminder_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final QueueService _queue;

  @override
  void initState() {
    super.initState();
    _queue = context.read<QueueService>();
    _queue.watchedPatientId = context.read<AuthService>().current?.id;
    _queue.alert.addListener(_onAlert);
  }

  @override
  void dispose() {
    _queue.alert.removeListener(_onAlert);
    _queue.watchedPatientId = null;
    super.dispose();
  }

  void _onAlert() {
    final msg = _queue.alert.value;
    if (msg == null || !mounted) return;
    showMessage(context, msg, icon: CupertinoIcons.bell_fill);
    _queue.alert.value = null;
  }

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: goTo),
      const MyQueueScreen(),
      const HistoryScreen(),
      const ReminderScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _index,
        onTap: goTo,
        activeColor: AppColors.blue,
        inactiveColor: AppColors.gray,
        backgroundColor: const Color(0xF0F9F9F9),
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            activeIcon: Icon(CupertinoIcons.heart_fill),
            label: 'Ringkasan',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tickets),
            activeIcon: Icon(CupertinoIcons.tickets_fill),
            label: 'Antrean',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            activeIcon: Icon(CupertinoIcons.clock_fill),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell),
            activeIcon: Icon(CupertinoIcons.bell_fill),
            label: 'Pengingat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            activeIcon: Icon(CupertinoIcons.person_crop_circle_fill),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
