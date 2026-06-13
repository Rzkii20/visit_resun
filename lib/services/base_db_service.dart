import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';

abstract class BaseDbService {
  // Wisata CRUD
  Future<List<WisataModel>> getWisata();
  Future<void> addWisata(WisataModel wisata);
  Future<void> updateWisata(WisataModel wisata);
  Future<void> deleteWisata(String id);

  // Homestay CRUD
  Future<List<HomestayModel>> getHomestays();
  Future<void> addHomestay(HomestayModel homestay);
  Future<void> updateHomestay(HomestayModel homestay);
  Future<void> deleteHomestay(String id);

  // Suvenir CRUD
  Future<List<SuvenirModel>> getSuvenirs();
  Future<void> addSuvenir(SuvenirModel suvenir);
  Future<void> updateSuvenir(SuvenirModel suvenir);
  Future<void> deleteSuvenir(String id);
}
