import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';
import 'base_db_service.dart';

class FirebaseDbService implements BaseDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Wisata ---
  @override
  Future<List<WisataModel>> getWisata() async {
    final query = await _db.collection('wisata').get();
    return query.docs.map((doc) {
      final map = doc.data();
      map['id'] = doc.id;
      return WisataModel.fromMap(map);
    }).toList();
  }

  @override
  Future<void> addWisata(WisataModel wisata) async {
    final docRef = _db.collection('wisata').doc();
    final data = wisata.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
  }

  @override
  Future<void> updateWisata(WisataModel wisata) async {
    await _db.collection('wisata').doc(wisata.id).update(wisata.toMap());
  }

  @override
  Future<void> deleteWisata(String id) async {
    await _db.collection('wisata').doc(id).delete();
  }

  // --- Homestay ---
  @override
  Future<List<HomestayModel>> getHomestays() async {
    final query = await _db.collection('homestay').get();
    return query.docs.map((doc) {
      final map = doc.data();
      map['id'] = doc.id;
      return HomestayModel.fromMap(map);
    }).toList();
  }

  @override
  Future<void> addHomestay(HomestayModel homestay) async {
    final docRef = _db.collection('homestay').doc();
    final data = homestay.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
  }

  @override
  Future<void> updateHomestay(HomestayModel homestay) async {
    await _db.collection('homestay').doc(homestay.id).update(homestay.toMap());
  }

  @override
  Future<void> deleteHomestay(String id) async {
    await _db.collection('homestay').doc(id).delete();
  }

  // --- Suvenir ---
  @override
  Future<List<SuvenirModel>> getSuvenirs() async {
    final query = await _db.collection('suvenir').get();
    return query.docs.map((doc) {
      final map = doc.data();
      map['id'] = doc.id;
      return SuvenirModel.fromMap(map);
    }).toList();
  }

  @override
  Future<void> addSuvenir(SuvenirModel suvenir) async {
    final docRef = _db.collection('suvenir').doc();
    final data = suvenir.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
  }

  @override
  Future<void> updateSuvenir(SuvenirModel suvenir) async {
    await _db.collection('suvenir').doc(suvenir.id).update(suvenir.toMap());
  }

  @override
  Future<void> deleteSuvenir(String id) async {
    await _db.collection('suvenir').doc(id).delete();
  }
}
