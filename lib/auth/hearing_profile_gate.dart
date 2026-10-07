import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'assort_page/assort_page_widget.dart';
import 'hearing_status.dart';

/// Every signed-in application route checks the profile, including cold starts
/// and deep links. Keep the subscription scoped to the authenticated UID.
class HearingProfileGate extends StatefulWidget {
  const HearingProfileGate({
    super.key,
    required this.userId,
    required this.builder,
  });

  final String userId;
  final WidgetBuilder builder;

  @override
  State<HearingProfileGate> createState() => _HearingProfileGateState();
}

class _HearingProfileGateState extends State<HearingProfileGate> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant HearingProfileGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _subscribe();
    }
  }

  void _subscribe() {
    _profileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots(includeMetadataChanges: true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      key: ValueKey(widget.userId),
      stream: _profileStream,
      builder: (context, snapshot) {
        final state = resolveHearingProfileState(
          loading: snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData,
          failed: snapshot.hasError,
          hasPendingWrites: snapshot.data?.metadata.hasPendingWrites ?? false,
          hearing: snapshot.data?.data()?['hearing'],
        );
        if (state == HearingProfileState.failed) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('사용자 정보를 불러오지 못했습니다. 다시 시도해주세요.'),
                  TextButton(
                    onPressed: () => setState(_subscribe),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state == HearingProfileState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Firestore emits local writes before the server accepts them. Keep
        // onboarding mounted until the selection has actually been saved.
        if (state == HearingProfileState.needsSelection) {
          return const AssortPageWidget();
        }
        return widget.builder(context);
      },
    );
  }
}
