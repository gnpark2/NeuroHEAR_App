import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AdvancedResultsRecord extends FirestoreRecord {
  AdvancedResultsRecord._(
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
          ? parent.collection('AdvancedResults')
          : FirebaseFirestore.instance.collectionGroup('AdvancedResults');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('AdvancedResults').doc(id);

  static Stream<AdvancedResultsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AdvancedResultsRecord.fromSnapshot(s));

  static Future<AdvancedResultsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AdvancedResultsRecord.fromSnapshot(s));

  static AdvancedResultsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AdvancedResultsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AdvancedResultsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AdvancedResultsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AdvancedResultsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AdvancedResultsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAdvancedResultsRecordData({
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

class AdvancedResultsRecordDocumentEquality
    implements Equality<AdvancedResultsRecord> {
  const AdvancedResultsRecordDocumentEquality();

  @override
  bool equals(AdvancedResultsRecord? e1, AdvancedResultsRecord? e2) {
    return e1?.numOfQuestions == e2?.numOfQuestions &&
        e1?.numOfCollectQuestions == e2?.numOfCollectQuestions &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(AdvancedResultsRecord? e) => const ListEquality()
      .hash([e?.numOfQuestions, e?.numOfCollectQuestions, e?.createdTime]);

  @override
  bool isValidKey(Object? o) => o is AdvancedResultsRecord;
}
