import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqttclient/subscribe.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();

  ConnectPage(this.address, this.username, this.password);

  final String address;
  final String username;
  final String password;
}

class _ConnectPageState extends State<ConnectPage> {
  MqttServerClient client;
  Stream<MqttClientConnectionStatus> d;

  @override
  void initState() {
    try {
      client = MqttServerClient(widget.address, 'JerbbMQTTClient');
      client.onConnected = onConnect;
      client.autoReconnect = true;
      d = client.connect(widget.username, widget.password).asStream();
    } catch (e) {
      print(e.toString());
    }

    d.listen((event) {
      setState(() {
        if(event.returnCode == MqttConnectReturnCode.badUsernameOrPassword)
          print("Bad Username or Password");
      });

      print(event.returnCode);
    });

    super.initState();
  }

  void onConnect() {
    print("Connected to server, Changing Pages");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SubscribePage(client)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attempting to Connect..."),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Attempting to connect to ${widget.address}"),
              Padding(
                padding: const EdgeInsets.all(45),
                child: LinearProgressIndicator(),
              )
            ]),
      ),
    );
  }
}
