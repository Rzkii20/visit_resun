import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';
import '../routes/app_routes.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  Future<void> _openWhatsApp(BuildContext context, String number, String itemName) async {
    final message = Uri.encodeComponent('Halo, saya tertarik dengan "$itemName" di aplikasi Visit Resun.');
    final url = 'https://wa.me/$number?text=$message';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String type = args['type']; // 'wisata', 'homestay', 'suvenir'
    final dynamic item = args['data'];

    // Pre-cast items at the top of build to avoid inside-list statement declarations!
    final w = type == 'wisata' ? item as WisataModel : null;
    final h = type == 'homestay' ? item as HomestayModel : null;
    final s = type == 'suvenir' ? item as SuvenirModel : null;

    String title = '';
    String imageUrl = '';
    String description = '';
    double rating = 4.0;
    String badgeText = '';

    if (type == 'wisata') {
      title = w!.nama;
      imageUrl = w.gambar;
      description = w.deskripsi;
      rating = w.rating;
      badgeText = w.kategori;
    } else if (type == 'homestay') {
      title = h!.nama;
      imageUrl = h.gambar;
      description = 'Tempat menginap yang nyaman dan ramah lingkungan di Desa Resun. Nikmati keramahan penduduk lokal dan kebudayaan Melayu yang kental selama Anda menginap di sini.';
      rating = h.rating;
      badgeText = 'Rp ${h.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/malam';
    } else if (type == 'suvenir') {
      title = s!.nama;
      imageUrl = s.gambar;
      description = s.deskripsi;
      rating = s.rating;
      badgeText = 'Rp ${s.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Header Panel
            Stack(
              children: [
                Hero(
                  tag: 'img_${item.id}',
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Soft gradient protection on image
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Navigation Floating Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Panel
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppConfig.cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.textColorPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConfig.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Rating Row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppConfig.accentColor, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textColorPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '(Ulasan Wisatawan)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConfig.textColorSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Deskripsi Lengkap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConfig.textColorSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Adaptable Sections based on Type
                    if (type == 'wisata') ...[
                      // Wisata specific info
                      const Text(
                        'Informasi Kunjungan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.access_time_rounded, 'Jam Buka', (item as WisataModel).jamBuka),
                      _buildInfoRow(Icons.confirmation_num_outlined, 'Tiket Masuk', item.tiketMasuk),
                      const SizedBox(height: 24),

                      // GIS Location Card
                      _buildGisCard(context, item.lat, item.lng, title, item.id),
                    ] else if (type == 'homestay' && h != null) ...[
                      // Homestay specific info
                      const Text(
                        'Fasilitas Homestay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: h.fasilitas.map((f) {
                          return Chip(
                            label: Text(f, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            backgroundColor: AppConfig.primaryColor.withOpacity(0.06),
                            side: BorderSide(color: AppConfig.primaryColor.withOpacity(0.15)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // GIS Location Card
                      _buildGisCard(context, h.lat, h.lng, title, h.id),
                      const SizedBox(height: 24),

                      // Order/Booking button
                      ElevatedButton(
                        onPressed: () => _openWhatsApp(context, h.kontak, h.nama),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_rounded),
                            SizedBox(width: 8),
                            Text('Hubungi Pemilik (Booking)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ] else if (type == 'suvenir' && s != null) ...[
                      // Suvenir specific info
                      _buildInfoRow(Icons.inventory_2_outlined, 'Status Ketersediaan', s.stok > 0 ? '${s.stok} unit tersedia' : 'Stok habis'),
                      const SizedBox(height: 24),

                      // Order button
                      ElevatedButton(
                        onPressed: () => _openWhatsApp(context, s.kontak, s.nama),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined),
                            SizedBox(width: 8),
                            Text('Pesan via WhatsApp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppConfig.primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppConfig.textColorSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: AppConfig.textColorPrimary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGisCard(BuildContext context, double lat, double lng, String name, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.pin_drop_rounded, color: Colors.red, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Koordinat Lokasi (GIS)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latitude: ${lat.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
              ),
              Text(
                'Longitude: ${lng.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConfig.textColorPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.map,
                arguments: {'lat': lat, 'lng': lng, 'selectedId': id},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buka di Peta GIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
