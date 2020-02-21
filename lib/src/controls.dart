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

  const PlayerControls({Key key}) : super(key: key);

  ThemeData theme(BuildContext context) => ThemeData.dark();
  List<Widget> children(BuildContext context, PlayerProvider player);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme(context),
      child: Builder(
        builder: (context) {
          final player = Provider.of<PlayerProvider>(context);
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
  const DefaultControls({Key key}) : super(key: key);

  @override
  List<Widget> children(context, PlayerProvider player) {
    final iconSize = 48.0;
    final duration = player._controller.value.duration;
    final timerStyle = Theme.of(context).textTheme.body1;
    final visibilityHandler = Positioned.fill(
      child: GestureDetector(
        onTap: player.changeControlsVisibility,
      ),
    );
    final progressbar = Positioned(
      bottom: player.isFullscreen ? 56 : 0,
      left: 0,
      right: 0,
      child: Builder(builder: (context) {
        if (player.isFullscreen && player.isControlsShown) {
          return PlayerProgressBar();
        } else if (player.isControlsShown) {
          return PlayerProgressBar(padding: const EdgeInsets.only(top: 12));
        } else {
          return PlayerProgressBar(
            padding: EdgeInsets.zero,
            handleRadius: null,
            enableScrub: false,
          );
        }
      }),
    );
    if (!player._isControlsShown && !player._isFullscreen) {
      return [
        visibilityHandler,
        progressbar,
      ];
    }
    if (!player._isControlsShown) return [visibilityHandler];
    return [
      visibilityHandler,
      progressbar,
      if (player.value.isCompleted)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.replay),
            onPressed: player.playPause,
          ),
        )
      else if (player.value.isPlaying)
        Center(
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(Icons.pause),
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
      Align(
        alignment: Alignment(0.6, 0),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.forward_10),
          onPressed: () => player.seek(10),
        ),
      ),
      if (!player.onlyFullscreen)
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
        bottom: player._isFullscreen ? 92 : 12,
        left: 16,
        child: ValueListenableBuilder<VideoPlayerValue>(
          builder: (context, value, child) {
            return Text(
              '${value.position.formatHHmm(includeHours: duration.inHours > 0)}',
              style: timerStyle,
            );
          },
          valueListenable: player._controller,
        ),
      ),
      Positioned(
        bottom: player._isFullscreen ? 92 : 12,
        right: 16,
        child: Text(
          '${duration.formatHHmm(includeHours: duration.inHours > 0)}',
          style: timerStyle,
        ),
      ),
      Positioned(
        top: 0,
        left: 0,
        child: BackButton(),
      )
    ];
  }
}

class YoutubeControls extends PlayerControls {
  final int seekSeconds;
  final VoidCallback onNext, onPrevious;

  const YoutubeControls(
      {this.onNext, this.onPrevious, this.seekSeconds = 10, Key key})
      : super(key: key);

  @override
  List<Widget> children(BuildContext context, PlayerProvider player) {
    final visibilityHandler = Positioned.fill(
      child: _YoutubeGestureHandler(
        player: player,
        seekSeconds: seekSeconds,
      ),
    );
    if (!player.isControlsShown && player.isFullscreen) {
      return [visibilityHandler];
    }

    final iconSize = 48.0;
    final duration = player.value.duration;
    final timerStyle = Theme.of(context).textTheme.body1;
    final progressbar = Positioned(
      bottom: player.isFullscreen ? 24 : 0,
      left: 0,
      right: 0,
      child: Builder(builder: (context) {
        if (player.isFullscreen && player.isControlsShown) {
          return PlayerProgressBar();
        } else if (player.isControlsShown) {
          return PlayerProgressBar(padding: const EdgeInsets.only(top: 12));
        } else {
          return PlayerProgressBar(
            padding: EdgeInsets.zero,
            handleRadius: null,
            enableScrub: false,
          );
        }
      }),
    );
    if (!player._isControlsShown && !player._isFullscreen) {
      return [visibilityHandler, progressbar];
    }
    return [
      visibilityHandler,
      progressbar,
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
          icon: Icon(Icons.skip_previous),
          onPressed: onPrevious,
        ),
      ),
      Align(
        alignment: Alignment(0.6, 0),
        child: IconButton(
          iconSize: iconSize,
          icon: Icon(Icons.skip_next),
          onPressed: onNext,
        ),
      ),
      Positioned(
        bottom: player.isFullscreen ? 56 : 18,
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
        bottom: player.isFullscreen ? 56 : 18,
        right: 56,
        child: Text(
          '${duration.formatHHmm(includeHours: duration.inHours > 0)}',
          style: timerStyle,
        ),
      ),
      if (!player.onlyFullscreen)
        Positioned(
          bottom: player.isFullscreen ? 42 : 4,
          right: 8,
          child: IconButton(
            icon: player.isFullscreen
                ? Icon(Icons.fullscreen_exit)
                : Icon(Icons.fullscreen),
            onPressed: player.toggleFullscreen,
          ),
        ),
      Positioned(
        top: 0,
        left: 0,
        child: BackButton(),
      )
    ];
  }
}

class _YoutubeGestureHandler extends StatefulWidget {
  final PlayerProvider player;
  final int seekSeconds;

  const _YoutubeGestureHandler({
    Key key,
    @required this.player,
    @required this.seekSeconds,
  }) : super(key: key);

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
                  log('BACK ${rewindSeeked * widget.seekSeconds} seconds',
                      name: 'CONTROLS');
                });
                rewindAnimCtrl.forward(from: 0);
                widget.player.seek(-widget.seekSeconds);
              } else {
                widget.player.changeControlsVisibility();
              }
            },
            onDoubleTap: rewindAnimCtrl.isAnimating ||
                    widget.player.value.position <= const Duration()
                ? null
                : () {
                    log('onDoubleTap ${rewindSeeked * widget.seekSeconds} seconds',
                        name: 'CONTROLS');
                    setState(() {
                      rewindSeeked = 1;
                    });
                    rewindAnimCtrl.forward(from: 0);
                    widget.player.seek(-widget.seekSeconds);
                  },
            child: SeekFeedback.reverse(
              controller: rewindAnimCtrl,
              seconds: rewindSeeked * widget.seekSeconds,
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
                log('Forward onTap ${forwardSeeked * widget.seekSeconds} seconds',
                    name: 'CONTROLS');
                setState(() {
                  forwardSeeked += 1;
                });
                forwardAnimCtrl.forward(from: 0);
                widget.player.seek(widget.seekSeconds);
              } else {
                widget.player.changeControlsVisibility();
              }
            },
            onDoubleTap:
                forwardAnimCtrl.isAnimating || widget.player.value.isCompleted
                    ? null
                    : () {
                        log('Forward onDoubleTap ${forwardSeeked * widget.seekSeconds} seconds',
                            name: 'CONTROLS');
                        setState(() {
                          forwardSeeked = 1;
                        });
                        forwardAnimCtrl.forward(from: 0);
                        widget.player.seek(widget.seekSeconds);
                      },
            child: SeekFeedback.forward(
              controller: forwardAnimCtrl,
              seconds: forwardSeeked * widget.seekSeconds,
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
