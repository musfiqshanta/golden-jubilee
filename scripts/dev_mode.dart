// Development mode script
// Run this to switch to development mode: dart scripts/dev_mode.dart

import 'dart:io';

void main() {
  print('🔄 Switching to DEVELOPMENT mode...');

  // Read the main.dart file
  final mainFile = File('lib/main.dart');
  String content = mainFile.readAsStringSync();

  // Replace the environment setting
  content = content.replaceAll(
    'CollectionConfig.setEnvironment(Environment.production);',
    'CollectionConfig.setEnvironment(Environment.development);',
  );

  // Write back to the file
  mainFile.writeAsStringSync(content);

  print('✅ Switched to DEVELOPMENT mode!');
  print(
    '🔥 Now your app will use _dev collections (batches_dev, registrations_dev, etc.)',
  );
  print('📝 Your live data will remain safe in the original collections');
  print('🔄 To switch back to production, run: dart scripts/prod_mode.dart');
}
