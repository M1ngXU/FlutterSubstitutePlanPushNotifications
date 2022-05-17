import 'package:substitute_plan_push_notifications/cache/logger.dart';
import 'package:substitute_plan_push_notifications/manager.dart';
import 'package:substitute_plan_push_notifications/ui/schools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:substitute_plan_push_notifications/util.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../generated/l10n.dart';

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
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                child: TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: S.of(context).serverURL,
                  ),
                  autofillHints: const [AutofillHints.url],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                child: TextField(
                  readOnly: true,
                  onTap: () => S.of(context).searchID.toastify(toastLength: Toast.LENGTH_LONG),
                  controller: _slinkController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.search_rounded),
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
                    ),
                    labelText: S.of(context).schoolID,
                  ),
                  autofillHints: const ['slink'],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                child: TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: S.of(context).usernameEmail,
                  ),
                  autofillHints: const [AutofillHints.username],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                child: TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: S.of(context).password,
                  ),
                  autofillHints: const [AutofillHints.password],
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
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
