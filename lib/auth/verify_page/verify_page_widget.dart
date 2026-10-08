import 'dart:async';

import 'package:flutter/services.dart';

import '/flutter_flow/scrollable_page_body.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'verify_page_model.dart';
export 'verify_page_model.dart';

class VerifyPageWidget extends StatefulWidget {
  const VerifyPageWidget({super.key, required this.phoneNumber});

  final String? phoneNumber;

  @override
  State<VerifyPageWidget> createState() => _VerifyPageWidgetState();
}

class _VerifyPageWidgetState extends State<VerifyPageWidget> {
  late VerifyPageModel _model;
  late final VoidCallback _removePhoneAuthListener;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode _pinCodeFocusNode = FocusNode(
    debugLabel: 'VerifyPage.smsCode',
  );

  Timer? _countdownTimer;
  late DateTime _codeExpiresAt;
  late DateTime _resendAvailableAt;

  int _resendSeconds = 30;
  bool _resending = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => VerifyPageModel());

    _removePhoneAuthListener = authManager.handlePhoneAuthStateChanges(context);

    _restartCodeTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestPinKeyboard();
    });
  }

  void _restartCodeTimer() {
    final now = DateTime.now();

    _codeExpiresAt = now.add(
      Duration(milliseconds: _model.timerInitialTimeMs),
    );
    _resendAvailableAt = now.add(const Duration(seconds: 30));

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateCountdown(),
    );
  }

  void _updateCountdown() {
    if (!mounted) return;

    final now = DateTime.now();

    setState(() {
      _model.timerMilliseconds = _codeExpiresAt
          .difference(now)
          .inMilliseconds
          .clamp(0, _model.timerInitialTimeMs)
          .toInt();

      _model.timerValue = StopWatchTimer.getDisplayTime(
        _model.timerMilliseconds,
        hours: false,
        milliSecond: false,
      );

      _resendSeconds =
          (_resendAvailableAt.difference(now).inMilliseconds / 1000)
              .ceil()
              .clamp(0, 30)
              .toInt();
    });

    if (_model.timerMilliseconds == 0 && _resendSeconds == 0) {
      _countdownTimer?.cancel();
    }
  }

  Future<void> _resendCode() async {
    if (_resending || _verifying || _resendSeconds > 0) return;

    final phoneNumber = widget.phoneNumber;

    if (phoneNumber == null || !phoneNumber.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('핸드폰 번호를 다시 입력해주세요.'),
        ),
      );
      return;
    }

    setState(() => _resending = true);

    // 실패한 요청도 연속해서 누르지 않도록 대기 시간을 적용합니다.
    _resendAvailableAt = DateTime.now().add(
      const Duration(seconds: 30),
    );
    _startCountdown();

    try {
      await authManager.beginPhoneAuth(
        context: context,
        phoneNumber: phoneNumber,
        resend: true,
        onCodeSent: (_) {
          if (!mounted) return;

          _model.pinCodeController?.clear();
          _restartCodeTimer();
          _requestPinKeyboard();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인증코드를 다시 보냈습니다.'),
            ),
          );
        },
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('재전송하지 못했습니다. 잠시 후 다시 시도해주세요.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _resending = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_resending || _verifying) return;

    final smsCode = _model.pinCodeController!.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('6자리 인증코드를 입력하세요.'),
        ),
      );
      return;
    }

    setState(() => _verifying = true);

    try {
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.verifySmsCode(
        context: context,
        smsCode: smsCode,
      );

      if (!mounted || user == null) return;

      context.goNamedAuth('_initialize', mounted);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증하지 못했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  void _requestPinKeyboard() {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    _pinCodeFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (!_pinCodeFocusNode.hasFocus) return;

      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _removePhoneAuthListener();
    _pinCodeFocusNode.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: ScrollablePageBody(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '인증 코드 입력',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 30.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        '문자로 받은 6자리 인증코드를 입력하세요.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Container(
                        width: 600.0,
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            32.0,
                            0.0,
                            32.0,
                          ),
                          child: PinCodeTextField(
                            autoDisposeControllers: false,
                            appContext: context,
                            length: 6,
                            focusNode: _pinCodeFocusNode,
                            autoFocus: false,
                            autoUnfocus: false,
                            onTap: _requestPinKeyboard,
                            textStyle:
                                FlutterFlowTheme.of(context).bodyLarge.override(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0.0,
                                    ),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            enableActiveFill: false,
                            enablePinAutofill: false,
                            errorTextSpace: 16.0,
                            showCursor: true,
                            cursorColor: FlutterFlowTheme.of(context).primary,
                            obscureText: false,
                            hintCharacter: '●',
                            keyboardType: TextInputType.number,
                            pinTheme: PinTheme(
                              fieldHeight: 44.0,
                              fieldWidth:
                                  ((MediaQuery.sizeOf(context).width - 64.0) /
                                          6.0)
                                      .clamp(24.0, 44.0)
                                      .toDouble(),
                              borderWidth: 2.0,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              shape: PinCodeFieldShape.box,
                              activeColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              inactiveColor:
                                  FlutterFlowTheme.of(context).alternate,
                              selectedColor:
                                  FlutterFlowTheme.of(context).primary,
                              activeFillColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              inactiveFillColor:
                                  FlutterFlowTheme.of(context).alternate,
                              selectedFillColor:
                                  FlutterFlowTheme.of(context).primary,
                            ),
                            controller: _model.pinCodeController,
                            onChanged: (_) {},
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _model.pinCodeControllerValidator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          16.0,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 12,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0,
                                    0.0,
                                    0.0,
                                    0.0,
                                  ),
                                  child: Text(
                                    _model.timerValue,
                                    textAlign: TextAlign.start,
                                    style: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          fontFamily: 'Outfit',
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 12,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    0.0,
                                    4.0,
                                    0.0,
                                  ),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: _resending || _verifying
                                        ? null
                                        : () => context.goNamed('AuthPage'),
                                    child: Text(
                                      '핸드폰 번호 다시 작성하기',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            color: Color(0xFF0079FF),
                                            fontSize: 24.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0,
                                    16.0,
                                    0.0,
                                    0.0,
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.mousePointer,
                                    color: Color(0xFF0079FF),
                                    size: 24.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_model.timerMilliseconds == 0)
                        const Text(
                          '인증코드를 받지 못하셨습니까?',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      TextButton.icon(
                        onPressed:
                            _resending || _verifying || _resendSeconds > 0
                                ? null
                                : _resendCode,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.redAccent,
                          size: 20.0,
                        ),
                        label: Text(
                          _resending
                              ? '재전송 중…'
                              : _resendSeconds > 0
                                  ? '$_resendSeconds초 후 다시 받기'
                                  : '인증번호 다시 받기',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    color: _resending || _resendSeconds > 0
                                        ? FlutterFlowTheme.of(context)
                                            .secondaryText
                                        : Color(0xFF0079FF),
                                  ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          16.0,
                          0.0,
                          0.0,
                        ),
                        child: FFButtonWidget(
                          onPressed:
                              _resending || _verifying ? null : _verifyCode,
                          text: '인증완료',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                              24.0,
                              0.0,
                              24.0,
                              0.0,
                            ),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
