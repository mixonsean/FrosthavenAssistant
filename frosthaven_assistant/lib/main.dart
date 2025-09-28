import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Layout/theme.dart';
import 'package:frosthaven_assistant/Resource/settings.dart';
import 'package:frosthaven_assistant/Resource/state/game_state.dart';
import 'package:frosthaven_assistant/main_state.dart';
import 'package:frosthaven_assistant/services/service_locator.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

import 'Resource/game_data.dart';
import 'Resource/theme_switcher.dart';

import 'keyboard_shortcuts.dart';
import 'Resource/enums.dart' as fh;
import 'Resource/commands/imbue_element_command.dart';
import 'Resource/commands/use_element_command.dart';
import 'package:flutter/widgets.dart';

const title = 'X-haven Assistant';

void _enablePlatformOverrideForDesktop() {
  if (kDebugMode && !kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  setupGetIt();

  _enablePlatformOverrideForDesktop();
  //debugPrintRebuildDirtyWidgets = true;
  //debugProfileBuildsEnabled = true;
  //debugProfileLayoutsEnabled = true;

  const minScreenWidth = 400.0;
  const minScreenHeight = 600.0;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle(title);
    if (!Platform.isMacOS) {
      windowManager.setMinimumSize(const Size(minScreenWidth, minScreenHeight));
    }
    setWindowMinSize(const Size(minScreenWidth,
        minScreenHeight)); //when updating flutter you may need to re-set these values in main.cpp
    setWindowMaxSize(Size.infinite);
  }

  ErrorWidget.builder = ((e) {
    if (!kDebugMode) {
      //to not show the gray boxes, when there are exceptions
      return Container();
      //todo: save a log?
    }
    //show the error in debug builds

    return ErrorWidget(e);
  });

  runApp(ThemeSwitcherWidget(initialTheme: theme, child: const MyApp()));
}

final loading = ValueNotifier<bool>(true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    //debugInvertOversizedImages = true;
    //double wtf = MediaQuery.of(context).devicePixelRatio;

    //call after keyboard
    if (Platform.isIOS || Platform.isAndroid) {
      WakelockPlus.enable();
      //should force app to be in foreground and disable screen lock
    }

    try {
      //initialize game
      getIt<GameState>().init();
      getIt<GameData>()
          .loadData("assets/data/")
          .then((value) => getIt<GameState>().load())
          .then((value) => getIt<Settings>().init())
          .then((value) => {loading.value = false});
    } catch (error) {
      loading.value = false;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      checkerboardOffscreenLayers: false,
      showPerformanceOverlay: false,
      title: title,
      theme: ThemeSwitcher.of(context).themeData,
      home: XhKeyboardShortcuts(
  onToggle: _kbToggleElement,
  onNextInInitiative: _kbNextInInitiative,   // NEW
  onPrevInInitiative: _kbPrevInInitiative,   // optional
   onToggleFullscreen: () async {
    final isFs = await windowManager.isFullScreen();
    await getIt<Settings>().setFullscreen(!isFs); // <-- call via getIt
  },
  child: const MyHomePage(title: title),
),



    );
  }
}
final GameState _kbGameState = getIt<GameState>();

fh.Elements _toRepo(XhElement e) => switch (e) {
  XhElement.fire  => fh.Elements.fire,
  XhElement.ice   => fh.Elements.ice,
  XhElement.air   => fh.Elements.air,
  XhElement.earth => fh.Elements.earth,
  XhElement.light => fh.Elements.light,
  XhElement.dark  => fh.Elements.dark,
};

void _kbToggleElement(XhElement e) {
  final elem = _toRepo(e);
  final current = _kbGameState.elementState[elem];

  if (current == fh.ElementState.full || current == fh.ElementState.half) {
    // currently active → clear to NONE
    _kbGameState.action(UseElementCommand(elem));
  } else {
    // currently inert → set to FULL
    _kbGameState.action(ImbueElementCommand(elem, false));
  }
}
void _kbNextInInitiative() {
  // TEMP: we’ll replace with the real command
  debugPrint('[KB] next in initiative');
}

void _kbPrevInInitiative() {
  // TEMP: we’ll replace with the real command
  debugPrint('[KB] prev in initiative');
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MainState();
}
