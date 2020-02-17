part of player;

class PlayerProvider with ChangeNotifier {
  final PlayerProvider dPlayerProvider;
  final DataSourceCallback onComplete, onNext, onPrevious;
  final double minAspectRatio, maxAspectRatio;
  final bool autoPlay;
  final LoadingBuilder loadingBuilder;
  final ErrorBuilder errorBuilder;
  final Duration hideControlsIn;
  bool _isControlsShown = false;
  int _hideControlsMatcher = 0;
  final bool onlyFullscreen;
  bool _isFullscreen;

  final VideoPlayerController controller;
  VoidCallback listener;
  bool _isDisposed = false;

  bool get mounted => !_isDisposed;
  VideoPlayerValue get value => controller.value;
  bool get isFullscreen => _isFullscreen;

  PlayerProvider(
    BuildContext context, {
    @required this.controller,
    this.dPlayerProvider,
    this.onComplete,
    this.onNext,
    this.onPrevious,
    this.autoPlay = true,
    this.loadingBuilder,
    this.errorBuilder,
    this.hideControlsIn = const Duration(seconds: 3),
    this.minAspectRatio = 16 / 9,
    this.maxAspectRatio = 16 / 9,
    this.onlyFullscreen = false,
  }) : assert(
            minAspectRatio != null && maxAspectRatio != null,
            'minAspectRatio and maxAspectRatio cannot be null. If you want '
            'to have constant aspect ratio, asssign the constant aspect ratio'
            ' to both of them') {
    _isFullscreen = onlyFullscreen;
    listener = () {
      if (value.hasError) {
        notifyListeners();
      } else if (value.position == value.duration) {
        _showControls();
      }
    };
  }

  void init() async {
    if (_isDisposed) return;
    controller.removeListener(listener);
    controller.addListener(listener);
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

  Future<void> seek(int seconds) async {
    final isCompleted = value.isCompleted;
    await controller
        .seekTo(controller.value.position + Duration(seconds: seconds));
    if (isCompleted) {
      await controller.play();
    }
    if (_isControlsShown) _showControls();
  }

  ///Shows controls for [_visibleDuration] and disables
  void _showControls({bool autoHide = true}) {
    if (_isDisposed) return;
    if (!_isControlsShown) {
      _isControlsShown = true;
      notifyListeners();
    }
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
