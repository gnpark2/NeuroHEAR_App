/// Existing Firestore values: T = 건청, N = 난청.
bool isValidHearingStatus(Object? value) => value == 'T' || value == 'N';

enum HearingProfileState { loading, failed, needsSelection, ready }

HearingProfileState resolveHearingProfileState({
  required bool loading,
  required bool failed,
  required bool hasPendingWrites,
  required Object? hearing,
}) {
  if (failed) return HearingProfileState.failed;
  if (loading) return HearingProfileState.loading;
  if (hasPendingWrites || !isValidHearingStatus(hearing)) {
    return HearingProfileState.needsSelection;
  }
  return HearingProfileState.ready;
}

/// An unanswered question must never silently become 난청.
String? hearingStatusFromSelection(String? selection) {
  switch (selection) {
    case '건청':
      return 'T';
    case '난청':
      return 'N';
    default:
      return null;
  }
}
