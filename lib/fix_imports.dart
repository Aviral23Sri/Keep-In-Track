import 'dart:io';

void main() {
  final files = [
    'category_providers.dart',
    'dashboard_providers.dart',
    'merchant_providers.dart',
    'reports_providers.dart',
    'settings_providers.dart',
    'transaction_providers.dart'
  ];

  for (final file in files) {
    final f = File('lib/shared/providers/\$file');
    if (f.existsSync()) {
      final content = f.readAsStringSync();
      if (!content.contains('flutter_riverpod.dart')) {
        f.writeAsStringSync("import 'package:flutter_riverpod/flutter_riverpod.dart';\\n" + content);
        print('Fixed \$file');
      }
    }
  }
}
