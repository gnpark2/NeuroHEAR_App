// Run from this lib-only repository: dart regression_tests/hearing_status_test.dart
// No Flutter/Firebase project or live user data is required for these policy tests.
import '../auth/hearing_status.dart';

void expectEqual(Object? actual, Object? expected, String scenario) {
  if (actual != expected) {
    throw StateError('$scenario: expected $expected, got $actual');
  }
}

void main() {
  for (final value in [null, '', ' ', 'unknown', '건청', '난청', true, false, 0]) {
    expectEqual(
      isValidHearingStatus(value),
      false,
      'Invalid stored value $value',
    );
    expectEqual(
      resolveHearingProfileState(
        loading: false,
        failed: false,
        hasPendingWrites: false,
        hearing: value,
      ),
      HearingProfileState.needsSelection,
      'Restart with missing or malformed hearing value $value',
    );
  }
  for (final value in ['T', 'N']) {
    expectEqual(
      isValidHearingStatus(value),
      true,
      'Existing completed profile',
    );
    expectEqual(
      resolveHearingProfileState(
        loading: false,
        failed: false,
        hasPendingWrites: false,
        hearing: value,
      ),
      HearingProfileState.ready,
      'Restart after a confirmed save ($value)',
    );
    expectEqual(
      resolveHearingProfileState(
        loading: false,
        failed: false,
        hasPendingWrites: true,
        hearing: value,
      ),
      HearingProfileState.needsSelection,
      'Offline or unacknowledged save must not enter home ($value)',
    );
    expectEqual(
      resolveHearingProfileState(
        loading: true,
        failed: false,
        hasPendingWrites: false,
        hearing: value,
      ),
      HearingProfileState.loading,
      'Retained snapshot during a new subscription must not enter home',
    );
    expectEqual(
      resolveHearingProfileState(
        loading: false,
        failed: true,
        hasPendingWrites: false,
        hearing: value,
      ),
      HearingProfileState.failed,
      'Read failure must not reuse a previously completed profile',
    );
  }
  expectEqual(hearingStatusFromSelection(null), null, 'No selection');
  expectEqual(hearingStatusFromSelection(''), null, 'Empty selection');
  expectEqual(hearingStatusFromSelection('unknown'), null, 'Invalid selection');
  expectEqual(hearingStatusFromSelection('건청'), 'T', 'Explicit 건청');
  expectEqual(hearingStatusFromSelection('난청'), 'N', 'Explicit 난청');
  print('33 hearing onboarding policy checks passed.');
}
