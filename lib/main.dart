import 'package:flutter/material.dart';
import 'package:mac_notifications/mac_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:macos_ui/macos_ui.dart';
import 'connect.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'MQTT Notifier',
      theme: MacosThemeData.light().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: MacosThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Connect to MQTT Broker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _loginFormKey = new GlobalKey<FormState>();
  var _addressKey = new TextEditingController();
  var _unameKey = new TextEditingController();
  var _passwordKey = new TextEditingController();
  var _portKey = new TextEditingController();

  // void _incrementCounter() {
  //   try {
  //     MacNotifications.showNotification(
  //       MacNotificationOptions(
  //         identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
  //         title: 'Hello There!',
  //         subtitle: "You're probably wondering what this does.",
  //         informative: "You'll see soon enough 😉",
  //       ),
  //     );
  //   } on PlatformException {}
  // }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      titleBar: TitleBar(child: Text(widget.title)),
      children: <Widget>[
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(20),
              child: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Form(
                  key: _loginFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: MacosTextField(
                                controller: _addressKey,
                                placeholder: "MQTT Broker Address",
                                // validator: (String s) {
                                //   return s.isEmpty ? 'Please enter an address' : null;
                                // },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: MacosTextField(
                                controller: _portKey,
                                placeholder: "1883",
                                // validator: (String s) {
                                //   return s.isEmpty ? 'Please enter an address' : null;
                                // },
                              ),
                            ),
                          ],
                        ),
                      ),
                      MacosTextField(
                        controller: _unameKey,
                        placeholder: "MQTT Broker Username",
                      ),
                      MacosTextField(
                        controller: _passwordKey,
                        placeholder: "MQTT Broker Password",
                        obscureText: true,
                      ),
                      SizedBox(height: 50, width: 1),
                      PushButton(
                        child: Text("Connect to MQTT Broker"),
                        buttonSize: ButtonSize.large,
                        onPressed: () => {
                          if (_loginFormKey.currentState.validate())
                            {
                              if (_addressKey.value.text.isNotEmpty)
                                {
                                  if (!kIsWeb)
                                    MacNotifications.showNotification(
                                      MacNotificationOptions(
                                        identifier:
                                            'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
                                        title:
                                            'Connecting to ${_addressKey.value.text}',
                                        subtitle:
                                            'With username ${_unameKey.value.text}',
                                      ),
                                    ),
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ConnectPage(
                                                  _addressKey.value.text.trim(),
                                                  _unameKey.value.text.trim(),
                                                  _passwordKey.value.text
                                                      .trim(),
                                                  port: int.parse(
                                                      _portKey.value.text != "" ? _portKey.value.text : "1883"))))
                                }
                              else
                                {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MacosAlertDialog(
                                      appIcon: FlutterLogo(
                                        size: 56,
                                      ),
                                      title: Text(
                                        'An address is required',
                                        style: MacosTheme.of(context)
                                            .typography
                                            .headline,
                                      ),
                                      message: Text(
                                        'Please type an address in the field',
                                        textAlign: TextAlign.center,
                                        style: MacosTheme.of(context)
                                            .typography
                                            .headline,
                                      ),
                                      primaryButton: PushButton(
                                        buttonSize: ButtonSize.large,
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  )
                                }
                            }
                        },
                      ),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ],

      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.connect_without_contact),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
