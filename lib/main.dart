import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mac_notifications/mac_notifications.dart';
import 'connect.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
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

  void _incrementCounter() {
    try {
      MacNotifications.showNotification(
        MacNotificationOptions(
          identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
          title: 'Hello There!',
          subtitle: "You're probably wondering what this does.",
          informative:
              "You'll see soon enough 😉",
        ),
      );
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
                child: TextFormField(
                  controller: _addressKey,
                  decoration: InputDecoration(labelText: "MQTT Broker Address"),
                  validator: (String s) {
                    return s.isEmpty ? 'Please enter an address' : null;
                  },
                ),
              ),
              TextFormField(
                controller: _unameKey,
                decoration: InputDecoration(labelText: "MQTT Broker Username"),
              ),
              TextFormField(
                controller: _passwordKey,
                decoration: InputDecoration(labelText: "MQTT Broker Password"),
                obscureText: true,
              ),
              SizedBox(height: 50, width: 1),
              RaisedButton(
                child: Text("Connect to MQTT Broker"),
                onPressed: () => {
                  if (_loginFormKey.currentState.validate())
                    {
                      MacNotifications.showNotification(
                        MacNotificationOptions(
                          identifier:
                              'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Connecting to ${_addressKey.value.text}',
                          subtitle: 'With username ${_unameKey.value.text}',
                        ),
                      ),
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ConnectPage(_addressKey.value.text, _unameKey.value.text, _passwordKey.value.text)))
                    }
                },
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
