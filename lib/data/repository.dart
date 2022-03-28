import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Repository {
  Future<void> create(Habit habit);

  Stream<List<IDModel<Habit>>> readAllStream();

  Future<List<IDModel<Habit>>> readAll();

  Future<void> update(IDModel<Habit> habit);

  Future<void> delete(String id);
}

class RepositoryImpl implements Repository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const RepositoryImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<void> create(Habit habit) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    final habitRef = firestore.collection(user.uid).doc('habit').collection('habit').withConverter<Habit>(
          fromFirestore: (snapshot, _) => HabitJson.fromJson(snapshot.data()!),
          toFirestore: (habit, _) => HabitJson.toJson(habit),
        );

    await habitRef.add(habit);
  }

  @override
  Stream<List<IDModel<Habit>>> readAllStream() {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    return firestore
        .collection(user.uid)
        .doc('habit')
        .collection('habit')
        .withConverter<Habit>(
          fromFirestore: (snapshot, _) => HabitJson.fromJson(snapshot.data()!),
          toFirestore: (habit, _) => HabitJson.toJson(habit),
        )
        .snapshots()
        .map((event) => event.docs.map((e) => IDModel(id: e.id, value: e.data())).toList(growable: false));
  }

  @override
  Future<List<IDModel<Habit>>> readAll() {
    // TODO: implement readAll
    throw UnimplementedError();
  }

  @override
  Future<void> update(IDModel<Habit> habit) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    await firestore
        .collection(user.uid)
        .doc('habit')
        .collection('habit')
        .doc(habit.id)
        .update(HabitJson.toJson(habit.value));
  }

  @override
  Future<void> delete(String id) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    await firestore.collection(user.uid).doc('habit').collection('habit').doc(id).delete();
  }
}
