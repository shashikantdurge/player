part of player;

class PlayerProvider with ChangeNotifier {
  final VoidCallback onComplete;
  final bool autoPlay;
  Duration _hideControlsIn;
  final bool onlyFullscreen;
  VideoPlayerController _controller;

  bool _isControlsShown = false;

  int _hideControlsMatcher = 0;
  bool _isFullscreen;
  VoidCallback _listener;
  bool _isDisposed = false;

  bool get isControlsShown => _isControlsShown;
  bool get mounted => !_isDisposed;
  VideoPlayerValue get value => _controller.value;
  bool get isFullscreen => _isFullscreen;
  VideoPlayerController get controller => _controller;

  PlayerProvider({
    @required VideoPlayerController controller,
    this.onComplete,
    this.autoPlay,
    Duration hideControlsIn,
    this.onlyFullscreen,
  })  : _controller = controller,
        _hideControlsIn = hideControlsIn {
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
    _controller.removeListener(_listener);
    _controller.addListener(_listener);
    notifyListeners();
    try {
      await _controller.initialize();
      if (onlyFullscreen) enterFullscreen();
      if (autoPlay) {
        await _controller.play();
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
      await _controller.pause();
    } else if (value.position == value.duration) {
      await _controller.seekTo(Duration.zero);
      await _controller.play();
    } else if (!value.isPlaying) {
      await _controller.play();
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
    await _controller
        .seekTo(_controller.value.position + Duration(seconds: seconds));
    if (isCompleted && seconds < 0) {
      await _controller.play();
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
        _hideControlsIn,
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
    _controller.dispose();
    Wakelock.disable();
    super.dispose();
  }
}
