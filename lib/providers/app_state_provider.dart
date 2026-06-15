import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';
import '../services/base_auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/base_db_service.dart';
import '../services/mock_db_service.dart';
import '../services/firebase_db_service.dart';

class AppStateProvider extends ChangeNotifier {
  late final BaseAuthService _authService;
  late final BaseDbService _dbService;

  UserModel? _currentUser;
  bool _isLoading = false;

  List<WisataModel> _wisataList = [];
  List<HomestayModel> _homestayList = [];
  List<SuvenirModel> _suvenirList = [];

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isGuest => _currentUser?.role == 'guest';

  List<WisataModel> get wisataList => _wisataList;
  List<HomestayModel> get homestayList => _homestayList;
  List<SuvenirModel> get suvenirList => _suvenirList;

  AppStateProvider() {
    _initializeServices();
  }

  void _initializeServices() {
    if (AppConfig.useFirebase) {
      _authService = FirebaseAuthService();
      _dbService = FirebaseDbService();
    } else {
      _authService = MockAuthService();
      _dbService = MockDbService();
    }
    // Check if user is already logged in
    checkLoginSession();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Auth Methods ---
  Future<void> checkLoginSession() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
    if (_currentUser != null) {
      loadAllData();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        await loadAllData();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
    }
    _setLoading(false);
    return false;
  }

  Future<void> loginAsGuest() async {
    _setLoading(true);
    _currentUser = UserModel(
      uid: 'guest',
      name: 'Tamu / Pengunjung',
      email: 'tamu@visitresun.com',
      role: 'guest',
      photo: 'https://api.dicebear.com/7.x/adventurer/svg?seed=Guest',
    );
    notifyListeners();
    try {
      await loadAllData();
    } catch (e) {
      debugPrint('Error loading data for guest: $e');
    }
    _setLoading(false);
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _setLoading(true);
    try {
      final user = await _authService.register(name, email, password, role);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        await loadAllData();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      _setLoading(false);
      rethrow;
    }
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _currentUser = null;
    _wisataList.clear();
    _homestayList.clear();
    _suvenirList.clear();
    _setLoading(false);
  }

  // --- Load Data Methods ---
  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadWisata(),
        loadHomestays(),
        loadSuvenirs(),
      ]);
    } catch (e) {
      debugPrint('Load Data Error: $e');
    }
    _setLoading(false);
  }

  Future<void> loadWisata() async {
    _wisataList = await _dbService.getWisata();
    notifyListeners();
  }

  Future<void> loadHomestays() async {
    _homestayList = await _dbService.getHomestays();
    notifyListeners();
  }

  Future<void> loadSuvenirs() async {
    _suvenirList = await _dbService.getSuvenirs();
    notifyListeners();
  }

  Future<void> syncMockDataToFirebase() async {
    _setLoading(true);
    try {
      final mockDb = MockDbService();
      final mockWisata = await mockDb.getWisata();
      final mockHomestays = await mockDb.getHomestays();
      final mockSuvenirs = await mockDb.getSuvenirs();

      if (_dbService is FirebaseDbService) {
        final firestore = FirebaseFirestore.instance;

        // Sync wisata
        for (var item in mockWisata) {
          await firestore.collection('wisata').doc(item.id).set(item.toMap());
        }
        // Sync homestays
        for (var item in mockHomestays) {
          await firestore.collection('homestay').doc(item.id).set(item.toMap());
        }
        // Sync suvenirs
        for (var item in mockSuvenirs) {
          await firestore.collection('suvenir').doc(item.id).set(item.toMap());
        }

        await loadAllData();
      } else {
        throw Exception("Aplikasi sedang tidak menggunakan Firebase.");
      }
    } catch (e) {
      debugPrint('Sync Mock Data Error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> uploadImage(XFile file, String folder) async {
    if (AppConfig.useFirebase) {
      try {
        final bytes = await file.readAsBytes();
        final extension = file.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
        
        final metadata = SettableMetadata(contentType: 'image/${extension.toLowerCase() == 'jpg' ? 'jpeg' : extension}');
        await ref.putData(bytes, metadata);
        return await ref.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image to Firebase: $e. Falling back to local base64.');
        return _fallbackToBase64(file);
      }
    } else {
      return _fallbackToBase64(file);
    }
  }

  Future<String> _fallbackToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final extension = file.name.split('.').last.toLowerCase();
      final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error loading local image: $e');
      return 'https://images.unsplash.com/photo-1508459855340-fb63ac591728?q=80&w=600';
    }
  }


  Future<void> updateProfilePhoto(XFile file) async {
    _setLoading(true);
    try {
      final url = await uploadImage(file, 'profiles');
      
      if (AppConfig.useFirebase) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePhotoURL(url);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'photo': url});
        }
      }
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(photo: url);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserName(String newName) async {
    _setLoading(true);
    try {
      if (AppConfig.useFirebase) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(newName);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'name': newName}, SetOptions(merge: true));
        }
      } else {
        // Update in SharedPreferences (mock auth)
        final prefs = await SharedPreferences.getInstance();
        final usersStr = prefs.getString('all_users');
        if (usersStr != null) {
          final List<dynamic> usersList = json.decode(usersStr);
          for (int i = 0; i < usersList.length; i++) {
            final map = Map<String, dynamic>.from(usersList[i]);
            if (map['uid'] == _currentUser?.uid) {
              map['name'] = newName;
              usersList[i] = map;
              break;
            }
          }
          await prefs.setString('all_users', json.encode(usersList));
        }
        // Update current_user cache
        if (_currentUser != null) {
          final updated = _currentUser!.copyWith(name: newName);
          await prefs.setString('current_user', json.encode(updated.toMap()));
        }
      }

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(name: newName);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- Wisata CRUD ---
  Future<void> addWisata(WisataModel wisata) async {
    _setLoading(true);
    await _dbService.addWisata(wisata);
    await loadWisata();
    _setLoading(false);
  }

  Future<void> updateWisata(WisataModel wisata) async {
    _setLoading(true);
    await _dbService.updateWisata(wisata);
    await loadWisata();
    _setLoading(false);
  }

  Future<void> deleteWisata(String id) async {
    _setLoading(true);
    await _dbService.deleteWisata(id);
    await loadWisata();
    _setLoading(false);
  }

  // --- Homestay CRUD ---
  Future<void> addHomestay(HomestayModel homestay) async {
    _setLoading(true);
    await _dbService.addHomestay(homestay);
    await loadHomestays();
    _setLoading(false);
  }

  Future<void> updateHomestay(HomestayModel homestay) async {
    _setLoading(true);
    await _dbService.updateHomestay(homestay);
    await loadHomestays();
    _setLoading(false);
  }

  Future<void> deleteHomestay(String id) async {
    _setLoading(true);
    await _dbService.deleteHomestay(id);
    await loadHomestays();
    _setLoading(false);
  }

  // --- Suvenir CRUD ---
  Future<void> addSuvenir(SuvenirModel suvenir) async {
    _setLoading(true);
    await _dbService.addSuvenir(suvenir);
    await loadSuvenirs();
    _setLoading(false);
  }

  Future<void> updateSuvenir(SuvenirModel suvenir) async {
    _setLoading(true);
    await _dbService.updateSuvenir(suvenir);
    await loadSuvenirs();
    _setLoading(false);
  }

  Future<void> deleteSuvenir(String id) async {
    _setLoading(true);
    await _dbService.deleteSuvenir(id);
    await loadSuvenirs();
    _setLoading(false);
  }
}
