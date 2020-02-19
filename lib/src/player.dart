part of player;

const _LOG = 'PLAYER';
typedef ErrorBuilder = Widget Function(
    BuildContext context, VoidCallback retry);

showVideo({
  @required BuildContext context,
  PlayerControls controls,
  WidgetBuilder loadingBuilder,
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
      loadingBuilder: loadingBuilder,
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
  final WidgetBuilder loadingBuilder;
  final ErrorBuilder errorBuilder;

  ///Callback function when video is completed.
  final VoidCallback onComplete;

  ///If set to `true`, plays automatically.
  final bool autoPlay;

  ///if there is no touch events from user,
  ///Controls are automatically hidden after [hideControlsIn] duration.
  final Duration hideControlsIn;

  ///The ratio for minimum width or maximum height
  ///
  ///Usually the ratio to allow portrait videos
  final double minAspectRatio;

  ///The ratio for maximum width or minimum height
  ///
  ///Usually the ratio to allow landscape videos
  final double maxAspectRatio;
  final VideoPlayerController controller;

  ///if set to `true`, plays video directly in fullscreen
  final bool onlyFullscreen;

  const Player({
    Key key,
    @required this.controller,
    this.loadingBuilder,
    this.errorBuilder,
    this.onComplete,
    this.controls = const DefaultControls(),
    this.autoPlay = true,
    this.hideControlsIn = const Duration(seconds: 5),
    this.minAspectRatio = 16 / 9,
    this.maxAspectRatio = 16 / 9,
  })  : onlyFullscreen = false,
        assert(autoPlay != null),
        assert(hideControlsIn != null),
        assert(controller != null),
        assert(
            minAspectRatio != null && maxAspectRatio != null,
            'minAspectRatio and maxAspectRatio cannot be null. If you want '
            'to have constant aspect ratio, asssign the constant aspect ratio'
            ' to both of them'),
        super(key: key);

  const Player._fullscreen({
    Key key,
    this.controls = const DefaultControls(),
    this.loadingBuilder,
    this.errorBuilder,
    this.onComplete,
    this.autoPlay = true,
    this.hideControlsIn = const Duration(seconds: 5),
    this.controller,
  })  : minAspectRatio = null,
        maxAspectRatio = null,
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
    if (widget.controller.dataSource != oldWidget.controller.dataSource) {
      player._controller.dispose();
      player._controller = widget.controller;
      player.init();
    }
    if (oldWidget.hideControlsIn != widget.hideControlsIn) {
      player._hideControlsIn = widget.hideControlsIn;
    }
    super.didUpdateWidget(oldWidget);
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
          child: AspectRatio(
            aspectRatio: player.value.aspectRatio,
            child: VideoPlayer(player._controller),
          ),
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
      playerWidget = AnimatedSize(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        child: AspectRatio(
          aspectRatio: player.value.playerRatio.clamp(
            widget.minAspectRatio,
            widget.maxAspectRatio,
          ),
          child: playerWidget,
        ),
      );
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
