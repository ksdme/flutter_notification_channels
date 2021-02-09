import 'package:flutter/material.dart';
import 'package:flutter_notification_channels/flutter_notification_channels.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final channelInputController = TextEditingController();
  String channelSupportText = "Unknown";
  bool lights = true;
  bool vibrate = true;
  bool customSound = false;

  @override
  void initState() {
    super.initState();
    this.checkSupport();
  }

  checkSupport() async {
    final support = await FlutterNotificationChannels.areChannelsSupported;

    this.setState(() {
      this.channelSupportText = support ?
        'Notification Channels are Supported' :
        'Notification Channels are Not Supported';
    });
  }

  handleOnCreate(BuildContext context) async {
    final channel = this.channelInputController.text;

    await FlutterNotificationChannels.createChannel(
      id: channel,
      name: 'Channel: $channel',
      description: 'Channel: $channel',
      sound: this.customSound ? 'chime.ogg' : 'default',
      lights: this.lights,
      vibrate: this.vibrate,
    );

    Scaffold.of(context).showSnackBar(SnackBar(
      content: const Text('Created Channel'),
    ));
  }

  handleOnRemove(BuildContext context) async {
    final channel = this.channelInputController.text;

    await FlutterNotificationChannels.removeChannel(
      channel,
    );

    Scaffold.of(context).showSnackBar(SnackBar(
      content: const Text('Removed Channel'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_notification_channels'),
        ),
        body: Builder(
          builder: (context) => Column(
            children: [
              Padding(
                child: Text(
                  this.channelSupportText,
                ),
                padding: EdgeInsets.all(32),
              ),
              Padding(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Channel ID',
                  ),
                  controller: this.channelInputController,
                ),
                padding: EdgeInsets.all(16),
              ),
              SwitchListTile(
                title: const Text('Lights'),
                value: this.lights,
                onChanged: (value) => this.setState(() {
                  this.lights = value;
                }),
              ),
              SwitchListTile(
                title: const Text('Vibrate'),
                value: this.vibrate,
                onChanged: (value) => this.setState(() {
                  this.vibrate = value;
                }),
              ),
              SwitchListTile(
                title: const Text('Custom Sound'),
                subtitle: const Text('Will use chime.ogg from /res/raw'),
                value: this.customSound,
                onChanged: (value) => this.setState(() {
                  this.customSound = value;
                }),
              ),
              Row(
                children: [
                  Expanded(
                    child: FlatButton(
                      child: const Text('+  Create Channel'),
                      onPressed: () => this.handleOnCreate(context),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      child: const Text('-  Remove Channel'),
                      onPressed: () => this.handleOnRemove(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
