import 'package:flutter/material.dart';

class LoginDialog extends StatelessWidget {
  final VoidCallback onLoginPressed;
  const LoginDialog({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text('Login Required'),
      content: Text(
          "Une authentification est nécessaire avant de pouvoir changer de mot de passe."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLoginPressed();
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
