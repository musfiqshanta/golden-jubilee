// Production mode script
// Run this to switch to production mode: dart scripts/prod_mode.dart

import 'dart:io';

void main() {
  print('🔄 Switching to PRODUCTION mode...');

  // Read the main.dart file
  final mainFile = File('lib/main.dart');
  String content = mainFile.readAsStringSync();

  // Replace the environment setting
  content = content.replaceAll(
    'CollectionConfig.setEnvironment(Environment.development);',
    'CollectionConfig.setEnvironment(Environment.production);',
  );

  // Write back to the file
  mainFile.writeAsStringSync(content);

  print('✅ Switched to PRODUCTION mode!');
  print(
    '🚀 Now your app will use live collections (batches, registrations, etc.)',
  );
  print('⚠️  Be careful - any changes will affect real users!');
  print('🔄 To switch back to development, run: dart scripts/dev_mode.dart');
}
