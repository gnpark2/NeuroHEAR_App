import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/auth/delete_user_component/delete_user_component_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import 'basic_practice_page_model.dart';
export 'basic_practice_page_model.dart';

import 'package:audioplayers/audioplayers.dart';

class BasicPracticePageWidget extends StatefulWidget {
  const BasicPracticePageWidget({super.key});

  @override
  State<BasicPracticePageWidget> createState() =>
      _BasicPracticePageWidgetState();
}

class _BasicPracticePageWidgetState extends State<BasicPracticePageWidget> {
  late BasicPracticePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<int> playedNumbers = [];
  int randomDisplayedNumber = 0;
  String resultMessage = '';
  bool showButtons = true;
  bool showResult = false;
  bool training = false;
  final List<AudioPlayer> _audioPlayers = [];
  bool session1Running = false;
  bool session2Running = false;
  bool session3Running = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BasicPracticePageModel());
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    for (var player in _audioPlayers) {
      player.dispose();
    }

    _model.dispose();

    super.dispose();
  }

  Future<void> playAudio(int number) async {
    final player = AudioPlayer();
    _audioPlayers.add(player);
    print(number);
    await player.play(AssetSource('audios/audioFile/44100_${number}_10dBFS.wav'));
  }

  Future<void> playRandomAudios(int count) async {
    final random = Random();
    List<int> numbers = List.generate(10, (index) => index)..shuffle();
    playedNumbers = numbers.take(count).toList();

    for (int number in playedNumbers) {
      if (!mounted) return; // Check if the widget is still in the tree
      await playAudio(number);
      await Future.delayed(Duration(seconds: 1)); // Add delay between audios
    }

    if (mounted) {
      setState(() {
        randomDisplayedNumber = random.nextInt(10);
        showButtons = false;
        showResult = false;
        training = false;
      });
    }
  }

  void checkAnswer(bool userSaidYes) {
    bool correctAnswer = playedNumbers.contains(randomDisplayedNumber);
    if (mounted) {
      setState(() {
        if (userSaidYes == correctAnswer) {
          resultMessage = '정답입니다!';
        } else {
          resultMessage = '오답입니다.';
        }
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date at midnight (start of the day) in KST
    final now = DateTime.now();
    final startOfDayKST = DateTime(now.year, now.month, now.day);

    return StreamBuilder<List<BasicResultsRecord>>(
      stream: queryBasicResultsRecord(
        parent: currentUserReference,
        queryBuilder: (basicResultsRecord) => basicResultsRecord
            .where('createdTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDayKST)),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        print(startOfDayKST);
        print(snapshot);
        print(snapshot.data);
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<BasicResultsRecord> testBasicResultsRecordList = snapshot.data!;
        BasicResultsRecord? testBasicResultsRecord;

        // If no record exists for today, create one
        if (testBasicResultsRecordList.isEmpty) {
          BasicResultsRecord.createDoc(currentUserReference!).set(
            createBasicResultsRecordData(
              numOfQuestions: 0,
              numOfCollectQuestions: 0,
              createdTime: Timestamp.now(),
            ),
          );

          // Return a loading indicator until the new record is created and the stream updates
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        } else {
          testBasicResultsRecord = testBasicResultsRecordList.first;
        }
        
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        endDrawer: Container(
          width: 250.0,
          child: Drawer(
            elevation: 16.0,
            child: Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: Color(0xFF0063A0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 25.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 60.0,
                            icon: Icon(
                              Icons.close_rounded,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              if (scaffoldKey.currentState!.isDrawerOpen ||
                                  scaffoldKey.currentState!.isEndDrawerOpen) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        GoRouter.of(context).prepareAuthEvent();
                        await authManager.signOut();
                        GoRouter.of(context).clearRedirectLocation();

                        context.goNamedAuth('AuthPage', context.mounted);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 4.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 20.0,
                              borderWidth: 1.0,
                              buttonSize: 40.0,
                              icon: FaIcon(
                                FontAwesomeIcons.signOutAlt,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                size: 24.0,
                              ),
                              onPressed: () {
                                print('IconButton pressed ...');
                              },
                            ),
                          ),
                          Text(
                            '로그아웃',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 24.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: FlutterFlowTheme.of(context).accent4,
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return GestureDetector(
                              onTap: () => _model.unfocusNode.canRequestFocus
                                  ? FocusScope.of(context)
                                      .requestFocus(_model.unfocusNode)
                                  : FocusScope.of(context).unfocus(),
                              child: Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: DeleteUserComponentWidget(),
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 4.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 20.0,
                              borderWidth: 1.0,
                              buttonSize: 40.0,
                              icon: FaIcon(
                                FontAwesomeIcons.trash,
                                color: FlutterFlowTheme.of(context).error,
                                size: 24.0,
                              ),
                              onPressed: () {
                                print('IconButton pressed ...');
                              },
                            ),
                          ),
                          Text(
                            '탈퇴하기',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: FlutterFlowTheme.of(context).error,
                                  fontSize: 24.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: FlutterFlowTheme.of(context).accent4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 20.0), // Adjust the value to your preference
                child: FlutterFlowIconButton(
                  borderRadius: 10.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  icon: FaIcon(
                    FontAwesomeIcons.listUl,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 30.0,
                  ),
                  onPressed: () async {
                    scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Color(0xffFFFFFF),
              ),
              title: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                child: Container(
                  width: 300.0,
                  /*decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),*/
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/neuroHearLogoBG.png',
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
            ),
            toolbarHeight: 100.0,
            elevation: 2.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 8.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8E8E8),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 16.0, 8.0, 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    '기본 훈련 기초 단계 (Level 1)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Color(0xFF0063A0),
                                          fontSize: 30.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '1. 소음 없이 숫자만 불려집니다!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.55.39_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '2. 다음엔 숫자가 하나만 불려집니다!\n이 숫자는 무작위(랜덤)로 아무거나 하나 나옵니다.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.45.12_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '3. 불려진 숫자 하나가 앞에서 들은 숫자들 사이에 있었나요?\n없었나요?\n기억을 더듬어서 답을 눌러주세요!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.46.33_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 80.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 설명>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '본 훈련은 숫자 세 개가 스피커로 불려지고, 그 후에 무작위로 숫자 하나가 제시 됩니다.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color: Color(0xFF0063A0),
                                              fontSize: 24.0,
                                              letterSpacing: 0.0,
                                              lineHeight: 1.6,
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 16.0, 0.0, 16.0),
                                        child: Text(
                                          '앞서 불린 세 개의 숫자 속에 무작위 숫자가 제시 되었다면 [있었다], 아니라면 [없었다]를 클릭해주세요.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF0063A0),
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.6,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 순서>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '1. 본인에게 편안한 크기로 컴퓨터 볼륨을 맞춰 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '2. [시작하기]를 눌러 주세요.',
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '3. 불려지는 세 개의 숫자를 듣고 기억해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '4. 화면에 보이는 무작위 숫자가 앞서 들은 세 개의 숫자에 포함이 되었다면 [있었다], 아니라면 [없었다]를 클릭해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '5. 다음 화면에서 세 가지 숫자가 무엇이었는지, 정답인지 아닌지 보입니다.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '6. 다시 [시작하기]를 클릭하여 반복해서 꾸준히 학습해주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                          indent: 20.0,
                          endIndent: 20.0,
                          color: Color(0xFF0063A0),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
                          child: RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '준비가 되셨다면 ',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                ),
                                TextSpan(
                                  text: '[시작하기]',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '를 클릭해주세요.',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.6,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (showButtons) ...[
                                FFButtonWidget(
                                  onPressed: () async {
                                    setState(() {
                                      showButtons = false;
                                      training = true;
                                      session1Running = true;
                                      session2Running = false;
                                      session3Running = false;
                                    });
                                    playRandomAudios(3);
                                  },
                                  text: '시작하기',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Color(0xFF01C5A2),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ],

                              if (!showButtons && training && !showResult && session1Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                                
                              ],

                              if(!showButtons && !session1Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '다른 훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                              ],

                              if (!showButtons && !training && !showResult && session1Running) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '앞서 들린 숫자에 보이는 숫자($randomDisplayedNumber)가 있었나요?',
                                    style: FlutterFlowTheme.of(context).headlineMedium,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(true);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '있었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(false);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '없었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (showResult && session1Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          resultMessage,
                                          style: FlutterFlowTheme.of(context).headlineMedium,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            '방금 나온 숫자는 : ${playedNumbers.join(', ')}입니다.',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () {
                                            setState(() {
                                              showButtons = true;
                                              showResult = false;
                                              session1Running = false;
                                              session2Running = false;
                                              session3Running = false;
                                              playedNumbers.clear();
                                              _audioPlayers.clear();
                                            });
                                          },
                                          text: '다시 시작',
                                          options: FFButtonOptions(
                                            width: 150.0,
                                            height: 50.0,
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 8.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8E8E8),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 16.0, 8.0, 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    '기본 훈련 중급 단계 (Level 2)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Color(0xFF0063A0),
                                          fontSize: 30.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '1. 소음 없이 숫자만 불려집니다!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.55.39_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '2. 다음엔 숫자가 하나만 불려집니다!\n이 숫자는 무작위(랜덤)로 아무거나 하나 나옵니다.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.45.12_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '3. 불려진 숫자 하나가 앞에서 들은 숫자들 사이에 있었나요?\n없었나요?\n기억을 더듬어서 답을 눌러주세요!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.46.33_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 80.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 설명>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '본 훈련은 숫자 네 개가 스피커로 불려지고, 그 후에 무작위로 숫자 하나가 제시 됩니다.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color: Color(0xFF0063A0),
                                              fontSize: 24.0,
                                              letterSpacing: 0.0,
                                              lineHeight: 1.6,
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 16.0, 0.0, 16.0),
                                        child: Text(
                                          '앞서 불린 네 개의 숫자 속에 무작위 숫자가 제시 되었다면 [있었다], 아니라면 [없었다]를 클릭해주세요.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF0063A0),
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.6,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 순서>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '1. 본인에게 편안한 크기로 컴퓨터 볼륨을 맞춰 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '2. [시작하기]를 눌러 주세요.',
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '3. 불려지는 네 개의 숫자를 듣고 기억해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '4. 화면에 보이는 무작위 숫자가 앞서 들은 네 개의 숫자에 포함이 되었다면 [있었다], 아니라면 [없었다]를 클릭해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '5. 다음 화면에서 네 가지 숫자가 무엇이었는지, 정답인지 아닌지 보입니다.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '6. 다시 [시작하기]를 클릭하여 반복해서 꾸준히 학습해주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                          indent: 20.0,
                          endIndent: 20.0,
                          color: Color(0xFF0063A0),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
                          child: RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '준비가 되셨다면 ',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                ),
                                TextSpan(
                                  text: '[시작하기]',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '를 클릭해주세요.',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.6,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (showButtons) ...[
                                FFButtonWidget(
                                  onPressed: () async {
                                    setState(() {
                                      showButtons = false;
                                      training = true;
                                      session1Running = false;
                                      session2Running = true;
                                      session3Running = false;
                                    });
                                    playRandomAudios(4);
                                  },
                                  text: '시작하기',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Color(0xFF01C5A2),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ],

                              if (!showButtons && training && !showResult && session2Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                                
                              ],

                              if (!showButtons && !session2Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '다른 훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                                
                              ],

                              if (!showButtons && !training && !showResult && session2Running) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '앞서 들린 숫자에 보이는 숫자($randomDisplayedNumber)가 있었나요?',
                                    style: FlutterFlowTheme.of(context).headlineMedium,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(true);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '있었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(false);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '없었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (showResult && session2Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          resultMessage,
                                          style: FlutterFlowTheme.of(context).headlineMedium,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            '방금 나온 숫자는 : ${playedNumbers.join(', ')}입니다.',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () {
                                            setState(() {
                                              showButtons = true;
                                              showResult = false;
                                              session1Running = false;
                                              session2Running = false;
                                              session3Running = false;
                                              playedNumbers.clear();
                                              _audioPlayers.clear();
                                            });
                                          },
                                          text: '다시 시작',
                                          options: FFButtonOptions(
                                            width: 150.0,
                                            height: 50.0,
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 8.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8E8E8),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 16.0, 8.0, 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    '기본 훈련 기초 단계 (Level 3)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Color(0xFF0063A0),
                                          fontSize: 30.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '1. 소음 없이 숫자만 불려집니다!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.55.39_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '2. 다음엔 숫자가 하나만 불려집니다!\n이 숫자는 무작위(랜덤)로 아무거나 하나 나옵니다.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.45.12_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 100.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Text(
                                    '3. 불려진 숫자 하나가 앞에서 들은 숫자들 사이에 있었나요?\n없었나요?\n기억을 더듬어서 답을 눌러주세요!',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                          lineHeight: 1.6,
                                        ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/Screenshot_2024-06-29_at_10.46.33_PM-removebg-preview.png',
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 80.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 설명>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '본 훈련은 숫자 다섯 개가 스피커로 불려지고, 그 후에 무작위로 숫자 하나가 제시 됩니다.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              color: Color(0xFF0063A0),
                                              fontSize: 24.0,
                                              letterSpacing: 0.0,
                                              lineHeight: 1.6,
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 16.0, 0.0, 16.0),
                                        child: Text(
                                          '앞서 불린 다섯 개의 숫자 속에 무작위 숫자가 제시 되었다면 [있었다], 아니라면 [없었다]를 클릭해주세요.',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF0063A0),
                                                fontSize: 24.0,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.6,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 32.0, 0.0, 16.0),
                                    child: Text(
                                      '<훈련 순서>',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0063A0),
                                            fontSize: 28.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '1. 본인에게 편안한 크기로 컴퓨터 볼륨을 맞춰 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '2. [시작하기]를 눌러 주세요.',
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '3. 불려지는 다섯 개의 숫자를 듣고 기억해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '4. 화면에 보이는 무작위 숫자가 앞서 들은 다섯 개의 숫자에 포함이 되었다면 [있었다], 아니라면 [없었다]를 클릭해 주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '5. 다음 화면에서 다섯 가지 숫자가 무엇이었는지, 정답인지 아닌지 보입니다.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 8.0),
                                          child: Text(
                                            '6. 다시 [시작하기]를 클릭하여 반복해서 꾸준히 학습해주세요.',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF0063A0),
                                                  fontSize: 24.0,
                                                  letterSpacing: 0.0,
                                                  lineHeight: 1.6,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 1.0,
                          indent: 50.0,
                          endIndent: 50.0,
                          color: Color(0xFF0063A0),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
                          child: RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '준비가 되셨다면 ',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                ),
                                TextSpan(
                                  text: '[시작하기]',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '를 클릭해주세요.',
                                  style: TextStyle(
                                    color: Color(0xFF0063A0),
                                  ),
                                )
                              ],
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    lineHeight: 1.6,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 32.0, 0.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (showButtons) ...[
                                FFButtonWidget(
                                  onPressed: () async {
                                    setState(() {
                                      showButtons = false;
                                      training = true;
                                      session1Running = false;
                                      session2Running = false;
                                      session3Running = true;
                                    });
                                    playRandomAudios(5);
                                  },
                                  text: '시작하기',
                                  options: FFButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Color(0xFF01C5A2),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Colors.white,
                                          fontSize: 24.0,
                                          letterSpacing: 0.0,
                                        ),
                                    elevation: 3.0,
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ],

                              if (!showButtons && training && !showResult && session3Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                                
                              ],

                              if (!showButtons && !session3Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[
                                    Text(
                                      '다른 훈련이 진행중입니다.',
                                      style: FlutterFlowTheme.of(context).headlineMedium,
                                    ),
                                  ]
                                )
                                
                              ],

                              if (!showButtons && !training && !showResult && session3Running) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '앞서 들린 숫자에 보이는 숫자($randomDisplayedNumber)가 있었나요?',
                                    style: FlutterFlowTheme.of(context).headlineMedium,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(true);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '있었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        checkAnswer(false);

                                        if (testBasicResultsRecord != null && resultMessage == '정답입니다!') {
                                          await testBasicResultsRecord.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                            'numOfCollectQuestions': FieldValue.increment(1),
                                          });
                                        } else {
                                          await testBasicResultsRecord!.reference.update({
                                            'numOfQuestions': FieldValue.increment(1),
                                          });
                                        }
                                      },
                                      text: '없었다',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (showResult && session3Running) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          resultMessage,
                                          style: FlutterFlowTheme.of(context).headlineMedium,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            '방금 나온 숫자는 : ${playedNumbers.join(', ')}입니다.',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () {
                                            setState(() {
                                              showButtons = true;
                                              showResult = false;
                                              session1Running = false;
                                              session2Running = false;
                                              session3Running = false;
                                              playedNumbers.clear();
                                              _audioPlayers.clear();
                                            });
                                          },
                                          text: '다시 시작',
                                          options: FFButtonOptions(
                                            width: 150.0,
                                            height: 50.0,
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: FlutterFlowTheme.of(context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.white,
                                                  fontSize: 24.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

// Ensure that createBasicResultsRecordData includes createdTime
Map<String, dynamic> createBasicResultsRecordData({
  required int numOfQuestions,
  required int numOfCollectQuestions,
  required Timestamp createdTime, // Add this parameter
}) {
  return {
    'numOfQuestions': numOfQuestions,
    'numOfCollectQuestions': numOfCollectQuestions,
    'createdTime': createdTime, // Add this field
  };
}