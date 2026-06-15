import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';
import 'base_db_service.dart';

class MockDbService implements BaseDbService {
  static const String _keyWisata = 'mock_wisata_v6';
  static const String _keyHomestays = 'mock_homestays_v6';
  static const String _keySuvenirs = 'mock_suvenirs_v6';

  Future<void> _seedIfEmpty() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Seed Wisata
    if (!prefs.containsKey(_keyWisata)) {
      final initialWisata = [
        // --- Tempat Wisata ---
        WisataModel(
          id: 'w_1',
          nama: 'Air Terjun Resun',
          deskripsi: 'Air terjun alami terindah di Kabupaten Lingga. Memiliki lima tingkatan air terjun dengan kolam alami berair sangat jernih dan sejuk, dikelilingi hutan hujan tropis yang asri. Sangat cocok untuk berenang dan melepas penat.',
          gambar: 'assets/images/air_terjun_resun.png',
          kategori: 'Tempat Wisata',
          lat: -0.14746797422103605,
          lng: 104.60392575314476,
          rating: 4.9,
          jamBuka: '07:30 - 17:30 WIB',
          tiketMasuk: 'Rp 5.000',
          isPaket: false,
        ),
        WisataModel(
          id: 'w_2',
          nama: 'Tour Mangrove & Kunang-Kunang',
          deskripsi: 'Menelusuri keasrian ekosistem hutan bakau Sungai Resun menggunakan perahu kayu tradisional milik nelayan setempat. Nikmati kesejukan udara, suara burung langka, pemandangan sunset mangrove, dan pertunjukan jutaan kunang-kunang di malam hari.',
          gambar: 'assets/images/wisata_mangrove_resun.png',
          kategori: 'Tempat Wisata',
          lat: -0.12848976817640548,
          lng: 104.61745140167176,
          rating: 4.8,
          jamBuka: '16:00 - 21:00 WIB',
          tiketMasuk: 'Rp 100.000 / perahu',
          isPaket: false,
        ),
        WisataModel(
          id: 'w_3',
          nama: 'Sungai Kem',
          deskripsi: 'Sungai jernih alami di Desa Resun yang menyajikan keindahan ekosistem air tawar tropis, dikelilingi vegetasi rimbun yang asri. Sangat ideal untuk wisata susur sungai, bermain air, dan bersantai menikmati suasana pedesaan yang sejuk.',
          gambar: 'assets/images/sungai_kim_resun.png',
          kategori: 'Tempat Wisata',
          lat: -0.13696218741310473,
          lng: 104.60919850419728,
          rating: 4.6,
          jamBuka: '08:00 - 17:00 WIB',
          tiketMasuk: 'Gratis',
          isPaket: false,
        ),

        // --- Paket Wisata ---
        WisataModel(
          id: 'w_4',
          nama: 'Camping Paket Hemat',
          deskripsi: 'Paket berkemah praktis di camping ground Air Terjun Resun. Sudah termasuk sewa tenda dome standar untuk 2 orang, matras tidur, serta akses fasilitas umum dan area api unggun.',
          gambar: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?q=80&w=600',
          kategori: 'Petualangan',
          lat: -0.147468,
          lng: 104.603926,
          rating: 4.5,
          jamBuka: '24 Jam',
          tiketMasuk: 'Rp 75.000 / malam',
          isPaket: true,
        ),
        WisataModel(
          id: 'w_5',
          nama: 'Camping Paket Sultan',
          deskripsi: 'Glamping premium lengkap di dekat Air Terjun Resun. Dilengkapi tenda dome berukuran besar, kasur empuk dengan selimut, dekorasi lampu estetik, fasilitas pemanggang barbecue (BBQ), dan sarapan pagi Melayu.',
          gambar: 'https://images.unsplash.com/photo-1537905569824-f89f14cceb68?q=80&w=600',
          kategori: 'Petualangan',
          lat: -0.147468,
          lng: 104.603926,
          rating: 4.9,
          jamBuka: '24 Jam',
          tiketMasuk: 'Rp 250.000 / malam',
          isPaket: true,
        ),
        WisataModel(
          id: 'w_6',
          nama: 'Paket 3 Day 2 Night Tour',
          deskripsi: 'Paket petualangan penuh selama 3 hari 2 malam di Desa Resun. Termasuk penginapan di homestay, pemandu lokal, makan, tiket wisata air terjun, susur sungai mangrove, dan workshop kerajinan desa.',
          gambar: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600',
          kategori: 'Tour Lengkap',
          lat: -0.147468,
          lng: 104.603926,
          rating: 4.9,
          jamBuka: '08:00 - 17:00 WIB',
          tiketMasuk: 'Rp 750.000 / paket',
          isPaket: true,
        ),
        WisataModel(
          id: 'w_7',
          nama: 'Wisata Edukasi Buah Salak',
          deskripsi: 'Belajar budidaya buah salak khas Desa Resun di perkebunan salak warga. Pengunjung dapat memetik langsung buah dari pohonnya dan mencoba mengawinkan bunga salak dipandu petani lokal.',
          gambar: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600',
          kategori: 'Agrowisata',
          lat: -0.140000,
          lng: 104.605000,
          rating: 4.7,
          jamBuka: '08:00 - 16:00 WIB',
          tiketMasuk: 'Rp 15.000',
          isPaket: true,
        ),
        WisataModel(
          id: 'w_8',
          nama: 'Edukasi Kerajinan Rajut Tas',
          deskripsi: 'Kunjungi dan pelajari langsung proses pembuatan tas rajut handmade oleh ibu-ibu kreatif Desa Resun. Pelajari teknik-teknik rajutan tradisional dan bawa pulang gantungan kunci rajut buatan sendiri.',
          gambar: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=600',
          kategori: 'Budaya',
          lat: -0.138000,
          lng: 104.608000,
          rating: 4.6,
          jamBuka: '09:00 - 15:00 WIB',
          tiketMasuk: 'Rp 20.000',
          isPaket: true,
        ),
        WisataModel(
          id: 'w_9',
          nama: 'Edukasi Kerajinan Bambu',
          deskripsi: 'Workshop anyaman bambu bersama pengrajin lokal berpengalaman. Anda akan belajar mengolah bambu menjadi tempat tisu, keranjang belanja, atau hiasan meja estetik.',
          gambar: 'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600',
          kategori: 'Budaya',
          lat: -0.139000,
          lng: 104.606000,
          rating: 4.7,
          jamBuka: '09:00 - 16:00 WIB',
          tiketMasuk: 'Rp 25.000',
          isPaket: true,
        ),
      ];
      await prefs.setString(_keyWisata, json.encode(initialWisata.map((e) => e.toMap()).toList()));
    }

    // 2. Seed Homestays
    if (!prefs.containsKey(_keyHomestays)) {
      final initialHomestays = [
        HomestayModel(
          id: 'h_1',
          nama: 'Homestay Pak Itam',
          harga: 150000.0,
          fasilitas: ['WiFi', 'AC', 'Kamar Mandi Dalam', 'Sarapan Pagi Melayu', 'Kopi & Teh Gratis', 'Parkir'],
          gambar: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600',
          lat: -0.146500,
          lng: 104.604200,
          rating: 4.8,
          kontak: '6282268875837',
        ),
        HomestayModel(
          id: 'h_2',
          nama: 'Homestay Bang Adek',
          harga: 130000.0,
          fasilitas: ['Kipas Angin', 'Kamar Mandi Dalam', 'TV Bersama', 'Parkir Motor', 'Dapur Bersama', 'Setrika'],
          gambar: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600',
          lat: -0.148000,
          lng: 104.602500,
          rating: 4.6,
          kontak: '6282268875837',
        ),
        HomestayModel(
          id: 'h_3',
          nama: 'Homestay Mak Wati',
          harga: 140000.0,
          fasilitas: ['WiFi', 'Kipas Angin', 'Kamar Mandi Luar', 'Sarapan Pagi Melayu', 'Suasana Asri Rumah Panggung', 'Jemuran'],
          gambar: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=600',
          lat: -0.145800,
          lng: 104.605100,
          rating: 4.7,
          kontak: '6282268875837',
        ),
      ];
      await prefs.setString(_keyHomestays, json.encode(initialHomestays.map((e) => e.toMap()).toList()));
    }

    // 3. Seed Suvenirs
    if (!prefs.containsKey(_keySuvenirs)) {
      final initialSuvenirs = [
        SuvenirModel(
          id: 's_1',
          nama: 'Kue Meskot Khas Resun',
          harga: 20000.0,
          gambar: 'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600',
          deskripsi: 'Kue kering tradisional khas Kabupaten Lingga dengan cita rasa gurih manis bertabur wijen yang diolah secara turun-temurun oleh masyarakat Desa Resun. Sangat lezat dipadukan dengan teh hangat.',
          rating: 4.9,
          stok: 40,
          kontak: '6282268875837',
        ),
        SuvenirModel(
          id: 's_2',
          nama: 'Buah Keruing Segar',
          harga: 15000.0,
          gambar: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600',
          deskripsi: 'Buah hutan musiman eksotis khas Desa Resun. Memiliki rasa asam manis menyegarkan yang unik dan berkhasiat tinggi bagi kesehatan tubuh.',
          rating: 4.5,
          stok: 15,
          kontak: '628987654321',
        ),
        SuvenirModel(
          id: 's_3',
          nama: 'Lakse Sagu Khas Resun',
          harga: 12000.0,
          gambar: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=600',
          deskripsi: 'Mie sagu khas Melayu yang diproses langsung dari sagu pohon asli Desa Resun. Disajikan kering atau kuah ikan bumbu kari yang pedas gurih nan menggugah selera.',
          rating: 4.8,
          stok: 30,
          kontak: '6282268875837',
        ),
        SuvenirModel(
          id: 's_4',
          nama: 'Durian Daun Resun',
          harga: 45000.0,
          gambar: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600',
          deskripsi: 'Durian hutan lokal unggulan asli Desa Resun. Daging buahnya berwarna kuning tebal, bertekstur legit lembut, dengan perpaduan rasa sangat manis dan sedikit pahit khas.',
          rating: 5.0,
          stok: 8,
          kontak: '628123456789',
        ),
        SuvenirModel(
          id: 's_5',
          nama: 'Kerajinan Anyaman Bambu',
          harga: 35000.0,
          gambar: 'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600',
          deskripsi: 'Peralatan rumah tangga, tempat tisu, dan vas bunga estetik yang dibuat dengan tangan terampil dari bambu hutan alami Desa Resun. Kuat, rapi, dan bernilai seni tinggi.',
          rating: 4.7,
          stok: 20,
          kontak: '628987654321',
        ),
        SuvenirModel(
          id: 's_6',
          nama: 'Rajutan Tangan Ibu Desa',
          harga: 75000.0,
          gambar: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=600',
          deskripsi: 'Tas rajut, gantungan kunci, dan aksesoris kerajinan rajutan buatan tangan ibu-ibu kreatif Desa Resun. Setiap produk bersifat unik dan ramah lingkungan.',
          rating: 4.8,
          stok: 12,
          kontak: '6282268875837',
        ),
      ];
      await prefs.setString(_keySuvenirs, json.encode(initialSuvenirs.map((e) => e.toMap()).toList()));
    }
  }

  // --- Wisata CRUD Implementation ---
  @override
  Future<List<WisataModel>> getWisata() async {
    await _seedIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyWisata);
    if (data != null) {
      final List<dynamic> list = json.decode(data);
      return list.map((e) => WisataModel.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  @override
  Future<void> addWisata(WisataModel wisata) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWisata();
    
    // Add item with generated ID if empty
    final newItem = wisata.copyWith(
      id: wisata.id.isEmpty ? 'w_${DateTime.now().millisecondsSinceEpoch}' : wisata.id,
    );
    items.add(newItem);
    
    await prefs.setString(_keyWisata, json.encode(items.map((e) => e.toMap()).toList()));
  }

  @override
  Future<void> updateWisata(WisataModel wisata) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWisata();
    final index = items.indexWhere((element) => element.id == wisata.id);
    if (index != -1) {
      items[index] = wisata;
      await prefs.setString(_keyWisata, json.encode(items.map((e) => e.toMap()).toList()));
    }
  }

  @override
  Future<void> deleteWisata(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getWisata();
    items.removeWhere((element) => element.id == id);
    await prefs.setString(_keyWisata, json.encode(items.map((e) => e.toMap()).toList()));
  }

  // --- Homestay CRUD Implementation ---
  @override
  Future<List<HomestayModel>> getHomestays() async {
    await _seedIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyHomestays);
    if (data != null) {
      final List<dynamic> list = json.decode(data);
      return list.map((e) => HomestayModel.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  @override
  Future<void> addHomestay(HomestayModel homestay) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHomestays();
    
    final newItem = homestay.copyWith(
      id: homestay.id.isEmpty ? 'h_${DateTime.now().millisecondsSinceEpoch}' : homestay.id,
    );
    items.add(newItem);
    
    await prefs.setString(_keyHomestays, json.encode(items.map((e) => e.toMap()).toList()));
  }

  @override
  Future<void> updateHomestay(HomestayModel homestay) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHomestays();
    final index = items.indexWhere((element) => element.id == homestay.id);
    if (index != -1) {
      items[index] = homestay;
      await prefs.setString(_keyHomestays, json.encode(items.map((e) => e.toMap()).toList()));
    }
  }

  @override
  Future<void> deleteHomestay(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHomestays();
    items.removeWhere((element) => element.id == id);
    await prefs.setString(_keyHomestays, json.encode(items.map((e) => e.toMap()).toList()));
  }

  // --- Suvenir CRUD Implementation ---
  @override
  Future<List<SuvenirModel>> getSuvenirs() async {
    await _seedIfEmpty();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keySuvenirs);
    if (data != null) {
      final List<dynamic> list = json.decode(data);
      return list.map((e) => SuvenirModel.fromMap(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  @override
  Future<void> addSuvenir(SuvenirModel suvenir) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getSuvenirs();
    
    final newItem = suvenir.copyWith(
      id: suvenir.id.isEmpty ? 's_${DateTime.now().millisecondsSinceEpoch}' : suvenir.id,
    );
    items.add(newItem);
    
    await prefs.setString(_keySuvenirs, json.encode(items.map((e) => e.toMap()).toList()));
  }

  @override
  Future<void> updateSuvenir(SuvenirModel suvenir) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getSuvenirs();
    final index = items.indexWhere((element) => element.id == suvenir.id);
    if (index != -1) {
      items[index] = suvenir;
      await prefs.setString(_keySuvenirs, json.encode(items.map((e) => e.toMap()).toList()));
    }
  }

  @override
  Future<void> deleteSuvenir(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getSuvenirs();
    items.removeWhere((element) => element.id == id);
    await prefs.setString(_keySuvenirs, json.encode(items.map((e) => e.toMap()).toList()));
  }
}
