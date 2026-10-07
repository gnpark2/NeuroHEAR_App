# NeuroHEAR 인증·온보딩 검토 및 적용 안내

검토 기준: `master`의 `be0966a` 및 접근 가능한 이전 커밋 `503e95d`.
이 저장소는 실행 가능한 Flutter 프로젝트 전체가 아니라 `lib` 소스 모음입니다.
`pubspec.yaml`, `pubspec.lock`, Android/iOS 프로젝트, assets, Firebase Security Rules가 없습니다.
따라서 설치된 앱과 이 소스가 같은 빌드인지, Android 패키지명·서명 지문·SDK 버전,
실제 Firebase 권한 및 데이터 접근 설정은 이 저장소만으로 확인할 수 없습니다.

## 공개 저장소 점검 결과

| 항목 | 확인 결과 / 조치 |
| --- | --- |
| Admin SDK 서비스 계정 JSON, 개인키, 배포 서명키 | 현재 추적 파일과 접근 가능한 두 커밋에서 발견하지 못함. 정규식 점검은 완전한 비밀정보 감사를 보장하지 않음. |
| 실제 사용자 전화번호·데이터 덤프 | 검토 범위에서 발견하지 못함. 사용자/훈련 결과 스키마 정의는 실제 사용자 데이터와 다름. |
| Firebase 클라이언트 설정 | `backend/firebase/firebase_config.dart`에 기존 프로젝트 식별자 하드코딩. 관리자 비밀키가 아님. Web 설정을 빌드 인자로 분리하고 예제를 추가함. |
| `.env` | Git에 포함되지 않았지만 Dart 파일처럼 import하고 있었음. 잘못된 import와 `String apiKey = apiKey;` 자기 참조 선언을 제거함. |
| 로그 | `BasicPracticePage`가 훈련 결과 snapshot/data를 출력하던 코드를 제거함. 라우터 진단 로그도 비활성화함. |
| 제외 규칙 | 비밀키, 서명키, `.env`, 개인별 설정, 빌드 산출물을 제외하도록 `.gitignore` 추가. 이미 커밋한 파일/이력은 소급 삭제되지 않음. |
| Firestore Rules / App Check | Rules 파일과 App Check 초기화 코드는 제공된 소스에 없음. README의 App Check 표기만으로 보호 활성화를 확인할 수 없음. Console에서 별도 확인 필요. |

Firebase용 클라이언트 API 키와 프로젝트 ID는 식별자입니다. 데이터 보호는 Firestore/
Storage Rules와 해당 서비스의 App Check 등으로 구성해야 합니다. Admin SDK의 서비스
계정 개인키와 서버 비밀키는 앱에 넣거나 Git에 공개하면 안 됩니다.
비밀키가 별도 로컬 파일이나 다른 브랜치에서 노출됐다면 키 폐기/교체가 우선이며,
필요하면 Git 이력 정리도 수행해야 합니다. 이 변경은 과거 이력을 다시 쓰지 않습니다.

추가로 현재 Web 전화번호 인증은 전화번호를 라우트 query parameter로 전달합니다.
공개 소스에 실제 번호가 들어 있는 것은 아니지만 실행 시 브라우저 방문 기록 등에
번호가 남을 수 있습니다. Web을 계속 배포한다면 메모리 기반 전달 방식으로 바꾸고
새로고침 시 인증 재시작 처리를 함께 적용하는 것이 좋습니다.

## 난청·건청 선택 문제의 원인과 변경

기존 `flutter_flow/nav/nav.dart`의 초기/오류 경로는 로그인만 되어 있으면 `NavBarPage`를
열었습니다. 청력 상태 확인은 `VerifyPage`의 SMS 인증 성공 후에만 실행되어,
인증 상태가 유지된 채 앱을 재실행하면 선택 화면을 건너뛸 수 있었습니다.

또한 `AssortPage`의 `radioButtonValue == '건청' ? 'T' : 'N'`은 선택하지 않은 `null`도
난청으로 저장했습니다.

변경 후:

- 초기 화면, 홈/훈련 등 앱 경로 및 오류 경로에서 공통 `HearingProfileGate`를 적용합니다.
- 현재 인증 UID의 `users/{uid}` 문서를 구독합니다. 계정이 바뀌면 이전 구독 상태를 재사용하지 않습니다.
- `hearing`이 정확히 `T`(건청) 또는 `N`(난청)일 때만 앱 콘텐츠를 엽니다.
- 문서가 없거나 값이 없거나 잘못되었으면 선택 화면을 표시합니다.
- 읽는 중에는 로딩, 읽기 실패 시에는 재시도 화면을 표시합니다. 실패를 완료로 취급하지 않습니다.
- 미선택 상태의 저장을 막고, 서버가 승인하지 않은 로컬 쓰기만으로 메인 화면을 열지 않습니다.
- 선택 저장은 merge를 사용해 기존 필드를 보존하고 누락된 사용자 문서도 생성할 수 있게 합니다.
- 최초 사용자 문서 생성은 트랜잭션으로 처리해 동시에 저장한 청력 선택을 덮어쓰지 않습니다.
- 수동 SMS 인증과 Android 즉시 인증 모두 공통 초기 경로로 진입합니다.

기존 데이터의 `T`/`N` 형식은 유지합니다. 과거 버그로 잘못 저장된 `N`은 사용자가 실제로
난청을 선택한 `N`과 구분할 수 없으므로 자동 변경하지 않습니다. 해당 사용자는 별도로
본인 선택을 다시 확인해야 합니다. 이 UI 검사는 서버 Security Rules를 대신하지 않습니다.

## Firebase 인증 오류

`This app is not authorized to use Firebase Authentication`는 앱 등록 및 검증 설정을
확인해야 하는 오류입니다. 소스에 SHA 값을 작성하거나 앱 검증을 끄는 것으로 해결할
문제가 아닙니다. 현재 Android 코드는 `Firebase.initializeApp()`로 네이티브 설정을
읽으므로 Web 설정 파일만 바꿔도 Android 프로젝트는 이전되지 않습니다.

기존 프로젝트에 접근 가능한 다른 관리자가 있다면 새 Google 계정에 적절한 프로젝트
권한을 부여받을 수 있습니다. 접근 복구가 불가능하다는 전제에서는 새 프로젝트를
만들어 다시 연결해야 합니다. 아래 작업은 이 코드 변경만으로 완료되지 않습니다.

### Android 새 프로젝트 연결

1. 관리 가능한 Google 계정으로 새 Firebase 프로젝트를 생성합니다.
2. 실제 Flutter 프로젝트의 `android/app/build.gradle` 또는 `.kts`의 `applicationId`를
   확인하고 그 값으로 Android 앱을 등록합니다. Dart package 이름으로 추정하지 마세요.
3. Windows PowerShell에서 실제 Flutter 프로젝트 기준으로 실행합니다.

   ```powershell
   cd android
   .\gradlew.bat signingReport
   cd ..
   ```

4. 실행/배포할 빌드의 SHA-1, SHA-256을 새 프로젝트의 Android 앱에 등록합니다.
   debug와 release 인증서는 다를 수 있습니다. Google Play 배포라면 Play App Signing의
   앱 서명 인증서도 확인합니다. 업로드 키와 앱 서명 키를 혼동하지 마세요.
5. 새 프로젝트에서 받은 `google-services.json`으로 `android/app/google-services.json`을
   교체합니다. 패키지명과 프로젝트가 모두 일치하는지 확인합니다.
6. Authentication의 전화번호 공급자를 켜고 필요한 SMS 지역(한국 등)을 허용합니다.
   현재 실제 인증 SMS는 Blaze 요금제가 필요합니다. 테스트는 Console에 등록한 가상
   전화번호로 먼저 진행할 수 있습니다. 실제 전화번호 인증을 우회하는 코드를 배포하지 마세요.
7. 새 Firestore DB에 스키마와 필요한 인덱스를 구성하고 사용자별 접근 규칙을 배포합니다.
   기존 코드가 쓰는 `users/{uid}` 및 그 하위 `BasicResults`, `AdvancedResults` 등을 확인합니다.
   쓰기 권한은 다른 사용자의 문서 접근을 막고 청력 상태의 허용값도 검증해야 합니다.
8. 실제 프로젝트에서 `flutter clean`, `flutter pub get` 후 다시 빌드합니다.
   설치 앱에 남아 있는 이전 프로젝트 세션도 고려하여 테스트 계정으로 확인합니다.

네이티브 설정을 대신해 FlutterFire CLI의 `flutterfire configure`와 생성된
`DefaultFirebaseOptions.currentPlatform`을 사용하는 방식도 가능합니다. 그 경우
현재 초기화 코드를 해당 방식으로 통일하고 모든 타깃이 같은 새 프로젝트를 가리키도록
해야 합니다. 두 프로젝트의 설정을 섞지 마세요.

iOS도 사용하는 경우 새 프로젝트의 동일 Bundle ID 앱 등록과 `GoogleService-Info.plist`,
전화번호 인증용 APNs/reCAPTCHA 관련 설정을 별도로 구성해야 합니다.

### Web을 계속 사용하는 경우

실제 Flutter 프로젝트 루트에 `firebase.web.example.json`을 복사한 뒤,
`firebase.web.local.json`으로 복제하여 새 프로젝트의 Web 앱 설정을 채웁니다.

```powershell
flutter run -d chrome --dart-define-from-file=firebase.web.local.json
flutter build web --dart-define-from-file=firebase.web.local.json
```

Authentication의 승인된 도메인에 실제 배포 도메인을 등록합니다. 클라이언트 설정은
빌드 결과에서도 확인할 수 있으므로 빌드 인자를 비밀키 보관 수단으로 사용하지 마세요.

### 기존 사용자와 기록

새 프로젝트로 바꿔도 이전 Auth 사용자, UID, Firestore 기록, Storage 파일이 자동 이동하지
않습니다. 이전 프로젝트의 권한 또는 적절한 백업 없이는 전체 이전을 보장할 수 없습니다.
동일한 전화번호로 다시 로그인했다고 이전 프로젝트의 UID/훈련 기록이 복원되는 것도 아닙니다.
원래 데이터가 중요하면 새 사용자 데이터와 연결하기 전에 이전/매핑 계획을 정해야 합니다.

## 적용 위치와 검증

이 저장소의 Dart 경로는 실제 Flutter 프로젝트의 `lib/` 아래에 대응합니다.
변경된 기존 Dart 파일과 새 `auth/hearing_status.dart`, `auth/hearing_profile_gate.dart`를
해당 위치에 반영하세요. `.gitignore`와 Web 설정 예제는 실제 프로젝트 루트 기준입니다.
`regression_tests/`는 앱 화면이 들어 있는 기존 `test/` 폴더와 구분한 검사 코드입니다.

검증 완료:

- Dart 3.13.5로 `dart regression_tests/hearing_status_test.dart`: 33개 정책 검사 통과.
- 정책 함수/검사 코드 `dart analyze`: 문제 없음.
- 수정 Dart 파일의 formatter 파싱 및 `git diff --check` 확인.
- 접근 가능한 두 커밋에서 개인키, 서비스 계정, 대표 토큰/API 키, 한국 전화번호 패턴 검색.

검증 한계:

- 정책 단위 검사는 실제 Flutter 위젯/네비게이션 또는 Firebase 연동 테스트가 아닙니다.
- `pubspec.yaml`, 플랫폼 설정 및 자산이 없어 전체 `flutter analyze`, APK 빌드,
  실제 SMS 인증/Firestore 권한 검증은 수행하지 못했습니다.
- Firebase Console 설정 및 기존 프로젝트 데이터는 변경하지 않았습니다.

실제 프로젝트에서 확인할 시나리오:

1. 새 번호 인증 → 선택 전에 앱 강제 종료 → 재실행 → 선택 화면 표시.
2. 선택 없이 시작하기 → 안내 표시, Firestore에 `N`을 쓰지 않음.
3. 건청/난청 각각 저장 → 재실행 → 홈 표시 및 `T`/`N` 유지.
4. 문서 없음/빈 값/잘못된 값으로 홈·훈련 경로 직접 접근 → 선택 화면 표시.
5. Firestore 읽기 권한 거부 → 재시도 화면, 메인 진입 없음.
6. 저장 중 네트워크 끊김/쓰기 거부 → 메인 진입 없음; 재연결/재시도 후 서버 저장 확인.
7. A 계정 로그아웃 후 미완료 B 계정 로그인 → A의 선택으로 통과하지 않음.
8. Android 즉시 인증 및 수동 SMS 인증 각각 신규 사용자 문서 생성/선택 진행 확인.
9. 인증 성공 직후 앱 종료로 사용자 문서가 누락된 경우 선택 저장으로 복구 확인.

## 공식 문서

- https://firebase.google.com/docs/auth/android/phone-auth
- https://firebase.google.com/docs/auth/limits
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/projects/api-keys
- https://firebase.google.com/support/troubleshooter/access/project/lost
