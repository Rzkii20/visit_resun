class SuvenirModel {
  final String id;
  final String nama;
  final double harga;
  final String gambar;
  final String deskripsi;
  final double rating;
  final int stok;
  final String kontak; // WhatsApp contact

  SuvenirModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.gambar,
    required this.deskripsi,
    required this.rating,
    required this.stok,
    required this.kontak,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'gambar': gambar,
      'deskripsi': deskripsi,
      'rating': rating,
      'stok': stok,
      'kontak': kontak,
    };
  }

  factory SuvenirModel.fromMap(Map<String, dynamic> map) {
    return SuvenirModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      harga: (map['harga'] as num?)?.toDouble() ?? 5000.0,
      gambar: map['gambar'] ?? 'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600',
      deskripsi: map['deskripsi'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.0,
      stok: map['stok'] ?? 10,
      kontak: map['kontak'] ?? '628123456789',
    );
  }

  SuvenirModel copyWith({
    String? id,
    String? nama,
    double? harga,
    String? gambar,
    String? deskripsi,
    double? rating,
    int? stok,
    String? kontak,
  }) {
    return SuvenirModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      gambar: gambar ?? this.gambar,
      deskripsi: deskripsi ?? this.deskripsi,
      rating: rating ?? this.rating,
      stok: stok ?? this.stok,
      kontak: kontak ?? this.kontak,
    );
  }
}
