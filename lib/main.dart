import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

//import 'dart:html' as html;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    debugPrint('[BOOT] 1. Firebase 초기화 시작');

    await initFirebase().timeout(
      const Duration(seconds: 20),
    );

    debugPrint(
      '[FIREBASE] projectId=${Firebase.app().options.projectId}',
    );
    debugPrint(
      '[FIREBASE] appId=${Firebase.app().options.appId}',
    );

    debugPrint('[BOOT] 2. Firebase 초기화 완료');
    debugPrint('[BOOT] 3. 테마 초기화 시작');

    await FlutterFlowTheme.initialize().timeout(
      const Duration(seconds: 20),
    );

    debugPrint('[BOOT] 4. 테마 초기화 완료');

    runApp(MyApp());

    debugPrint('[BOOT] 5. runApp 호출 완료');
  } catch (error, stackTrace) {
    debugPrint('[BOOT ERROR] $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    debugPrint('[APP] initState 시작');

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    userStream = neuroHEARFirebaseUserStream();

    userStream.listen(
      (user) {
        debugPrint('[AUTH] 인증 상태 수신: loggedIn=${user.loggedIn}');

        _appStateNotifier.update(user);

        debugPrint('[AUTH] loading=${_appStateNotifier.loading}');
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[AUTH ERROR] $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    jwtTokenStream.listen((_) {});

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      _appStateNotifier.stopShowingSplashImage();

      debugPrint(
        '[APP] 스플래시 종료: loading=${_appStateNotifier.loading}',
      );
    });
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'neuroHEAR',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''), // Korean
        Locale('en', ''), // English
      ],
      /*theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,*/
      theme: ThemeData.light(), // 라이트 테마 설정
      darkTheme: ThemeData.light(), // 다크 모드 테마도 라이트 모드로 설정
      themeMode: ThemeMode.light, // 항상 라이트 모드를 사용
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'HomePage';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'HomePage': HomePageWidget(),
      'IntroducePage': IntroducePageWidget(),
      'SelfTestPage': SelfTestPageWidget(),
      'BasicPracticePage': BasicPracticePageWidget(),
      'AdvancedPracticePage': AdvancedPracticePageWidget(),
      'CalendarPage': CalendarPageWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF0063A0),
        unselectedItemColor: Color(0x8A000000),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontSize: 18.0, fontWeight: FontWeight.bold), // 선택된 아이템의 레이블 크기 조정
        unselectedLabelStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold), // 선택되지 않은 아이템의 레이블 크기 조정
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.home,
              size: 24.0,
            ),
            label: '메인',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.infoCircle,
              size: 24.0,
            ),
            label: '정보',
            tooltip: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.edit_square,
              size: 24.0,
            ),
            label: '검사',
            tooltip: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.looks_one,
              size: 24.0,
            ),
            label: '기초',
            tooltip: 'Basic',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.looks_3,
              size: 24.0,
            ),
            label: '심화',
            tooltip: 'Advanced',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.calendarCheck,
              size: 24.0,
            ),
            label: '달력',
            tooltip: 'Calendar',
          )
        ],
      ),
    );
  }
}
