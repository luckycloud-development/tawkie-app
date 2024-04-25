import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LoginDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;
  const LoginDialog({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(L10n.of(context)!.loginReLog),
      content: Text(L10n.of(context)!.loginReLogForPassword),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(L10n.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLoginPressed();
          },
          child: Text(L10n.of(context)!.login),
        ),
      ],
    );
  }
}
