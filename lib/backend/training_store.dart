import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String trainingDayId(DateTime time) {
  final day = time.toUtc().add(const Duration(hours: 9));

  return '${day.year}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

Future<bool> saveTrainingAnswer({
  required String collection,
  required String answerId,
  required DateTime answeredAt,
  required bool correct,
}) async {
  if (collection != 'BasicResults' && collection != 'AdvancedResults') {
    throw ArgumentError.value(collection, 'collection');
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw StateError('로그인이 필요합니다.');
  }

  final db = FirebaseFirestore.instance;

  final daily = db
      .collection('users')
      .doc(user.uid)
      .collection(collection)
      .doc(trainingDayId(answeredAt));

  final answer = daily.collection('answers').doc(answerId);

  return db.runTransaction<bool>((transaction) async {
    final savedAnswer = await transaction.get(answer);

    // 같은 답변을 재시도한 경우 기존 결과를 반환합니다.
    if (savedAnswer.exists) {
      return savedAnswer.data()!['correct'] as bool;
    }

    final snapshot = await transaction.get(daily);
    final data = snapshot.data() ?? <String, dynamic>{};

    final questions = data['numOfQuestions'] ?? data['NumOfQuestions'] ?? 0;

    final right =
        data['numOfCollectQuestions'] ?? data['NumOfCollectQuestions'] ?? 0;

    if (questions is! int ||
        right is! int ||
        questions < 0 ||
        right < 0 ||
        right > questions) {
      throw StateError('훈련 기록의 문항 수가 올바르지 않습니다.');
    }

    transaction.set(
      daily,
      {
        'numOfQuestions': questions + 1,
        'numOfCollectQuestions': right + (correct ? 1 : 0),
        'createdTime': data['createdTime'] ??
            data['CreatedTime'] ??
            Timestamp.fromDate(answeredAt),
      },
      SetOptions(merge: true),
    );

    transaction.set(answer, {
      'correct': correct,
      'createdTime': Timestamp.fromDate(answeredAt),
    });

    return correct;
  });
}
