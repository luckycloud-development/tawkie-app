import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:one_of/one_of.dart';
import 'package:ory_kratos_client/ory_kratos_client.dart';
import 'package:tawkie/config/app_config.dart';

import 'package:tawkie/pages/settings_password/settings_password_view.dart';
import 'package:tawkie/utils/localized_exception_extension.dart';
import 'package:tawkie/widgets/matrix.dart';

class SettingsPassword extends StatefulWidget {
  const SettingsPassword({super.key});

  @override
  SettingsPasswordController createState() => SettingsPasswordController();
}

class SettingsPasswordController extends State<SettingsPassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPassword1Controller = TextEditingController();
  final TextEditingController newPassword2Controller = TextEditingController();

  String? oldPasswordError;
  String? newPassword1Error;
  String? newPassword2Error;

  bool loading = false;

  String baseUrl = AppConfig.baseUrl;
  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    dio = Dio(BaseOptions(baseUrl: '${baseUrl}panel/api/.ory'));

    // Set authorization header with session token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final sessionToken = await _secureStorage.read(key: 'sessionToken');
        options.headers['Authorization'] = 'Bearer $sessionToken';
        return handler.next(options);
      },
    ));
  }

  void changePassword() async {
    final OryKratosClient kratosClient = OryKratosClient(dio: dio);
    final api = kratosClient.getFrontendApi();

    setState(() {
      oldPasswordError = newPassword1Error = newPassword2Error = null;
    });
    if (oldPasswordController.text.isEmpty) {
      setState(() {
        oldPasswordError = L10n.of(context)!.pleaseEnterYourPassword;
      });
      return;
    }
    if (newPassword1Controller.text.isEmpty ||
        newPassword1Controller.text.length < 6) {
      setState(() {
        newPassword1Error = L10n.of(context)!.pleaseChooseAStrongPassword;
      });
      return;
    }
    if (newPassword1Controller.text != newPassword2Controller.text) {
      setState(() {
        newPassword2Error = L10n.of(context)!.passwordsDoNotMatch;
      });
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final settingsFlowResponse = await api.createNativeSettingsFlow();

      final updateSettingsFlow =
          UpdateSettingsFlowWithPasswordMethod((builder) => builder
            ..method = 'password'
            ..password = newPassword1Controller.text);

      // Create an UpdateLoginFlowBodyBuilder object and assign it the UpdateLoginFlowWithPasswordMethod object
      final updateSettingsFlowBody = UpdateSettingsFlowBody(
        (builder) =>
            builder..oneOf = OneOf.fromValue1(value: updateSettingsFlow),
      );

      final passwordResponse = await api.updateSettingsFlow(
          flow: settingsFlowResponse.data!.id,
          updateSettingsFlowBody: updateSettingsFlowBody);
      if (kDebugMode) {
        print('Successfully settingsFlowResponse with new password');
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.passwordHasBeenChanged),
        ),
      );
      if (mounted) context.pop();
    } on DioException catch (e) {
      // Handle DioError specifically

      setState(() {
        newPassword2Error = e.toLocalizedString(
          context,
          ExceptionContext.changePassword,
        );
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => SettingsPasswordView(this);
}
