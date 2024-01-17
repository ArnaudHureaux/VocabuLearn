import 'dart:io';
import 'package:path_provider/path_provider.dart';

void clearSettingsFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/settings.txt';
    await File(path).writeAsString('');
    print('Le contenu de settings.txt a été effacé.');
  } catch (e) {
    print("Erreur lors de l'effacement du fichier: $e");
  }
}

void main() {
  clearSettingsFile();
}
