part of player;

class PlayerProvider with ChangeNotifier {
  final PlayerProvider dPlayerProvider;
  final DataSourceCallback onComplete, onNext, onPrevious;
  final double minAspectRatio, maxAspectRatio;
  final bool autoPlay;
  final Widget title;
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

  VideoPlayerValue get value => controller.value;

  PlayerProvider(
    BuildContext context, {
    @required this.controller,
    this.dPlayerProvider,
    this.onComplete,
    this.onNext,
    this.onPrevious,
    this.autoPlay = true,
    this.title, //TODO put it in Player Controls
    this.loadingBuilder, //TODO put it in Player Controls
    this.errorBuilder, //TODO put it in Player Controls
    this.hideControlsIn = const Duration(seconds: 5),
    this.minAspectRatio = 16 / 9,
    this.maxAspectRatio = 16 / 9,
    this.onlyFullscreen = false,
  }) {
    _isFullscreen = onlyFullscreen;
    listener = () {
//      log('$value', name: 'PLAYER PROVIDER');
      if (value.hasError) {
        notifyListeners();
      } else if (value.position == value.duration) {
        _showControls();
      }
//      else if (_lastValue.isPlaying != value.isPlaying) {
//        notifyListeners();
//      }

//      if (_lastValue.isBuffering != value.isBuffering) {
//        notifyListeners();
//      }
//      _lastValue = value;
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
    await controller
        .seekTo(controller.value.position + Duration(seconds: seconds));
    _showControls();
  }

  ///Shows controls for [_visibleDuration] and disables
  void _showControls() {
    if (_isDisposed) return;
    _isControlsShown = true;
    notifyListeners();
    final matcher = _hideControlsMatcher + 1;
    if (value.isPlaying) {
      Future.delayed(
        hideControlsIn,
        () => _hideControls(matcher),
      );
    }
    _hideControlsMatcher = matcher;
  }

  void _hideControls(int matcher) {
    if (_isDisposed) return;
    if (matcher != _hideControlsMatcher) return;
    _isControlsShown = false;
    notifyListeners();
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
