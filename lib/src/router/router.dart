import 'dart:async';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

import '../ui/loading.widget.dart';

typedef void _InitAction<T extends BLoC>(T bloc);
typedef Widget _RouteBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

class Router {
  /// 导航
  static Future<T> navigate<B extends BLoC, T>(
    /// context
    BuildContext context, {

    /// 是否替换route
    bool replace = false,

    /// 是否自动关闭输入法
    bool autoCloseKeyboard = false,

    /// 自定义的PageRoute, 如果传入了这个参数, 那么就不再使用本方法构造的[MaterialPageRoute]
    /// 并且以下参数均不再有效
    PageRoute<T> route,

    /// 目标Screen
    Widget screen,

    /// 是否全屏dialog, 传递给[MaterialPageRoute]
    bool fullScreenDialog = false,

    /// 是否maintain state, 传递给[MaterialPageRoute]
    bool maintainState = true,

    /// 初始化方法
    _InitAction<B> init,

    /// 是否局部[Navigator]
    bool scoped = false,
  }) {
    B bloc;
    if (B != BLoC) {
      // 说明BLoC泛型被设置, 那么去kiwi里去获取实例
      bloc = kiwi.Container().resolve();
    }

    Widget child;
    // 是否使用BLoCProvider
    if (isNotEmpty(bloc)) {
      child = BLoCProvider<B>(
        bloc: bloc,
        init: init,
        child: autoCloseKeyboard ? AutoCloseKeyboard(child: screen) : screen,
      );
    } else {
      child = autoCloseKeyboard ? AutoCloseKeyboard(child: screen) : screen;
    }
    // 是否局部Navigator
    if (scoped) {
      child = Navigator(
        onGenerateRoute: (setting) {
          // Navigator找不到目标route时, 便会调用这个方法, 这里就当做是变通方法
          return MaterialPageRoute(builder: (context) => child);
        },
      );
    }

    route ??= MaterialPageRoute(
      fullscreenDialog: fullScreenDialog,
      maintainState: maintainState,
      builder: (context) => child,
      settings: RouteSettings(name: screen.runtimeType.toString()),
    );

    if (replace) {
      return Navigator.of(context).pushReplacement(route);
    } else {
      return Navigator.of(context).push<T>(route);
    }
  }

  /// 自定义导航
  @Deprecated('用navigate代替')
  static Future<T> navigateCustom<T>(BuildContext context, PageRoute<T> route) {
    return Navigator.of(context).push<T>(route);
  }

  /// 自定义route的导航
  @Deprecated('用navigate代替')
  static Future<T> navigateRouteBuilder<T>({
    @required BuildContext context,
    @required _RouteBuilder builder,
    @required Widget child,
    bool fullScreenDialog = false,
    Duration transitionDuration = const Duration(milliseconds: 600),
    Color barrierColor,
    bool barrierDismissible = false,
    String barrierLabel,
  }) async {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<Null>(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (BuildContext context, Widget child) {
              return builder(context, child, animation);
            },
          );
        },
        transitionDuration: transitionDuration,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        settings: RouteSettings(name: child.runtimeType.toString()),
      ),
    );
  }

  /// 不保留源页面的跳转
  @Deprecated('用navigate代替')
  static void navigateReplace(
    BuildContext context,
    Widget widget, {
    bool fullScreenDialog = false,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: fullScreenDialog,
        builder: (context) => widget,
        settings: RouteSettings(name: widget.runtimeType.toString()),
      ),
    );
  }

  /// 提供BLoC的导航
  @Deprecated('用navigate代替')
  static Future<R> navigateWithBLoC<B extends BLoC, R>(
    BuildContext context,
    Widget widget, {
    _InitAction<B> init,
    bool fullScreenDialog = false,
  }) {
    final bloc = kiwi.Container().resolve<B>();
    return Navigator.of(context).push<R>(
      MaterialPageRoute(
        fullscreenDialog: fullScreenDialog,
        builder: (context) {
          return BLoCProvider<B>(
            bloc: bloc,
            child: AutoCloseKeyboard(
              child: Builder(
                builder: (context) {
                  if (init != null) init(bloc);
                  return widget;
                },
              ),
            ),
          );
        },
        settings: RouteSettings(name: widget.runtimeType.toString()),
      ),
    );
  }

  /// 退出当前页
  static void pop<T>(BuildContext context, [T data]) {
    Navigator.of(context).pop<T>(data);
  }

  /// 退出到目标页
  static void popTo<T>(BuildContext context, Type routeType) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == routeType.toString(),
    );
  }

  static void pushAndClearAll(BuildContext context, Widget widget) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => widget,
        settings: RouteSettings(name: widget.runtimeType.toString()),
      ),
      (route) => false,
    );
  }

  /// 等待页
  static Future<T> loading<T>(BuildContext context, Future<T> futureTask) {
    showDialog(
      context: context,
      builder: (context) => LoadingWidget(),
      barrierDismissible: false,
    );
    return futureTask.whenComplete(() {
      pop(context);
    });
  }
}
