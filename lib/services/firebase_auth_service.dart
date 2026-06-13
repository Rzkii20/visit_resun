import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'base_auth_service.dart';

class FirebaseAuthService implements BaseAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan. Silahkan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silahkan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silahkan login atau gunakan email lain.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silahkan coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan. Silahkan hubungi admin.';
      case 'permission-denied':
        return 'Akses ditolak ke database. Silahkan hubungi admin untuk mengatur Firestore rules.';
      default:
        return 'Terjadi kesalahan: $code. Silahkan coba lagi.';
    }
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final doc = await _db
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        } else {
          return UserModel(
            uid: credential.user!.uid,
            name: credential.user!.displayName ?? 'Pengunjung',
            email: credential.user!.email ?? email,
            role: 'user',
            photo:
                credential.user!.photoURL ??
                'https://api.dicebear.com/7.x/adventurer/svg?seed=User',
          );
        }
      }
      return null;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<UserModel?> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);

        final newUser = UserModel(
          uid: credential.user!.uid,
          name: name,
          email: email,
          role: 'user', // Enforce role as 'user' for safety
          photo: 'https://api.dicebear.com/7.x/adventurer/svg?seed=$name',
        );

        // Simpan ke Firestore
        try {
          await _db.collection('users').doc(newUser.uid).set(newUser.toMap());
        } catch (e) {
          // Jika Firestore error, beri notifikasi tapi user tetap terdaftar di Auth
          debugPrint('Firestore error: $e');
          throw Exception(
            'Registrasi berhasil di Auth tapi gagal simpan profil ke database. Silahkan hubungi admin untuk mengatur Firestore rules.',
          );
        }
        return newUser;
      }
      return null;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('permission-denied')) {
        throw Exception(_getErrorMessage('permission-denied'));
      }
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Pengunjung',
        email: user.email ?? '',
        role: 'user',
        photo:
            user.photoURL ??
            'https://api.dicebear.com/7.x/adventurer/svg?seed=User',
      );
    }
    return null;
  }
}
