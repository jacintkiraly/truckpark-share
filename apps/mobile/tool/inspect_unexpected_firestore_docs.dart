import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _collection = 'parking_spots';

const _documentId = 'p5qHPpf2zSEmhrhCH4ds';

Future<void> main() async {
  print('==================================================');
  print('TruckPark Share - Inspect Firestore Document');
  print('==================================================');

  print('');
  print('Document: $_collection/$_documentId');

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  final snapshot = await firestore
      .collection(_collection)
      .doc(_documentId)
      .get();

  if (!snapshot.exists) {
    print('');
    print('Document does not exist.');
    return;
  }

  final data = snapshot.data();

  if (data == null) {
    print('');
    print('Document exists, but contains no readable data.');
    return;
  }

  print('');
  print('Document exists.');
  print('');
  print('Fields:');

  for (final entry in data.entries) {
    print('${entry.key}: ${entry.value}');
  }

  print('');
  print('RESULT: INSPECTION COMPLETE');
}
