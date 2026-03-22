import 'package:flutter_test/flutter_test.dart';
import 'package:qlsv/features/lecturer/domain/models/lecturer_models.dart';
import 'package:qlsv/features/lecturer/domain/repositories/lecturer_repository.dart';
import 'package:qlsv/features/lecturer/presentation/controllers/lecturer_module_cubit.dart';

class _FakeLecturerRepository implements LecturerRepository {
  _FakeLecturerRepository(this._classes);

  final List<LecturerClassroom> _classes;

  @override
  Future<List<LecturerClassroom>> fetchClassesByLecturer(String lecturerId) async {
    return _classes;
  }

  @override
  Future<void> seedDemoDataIfEmpty({
    required String lecturerId,
    required List<LecturerClassroom> demoClasses,
  }) async {}

  @override
  Future<void> submitAttendanceSession({
    required String classId,
    required Map<String, bool> attendanceByStudent,
  }) async {}

  @override
  Future<void> updateStudentGrade({
    required String classId,
    required String studentId,
    required double midtermScore,
    required double finalScore,
  }) async {}
}

void main() {
  group('LecturerModuleCubit', () {
    late LecturerModuleCubit cubit;

    setUp(() {
      cubit = LecturerModuleCubit(
        repository: _FakeLecturerRepository(const []),
        autoSyncOnStart: false,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('khởi tạo với danh sách lớp và lớp được chọn mặc định', () {
      expect(cubit.state.classes, isNotEmpty);
      expect(cubit.state.selectedAttendanceClassId, isNotNull);
      expect(cubit.state.selectedGradingClassId, isNotNull);
    });

    test('lưu điểm danh cập nhật attendedSessions và totalSessions', () async {
      final classId = cubit.state.selectedAttendanceClassId!;
      final studentBefore = cubit.state.selectedAttendanceClass!.students.first;

      cubit.toggleAttendance(
        classId: classId,
        studentId: studentBefore.id,
        isPresent: true,
      );
      await cubit.submitAttendanceSession();

      final studentAfter = cubit.state.selectedAttendanceClass!.students
          .firstWhere((student) => student.id == studentBefore.id);

      expect(studentAfter.totalSessions, studentBefore.totalSessions + 1);
      expect(studentAfter.attendedSessions, studentBefore.attendedSessions + 1);
    });

    test('nhập điểm cập nhật đúng điểm giữa kỳ và cuối kỳ', () async {
      final classId = cubit.state.selectedGradingClassId!;
      final studentId = cubit.state.selectedGradingClass!.students.first.id;

      await cubit.updateStudentGrade(
        classId: classId,
        studentId: studentId,
        midtermScore: 8.5,
        finalScore: 9.0,
      );

      final studentAfter = cubit.state.selectedGradingClass!.students
          .firstWhere((student) => student.id == studentId);

      expect(studentAfter.midtermScore, 8.5);
      expect(studentAfter.finalScore, 9.0);
      expect(studentAfter.overallScore, closeTo(8.8, 0.0001));
    });

    test('đánh dấu tất cả có mặt tạo draft đầy đủ cho cả lớp', () {
      final classId = cubit.state.selectedAttendanceClassId!;
      final selectedClass = cubit.state.selectedAttendanceClass!;

      cubit.markAllAttendanceForSelectedClass(true);

      final draft = cubit.state.attendanceDraftByClass[classId]!;
      expect(draft.length, selectedClass.students.length);
      expect(draft.values.every((value) => value), isTrue);
    });

    test('đồng bộ firestore cập nhật danh sách lớp từ repository', () async {
      const remoteClasses = [
        LecturerClassroom(
          id: 'MOB101',
          courseCode: 'MOB101',
          courseName: 'Lập trình di động',
          semester: 'HK2',
          room: 'A1-201',
          schedule: 'Thứ 5',
          students: [
            StudentRecord(id: 'SV900', fullName: 'Sinh viên test'),
          ],
        ),
      ];

      final syncCubit = LecturerModuleCubit(
        repository: _FakeLecturerRepository(remoteClasses),
        autoSyncOnStart: false,
      );

      await syncCubit.refreshFromFirestore();

      expect(syncCubit.state.classes.length, 1);
      expect(syncCubit.state.classes.first.id, 'MOB101');

      await syncCubit.close();
    });
  });
}
