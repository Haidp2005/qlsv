import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/lecturer_models.dart';
import '../../domain/repositories/lecturer_repository.dart';

class FirestoreLecturerRepository implements LecturerRepository {
  FirestoreLecturerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _classesCollection =>
      _firestore.collection('classes');

  @override
  Future<List<LecturerClassroom>> fetchClassesByLecturer(String lecturerId) async {
    final classesSnapshot = await _classesCollection
        .where('lecturerId', isEqualTo: lecturerId)
        .get();

    final classes = <LecturerClassroom>[];

    for (final classDoc in classesSnapshot.docs) {
      final data = classDoc.data();
      final studentsSnapshot =
          await classDoc.reference.collection('students').get();

      final students = studentsSnapshot.docs
          .map(
            (studentDoc) => _mapStudent(
              studentDoc.id,
              studentDoc.data(),
            ),
          )
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));

      classes.add(
        LecturerClassroom(
          id: classDoc.id,
          courseCode: (data['courseCode'] as String?) ?? classDoc.id,
          courseName: (data['courseName'] as String?) ?? 'Chưa đặt tên môn học',
          semester: (data['semester'] as String?) ?? 'Chưa xác định',
          room: (data['room'] as String?) ?? 'Chưa xác định',
          schedule: (data['schedule'] as String?) ?? 'Chưa xác định',
          students: students,
        ),
      );
    }

    classes.sort((a, b) => a.courseCode.compareTo(b.courseCode));
    return classes;
  }

  @override
  Future<void> seedDemoDataIfEmpty({
    required String lecturerId,
    required List<LecturerClassroom> demoClasses,
  }) async {
    final existedSnapshot = await _classesCollection
        .where('lecturerId', isEqualTo: lecturerId)
        .limit(1)
        .get();

    if (existedSnapshot.docs.isNotEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final classroom in demoClasses) {
      final classRef = _classesCollection.doc(classroom.id);
      batch.set(classRef, {
        'courseCode': classroom.courseCode,
        'courseName': classroom.courseName,
        'semester': classroom.semester,
        'room': classroom.room,
        'schedule': classroom.schedule,
        'lecturerId': lecturerId,
      });

      for (final student in classroom.students) {
        final studentRef = classRef.collection('students').doc(student.id);
        batch.set(studentRef, {
          'studentId': student.id,
          'fullName': student.fullName,
          'attendedSessions': student.attendedSessions,
          'totalSessions': student.totalSessions,
          'midtermScore': student.midtermScore,
          'finalScore': student.finalScore,
        });
      }
    }

    await batch.commit();
  }

  @override
  Future<void> submitAttendanceSession({
    required String classId,
    required Map<String, bool> attendanceByStudent,
  }) async {
    final classRef = _classesCollection.doc(classId);
    final studentsSnapshot = await classRef.collection('students').get();

    final batch = _firestore.batch();

    for (final studentDoc in studentsSnapshot.docs) {
      final studentId =
          (studentDoc.data()['studentId'] as String?) ?? studentDoc.id;
      final isPresent = attendanceByStudent[studentId] ?? false;

      batch.set(
        studentDoc.reference,
        {
          'studentId': studentId,
          'attendedSessions': FieldValue.increment(isPresent ? 1 : 0),
          'totalSessions': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  @override
  Future<void> updateStudentGrade({
    required String classId,
    required String studentId,
    required double midtermScore,
    required double finalScore,
  }) async {
    final studentRef = _classesCollection
        .doc(classId)
        .collection('students')
        .doc(studentId);

    await studentRef.set(
      {
        'studentId': studentId,
        'midtermScore': midtermScore,
        'finalScore': finalScore,
      },
      SetOptions(merge: true),
    );
  }

  StudentRecord _mapStudent(String docId, Map<String, dynamic> data) {
    final studentId = (data['studentId'] as String?) ?? docId;

    return StudentRecord(
      id: studentId,
      fullName: (data['fullName'] as String?) ?? 'Chưa cập nhật',
      attendedSessions: _toInt(data['attendedSessions']),
      totalSessions: _toInt(data['totalSessions']),
      midtermScore: _toDoubleOrNull(data['midtermScore']),
      finalScore: _toDoubleOrNull(data['finalScore']),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  double? _toDoubleOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
