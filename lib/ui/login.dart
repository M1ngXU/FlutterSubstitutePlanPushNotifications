import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:substitute_plan_push_notifications/ui/schools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../generated/l10n.dart';

Container _getTextField(
    TextEditingController controller,
    String hint,
    String autofillHint,
    {
      void Function()? onTap,
      TextInputType? keyboardType,
      Widget? suffix,
      bool readonly = false,
      bool obscureText = false
    }) =>  Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(5),
    child: PlatformTextField(
      controller: controller,
      readOnly: readonly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: onTap,
      autofillHints: [autofillHint],
      material: (_, __) => MaterialTextFieldData(
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hint,
            suffixIcon: suffix
        ),
      ),
      cupertino: (_, __) => CupertinoTextFieldData(
          placeholder: hint,
          placeholderStyle: const TextStyle(color: Colors.black38),
          style: const TextStyle(color: Colors.black54),
          decoration: BoxDecoration(
              color: CupertinoColors.extraLightBackgroundGray,
              border: Border.all(
                  color: CupertinoColors.lightBackgroundGray,
                  width: 2
              ),
              borderRadius: BorderRadius.circular(10)
          ),
          cursorColor: CupertinoColors.activeGreen,
          suffix: suffix,
          suffixMode: OverlayVisibilityMode.always
      ),
    )
);

class LoginScreen extends StatelessWidget {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _slinkController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(10),
      child: AutofillGroup(
          child: ListView(
            children: [
              _getTextField(
                _urlController,
                S.of(context).serverURL,
                AutofillHints.url,
                keyboardType: TextInputType.url
              ),
              _getTextField(
                  _slinkController,
                  S.of(context).schoolID,
                  'slink',
                  readonly: true,
                  keyboardType: TextInputType.name,
                  onTap: () => S.of(context).searchID.toastify(toastLength: Toast.LENGTH_LONG),
                  suffix: PlatformIconButton(
                      icon: Icon(PlatformIcons(context).search),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        var uri = Uri.parse(_urlController.text);
                        bool possibleConnection = false;
                        try {
                          var res = await get(uri.set('v1/leads', {'search': hashCode.toString()}));
                          possibleConnection = res.statusCode / 100 == 2;
                          if (!possibleConnection) throw 'Bad response from server (${res.statusCode}).';
                          showSearch(
                            context: context,
                            delegate: SchoolSearchDelegate(Uri.parse(_urlController.text)),
                          ).then((value) {
                            if (value != null) _slinkController.text = value;
                          });
                        } catch(e, st) {
                          Logger.ve(S.current.invalidURL, e, st);
                        }
                      }
                  )
              ),
              _getTextField(
                _usernameController,
                S.of(context).usernameEmail,
                AutofillHints.username,
                keyboardType: TextInputType.emailAddress,
              ),
              _getTextField(
                _passwordController,
                S.of(context).password,
                AutofillHints.password,
                obscureText: true
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: PlatformElevatedButton(
                    child: Text(S.of(context).login),
                    onPressed: () async {
                      if (await Manager.singleton.login(
                          _urlController.text,
                          _usernameController.text,
                          _passwordController.text,
                          _slinkController.text
                      )) {
                        TextInput.finishAutofillContext(shouldSave: true);
                      }
                    },
                  )
              ),
            ],
          )
      )
  );
}
