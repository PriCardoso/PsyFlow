import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance =
      FirestoreService._();

  final FirebaseFirestore db =
      FirebaseFirestore.instance;

  CollectionReference users() =>
      db.collection('users');

  CollectionReference patients() =>
      db.collection('patients');

  CollectionReference psychologists() =>
      db.collection('psychologists');

  CollectionReference tasks() =>
      db.collection('tasks');

  CollectionReference appointments() =>
      db.collection('appointments');

  CollectionReference interventions() =>
      db.collection('interventions');

  CollectionReference templates() =>
      db.collection('intervention_templates');

  CollectionReference notifications() =>
      db.collection('notifications');

  CollectionReference reports() =>
      db.collection('reports');

  CollectionReference settings() =>
      db.collection('settings');
}