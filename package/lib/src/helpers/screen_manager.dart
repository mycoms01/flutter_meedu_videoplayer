import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

class ScreenManager {
  /// [orientations] the device orientation after exit of the fullscreen
  final List<DeviceOrientation> orientations;

  /// [overlays] the device overlays after exit of the fullscreen
  final List<SystemUiOverlay> overlays;

  /// when the player is in fullscreen mode if forceLandScapeInFullscreen the player only show the landscape mode
  final bool forceLandScapeInFullscreen;

  ///how system overlay are handled hidden
  final SystemUiMode? systemUiMode;

  ///if system overlays should be hidden or not
  final bool hideSystemOverlay;

  const ScreenManager(
      {this.orientations = DeviceOrientation.values,
      this.overlays = SystemUiOverlay.values,
      this.forceLandScapeInFullscreen = true,
      this.systemUiMode,
      this.hideSystemOverlay = true});

  /// set the default orientations and overlays after exit of fullscreen
  Future<void> setDefaultOverlaysAndOrientations() async {
    await SystemChrome.setPreferredOrientations(orientations);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: overlays);
    // AutoOrientation.portraitAutoMode();
  }

  Future<void> setWindowsFullScreen(bool state, MeeduPlayerController _) async {
    _.fullscreen.value = state;
    //customDebugPrint(await windowManager.isFullScreen());
    await windowManager.ensureInitialized();
    //await windowManager.setFullScreen(state);

    if (state) {
      await windowManager.setFullScreen(state);
    } else {
      await windowManager.setFullScreen(state);
      Size size = await windowManager.getSize();
      await windowManager.setSize(Size(size.width + 1, size.height + 1));
      //windowManager.restore();
    }
  }

  Future<void> setWebFullScreen(bool state, MeeduPlayerController _) async {
    _.fullscreen.value = state;
    FullScreenWindow.setFullScreen(state);
  }

  Future<void> setOverlays(bool visible) async {
    if (hideSystemOverlay) {
      if (visible) {
        await SystemChrome.setEnabledSystemUIMode(
            systemUiMode ?? SystemUiMode.immersive,
            overlays: overlays);
      } else {
        //customDebugPrint("Closed2");
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: []);
      }
    }
  }

  /// hide the statusBar and the navigation bar, set only landscape mode only if forceLandScapeInFullscreen is true
  Future<void> setFullScreenOverlaysAndOrientations({
    hideOverLays = true,
  }) async {
    forceLandScapeInFullscreen
        ? AutoOrientation.landscapeAutoMode(forceSensor: true)
        : AutoOrientation.fullAutoMode();

    if (hideOverLays) {
      setOverlays(false);
    }
    //AutoOrientation.landscapeAutoMode(forceSensor: true);
  }
}