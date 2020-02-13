part of player;

const videoUrl1 =
    "https://player.vimeo.com/external/340643735.hd.mp4?s=86c98b4dc4b52bcd290236673e5de6724982b65e&profile_id=174";
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
  _PlayerState();
//  @override
//  void initState() {
//    super.initState();
//    widget.playerProvider.init();
//    widget.playerProvider.controller
//        .addListener(widget.playerProvider.listener);
//  }
//
//  @override
//  void didUpdateWidget(Player oldWidget) {
//    oldWidget.playerProvider.controller
//        .removeListener(widget.playerProvider.listener);
//    widget.playerProvider.controller
//        .addListener(widget.playerProvider.listener);
//    super.didUpdateWidget(oldWidget);
//  }
//
//  @override
//  void deactivate() {
//    widget.playerProvider.controller
//        .removeListener(widget.playerProvider.listener);
//    super.deactivate();
//  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return PlayerProvider(
            controller: VideoPlayerController.network(videoUrl1),
            hideControlsDuration: Duration(minutes: 10))
          ..init();
      },
      child: _VideoPlayer(),
    );
  }

//  @override
//  void dispose() {
//    widget.playerProvider.dispose();
//    super.dispose();
//  }
}

class _VideoPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    return AspectRatio(
      aspectRatio: player.value.aspectRatio,
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Positioned.fill(child: VideoPlayer(player.controller)),
          Positioned.fill(
              child: InkWell(onTap: player.changeControlsVisibility)),
          if (player.value.initialized)
            Positioned.fill(
              child: AnimatedSwitcher(
                  child: player._isControlsShown ? _PlayerControls() : null,
                  duration: const Duration(milliseconds: 250)),
            )
          else
            Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
