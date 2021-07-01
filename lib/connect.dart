import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  MqttBrowserClient browserClient;
  Stream<MqttClientConnectionStatus> d;

  @override
  void initState() {
    try {
      if (kIsWeb) {
        browserClient =
            MqttBrowserClient('ws://${widget.address}', 'JerbbMQTTSite');
        browserClient.onConnected = onConnectBrowser;
        browserClient.autoReconnect = true;
        browserClient.port = 8080;
        d = browserClient.connect(widget.username, widget.password).asStream();
      } else {
        client = MqttServerClient(widget.address, 'JerbbMQTTClient');
        client.onConnected = onConnect;
        client.autoReconnect = true;
        d = client.connect(widget.username, widget.password).asStream();
      }
    } catch (e) {
      print(e.toString());
    }

    d.listen((event) {
      setState(() {
        if (event.returnCode == MqttConnectReturnCode.badUsernameOrPassword)
          print("Bad Username or Password");
        if (event.returnCode == MqttConnectReturnCode.brokerUnavailable) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => MacosAlertDialog(
              appIcon: FlutterLogo(
                size: 56,
              ),
              title: Text(
                'An error has occured',
                style: MacosTheme.of(context).typography.headline,
              ),
              message: Text(
                event.returnCode.toString(),
                textAlign: TextAlign.center,
                style: MacosTheme.of(context).typography.headline,
              ),
              primaryButton: PushButton(
                buttonSize: ButtonSize.large,
                child: Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
        }
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

  void onConnectBrowser() {
    print("Connected to server, Changing Pages (Browser)");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SubscribePage(browserClient)));
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      titleBar: TitleBar(child: Text("Attempting to Connect...")),
      children: <Widget>[
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Attempting to connect to ${widget.address}"),
                      Padding(
                        padding: const EdgeInsets.all(45),
                        child: LinearProgressIndicator(),
                      ),
                      PushButton(
                        child: Text("Cancel Connection"),
                        buttonSize: ButtonSize.large,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
