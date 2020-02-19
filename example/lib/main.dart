import 'package:flutter/material.dart';
import 'package:player/player.dart';

const landscapeVideo =
    "https://player.vimeo.com/external/340643735.hd.mp4?s=86c98b4dc4b52bcd290236673e5de6724982b65e&profile_id=174";
const portraitVideo =
    "https://firebasestorage.googleapis.com/v0/b/shaale-one-development.appspot.com/o/temp%2Fvideoplayback.mp4?alt=media&token=83209811-676b-4d0c-bb4b-445b6a216796";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Player Demo Home page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => VideoExample()));
            },
            child: Text('Normal player'),
          ),
          RaisedButton(
            onPressed: () {
              showVideo(
                  context: context,
                  controller: VideoPlayerController.network(portraitVideo));
            },
            child: Center(child: Text('Full screen portrait video')),
          ),
          RaisedButton(
            onPressed: () {
              showVideo(
                  context: context,
                  controller: VideoPlayerController.network(landscapeVideo));
            },
            child: Center(child: Text('Full screen landscape video')),
          )
        ],
      ),
    );
  }
}

class VideoExample extends StatefulWidget {
  @override
  _VideoExampleState createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample> {
  String dataSource;
  PlayerControls playerControls;

  @override
  void initState() {
    super.initState();
    dataSource = portraitVideo;
    playerControls = DefaultControls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Player example')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Player(
              controller: VideoPlayerController.network(dataSource),
              minAspectRatio: 0.8,
              maxAspectRatio: 16 / 9,
              controls: playerControls,
            ),
            SizedBox(height: 32),
            Text(
              'Choose Video',
              style: Theme.of(context).textTheme.body2,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        dataSource = portraitVideo;
                      });
                    },
                    child: Text('Portrait video'),
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        dataSource = landscapeVideo;
                      });
                    },
                    child: Text('Landscape video'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Choose controls',
              style: Theme.of(context).textTheme.body2,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        playerControls = DefaultControls();
                      });
                    },
                    child: Text('Default controls'),
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        playerControls = YoutubeControls();
                      });
                    },
                    child: Text('Youtube controls'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
