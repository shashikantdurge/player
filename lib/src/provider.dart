part of player;

class PlayerProvider with ChangeNotifier {
  final VoidCallback onComplete;
  final bool autoPlay;
  final Duration hideControlsIn;
  final bool onlyFullscreen;
  final VideoPlayerController controller;

  bool _isControlsShown = false;
  int _hideControlsMatcher = 0;
  bool _isFullscreen;
  VoidCallback _listener;
  bool _isDisposed = false;

  bool get mounted => !_isDisposed;
  VideoPlayerValue get value => controller.value;
  bool get isFullscreen => _isFullscreen;

  PlayerProvider({
    @required this.controller,
    this.onComplete,
    this.autoPlay,
    this.hideControlsIn,
    this.onlyFullscreen,
  }) {
    _isFullscreen = onlyFullscreen;
    _listener = () {
      if (value.hasError) {
        notifyListeners();
      } else if (value.isCompleted) {
        _showControls();
        if (onComplete != null) onComplete();
      }
    };
  }

  void init() async {
    if (_isDisposed) return;
    controller.removeListener(_listener);
    controller.addListener(_listener);
    notifyListeners();
    try {
      await controller.initialize();
      if (onlyFullscreen) enterFullscreen();
      if (autoPlay) {
        await controller.play();
      }
      notifyListeners();
      Wakelock.enable();
    } catch (err) {
      //IGNORE error may be handled by [listener]
    }
  }

  ///`Play`, `Replay` or `Pause` the video
  Future<void> playPause() async {
    if (value.isPlaying) {
      await controller.pause();
    } else if (value.position == value.duration) {
      await controller.seekTo(Duration.zero);
      await controller.play();
    } else if (!value.isPlaying) {
      await controller.play();
    }
    _showControls();
  }

  ///Seeks [seconds]
  ///
  ///Reverse if [seconds]<0
  ///
  ///Forward if [seconds]>0
  Future<void> seek(int seconds) async {
    final isCompleted = value.isCompleted;
    await controller
        .seekTo(controller.value.position + Duration(seconds: seconds));
    if (isCompleted && seconds < 0) {
      await controller.play();
    }
    if (_isControlsShown) _showControls();
  }

  ///Shows controls for [_visibleDuration] and disables
  void _showControls({bool autoHide = true}) {
    if (_isDisposed) return;
    _isControlsShown = true;
    notifyListeners();
    final matcher = _hideControlsMatcher + 1;
    if (value.isPlaying && autoHide) {
      Future.delayed(
        hideControlsIn,
        () => _hideControls(matcher),
      );
    }
    _hideControlsMatcher = matcher;
  }

  void _hideControls(int matcher) {
    if (_isDisposed || matcher != _hideControlsMatcher) return;
    if (_isControlsShown) {
      _isControlsShown = false;
      notifyListeners();
    }
  }

  void changeControlsVisibility() {
    log('CHANGE CONTROLS VISIBILITY TO ${!_isControlsShown}', name: 'CONTROLS');
    if (_isControlsShown) {
      _hideControls(_hideControlsMatcher);
    } else {
      _showControls();
    }
  }

  void enterFullscreen() {
    if (_isDisposed) return;
    SystemChrome.setEnabledSystemUIOverlays([]);

    if (value.fullScreenOrientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
    _isFullscreen = true;
    notifyListeners();
  }

  void exitFullscreen() {
    if (_isDisposed) return;
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _isFullscreen = false;
    notifyListeners();
  }

  void toggleFullscreen() {
    if (_isFullscreen)
      exitFullscreen();
    else
      enterFullscreen();
  }

  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    Wakelock.disable();
    super.dispose();
  }
}
