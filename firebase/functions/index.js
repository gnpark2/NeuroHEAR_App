// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
//   let firestore = admin.firestore();
//   let userRef = firestore.doc("users/" + user.uid);
//   await firestore.collection("users").doc(user.uid).delete();
// });


const functions = require("firebase-functions/v1");
const { initializeApp, getApps } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");

if (getApps().length === 0) {
  initializeApp();
}

// 기존 함수 이름을 유지해야 기존 삭제 함수를 업데이트합니다.
exports.onUserDeleted = functions
  .runWith({
    failurePolicy: true,
  })
  .auth.user()
  .onDelete(async (user, context) => {
    const userRef = getFirestore()
      .collection("users")
      .doc(user.uid);

    await userRef.set(
      {
        uid: user.uid,
        accountStatus: "deleted",
        deletedAt: Timestamp.fromDate(
          new Date(context.timestamp)
        ),
      },
      {
        merge: true,
      }
    );

    functions.logger.info("탈퇴 상태 기록 완료", {
      uid: user.uid,
      eventId: context.eventId,
    });
  });