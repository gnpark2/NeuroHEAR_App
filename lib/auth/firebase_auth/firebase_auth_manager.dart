import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth_manager.dart';
import '../../flutter_flow/flutter_flow_util.dart';

import '/backend/backend.dart';
import 'anonymous_auth.dart';
import 'email_auth.dart';
import 'firebase_user_provider.dart';
import 'google_auth.dart';
import 'jwt_token_auth.dart';
import 'github_auth.dart';

export '../base_auth_user_provider.dart';

class FirebasePhoneAuthManager extends ChangeNotifier {
  bool? _triggerOnCodeSent;
  FirebaseAuthException? phoneAuthError;
  // Set when using phone verification (after phone number is provided).
  String? phoneAuthVerificationCode;
  // Set when using phone sign in in web mode (ignored otherwise).
  ConfirmationResult? webPhoneAuthConfirmationResult;
  // Used for handling verification codes for phone sign in.
  void Function(BuildContext)? _onCodeSent;

  bool get triggerOnCodeSent => _triggerOnCodeSent ?? false;
  set triggerOnCodeSent(bool val) => _triggerOnCodeSent = val;

  void Function(BuildContext) get onCodeSent =>
      _onCodeSent == null ? (_) {} : _onCodeSent!;
  set onCodeSent(void Function(BuildContext) func) => _onCodeSent = func;

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}

class FirebaseAuthManager extends AuthManager
    with
        EmailSignInManager,
        GoogleSignInManager,
        // AppleSignInManager,
        AnonymousSignInManager,
        JwtSignInManager,
        GithubSignInManager,
        PhoneSignInManager {
  FirebasePhoneAuthManager phoneAuthManager = FirebasePhoneAuthManager();
  int? _phoneAuthResendToken;
  String? _phoneAuthNumber;

  @override
  Future signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  Future<bool> deleteUser(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    try {
      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.code == 'requires-recent-login'
                  ? '로그아웃 후 다시 로그인한 다음 탈퇴해주세요.'
                  : '탈퇴하지 못했습니다. 연결 상태를 확인한 뒤 다시 시도해주세요.',
            ),
          ),
        );
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('탈퇴하지 못했습니다. 잠시 후 다시 시도해주세요.'),
          ),
        );
      }
      return false;
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: update email attempted with no logged in user!');
        return;
      }
      await currentUser?.updateEmail(email);
      await updateUserDocument(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Too long since most recent sign in. Sign in again before updating your email.')),
        );
      }
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message!}')),
      );
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent')),
    );
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
        'EMAIL',
      );

  @override
  Future<BaseAuthUser?> signInAnonymously(
    BuildContext context,
  ) =>
      _signInOrCreateAccount(context, anonymousSignInFunc, 'ANONYMOUS');

  // @override
  // Future<BaseAuthUser?> signInWithApple(BuildContext context) =>
  //     _signInOrCreateAccount(context, appleSignIn, 'APPLE');

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) =>
      _signInOrCreateAccount(context, googleSignInFunc, 'GOOGLE');

  @override
  Future<BaseAuthUser?> signInWithGithub(BuildContext context) =>
      _signInOrCreateAccount(context, githubSignInFunc, 'GITHUB');

  @override
  Future<BaseAuthUser?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  ) =>
      _signInOrCreateAccount(context, () => jwtTokenSignIn(jwtToken), 'JWT');

  VoidCallback handlePhoneAuthStateChanges(BuildContext context) {
    void listener() {
      if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) {
        return;
      }

      if (phoneAuthManager.triggerOnCodeSent) {
        final onCodeSent = phoneAuthManager.onCodeSent;
        phoneAuthManager.triggerOnCodeSent = false;
        onCodeSent(context);
      } else if (phoneAuthManager.phoneAuthError != null) {
        final error = phoneAuthManager.phoneAuthError!;
        phoneAuthManager.phoneAuthError = null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? '인증 요청에 실패했습니다.'),
          ),
        );
      }
    }

    phoneAuthManager.addListener(listener);
    return () => phoneAuthManager.removeListener(listener);
  }

  @override
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
    bool resend = false,
  }) async {
    final resendToken = resend && _phoneAuthNumber == phoneNumber
        ? _phoneAuthResendToken
        : null;

    if (!resend || _phoneAuthNumber != phoneNumber) {
      _phoneAuthResendToken = null;
    }

    _phoneAuthNumber = phoneNumber;

    phoneAuthManager.update(() {
      phoneAuthManager.onCodeSent = onCodeSent;
      phoneAuthManager.triggerOnCodeSent = false;
      phoneAuthManager.phoneAuthError = null;
    });
    if (kIsWeb) {
      phoneAuthManager.webPhoneAuthConfirmationResult =
          await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
      phoneAuthManager.update(() => phoneAuthManager.triggerOnCodeSent = true);
      return;
    }
    final completer = Completer<bool>();
    // Android may still complete instant verification even with a zero timeout.
    // It must initialize the profile and enter the same gate as manual SMS login.
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: false,
      forceRecaptchaFlow: false,
    );
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: Duration(
        seconds: 0,
      ), // Skips Android's default auto-verification
      verificationCompleted: (phoneAuthCredential) async {
        try {
          final credential = await FirebaseAuth.instance.signInWithCredential(
            phoneAuthCredential,
          );
          if (credential.user != null) {
            await maybeCreateUser(credential.user!);
          }
          phoneAuthManager.update(() {
            phoneAuthManager.triggerOnCodeSent = false;
            phoneAuthManager.phoneAuthError = null;
          });
          if (context.mounted) {
            context.goNamed('_initialize');
          }
          if (!completer.isCompleted) completer.complete(true);
        } on FirebaseException catch (e) {
          phoneAuthManager.update(() {
            phoneAuthManager.triggerOnCodeSent = false;
            phoneAuthManager.phoneAuthError = e is FirebaseAuthException
                ? e
                : FirebaseAuthException(
                    code: e.code,
                    message: '사용자 정보를 저장하지 못했습니다. 다시 시도해주세요.',
                  );
          });
          if (!completer.isCompleted) completer.complete(false);
        }
      },
      verificationFailed: (e) {
        debugPrint('[PHONE_AUTH] code=${e.code}');
        debugPrint('[PHONE_AUTH] message=${e.message}');
        phoneAuthManager.update(() {
          phoneAuthManager.triggerOnCodeSent = false;
          phoneAuthManager.phoneAuthError = e;
        });
        if (!completer.isCompleted) completer.complete(false);
      },
      codeSent: (verificationId, resendToken) {
        _phoneAuthResendToken = resendToken;

        phoneAuthManager.update(() {
          phoneAuthManager.phoneAuthVerificationCode = verificationId;
          phoneAuthManager.triggerOnCodeSent = true;
          phoneAuthManager.phoneAuthError = null;
        });

        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  }) {
    if (kIsWeb) {
      return _signInOrCreateAccount(
        context,
        () => phoneAuthManager.webPhoneAuthConfirmationResult!.confirm(smsCode),
        'PHONE',
      );
    } else {
      final authCredential = PhoneAuthProvider.credential(
        verificationId: phoneAuthManager.phoneAuthVerificationCode!,
        smsCode: smsCode,
      );
      return _signInOrCreateAccount(
        context,
        () => FirebaseAuth.instance.signInWithCredential(authCredential),
        'PHONE',
      );
    }
  }

  /// Tries to sign in or create an account using Firebase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<UserCredential?> Function() signInFunc,
    String authProvider,
  ) async {
    try {
      final userCredential = await signInFunc();
      if (userCredential?.user != null) {
        await maybeCreateUser(userCredential!.user!);
      }
      return userCredential == null
          ? null
          : NeuroHEARFirebaseUser.fromUserCredential(userCredential);
    } on FirebaseAuthException catch (e) {
      final errorMsg = switch (e.code) {
        'email-already-in-use' =>
          'Error: The email is already in use by a different account',
        'INVALID_LOGIN_CREDENTIALS' =>
          'Error: The supplied auth credential is incorrect, malformed or has expired',
        _ => 'Error: ${e.message!}',
      };
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
      return null;
    }
  }
}
