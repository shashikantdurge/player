part of player;

extension SuperDuration on Duration {
  String formatHHmm({bool includeHours = false}) {
    if (this == null) return null;
    if (includeHours)
      return '${this.inHours}:${_digits(this.inMinutes % 60, 2)}:${_digits(this.inSeconds % 60, 2)}';
    return '${this.inMinutes}:${_digits(this.inSeconds % 60, 2)}';
  }
}

String _digits(int value, int length) {
  String ret = '$value';
  if (ret.length < length) {
    ret = '0' * (length - ret.length) + ret;
  }
  return ret;
}

extension on VideoPlayerValue {
  bool get isCompleted => position == duration;
}
