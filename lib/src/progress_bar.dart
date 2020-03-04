part of player;

//TODO Extract from [Theme]
class PlayerProgressColors {
  const PlayerProgressColors({
    this.playedColor = const Color(0xffff0000),
    this.bufferedColor = const Color(0xff858585),
    this.backgroundColor = const Color(0xff343334),
    this.handleColor: const Color(0xffff0000),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Color handleColor;
}

class PlayerProgressBar extends StatefulWidget {
  final double height, handleRadius;
  final EdgeInsets padding;
  final bool enableScrub;
  PlayerProgressBar({
    this.colors = const PlayerProgressColors(),
    this.height = 4.0,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.handleRadius = 7.0,
    this.enableScrub = true,
  });

//  final VideoPlayerController controller;
  final PlayerProgressColors colors;

  @override
  _PlayerProgressBarState createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends State<PlayerProgressBar> {
  bool _controllerWasPlaying = false;
  PlayerProvider player;

  @override
  void didChangeDependencies() {
    player = Provider.of<PlayerProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  void seekToRelativePosition(Offset globalPosition) async {
    final box = context.findRenderObject() as RenderBox;
    final Offset tapPos = box.globalToLocal(globalPosition);
    final double relative = tapPos.dx / box.size.width;
    final Duration position = player.value.duration * relative;
    final isCompleted = player.value.isCompleted;
    await player.controller.seekTo(position);
    if (isCompleted) {
      //This is bug fix for https://github.com/flutter/flutter/issues/50686
      player.playPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: player.controller,
      builder: (context, value, child) {
        final progressBar = Container(
          padding: widget.padding,
          child: CustomPaint(
            size: Size.fromHeight(widget.height),
            painter: _ProgressBarPainter(
              value: value,
              colors: widget.colors,
              handleRadius: widget.handleRadius,
            ),
          ),
        );
        if (!widget.enableScrub) return progressBar;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: progressBar,
          onHorizontalDragStart: (DragStartDetails details) {
            if (!value.initialized) {
              return;
            }
            _controllerWasPlaying = value.isPlaying;
            if (_controllerWasPlaying) {
              player.controller.pause();
            }
            player._showControls(autoHide: false);
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (!value.initialized) {
              return;
            }
            seekToRelativePosition(details.globalPosition);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_controllerWasPlaying) {
              player.controller.play();
            }
            player._showControls();
          },
          onTapDown: (TapDownDetails details) {
            if (!value.initialized) {
              return;
            }
            seekToRelativePosition(details.globalPosition);
          },
        );
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({@required this.value, this.colors, this.handleRadius});

  final VideoPlayerValue value;
  final PlayerProgressColors colors;
  final double handleRadius;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = colors.backgroundColor;
    canvas.drawRect(Offset.zero & size, paint);
    if (!value.initialized) {
      return;
    }

    //BUFFERED
    paint.color = colors.bufferedColor;
    for (DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRect(
        Rect.fromPoints(Offset(start, 0), Offset(end, size.height)),
        paint,
      );
    }

    //PLAYED
    paint.color = colors.playedColor;
    final playedValue =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    canvas.drawRect(
      Offset.zero & Size(playedValue.clamp(0.0, 1.0) * size.width, size.height),
      paint,
    );
    //HANDLE BAR
    if (handleRadius != null) {
      paint.color = colors.handleColor;
      canvas.drawCircle(
        Offset(playedValue * size.width, size.height / 2),
        handleRadius,
        paint,
      );
    }
  }
}
