part of player;

class PlayerProvider with ChangeNotifier {
  final PlayerProvider dPlayerProvider;
  final DataSourceCallback onComplete, onNext, onPrevious;
  final double aspectRatio;
  final bool autoFit;
  final bool autoPlay;
  final Widget title;
  final LoadingBuilder loadingBuilder;
  final ErrorBuilder errorBuilder;
  final Duration hideControlsDuration;
  bool _isControlsShown = false;
  int _hideControlsMatcher = 0;
  final VideoPlayerController controller;
  VoidCallback listener;
//  VideoPlayerValue _lastValue;

  VideoPlayerValue get value => controller.value;

  PlayerProvider({
    @required this.controller,
    this.dPlayerProvider,
    this.onComplete,
    this.onNext,
    this.onPrevious,
    this.autoFit,
    this.autoPlay = true,
    this.title, //TODO put it in Player Controls
    this.loadingBuilder, //TODO put it in Player Controls
    this.errorBuilder, //TODO put it in Player Controls
    this.hideControlsDuration = const Duration(seconds: 5),
    this.aspectRatio,
  }) {
    listener = () {
      log('$value', name: 'PLAYER PROVIDER');
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
    controller.removeListener(listener);
    controller.addListener(listener);
    notifyListeners();
    await controller.initialize();
    if (autoPlay) {
      await controller.play();
    }
    notifyListeners();
    Wakelock.enable();
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
    _isControlsShown = true;
    notifyListeners();
    final matcher = _hideControlsMatcher + 1;
    if (value.isPlaying) {
      Future.delayed(
        hideControlsDuration,
        () => _hideControls(matcher),
      );
    }
    _hideControlsMatcher = matcher;
  }

  void _hideControls(int matcher) {
    if (matcher != _hideControlsMatcher) return;
    _isControlsShown = false;
    notifyListeners();
  }

  void changeControlsVisibility() {
    if (_isControlsShown) {
      _hideControls(_hideControlsMatcher);
    } else {
      _showControls();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    Wakelock.disable();
    super.dispose();
  }
}

//enum $PlayerState { initializing, playing, paused, completed, error }
