import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bill_keeper/app.dart';
import 'package:bill_keeper/data/providers/database_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => AppDatabase()),
      ],
      child: const BillKeeperApp(),
    ),
  );
}
