part of player;

const _LOG = 'PLAYER';
typedef ErrorBuilder = Widget Function(
    BuildContext context, VoidCallback retry);

showVideo({
  @required BuildContext context,
  PlayerControls controls,
  WidgetBuilder thumbnail,
  ErrorBuilder errorBuilder,
  VoidCallback onComplete,
  bool autoPlay,
  Duration hideControlsIn,
  @required VideoPlayerController controller,
}) {
  Navigator.of(context, rootNavigator: true)
      .push(MaterialPageRoute(builder: (context) {
    return Player._fullscreen(
      controls: controls ?? const DefaultControls(),
      thumbnail: thumbnail,
      errorBuilder: errorBuilder,
      onComplete: onComplete,
      autoPlay: autoPlay ?? true,
      hideControlsIn: hideControlsIn ?? const Duration(seconds: 5),
      controller: controller,
    );
  }));
}

class Player extends StatefulWidget {
  ///Available controls are
  ///
  /// * [DefaultControls]
  /// * [YoutubeControls]
  final PlayerControls controls;
  final WidgetBuilder thumbnail;
  final ErrorBuilder errorBuilder;

  final bool loop;

  ///Callback function when video is completed.
  final VoidCallback onComplete;

  ///If set to `true`, plays automatically.
  final bool autoPlay;

  ///if there is no touch events from user,
  ///Controls are automatically hidden after [hideControlsIn] duration.
  final Duration hideControlsIn;

  ///The ratio for minimum width and maximum height
  ///
  ///Usually the ratio to allow portrait videos
  final double portraitRatio;

  ///The ratio for maximum width and minimum height
  ///
  ///Usually the ratio to allow landscape videos
  final double landscapeRatio;
  final VideoPlayerController controller;

  ///if set to `true`, plays video directly in fullscreen
  final bool onlyFullscreen;

  const Player({
    Key key,
    @required this.controller,
    this.thumbnail,
    this.errorBuilder,
    this.onComplete,
    this.controls,
    this.autoPlay = true,
    this.hideControlsIn = const Duration(seconds: 5),
    this.portraitRatio = 16 / 9,
    this.landscapeRatio = 16 / 9,
    this.loop = false,
  })  :
//        this.controls = controls ?? const DefaultControls(),
        onlyFullscreen = false,
        assert(autoPlay != null),
        assert(hideControlsIn != null),
        assert(controller != null),
//        assert(controls != null),
        assert(
            portraitRatio != null && landscapeRatio != null,
            'portraitRatio and landscapeRatio cannot be null. If you want '
            'to have same aspect ratio irrespective of the video\'s aspect ratio, asssign the same ratio'
            ' to both of them'),
        super(key: key);

  const Player._fullscreen({
    Key key,
    this.controls = const DefaultControls(),
    this.thumbnail,
    this.errorBuilder,
    this.onComplete,
    this.autoPlay = true,
    this.hideControlsIn = const Duration(seconds: 5),
    this.controller,
    this.loop = false,
  })  : portraitRatio = null,
        landscapeRatio = null,
        onlyFullscreen = true,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerState();
  }

  Widget defaultLoader(context) => Center(child: CircularProgressIndicator());
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  bool _isFullscreen;
  PlayerProvider player;

  @override
  void initState() {
    super.initState();
    _isFullscreen = widget.onlyFullscreen;
    player = PlayerProvider(
      controller: widget.controller,
      hideControlsIn: widget.hideControlsIn,
      autoPlay: widget.autoPlay,
      onComplete: widget.onComplete,
      onlyFullscreen: widget.onlyFullscreen,
    )
      ..init()
      ..addListener(_listener);
  }

  @override
  void didUpdateWidget(Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.dataSource != oldWidget.controller.dataSource) {
      player._controller.dispose();
      player._controller = widget.controller;
      player.init();
    }
    if (oldWidget.hideControlsIn != widget.hideControlsIn) {
      player._hideControlsIn = widget.hideControlsIn;
    }
    if (widget.loop != oldWidget.loop) {
      player.controller?.setLooping(widget.loop ?? false);
    }
  }

  void _listener() {
//    setState(() {});
    if (_isFullscreen != player._isFullscreen) {
      setState(() {
        this._isFullscreen = player._isFullscreen;
      });
      _handleFullscreen();
    } else {
      setState(() {});
    }
  }

  _pushFullScreen() async {
    player.enterFullscreen();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) {
          return buildPlayer(true);
        },
      ),
    );
  }

  _handleFullscreen() {
    if (player._isFullscreen) {
      _pushFullScreen();
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Widget buildPlayer(bool isVisible) {
    log('isVisible $isVisible', name: _LOG);
    if (!isVisible) return SizedBox();
    Widget playerWidget = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Center(
          child: Builder(builder: (context) {
            if (player.value.initialized && player.value.hasVideo) {
              return AspectRatio(
                  aspectRatio: player.value.aspectRatio,
                  child: VideoPlayer(player.controller));
            } else if (widget.thumbnail != null) {
              return widget.thumbnail(context);
            } else {
              return Container();
            }
          }),
        ),
        Positioned.fill(
          child: player.value.initialized
              ? Material(
                  color: Colors.transparent,
                  child: ListenableProvider.value(
                    value: player,
                    child: widget.controls,
                  ),
                )
              : player.value.hasError
                  ? Icon(Icons.error, color: Colors.white)
                  : Center(child: CircularProgressIndicator()),
        ),
        //TODO Add it to the controls
        if (!player.value.initialized)
          Positioned(
            top: 8,
            left: 8,
            child: BackButton(color: Colors.white),
          ),
      ],
    );
    if (_isFullscreen) {
      playerWidget = WillPopScope(
        child: playerWidget,
        onWillPop: () async {
          player.exitFullscreen();
          return false;
        },
      );
    } else if (!player.onlyFullscreen) {
      playerWidget = AspectRatio(
        aspectRatio: player.value.playerRatio.clamp(
          widget.portraitRatio,
          widget.landscapeRatio,
        ),
        child: playerWidget,
      );

      if (widget.portraitRatio != widget.landscapeRatio) {
        playerWidget = AnimatedSize(
          vsync: this,
          duration: const Duration(milliseconds: 250),
          child: playerWidget,
        );
      }
    }

    return Material(
      color: Colors.black,
      child: Center(child: playerWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPlayer(player.onlyFullscreen ? true : !_isFullscreen);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
