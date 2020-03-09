library player;

import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:phone_state_i/phone_state_i.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

export 'package:video_player/video_player.dart'
    show VideoPlayerController, VideoPlayerValue;

part 'src/controls.dart';
part 'src/player.dart';
part 'src/progress_bar.dart';
part 'src/provider.dart';
part 'src/utils.dart';
