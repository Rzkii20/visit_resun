class HomestayModel {
  final String id;
  final String nama;
  final double harga;
  final List<String> fasilitas;
  final String gambar;
  final double lat;
  final double lng;
  final double rating;
  final String kontak; // WhatsApp contact

  HomestayModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.fasilitas,
    required this.gambar,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.kontak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'fasilitas': fasilitas,
      'gambar': gambar,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'kontak': kontak,
    };
  }

  factory HomestayModel.fromMap(Map<String, dynamic> map) {
    return HomestayModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      harga: (map['harga'] as num?)?.toDouble() ?? 100000.0,
      fasilitas: List<String>.from(map['fasilitas'] ?? []),
      gambar: map['gambar'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.0,
      kontak: map['kontak'] ?? '628123456789',
    );
  }

  HomestayModel copyWith({
    String? id,
    String? nama,
    double? harga,
    List<String>? fasilitas,
    String? gambar,
    double? lat,
    double? lng,
    double? rating,
    String? kontak,
  }) {
    return HomestayModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      fasilitas: fasilitas ?? this.fasilitas,
      gambar: gambar ?? this.gambar,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      kontak: kontak ?? this.kontak,
    );
  }
}
