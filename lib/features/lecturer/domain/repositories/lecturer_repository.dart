import '../models/lecturer_models.dart';

abstract class LecturerRepository {
  Future<List<LecturerClassroom>> fetchClassesByLecturer(String lecturerId);

  Future<void> seedDemoDataIfEmpty({
    required String lecturerId,
    required List<LecturerClassroom> demoClasses,
  });

  Future<void> submitAttendanceSession({
    required String classId,
    required Map<String, bool> attendanceByStudent,
    required String date,
  });

  Future<void> updateStudentGrade({
    required String classId,
    required String studentId,
    required double midtermScore,
    required double finalScore,
  });
}
