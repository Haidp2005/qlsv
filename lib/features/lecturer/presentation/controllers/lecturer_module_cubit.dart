import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/firestore_lecturer_repository.dart';
import '../../domain/models/lecturer_models.dart';
import '../../domain/repositories/lecturer_repository.dart';

class LecturerModuleState extends Equatable {
  const LecturerModuleState({
    required this.classes,
    required this.selectedAttendanceClassId,
    required this.selectedGradingClassId,
    required this.attendanceDraftByClass,
    required this.isSyncing,
    this.feedbackMessage,
    this.errorMessage,
  });

  final List<LecturerClassroom> classes;
  final String? selectedAttendanceClassId;
  final String? selectedGradingClassId;
  final Map<String, Map<String, bool>> attendanceDraftByClass;
  final bool isSyncing;
  final String? feedbackMessage;
  final String? errorMessage;

  LecturerClassroom? get selectedAttendanceClass {
    if (selectedAttendanceClassId == null) {
      return null;
    }
    for (final classroom in classes) {
      if (classroom.id == selectedAttendanceClassId) {
        return classroom;
      }
    }
    return null;
  }

  LecturerClassroom? get selectedGradingClass {
    if (selectedGradingClassId == null) {
      return null;
    }
    for (final classroom in classes) {
      if (classroom.id == selectedGradingClassId) {
        return classroom;
      }
    }
    return null;
  }

  LecturerModuleState copyWith({
    List<LecturerClassroom>? classes,
    String? selectedAttendanceClassId,
    bool clearSelectedAttendanceClassId = false,
    String? selectedGradingClassId,
    bool clearSelectedGradingClassId = false,
    Map<String, Map<String, bool>>? attendanceDraftByClass,
    bool? isSyncing,
    String? feedbackMessage,
    bool clearFeedbackMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LecturerModuleState(
      classes: classes ?? this.classes,
      selectedAttendanceClassId: clearSelectedAttendanceClassId
          ? null
          : (selectedAttendanceClassId ?? this.selectedAttendanceClassId),
      selectedGradingClassId: clearSelectedGradingClassId
          ? null
          : (selectedGradingClassId ?? this.selectedGradingClassId),
      attendanceDraftByClass: attendanceDraftByClass ?? this.attendanceDraftByClass,
      isSyncing: isSyncing ?? this.isSyncing,
      feedbackMessage:
          clearFeedbackMessage ? null : (feedbackMessage ?? this.feedbackMessage),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        classes,
        selectedAttendanceClassId,
        selectedGradingClassId,
        attendanceDraftByClass,
        isSyncing,
        feedbackMessage,
        errorMessage,
      ];
}

class LecturerModuleCubit extends Cubit<LecturerModuleState> {
  LecturerModuleCubit({
    LecturerRepository? repository,
    this.lecturerId = _defaultLecturerId,
    this.autoSyncOnStart = true,
  })
      : _repository = repository ?? FirestoreLecturerRepository(),
        super(
          LecturerModuleState(
            classes: _seedClasses,
            selectedAttendanceClassId: _seedClasses.first.id,
            selectedGradingClassId: _seedClasses.first.id,
            attendanceDraftByClass: const {},
            isSyncing: false,
          ),
        ) {
    if (autoSyncOnStart) {
      unawaited(refreshFromFirestore());
    }
  }

  static const String _defaultLecturerId = 'lecturer_demo_001';

  final LecturerRepository _repository;
  final String lecturerId;
  final bool autoSyncOnStart;

  static final List<LecturerClassroom> _seedClasses = [
    const LecturerClassroom(
      id: 'SE114',
      courseCode: 'SE114',
      courseName: 'Lập trình hướng đối tượng',
      semester: 'HK2 - 2025/2026',
      room: 'B3-203',
      schedule: 'Thứ 2, 07:30 - 09:30',
      students: [
        StudentRecord(id: 'SV001', fullName: 'Nguyễn Minh Anh'),
        StudentRecord(id: 'SV002', fullName: 'Trần Hoàng Nam'),
        StudentRecord(id: 'SV003', fullName: 'Lê Gia Huy'),
      ],
    ),
    const LecturerClassroom(
      id: 'CS221',
      courseCode: 'CS221',
      courseName: 'Cấu trúc dữ liệu và giải thuật',
      semester: 'HK2 - 2025/2026',
      room: 'A2-105',
      schedule: 'Thứ 4, 13:30 - 16:00',
      students: [
        StudentRecord(id: 'SV004', fullName: 'Phạm Quỳnh Anh'),
        StudentRecord(id: 'SV005', fullName: 'Bùi Quốc Khánh'),
      ],
    ),
  ];

  void clearFeedbackMessage() {
    emit(state.copyWith(clearFeedbackMessage: true));
  }

  void clearErrorMessage() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> refreshFromFirestore() async {
    emit(
      state.copyWith(
        isSyncing: true,
        clearFeedbackMessage: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repository.seedDemoDataIfEmpty(
        lecturerId: lecturerId,
        demoClasses: _seedClasses,
      );

      final classrooms = await _repository.fetchClassesByLecturer(lecturerId);
      final selectedAttendanceClassId =
          _pickSelectedClassId(classrooms, state.selectedAttendanceClassId);
      final selectedGradingClassId =
          _pickSelectedClassId(classrooms, state.selectedGradingClassId);

      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          classes: classrooms,
          selectedAttendanceClassId: selectedAttendanceClassId,
          selectedGradingClassId: selectedGradingClassId,
          isSyncing: false,
          feedbackMessage: 'Đã đồng bộ dữ liệu giảng viên từ Firestore.',
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isSyncing: false,
          errorMessage: 'Không thể đồng bộ Firestore. Đang dùng dữ liệu cục bộ.',
        ),
      );
    }
  }

  void selectAttendanceClass(String classId) {
    emit(
      state.copyWith(
        selectedAttendanceClassId: classId,
        clearFeedbackMessage: true,
      ),
    );
  }

  void selectGradingClass(String classId) {
    emit(
      state.copyWith(
        selectedGradingClassId: classId,
        clearFeedbackMessage: true,
      ),
    );
  }

  void toggleAttendance({
    required String classId,
    required String studentId,
    required bool isPresent,
  }) {
    final nextDraftByClass = Map<String, Map<String, bool>>.from(
      state.attendanceDraftByClass,
    );
    final classDraft =
        Map<String, bool>.from(nextDraftByClass[classId] ?? <String, bool>{});

    classDraft[studentId] = isPresent;
    nextDraftByClass[classId] = classDraft;

    emit(
      state.copyWith(
        attendanceDraftByClass: nextDraftByClass,
        clearFeedbackMessage: true,
      ),
    );
  }

  void markAllAttendanceForSelectedClass(bool isPresent) {
    final classId = state.selectedAttendanceClassId;
    if (classId == null) {
      return;
    }

    final targetClass = _findClassById(classId);
    if (targetClass == null) {
      return;
    }

    final nextDraftByClass = Map<String, Map<String, bool>>.from(
      state.attendanceDraftByClass,
    );

    final draft = <String, bool>{
      for (final student in targetClass.students) student.id: isPresent,
    };
    nextDraftByClass[classId] = draft;

    emit(
      state.copyWith(
        attendanceDraftByClass: nextDraftByClass,
        clearFeedbackMessage: true,
      ),
    );
  }

  Future<void> submitAttendanceSession() async {
    final classId = state.selectedAttendanceClassId;
    if (classId == null) {
      return;
    }

    final targetClass = _findClassById(classId);
    if (targetClass == null) {
      return;
    }

    final classDraft = state.attendanceDraftByClass[classId] ?? const {};
    final updatedStudents = targetClass.students.map((student) {
      final isPresent = classDraft[student.id] ?? false;
      return student.copyWith(
        totalSessions: student.totalSessions + 1,
        attendedSessions: student.attendedSessions + (isPresent ? 1 : 0),
      );
    }).toList();

    final updatedClass = targetClass.copyWith(students: updatedStudents);

    final updatedClassrooms = state.classes.map((classroom) {
      if (classroom.id == classId) {
        return updatedClass;
      }
      return classroom;
    }).toList();

    final nextDraftByClass = Map<String, Map<String, bool>>.from(
      state.attendanceDraftByClass,
    )..remove(classId);

    emit(
      state.copyWith(
        classes: updatedClassrooms,
        attendanceDraftByClass: nextDraftByClass,
        feedbackMessage: 'Đã lưu điểm danh cho buổi học mới.',
        clearErrorMessage: true,
      ),
    );

    final attendanceByStudent = <String, bool>{
      for (final student in targetClass.students)
        student.id: (classDraft[student.id] ?? false),
    };

    emit(state.copyWith(isSyncing: true));

    try {
      await _repository.submitAttendanceSession(
        classId: classId,
        attendanceByStudent: attendanceByStudent,
      );
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isSyncing: false,
          feedbackMessage: 'Đã lưu điểm danh và đồng bộ Firestore.',
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isSyncing: false,
          errorMessage: 'Lưu cục bộ thành công nhưng đồng bộ Firestore thất bại.',
        ),
      );
    }
  }

  Future<void> updateStudentGrade({
    required String classId,
    required String studentId,
    required double midtermScore,
    required double finalScore,
  }) async {
    final targetClass = _findClassById(classId);
    if (targetClass == null) {
      return;
    }

    final updatedStudents = targetClass.students.map((student) {
      if (student.id != studentId) {
        return student;
      }
      return student.copyWith(
        midtermScore: midtermScore,
        finalScore: finalScore,
      );
    }).toList();

    final updatedClass = targetClass.copyWith(students: updatedStudents);

    final updatedClassrooms = state.classes.map((classroom) {
      if (classroom.id == classId) {
        return updatedClass;
      }
      return classroom;
    }).toList();

    emit(
      state.copyWith(
        classes: updatedClassrooms,
        feedbackMessage: 'Đã cập nhật điểm sinh viên $studentId.',
        clearErrorMessage: true,
      ),
    );

    emit(state.copyWith(isSyncing: true));

    try {
      await _repository.updateStudentGrade(
        classId: classId,
        studentId: studentId,
        midtermScore: midtermScore,
        finalScore: finalScore,
      );
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isSyncing: false,
          feedbackMessage: 'Đã cập nhật điểm và đồng bộ Firestore.',
        ),
      );
    } catch (_) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          isSyncing: false,
          errorMessage: 'Cập nhật cục bộ thành công nhưng đồng bộ Firestore thất bại.',
        ),
      );
    }
  }

  String? _pickSelectedClassId(
    List<LecturerClassroom> classrooms,
    String? previousClassId,
  ) {
    if (classrooms.isEmpty) {
      return null;
    }

    if (previousClassId != null) {
      for (final classroom in classrooms) {
        if (classroom.id == previousClassId) {
          return previousClassId;
        }
      }
    }

    return classrooms.first.id;
  }

  LecturerClassroom? _findClassById(String classId) {
    for (final classroom in state.classes) {
      if (classroom.id == classId) {
        return classroom;
      }
    }
    return null;
  }
}
