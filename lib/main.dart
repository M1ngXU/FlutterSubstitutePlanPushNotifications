import 'dart:convert';
import 'dart:developer';

import 'package:better_sdui_push_notification/cache/manager.dart';
import 'package:better_sdui_push_notification/sdui_protocol/agent.dart';
import 'package:flutter/material.dart';

import 'cache/login_data.dart';
/*
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CacheManager.create().then((cacheManager) async {
    cacheManager.write(LoginData(username: "max.obreiter@gmail.com", password: "1f9766fd56", school: "gymnasium-walldorf").toString());
    var s = await SduiAgent.create(LoginData.fromJson(jsonDecode(cacheManager.read())));
    log(s.loginData.toString());
  });
  runApp(const MyApp());
}*/

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Better SDUI';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(scaffoldBackgroundColor: const Color.fromRGBO(0, 0, 0, 1.0)),
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Better SDUI Notification',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                      color:  Colors.white,
                      fontSize: 20),
                )),
            Container(
              padding:  const EdgeInsets.fromLTRB(0, 0, 0, 5),
              color: Colors.white,
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              color: Colors.white,
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),

            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {
                    login(nameController.text, passwordController.text);
                  },
                )
            ),
          ],
        ));
  }

  void login(String s, String t) => log("username: $s, password: $t");
}