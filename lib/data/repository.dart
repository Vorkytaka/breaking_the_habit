import 'package:breaking_the_habit/model/habit.dart';
import 'package:breaking_the_habit/model/id_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class Repository {
  Future<void> createHabit(Habit habit);

  Stream<List<IDModel<Habit>>> readAllHabitsStream();

  Future<List<IDModel<Habit>>> readAllHabits();

  Future<void> updateHabit(IDModel<Habit> habit);

  Future<void> deleteHabit(String id);

  Future<void> addActivity(IDModel<Habit> habit, DateTime date, [DateTime? time]);

  Stream<Map<int, List<Map<String, dynamic>>>> streamAllActivitiesPerMonth(DateTime datetime);
}

class RepositoryImpl implements Repository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const RepositoryImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<void> createHabit(Habit habit) async {
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
  Stream<List<IDModel<Habit>>> readAllHabitsStream() {
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
  Future<List<IDModel<Habit>>> readAllHabits() {
    // TODO: implement readAll
    throw UnimplementedError();
  }

  @override
  Future<void> updateHabit(IDModel<Habit> habit) async {
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
  Future<void> deleteHabit(String id) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    await firestore.collection(user.uid).doc('habit').collection('habit').doc(id).delete();
  }

  @override
  Future<void> addActivity(IDModel<Habit> habit, DateTime datetime, [DateTime? time]) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    final date = '${datetime.month}.${datetime.year}';

    await firestore.collection(user.uid).doc(date).get().then((snapshot) async {
      if (!snapshot.exists) {
        await firestore.collection(user.uid).doc(date).set({});
      }
    });

    await firestore.collection(user.uid).doc(date).update(
      {
        '${datetime.day}': FieldValue.arrayUnion([
          {
            'habit_id': habit.id,
            'timestamp': time?.toUtc().millisecondsSinceEpoch,
          }
        ]),
      },
    );
  }

  Stream<Map<int, List<Map<String, dynamic>>>> streamAllActivitiesPerMonth(DateTime datetime) {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    final date = '${datetime.month}.${datetime.year}';

    return firestore.collection(user.uid).doc(date).snapshots().map((event) => event.data()!.map((key, value) {
          return MapEntry(
            int.parse(key),
            value.map<Map<String, dynamic>>((e) => <String, dynamic>{
              'habit_id': e['habit_id'],
              'timestamp': e['timestamp'],
            }).toList(),
          );
        }));
  }
}
