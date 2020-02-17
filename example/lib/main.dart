import 'package:flutter/material.dart';
import 'package:player/player.dart';

const videoUrl1 =
    "https://player.vimeo.com/external/340643735.hd.mp4?s=86c98b4dc4b52bcd290236673e5de6724982b65e&profile_id=174";
const portraitVideo =
    "https://firebasestorage.googleapis.com/v0/b/shaale-one-development.appspot.com/o/temp%2Fvideoplayback.mp4?alt=media&token=83209811-676b-4d0c-bb4b-445b6a216796";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DPlayer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'DPlayer Demo Home page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              showVideo(
                  context: context,
                  controller: VideoPlayerController.network(portraitVideo));
            },
            child: Text('Full screen PORTRAIT'),
          ),
          RaisedButton(
            onPressed: () {
              showVideo(
                  context: context,
                  controller: VideoPlayerController.network(videoUrl1));
            },
            child: Text('Full screen LANDSCAPE'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PortraitVideoExample();
              }));
            },
            child: Text('Portrait video'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return LandscapeVideoExample();
              }));
            },
            child: Text('Landscape video'),
          ),
        ],
      ),
    );
  }
}

class PortraitVideoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Player(
              controller: VideoPlayerController.network(portraitVideo),
              minAspectRatio: 1,
              controls: DefaultControls(),
            ),
            Text('TODO BODY')
          ],
        ),
      ),
    );
  }
}

class LandscapeVideoExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Player(
              controller: VideoPlayerController.network(videoUrl1),
              minAspectRatio: 0.8,
            ),
            Text('TODO BODY')
          ],
        ),
      ),
    );
  }
}
