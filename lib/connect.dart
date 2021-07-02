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

  ConnectPage(this.address, this.username, this.password, {this.port = 1883});

  final String address;
  final String username;
  final String password;
  final int port;
}

class _ConnectPageState extends State<ConnectPage> {
  MqttServerClient client;
  MqttBrowserClient browserClient;
  Stream<MqttClientConnectionStatus> d;

  @override
  void initState() {
    try {
      if (kIsWeb) {
        print('Connecting to ws://${widget.address}:${widget.port}');
        browserClient =
            MqttBrowserClient('ws://${widget.address}', 'JerbbMQTTSite');
        browserClient.onConnected = onConnectBrowser;
        browserClient.autoReconnect = true;
        browserClient.port = widget.port;
        d = browserClient.connect(widget.username, widget.password).asStream();
      } else {
        print('Connecting to ${widget.address}:${widget.port}');
        client = MqttServerClient(widget.address, 'JerbbMQTTClient');
        client.onConnected = onConnect;
        client.autoReconnect = true;
        client.port = widget.port;
        d = client.connect(widget.username, widget.password).asStream();
      }
    } catch (e) {
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
            e.toString(),
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

    d.listen((event) {
      setState(() {
        if (event.returnCode == MqttConnectReturnCode.badUsernameOrPassword)
          print("Bad Username or Password");
        if (event.returnCode == MqttConnectReturnCode.notAuthorized) {
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
