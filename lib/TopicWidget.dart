import 'package:flutter/material.dart';

class TopicDisplay extends StatelessWidget {
  TopicDisplay(this._topicName, this._recentMessage, this.addCommandFunc,
      this.removeCommandFunc, this.hasCommand);

  final String _topicName;
  final String _recentMessage;
  final void Function(String) addCommandFunc;
  final void Function(String) removeCommandFunc;
  final bool hasCommand;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.green,
      elevation: 15,
      child: ListTile(
        title: Text(_topicName),
        subtitle: Text(_recentMessage),
        trailing: FittedBox(
          fit: BoxFit.fill,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              hasCommand
                  ? IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () => removeCommandFunc(_topicName),
                    )
                  : Container(),
              IconButton(
                icon: Icon(Icons.access_alarm_sharp),
                onPressed: () => addCommandFunc(_topicName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
