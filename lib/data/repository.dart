import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Repository {
  Future<void> create(Habit habit);

  Future<List<IDModel<Habit>>> readAll();

  Future update();

  Future remove();
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

    if(user == null) {
      throw Exception('Not auth');
    }

    final habitRef = firestore.collection(user.uid).doc('habit').collection('habit').withConverter<Habit>(
          fromFirestore: (snapshot, _) => HabitJson.fromJson(snapshot.data()!),
          toFirestore: (habit, _) => HabitJson.toJson(habit),
        );

    await habitRef.add(habit);
  }

  @override
  Future<List<IDModel<Habit>>> readAll() {
    // TODO: implement readAll
    throw UnimplementedError();
  }

  @override
  Future update() {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future remove() {
    // TODO: implement remove
    throw UnimplementedError();
  }
}
