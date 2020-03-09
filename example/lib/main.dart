import 'package:flutter/material.dart';
import 'package:player/player.dart';

const landscapeVideo =
    "https://player.vimeo.com/external/340643735.hd.mp4?s=86c98b4dc4b52bcd290236673e5de6724982b65e&profile_id=174";
const portraitVideo =
    "https://firebasestorage.googleapis.com/v0/b/shaale-one-development.appspot.com/o/temp%2Fvideoplayback.mp4?alt=media&token=83209811-676b-4d0c-bb4b-445b6a216796";
const audio =
    "https://firebasestorage.googleapis.com/v0/b/shaale-one-development.appspot.com/o/Library%2FAudio%2F1L9bWB3FNCXJTmoYQPKp%2F002%20-%202.8.10.mp3?alt=media&token=31e0bfb9-e590-4c74-a91c-c5f295e136a8";

const playlist = [portraitVideo, landscapeVideo, audio];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => VideoExample()));
            },
            child: Center(child: Text('PLAYER - All features')),
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
  ///Index of the data source from [playlist] being played
  int index;
//  PlayerControls playerControls;
  Type controlsType;
  bool thumbnailEnabled;
  bool loop;

  @override
  void initState() {
    super.initState();
    index = 0;
    thumbnailEnabled = true;
    loop = false;
//    controlsType = DefaultControls;
  }

  void changeDataSource(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  PlayerControls get playerControls {
    if (controlsType == DefaultControls) {
      return DefaultControls();
    } else if (controlsType == YoutubeControls) {
      return YoutubeControls(
        onNext: index < playlist.length - 1
            ? () {
                setState(() {
                  index += 1;
                });
              }
            : null,
        onPrevious: index > 0
            ? () {
                setState(() {
                  index -= 1;
                });
              }
            : null,
      );
    }
    return null;
  }

  void changeControlsType(Type newControlsType) {
    setState(() {
      controlsType = newControlsType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(title: Text('Player example')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Player(
              controller: VideoPlayerController.network(playlist[index]),
              portraitRatio: 1,
              landscapeRatio: 16 / 9,
              controls: playerControls,
              loop: loop,
              thumbnail: thumbnailEnabled ? (_) => FlutterLogo(size: 86) : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SwitchListTile(
                      title: Text('Thumbnail'),
                      subtitle: Text(
                          'Displayed while the video is being loaded and/or if it\'s audio'),
                      isThreeLine: true,
                      value: thumbnailEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          thumbnailEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: Text('Loop'),
                      subtitle: Text('Media will play again after completion'),
                      value: loop,
                      onChanged: (bool value) {
                        setState(() {
                          loop = value;
                        });
                      },
                    ),
                    ListTile(title: Text('Choose Video/Audio')),
                    RadioListTile(
                      title: Text('Portrait video'),
                      value: 0,
                      groupValue: index,
                      onChanged: changeDataSource,
                    ),
                    RadioListTile(
                      title: Text('Landcape video'),
                      value: 1,
                      groupValue: index,
                      onChanged: changeDataSource,
                    ),
                    RadioListTile(
                      title: Text('Audio'),
                      value: 2,
                      groupValue: index,
                      onChanged: changeDataSource,
                    ),
                    ListTile(title: Text('Choose controls')),
                    RadioListTile<Type>(
                      value: DefaultControls,
                      title: Text('Default controls'),
                      groupValue: controlsType,
                      onChanged: changeControlsType,
                    ),
                    RadioListTile<Type>(
                      value: YoutubeControls,
                      title: Text('Youtube controls'),
                      groupValue: controlsType,
                      onChanged: changeControlsType,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
