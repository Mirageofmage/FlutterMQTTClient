import 'package:flutter/material.dart';
import 'package:mac_notifications/mac_notifications.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqttclient/TopicWidget.dart';

class SubscribePage extends StatefulWidget {
  @override
  _SubscribePageState createState() => _SubscribePageState();

  SubscribePage(this.client);

  final MqttServerClient client;
}

class _SubscribePageState extends State<SubscribePage> {
  var _subscribeKey = new GlobalKey<FormState>();
  var _subscribeController = new TextEditingController();

  List<Subscription> _subscriptionList = new List<Subscription>();
  Map<String, String> _messageList = new Map<String, String>();

  @override
  void dispose() {
    widget.client.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    MacNotifications.showNotification(
      MacNotificationOptions(
          identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
          title: 'Connected Successfully',
          subtitle: 'Successfully connected to ${widget.client.server}'),
    );

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

      MacNotifications.showNotification(
        MacNotificationOptions(
          identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
          title: 'Message recieved on ${c[0].topic}',
          subtitle: 'Message contents: "$payload"',
        ),
      );

      setState(() {
        _messageList.addAll({c[0].topic: payload});
      });
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
    MacNotifications.showNotification(
      MacNotificationOptions(
          identifier: 'mqtt-client${DateTime.now().millisecondsSinceEpoch}',
          title: 'Reconnected',
          subtitle: 'Automatically reconnected to ${widget.client.server}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.server),
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert),
            onPressed: addNewSubscription,
          )
        ],
      ),
      body: Container(
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
                              .toString()),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                  "Are you sure you wish to delete this item?"),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("DELETE")),
                                FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
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
                              _subscriptionList[index].topic.toString());
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
}
