part of player;

//const _progressBarHeight = 4.0;

class _PlayerControls extends StatelessWidget {
  final _iconSize = 48.0;
  final _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    log('Player state in _PlayerControls Widget - ${player.value}',
        name: 'VIDEO PLAYER');
    final orientation = MediaQuery.of(context).orientation;
    final duration = player.controller.value.duration;

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Positioned.fill(child: Container(color: Colors.black45)),
        Positioned.fill(
            child: GestureDetector(onTap: player.changeControlsVisibility)),
        Positioned(
          bottom: player._isFullscreen ? 16 : 0,
          left: 0,
          right: 0,
          child: PlayerProgressBar(player.controller),
        ),
//FIXME isBuffering always returns false, a BUG is filed in video_player plugin
//        ValueListenableBuilder<VideoPlayerValue>(
//          builder: (context, value, child) {
//            if (value.isBuffering) return child;
//            return SizedBox();
//          },
//          child: Center(child: CircularProgressIndicator()),
//          valueListenable: player.controller,
//        ),
        Selector<PlayerProvider, VideoPlayerValue>(
          builder: (context, value, child) {
            if (value.isPlaying) {
              return Center(
                child: IconButton(
                    iconSize: _iconSize,
                    color: _iconColor,
                    icon: Icon(Icons.pause),
                    onPressed: player.playPause),
              );
            } else if (value.isCompleted) {
              return Center(
                child: IconButton(
                    iconSize: _iconSize,
                    color: _iconColor,
                    icon: Icon(Icons.replay),
                    onPressed: player.playPause),
              );
            } else if (!value.isPlaying) {
              return Center(
                child: IconButton(
                    iconSize: _iconSize,
                    color: _iconColor,
                    icon: Icon(Icons.play_arrow),
                    onPressed: player.playPause),
              );
            } else {
              return SizedBox();
            }
          },
          selector: (context, player) => player.value,
          shouldRebuild: (oldValue, newValue) =>
              oldValue.isPlaying != newValue.isPlaying ||
              oldValue.isCompleted == newValue.isCompleted,
        ),
        Align(
          alignment: Alignment(-0.6, 0),
          child: IconButton(
              iconSize: _iconSize,
              color: _iconColor,
              icon: Icon(Icons.replay_10),
              onPressed: () => player.seek(-10)),
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
              iconSize: _iconSize,
              color: _iconColor,
              icon: Icon(Icons.forward_10),
              onPressed: () => player.seek(10)),
        ),
        Positioned(
          bottom: orientation == Orientation.landscape ? 28 : 12,
          left: 16,
          child: ValueListenableBuilder<VideoPlayerValue>(
            builder: (context, value, child) {
              return Text(
                  '${value.position.formatHHmm(includeHours: duration.inHours > 0)}');
            },
            valueListenable: player.controller,
          ),
        ),
        Positioned(
            bottom: orientation == Orientation.landscape ? 28 : 12,
            right: 16,
            child: Text(
                '${duration.formatHHmm(includeHours: duration.inHours > 0)}')),
//            if (uiConfig.backButtonEnabled)
//              _BackButton()
      ],
    );
  }
}
