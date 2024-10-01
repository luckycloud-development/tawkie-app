import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tawkie/utils/app_info.dart';

Future<String?> checkForUpdate() async {
  final String url = "https://api.github.com/repos/Tawkie/tawkie-app/releases/latest";
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final latestVersion = data['tag_name']; // Recovers the latest version tag
    final downloadUrl = data['assets'][0]['browser_download_url']; // Retrieves download URL

    // Dynamic retrieval of the current version
    final String currentVersion = await getAppVersion();

    if (latestVersion != currentVersion) {
      // If a new version is available, we return the URL
      return downloadUrl;
    }
  } else {
    print('Erreur lors de la récupération des informations de version.');
  }
  return null;
}