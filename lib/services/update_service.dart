import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tawkie/utils/app_info.dart';

Future<String?> getLatestVersionFromGitHub() async {
  final String url = "https://api.github.com/repos/Tawkie/tawkie-app/releases/latest";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final latestVersion = data['tag_name']; // Retrieves the tag for the latest version

    print("La dernière version récupérée de GitHub : $latestVersion");
    return latestVersion;
  } else {
    print('Erreur lors de la récupération des informations de version : ${response.statusCode}');
    return null;
  }
}

Future<String?> getWindowsExeDownloadUrl() async {
  try {
    final String url = "https://api.github.com/repos/Tawkie/tawkie-app/releases/latest";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> assets = data['assets'];

      // Browse asset list to find URL of Windows file (.exe)
      for (var asset in assets) {
        if (asset['name'].endsWith('.exe')) {
          print("URL du fichier .exe : ${asset['browser_download_url']}");
          return asset['browser_download_url'];
        }
      }
      print('Aucun fichier .exe trouvé dans les assets de la release.');
      return null;
    } else {
      print('Erreur lors de la récupération des informations de la release : ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print("Erreur lors de la récupération de l'URL : $e");
    return null;
  }
}
