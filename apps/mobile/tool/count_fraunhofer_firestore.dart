import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

const _collection = 'parking_spots';

Future<void> main() async {
  print('==================================================');
  print('TruckPark Share - Firestore Count Diagnostic');
  print('==================================================');

  print('');
  print('Initializing Firebase Admin SDK...');

  final app = FirebaseApp.initializeApp();
  final firestore = app.firestore();

  print('Firebase Admin SDK initialized.');

  print('');
  print('Running server-side count aggregation...');

  final aggregate = await firestore
      .collection(_collection)
      .count()
      .get();

  print('');
  print('==================================================');
  print('RESULT');
  print('==================================================');

  print(
    'Firestore collection count: '
    '${aggregate.count}',
  );

  print('');
  print('No documents were downloaded.');
  print('No writes were performed.');
}
