part of player;

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
  final PlayerControls controls;
  final WidgetBuilder loadingBuilder;
  final ErrorBuilder errorBuilder;
  final VoidCallback onComplete;
  final bool autoPlay;
  final Duration hideControlsIn;
  final double minAspectRatio;
  final double maxAspectRatio;
  final VideoPlayerController controller;
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
    final thisWidget = widget;
    final isEqual = oldWidget == thisWidget;
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  void _listener() {
//    setState(() {});
    if (_isFullscreen != player._isFullscreen) {
      this._isFullscreen = player._isFullscreen;
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
          return ListenableProvider.value(
            value: player,
            child: buildPlayer(true),
          );
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
    if (!isVisible) return SizedBox();
    Widget playerWidget = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Center(
          child: AspectRatio(
            aspectRatio: player.value.aspectRatio,
            child: VideoPlayer(player.controller),
          ),
        ),
        Positioned.fill(
          child: player.value.initialized
              ? Material(
                  color: Colors.transparent,
                  child: widget.controls,
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
    } else {
      playerWidget = AnimatedSize(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        child: AspectRatio(
          aspectRatio: player.value.playerRatio
              .clamp(widget.minAspectRatio, widget.maxAspectRatio),
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
    return ListenableProvider.value(
      value: player,
      child: buildPlayer(player.onlyFullscreen ? true : !_isFullscreen),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
