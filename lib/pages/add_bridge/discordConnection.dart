import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class DiscordConnection extends StatelessWidget {
  const DiscordConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.discord_connectionTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(L10n.of(context)!.discord_connectToQrCode),
            onTap: () {},
          ),
          ListTile(
            title: Text(L10n.of(context)!.discord_connectUsernamePassword),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
