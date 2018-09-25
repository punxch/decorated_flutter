import 'dart:async';
import 'dart:ui';

import 'package:rxdart/rxdart.dart';

const int kDuration = 60;

/// 负责控制倒计时的类
class CaptchaController {
  CaptchaController._();

  factory CaptchaController(Type key) {
    if (!controllerMap.containsKey(key)) {
      controllerMap[key] = CaptchaController._();
    }
    return controllerMap[key];
  }

  static final controllerMap = Map<Type, CaptchaController>();

  static void disposeAll() {
    controllerMap.forEach((_, controller) => controller.dispose());
  }

  VoidCallback callback;

  bool started = false;
  bool done = false;
  bool disposed = false;

  int remain = kDuration;

  StreamSubscription<int> _subscription;

  void start() {
    started = true;
    if (done || _subscription == null) {
      done = false;
      _subscription = Observable.periodic(Duration(seconds: 1), (data) {
        return kDuration - 1 - data;
      }).take(kDuration).asBroadcastStream().doOnDone(() {
        done = true;
        started = false;
        callback();
      }).listen((tick) {
        remain = tick;
        callback();
      });
    }
  }

  void addListener(VoidCallback callback) {
    this.callback = callback;
  }

  void dispose() async {
    await _subscription?.cancel();
  }
}
