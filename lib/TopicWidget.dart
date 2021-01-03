import 'package:flutter/material.dart';

class TopicDisplay extends StatelessWidget {


  TopicDisplay(this._topicName, this._recentMessage);

  final String _topicName;
  final String _recentMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.green,
      elevation: 15,
          child: ListTile(
        title: Text(_topicName),
        subtitle: Text(_recentMessage),
      ),
    );
  }
}