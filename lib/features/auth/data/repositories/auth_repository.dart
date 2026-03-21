import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String email, String password) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user != null) {
        // Fetch dữ liệu phân quyền từ collection users
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, user.uid);
        } else {
          // Fallback tạo model tạm nếu tài khoản có mà chưa có document
          return UserModel(uid: user.uid, email: user.email ?? email, role: 'student');
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // TODO: TẠM THỜI - Nút bấm trên UI gọi hàm này để tạo sẵn tài khoản test cho Giảng viên & Sinh viên
  Future<void> seedInitialData() async {
    try {
      // 1. Sinh viên
      User? studentUser;
      try {
        final c1 = await _firebaseAuth.createUserWithEmailAndPassword(email: 'student@gmail.com', password: 'password123');
        studentUser = c1.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final c1 = await _firebaseAuth.signInWithEmailAndPassword(email: 'student@gmail.com', password: 'password123');
          studentUser = c1.user;
        } else rethrow;
      }
      if (studentUser != null) {
        await _firestore.collection('users').doc(studentUser.uid).set({'email': 'student@gmail.com', 'role': 'student'});
      }

      // 2. Giảng viên
      User? lecturerUser;
      try {
        final c2 = await _firebaseAuth.createUserWithEmailAndPassword(email: 'lecturer@gmail.com', password: 'password123');
        lecturerUser = c2.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final c2 = await _firebaseAuth.signInWithEmailAndPassword(email: 'lecturer@gmail.com', password: 'password123');
          lecturerUser = c2.user;
        } else rethrow;
      }
      if (lecturerUser != null) {
        await _firestore.collection('users').doc(lecturerUser.uid).set({'email': 'lecturer@gmail.com', 'role': 'lecturer'});
      }

      await _firebaseAuth.signOut(); // Trở về trạng thái chưa đăng nhập
    } catch (e) {
      throw Exception('Lỗi tạo mẫu: $e');
    }
  }
}
