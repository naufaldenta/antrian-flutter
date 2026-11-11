import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/local_storage.dart';
import 'services/auth_service.dart';
import 'services/queue_service.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorage.open();

  final auth = AuthService(storage);
  final queue = QueueService(storage);
  final reminders = ReminderService(storage);
  await auth.init();
  await queue.init();
  await reminders.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: queue),
        ChangeNotifierProvider.value(value: reminders),
      ],
      child: const AntreSehatApp(),
    ),
  );
}
