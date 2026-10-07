import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BasicResultsRecord extends FirestoreRecord {
  BasicResultsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "NumOfQuestions" field.
  int? _numOfQuestions;
  int get numOfQuestions => _numOfQuestions ?? 0;
  bool hasNumOfQuestions() => _numOfQuestions != null;

  // "NumOfCollectQuestions" field.
  int? _numOfCollectQuestions;
  int get numOfCollectQuestions => _numOfCollectQuestions ?? 0;
  bool hasNumOfCollectQuestions() => _numOfCollectQuestions != null;

  // "CreatedTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _numOfQuestions = castToType<int>(snapshotData['NumOfQuestions']);
    _numOfCollectQuestions =
        castToType<int>(snapshotData['NumOfCollectQuestions']);
    _createdTime = snapshotData['CreatedTime'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('BasicResults')
          : FirebaseFirestore.instance.collectionGroup('BasicResults');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('BasicResults').doc(id);

  static Stream<BasicResultsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BasicResultsRecord.fromSnapshot(s));

  static Future<BasicResultsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BasicResultsRecord.fromSnapshot(s));

  static BasicResultsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BasicResultsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BasicResultsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BasicResultsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BasicResultsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BasicResultsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBasicResultsRecordData({
  int? numOfQuestions,
  int? numOfCollectQuestions,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'NumOfQuestions': numOfQuestions,
      'NumOfCollectQuestions': numOfCollectQuestions,
      'CreatedTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class BasicResultsRecordDocumentEquality
    implements Equality<BasicResultsRecord> {
  const BasicResultsRecordDocumentEquality();

  @override
  bool equals(BasicResultsRecord? e1, BasicResultsRecord? e2) {
    return e1?.numOfQuestions == e2?.numOfQuestions &&
        e1?.numOfCollectQuestions == e2?.numOfCollectQuestions &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(BasicResultsRecord? e) => const ListEquality()
      .hash([e?.numOfQuestions, e?.numOfCollectQuestions, e?.createdTime]);

  @override
  bool isValidKey(Object? o) => o is BasicResultsRecord;
}
