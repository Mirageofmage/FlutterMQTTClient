import 'package:flutter/material.dart';
import 'package:mac_notifications/mac_notifications.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:universal_html/js.dart' as js;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mqttclient/SystemCommand.dart';
import 'package:mqttclient/TopicWidget.dart';
import 'package:process_run/shell.dart';

class SubscribePage extends StatefulWidget {
  @override
  _SubscribePageState createState() => _SubscribePageState();

  SubscribePage(this.client);

  final MqttClient client;
}

class _SubscribePageState extends State<SubscribePage> {
  var _subscribeKey = new GlobalKey<FormState>();
  var _subscribeController = new TextEditingController();

  var _commandProcController = new TextEditingController();
  var _commandController = new TextEditingController();

  var shell;

  List<Subscription> _subscriptionList = [];
  Map<String, String> _messageList = new Map<String, String>();
  Map<String, List<SystemCommand>> _commandList =
      new Map<String, List<SystemCommand>>();

  @override
  void dispose() {
    widget.client.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    if (!kIsWeb) {
      shell = Shell();
      MacNotifications.showNotification(
        MacNotificationOptions(
            identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
            title: 'Connected Successfully',
            subtitle: 'Successfully connected to ${widget.client.server}'),
      );
    } else {
      showNotification('Connected Successfully', 'Successfully connected to ${widget.client.server}');
    }

    widget.client.onSubscribed = onSubrcribed;
    widget.client.onSubscribeFail = subscribeFail;
    widget.client.onUnsubscribed = unSubscribed;
    widget.client.onAutoReconnected = autoReconnected;
    widget.client.onConnected = autoReconnected;
    widget.client.resubscribeOnAutoReconnect = true;

    widget.client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');

      if (!kIsWeb) {
        MacNotifications.showNotification(
          MacNotificationOptions(
            identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
            title: 'Message recieved on ${c[0].topic}',
            subtitle: 'Message contents: "$payload"',
          ),
        );
      } else {
        showNotification ('Message recieved on ${c[0].topic}', 'Message contents: "$payload"');
      }

      setState(() {
        _messageList.addAll({c[0].topic: payload});
      });

      for (var e in _commandList[c[0].topic]) {
        if (e.commandProc == payload) {
          print("Running command");
          shell.run(e.commandData);
          if (!kIsWeb) {
            MacNotifications.showNotification(
              MacNotificationOptions(
                identifier:
                    'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
                title: '${c[0].topic}: Running System Command',
                subtitle: 'Matching Message Recieved',
              ),
            );
          }
        }
      }
    });

    super.initState();
  }

  void onSubrcribed(String d) {
    setState(() {});
    print('Successfully subscribed $d');
  }

  void subscribeFail(String d) {
    setState(() {});
    print('Failed to subscribe: $d');
  }

  void unSubscribed(String d) {
    setState(() {});
    print('Unscrubed from: $d');
  }

  void autoReconnected() {
    if (!kIsWeb) {
      MacNotifications.showNotification(
        MacNotificationOptions(
            identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
            title: 'Reconnected',
            subtitle: 'Automatically reconnected to ${widget.client.server}'),
      );
    } else {
      showNotification('Reconnected', 'Automatically reconnected to ${widget.client.server}');
    }
  }

  void callAlert (){
    js.context.callMethod('alertMessage', ['Flutter is calling upon JavaScript!']);
  }

  void askPerms(){
    js.context.callMethod('askPerms');
  }

  void showNotification(String title, String body){
    js.context.callMethod('showNotification', [title, body]);
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
        titleBar: TitleBar(
          child: Text(widget.client.server),
          // actions: [
          //   IconButton(
          //     icon: Icon(Icons.add_alert),
          //     onPressed: addNewSubscription,
          //   )
          // ],
        ),
        sidebar: Sidebar(
          minWidth: 125,
          isResizable: false,
          startWidth: 125,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PushButton(
                    child: Text("Subscribe"),
                    buttonSize: ButtonSize.large,
                    onPressed: addNewSubscription,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                  ),
                  PushButton(
                    color: Colors.red,
                    child: Text("Disconnect"),
                    buttonSize: ButtonSize.large,
                    onPressed: () => Navigator.pop(context),
                  ),

                  kIsWeb ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                      ),
                      PushButton(
                        child: Text("Test Notification"),
                        buttonSize: ButtonSize.large,
                        onPressed: () => showNotification('Title of notification', 'Body of notificaiton'),
                      ),
                    ],
                  ) : null,
                ],
              ),
            );
          },
        ),
        children: <Widget>[
          ContentArea(
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  child: Row(
                    children: [
                      //Text(widget.client.server),
                      //widget.client.subscriptionsManager.subscriptions
                      Expanded(
                        child: SizedBox(
                          height: 2000,
                          child: ListView.builder(
                            //ListView.separated
                            itemCount: _subscriptionList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Dismissible(
                                background: Container(
                                  color: Colors.red,
                                ),
                                key: Key(_subscriptionList[index]
                                    .createdTime
                                    .toUtc()
                                    .toIso8601String()),
                                child: TopicDisplay(
                                    _subscriptionList[index].topic.toString(),
                                    (_messageList[_subscriptionList[index]
                                                .topic
                                                .toString()] ??
                                            "No Messages Received")
                                        .toString(),
                                    (s) => addNewCommand(
                                        _subscriptionList[index]
                                            .topic
                                            .toString()),
                                    (s) => removeCommand(
                                        _subscriptionList[index]
                                            .topic
                                            .toString()),
                                    (_commandList[_subscriptionList[index]
                                                .topic
                                                .toString()] ??
                                            [])
                                        .isNotEmpty),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text(
                                            "Are you sure you wish to delete this item?"),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("DELETE")),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("CANCEL"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  setState(() {
                                    widget.client.unsubscribe(
                                        _subscriptionList[index]
                                            .topic
                                            .toString());
                                    _subscriptionList.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ]);
  }

  void addNewSubscription() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subscribe to a new topic'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Name of the topic to subscribe to'),
                Form(
                    key: _subscribeKey,
                    child: TextFormField(
                      controller: _subscribeController,
                      validator: (value) =>
                          value.isEmpty ? 'Please enter a value' : null,
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_subscribeKey.currentState.validate()) {
                  Navigator.of(context).pop();
                  setState(() {
                    _subscriptionList.add(widget.client.subscribe(
                        _subscribeController.text, MqttQos.atLeastOnce));
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void addNewCommand(String streamName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Subscribe to a new topic'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                    key: _subscribeKey,
                    child: Column(
                      children: [
                        Text('Name of the matching message content'),
                        TextFormField(
                          controller: _commandProcController,
                          validator: (value) =>
                              value.isEmpty ? 'Please enter a value' : null,
                        ),
                        Divider(),
                        Text('System Command to run'),
                        TextFormField(
                          controller: _commandController,
                          validator: (value) =>
                              value.isEmpty ? 'Please enter a value' : null,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_subscribeKey.currentState.validate()) {
                  Navigator.of(context).pop(
                      [_commandProcController.text, _commandController.text]);
                  setState(() {
                    try {
                      _commandList[streamName].addAll({
                        SystemCommand(_commandProcController.text,
                            _commandController.text)
                      });
                    } catch (e) {
                      _commandList.addAll({
                        streamName: [
                          SystemCommand(_commandProcController.text,
                              _commandController.text)
                        ]
                      });
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void removeCommand(String streamName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text('Remove a system command'),
              content: Container(
                width: 800,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _commandList[streamName].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title:
                            Text(_commandList[streamName][index].commandProc),
                        subtitle:
                            Text(_commandList[streamName][index].commandData),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_forever_rounded),
                          onPressed: () {
                            return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm"),
                                  content: const Text(
                                      "Are you sure you wish to delete this item?"),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _commandList[streamName]
                                                .removeAt(index);
                                          });
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("DELETE")),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
