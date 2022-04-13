import 'package:breaking_the_habit/model/activity.dart';
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

  Stream<Map<int, List<Activity>>?> streamAllActivitiesPerMonth(DateTime datetime);
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
          toFirestore: (habit, _) => {
            ...HabitJson.toJson(habit),
            'createdDate': DateTime.now().toUtc(),
          },
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
        .orderBy('createdDate')
        .snapshots()
        .map((event) => event.docs
            .map((e) => IDModel(id: e.id, value: e.data()))
            .where((habit) => !habit.value.archive)
            .toList(growable: false));
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

    await firestore.collection(user.uid).doc('habit').collection('habit').doc(id).update({
      'archive': true,
    });
  }

  @override
  Future<void> addActivity(IDModel<Habit> habit, DateTime datetime, [DateTime? time]) async {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    final docRef =
        firestore.collection(user.uid).doc('${datetime.year}').collection('${datetime.year}').doc('${datetime.month}');

    await docRef.get().then((snapshot) async {
      if (!snapshot.exists) {
        await docRef.set({});
      }
    });

    await docRef.update(
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

  @override
  Stream<Map<int, List<Activity>>?> streamAllActivitiesPerMonth(DateTime datetime) {
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('Not auth');
    }

    final docRef =
        firestore.collection(user.uid).doc('${datetime.year}').collection('${datetime.year}').doc('${datetime.month}');

    return docRef.snapshots().map((event) => event.data()?.map((key, value) => MapEntry(
          int.parse(key),
          value.map<Activity>((e) {
            return ActivityJson.fromJson(e);
          }).toList(),
        )));
  }
}
