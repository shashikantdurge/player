part of player;

const videoUrl1 =
    "https://player.vimeo.com/external/340643735.hd.mp4?s=86c98b4dc4b52bcd290236673e5de6724982b65e&profile_id=174";
const portraitVideo =
    "https://firebasestorage.googleapis.com/v0/b/shaale-one-development.appspot.com/o/temp%2Fvideoplayback.mp4?alt=media&token=83209811-676b-4d0c-bb4b-445b6a216796";
typedef DataSourceCallback = PlayerProvider Function(BuildContext context);

typedef LoadingBuilder = Widget Function(BuildContext context);

typedef ErrorBuilder = Widget Function(
    BuildContext context, VoidCallback retry);

class Player extends StatefulWidget {
//  final PlayerProvider playerProvider;
  const Player({
    Key key,
//    @required this.playerProvider,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> {
  bool _isFullscreen;
  _PlayerState();

  pushFullScreen(BuildContext context) async {
    final provider = Provider.of<PlayerProvider>(context, listen: false);
    provider.enterFullscreen();
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) {
          return ListenableProvider<PlayerProvider>.value(
            value: provider,
            child: _VideoPlayer(isFullscreen: true),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return PlayerProvider(context,
            controller: VideoPlayerController.network(portraitVideo),
//            onlyFullscreen: true,
            hideControlsIn: Duration(seconds: 5))
          ..init();
      },
      child: Consumer<PlayerProvider>(
        builder: (context, values, child) {
          final player = Provider.of<PlayerProvider>(context, listen: false);
          log('Building Fullscreen Selector Builder Widget ${this._isFullscreen}; Provider $values ',
              name: 'PLAYER');

          if (player._isFullscreen != this._isFullscreen &&
              this._isFullscreen != null) {
            if (player._isFullscreen) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                pushFullScreen(context);
              });
            } else {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context, rootNavigator: true).pop();
              });
            }
          }
          this._isFullscreen = player._isFullscreen;
          return _VideoPlayer(isFullscreen: player.onlyFullscreen);
        },
      ),
    );
  }
}

class _VideoPlayer extends StatelessWidget {
  ///This is to prevent multiple videos playing. This could save battery life or improve the performance
  final bool isFullscreen;
  _VideoPlayer({Key key, @required this.isFullscreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    Widget playerWidget = AspectRatio(
      aspectRatio: player.value.aspectRatio,
      child: isFullscreen == player._isFullscreen
          ? Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                Positioned.fill(child: VideoPlayer(player.controller)),
                Positioned.fill(
                  child: player.value.initialized
                      ? AnimatedSwitcher(
                          child: player._isControlsShown
                              ? _PlayerControls()
                              : InkWell(onTap: player.changeControlsVisibility),
                          duration: const Duration(milliseconds: 250),
                        )
                      : player.value.hasError
                          ? Icon(Icons.error, color: Colors.white)
                          : Center(child: CircularProgressIndicator()),
                )
              ],
            )
          : SizedBox(),
    );
    if (player._isFullscreen) {
      playerWidget = WillPopScope(
        child: playerWidget,
        onWillPop: () async {
          player.exitFullscreen();
          return false;
        },
      );
    }
    return Material(
      color: Colors.black,
      child: Center(child: playerWidget),
    );
  }
}
