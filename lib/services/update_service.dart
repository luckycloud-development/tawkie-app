import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tawkie/utils/app_info.dart';

Future<String?> getLatestVersionFromGitHub() async {
  final String url = "https://api.github.com/repos/Tawkie/tawkie-app/releases/latest";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final latestVersion = data['tag_name']; // Retrieves the tag for the latest version

    print("La dernière version recup de github: $latestVersion");
    return latestVersion;
  } else {
    print('Erreur lors de la récupération des informations de version : ${response.statusCode}');
    return null;
  }
}

Future<String?> getWindowsExeDownloadUrl() async {
  final String url = "https://api.github.com/repos/Tawkie/tawkie-app/releases/latest";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<dynamic> assets = data['assets'];

    // Parcours de la liste des assets pour trouver l'URL du fichier Windows (.exe)
    for (var asset in assets) {
      if (asset['name'].endsWith('.exe')) {  // Vérifie si le nom du fichier se termine par .exe
        return asset['browser_download_url']; // Retourne l'URL de téléchargement
      }
    }
    print('Aucun fichier .exe trouvé dans les assets de la release.');
  } else {
    print('Erreur lors de la récupération des informations de la release : ${response.statusCode}');
  }
  return null;
}
