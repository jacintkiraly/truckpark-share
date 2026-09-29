import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

Future<void> main() async {
  print('==============================================');
  print('TruckPark Share - Firebase Firestore PoC');
  print('==============================================');

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();

  print('Firebase Admin SDK initialized.');

  final firestore = app.firestore();

  const documentId = 'truckpark_share_firestore_poc';

  print('');
  print('Testing Firestore write...');

  final documentReference =
      firestore.collection('parking_spots').doc(documentId);

  await documentReference.set({
    'poc': true,
    'createdBy': 'firebase_firestore_poc',
    'message': 'TruckPark Share Firestore connectivity test',
  });

  print('Firestore write: OK');

  print('');
  print('Testing Firestore read...');

  final snapshot = await documentReference.get();

  if (!snapshot.exists) {
    throw StateError(
      'Firestore document was not found after write.',
    );
  }

  print('Firestore read: OK');
  print('Document exists: ${snapshot.exists}');
  print('Document data: ${snapshot.data}');

  print('');
  print('Testing Firestore delete...');

  await documentReference.delete();

  print('Firestore delete: OK');

  print('');
  print('==============================================');
  print('RESULT: PASS');
  print('==============================================');
}
