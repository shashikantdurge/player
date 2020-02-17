part of player;

//FIXME isBuffering always returns false, a BUG is filed in video_player plugin
//        ValueListenableBuilder<VideoPlayerValue>(
//          builder: (context, value, child) {
//            if (value.isBuffering) return child;
//            return SizedBox();
//          },
//          child: Center(child: CircularProgressIndicator()),
//          valueListenable: player.controller,
//        ),

abstract class PlayerControls extends StatelessWidget {
  final Color barrierColor = Colors.black45;
  ThemeData theme(BuildContext context) => ThemeData.dark();
  List<Widget> children(BuildContext context, PlayerProvider player);

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    return Theme(
      data: theme(context),
      child: Builder(
        builder: (context) {
          final controls = Stack(
            fit: StackFit.passthrough,
            children: children(context, player),
          );
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: player._isControlsShown
                ? Container(
                    color: barrierColor,
                    child: controls,
                  )
                : controls,
          );
        },
      ),
    );
  }
}

class DefaultControls extends PlayerControls {
  @override
  List<Widget> children(context, PlayerProvider player) {
    final iconSize = 48.0;
    final duration = player.controller.value.duration;
    final timerStyle = Theme.of(context).textTheme.body1;
    final visibilityHandler = Positioned.fill(
      child: GestureDetector(
        onTap: player.changeControlsVisibility,
      ),
    );
    if (!player._isControlsShown && !player._isFullscreen) {
      return [
        visibilityHandler,
        Positioned(
          bottom: player._isFullscreen ? 16 : 0,
          left: 0,
          right: 0,
          child: PlayerProgressBar(
            player.controller,
            handleRadius: null,
          ),
        ),
      ];
    }
    if (!player._isControlsShown) return [visibilityHandler];
    return [
      visibilityHandler,
      Positioned(
        bottom: player._isFullscreen ? 16 : 0,
        left: 0,
        right: 0,
        child: PlayerProgressBar(player.controller),
      ),
      if (player.value.isPlaying)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.pause),
            onPressed: player.playPause,
          ),
        )
      else if (player.value.isCompleted)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.replay),
            onPressed: player.playPause,
          ),
        )
      else if (!player.value.isPlaying)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.play_arrow),
            onPressed: player.playPause,
          ),
        ),
      Align(
        alignment: Alignment(-0.6, 0),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.replay_10),
          onPressed: () => player.seek(-10),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          icon: player._isFullscreen
              ? Icon(Icons.fullscreen_exit)
              : Icon(Icons.fullscreen),
          onPressed: player.toggleFullscreen,
        ),
      ),
      Align(
        alignment: Alignment(0.6, 0),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.forward_10),
          onPressed: () => player.seek(10),
        ),
      ),
      Positioned(
        bottom: player._isFullscreen ? 28 : 12,
        left: 16,
        child: ValueListenableBuilder<VideoPlayerValue>(
          builder: (context, value, child) {
            return Text(
              '${value.position.formatHHmm(includeHours: duration.inHours > 0)}',
              style: timerStyle,
            );
          },
          valueListenable: player.controller,
        ),
      ),
      Positioned(
        bottom: player._isFullscreen ? 28 : 12,
        right: 16,
        child: Text(
          '${duration.formatHHmm(includeHours: duration.inHours > 0)}',
          style: timerStyle,
        ),
      ),
    ];
  }
}

class YoutubeControls extends PlayerControls {
  @override
  List<Widget> children(BuildContext context, PlayerProvider player) {
    final visibilityHandler = Positioned.fill(
      child: _YoutubeGestureHandler(player: player),
    );
    if (!player._isControlsShown && player.isFullscreen) {
      return [visibilityHandler];
    }
    final iconSize = 48.0;
    final duration = player.controller.value.duration;
    final timerStyle = Theme.of(context).textTheme.body1;
    if (!player._isControlsShown && !player._isFullscreen) {
      return [
        visibilityHandler,
        Positioned(
          bottom: player._isFullscreen ? 16 : 0,
          left: 0,
          right: 0,
          child: PlayerProgressBar(
            player.controller,
            handleRadius: null,
          ),
        ),
      ];
    }
    return [
      visibilityHandler,
      Positioned(
        bottom: player._isFullscreen ? 16 : 0,
        left: 0,
        right: 0,
        child: PlayerProgressBar(player.controller),
      ),
      if (player.value.isPlaying)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.pause),
            onPressed: player.playPause,
          ),
        )
      else if (player.value.isCompleted)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.replay),
            onPressed: player.playPause,
          ),
        )
      else if (!player.value.isPlaying)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.play_arrow),
            onPressed: player.playPause,
          ),
        ),
      Positioned(
        top: 8,
        right: 8,
        child: IconButton(
          icon: player._isFullscreen
              ? Icon(Icons.fullscreen_exit)
              : Icon(Icons.fullscreen),
          onPressed: player.toggleFullscreen,
        ),
      ),
      Positioned(
        bottom: player._isFullscreen ? 28 : 12,
        left: 16,
        child: ValueListenableBuilder<VideoPlayerValue>(
          builder: (context, value, child) {
            return Text(
              '${value.position.formatHHmm(includeHours: duration.inHours > 0)}',
              style: timerStyle,
            );
          },
          valueListenable: player.controller,
        ),
      ),
      Positioned(
        bottom: player._isFullscreen ? 28 : 12,
        right: 16,
        child: Text(
          '${duration.formatHHmm(includeHours: duration.inHours > 0)}',
          style: timerStyle,
        ),
      ),
    ];
  }
}

class _YoutubeGestureHandler extends StatefulWidget {
  final PlayerProvider player;

  const _YoutubeGestureHandler({Key key, @required this.player})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _YoutubeGestureHandlerState();
  }
}

class _YoutubeGestureHandlerState extends State<_YoutubeGestureHandler>
    with TickerProviderStateMixin {
  AnimationController rewindAnimCtrl, forwardAnimCtrl;
  int forwardSeeked = 1, rewindSeeked = 1;
  @override
  void initState() {
    super.initState();
    rewindAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener(animationListener);
    forwardAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener(animationListener);
  }

  void animationListener(AnimationStatus status) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (rewindAnimCtrl.isAnimating &&
                  widget.player.value.position > const Duration()) {
                setState(() {
                  rewindSeeked += 1;
                  log('BACK ${rewindSeeked * 10} seconds', name: 'CONTROLS');
                });
                rewindAnimCtrl.forward(from: 0);
                widget.player.seek(-10);
              } else {
                widget.player.changeControlsVisibility();
              }
            },
            onDoubleTap: rewindAnimCtrl.isAnimating ||
                    widget.player.value.position <= const Duration()
                ? null
                : () {
                    log('onDoubleTap ${rewindSeeked * 10} seconds',
                        name: 'CONTROLS');
                    setState(() {
                      rewindSeeked = 1;
                    });
                    rewindAnimCtrl.forward(from: 0);
                    widget.player.seek(-10);
                  },
            child: SeekFeedback.reverse(
              controller: rewindAnimCtrl,
              seconds: rewindSeeked * 10,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(onTap: widget.player.changeControlsVisibility),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (forwardAnimCtrl.isAnimating &&
                  widget.player.value.position < widget.player.value.duration) {
                log('Forward onTap ${forwardSeeked * 10} seconds',
                    name: 'CONTROLS');
                setState(() {
                  forwardSeeked += 1;
                });
                forwardAnimCtrl.forward(from: 0);
                widget.player.seek(10);
              } else {
                widget.player.changeControlsVisibility();
              }
            },
            onDoubleTap:
                forwardAnimCtrl.isAnimating || widget.player.value.isCompleted
                    ? null
                    : () {
                        log('Forward onDoubleTap ${forwardSeeked * 10} seconds',
                            name: 'CONTROLS');
                        setState(() {
                          forwardSeeked = 1;
                        });
                        forwardAnimCtrl.forward(from: 0);
                        widget.player.seek(10);
                      },
            child: SeekFeedback.forward(
              controller: forwardAnimCtrl,
              seconds: forwardSeeked * 10,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    rewindAnimCtrl.dispose();
    forwardAnimCtrl.dispose();
    super.dispose();
  }
}

class SeekFeedback extends AnimatedWidget {
  SeekFeedback.forward({Key key, AnimationController controller, this.seconds})
      : decoration = const BoxDecoration(
          color: const Color(0x1AEEEEEE),
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(1200),
            bottomLeft: const Radius.circular(1200),
          ),
        ),
        isReverse = false,
        super(key: key, listenable: controller);

  SeekFeedback.reverse({Key key, AnimationController controller, this.seconds})
      : decoration = const BoxDecoration(
          color: const Color(0x1AEEEEEE),
          borderRadius: const BorderRadius.only(
            topRight: const Radius.circular(1200),
            bottomRight: const Radius.circular(1200),
          ),
        ),
        isReverse = true,
        super(key: key, listenable: controller);

  final BoxDecoration decoration;
  final bool isReverse;

  final child = const Icon(Icons.play_arrow);
  final int seconds;

  Animation<double> get _progress => listenable;

  @override
  Widget build(BuildContext context) {
    if (_progress.value < 1 && _progress.value > 0) {
      Widget animation = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            child: child,
            opacity: 1 - _progress.value,
          ),
          Opacity(
            child: child,
            opacity: math.sin(_progress.value * math.pi),
          ),
          Opacity(
            child: child,
            opacity: _progress.value,
          ),
        ],
      );
      if (isReverse) {
        animation = Transform.rotate(
          angle: math.pi,
          child: animation,
        );
      }
      return Container(
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            animation,
            Text(
              '$seconds seconds',
              style: Theme.of(context).textTheme.body1,
            )
          ],
        ),
      );
      //PERFORM ANIMATION
    }
    return Container(color: Colors.transparent);
  }
}
