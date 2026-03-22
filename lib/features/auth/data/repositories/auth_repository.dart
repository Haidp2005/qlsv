import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> login(String username, String password) async {
    try {
      String email = username.trim();
      bool isLecturerFormat = false;

      // Giảng viên gõ chữ gv, sinh viên gõ sv
      if (!email.contains('@')) {
        isLecturerFormat = email.toLowerCase().startsWith('gv') || email.toLowerCase() == 'lecturer';
        email = '$email@app.edu.vn'.toLowerCase();
      }

      UserCredential credential;
      try {
        credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // Tự động Đăng ký nếu chưa tồn tại
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          credential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final User? user = credential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, user.uid);
        } else {
          final role = isLecturerFormat ? 'lecturer' : 'student';
          final newUser = UserModel(uid: user.uid, email: user.email ?? email, role: role);
          // Lưu vào Firestore mapping UID tới studentId cứng
          await _firestore.collection('users').doc(user.uid).set({
            'email': newUser.email,
            'role': newUser.role,
            'studentId': username.trim().toUpperCase(),
          });
          return newUser;
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
}
