class WisataModel {
  final String id;
  final String nama;
  final String deskripsi;
  final String gambar;
  final String kategori; // e.g., 'Alam', 'Budaya', 'Sejarah', 'Kuliner'
  final double lat;
  final double lng;
  final double rating;
  final String jamBuka;
  final String tiketMasuk;
  final bool isPaket;

  WisataModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.jamBuka,
    required this.tiketMasuk,
    this.isPaket = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori': kategori,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'jamBuka': jamBuka,
      'tiketMasuk': tiketMasuk,
      'isPaket': isPaket,
    };
  }

  factory WisataModel.fromMap(Map<String, dynamic> map) {
    return WisataModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambar: map['gambar'] ?? 'https://images.unsplash.com/photo-1508459855340-fb63ac591728?q=80&w=600',
      kategori: map['kategori'] ?? 'Alam',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.0,
      jamBuka: map['jamBuka'] ?? '08:00 - 17:00 WIB',
      tiketMasuk: map['tiketMasuk'] ?? 'Gratis',
      isPaket: map['isPaket'] ?? false,
    );
  }

  // Create a copy of the model with modified fields
  WisataModel copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    String? gambar,
    String? kategori,
    double? lat,
    double? lng,
    double? rating,
    String? jamBuka,
    String? tiketMasuk,
    bool? isPaket,
  }) {
    return WisataModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      gambar: gambar ?? this.gambar,
      kategori: kategori ?? this.kategori,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      jamBuka: jamBuka ?? this.jamBuka,
      tiketMasuk: tiketMasuk ?? this.tiketMasuk,
      isPaket: isPaket ?? this.isPaket,
    );
  }
}
