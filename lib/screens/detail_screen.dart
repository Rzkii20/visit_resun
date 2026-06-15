import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../models/suvenir_model.dart';
import '../routes/app_routes.dart';
import '../widgets/app_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

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

    final w = type == 'wisata' ? item as WisataModel : null;
    final h = type == 'homestay' ? item as HomestayModel : null;
    final s = type == 'suvenir' ? item as SuvenirModel : null;

    String title = '';
    String imageUrl = '';
    String description = '';
    double rating = 4.0;
    String tagLabel = '';
    
    // 3 Cards info data
    IconData infoIcon1 = Icons.info;
    String infoLabel1 = '';
    String infoVal1 = '';

    IconData infoIcon2 = Icons.info;
    String infoLabel2 = '';
    String infoVal2 = '';

    IconData infoIcon3 = Icons.info;
    String infoLabel3 = '';
    String infoVal3 = '';

    if (type == 'wisata') {
      title = w!.nama;
      imageUrl = w.gambar;
      description = w.deskripsi;
      rating = w.rating;
      tagLabel = w.isPaket ? 'Paket Wisata' : w.kategori;

      infoIcon1 = Icons.access_time_rounded;
      infoLabel1 = 'Jam Buka';
      infoVal1 = w.jamBuka;

      infoIcon2 = Icons.pin_drop_rounded;
      infoLabel2 = 'GIS Peta';
      infoVal2 = w.isPaket ? 'No GPS' : '${w.lat.toStringAsFixed(3)}, ${w.lng.toStringAsFixed(3)}';

      infoIcon3 = Icons.confirmation_number_rounded;
      infoLabel3 = 'Tiket';
      infoVal3 = w.tiketMasuk;
    } else if (type == 'homestay') {
      title = h!.nama;
      imageUrl = h.gambar;
      description = 'Nikmati ketenangan dan kenyamanan menginap di homestay Desa Wisata Resun. Tempat ideal untuk beristirahat bersama keluarga sambil menikmati alam pedesaan yang sejuk dan asri.';
      rating = h.rating;
      tagLabel = 'Penginapan';

      infoIcon1 = Icons.payments_rounded;
      infoLabel1 = 'Harga';
      infoVal1 = 'Rp ${h.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

      infoIcon2 = Icons.star_rounded;
      infoLabel2 = 'Rating';
      infoVal2 = '${h.rating.toStringAsFixed(1)} / 5.0';

      infoIcon3 = Icons.checklist_rounded;
      infoLabel3 = 'Fasilitas';
      infoVal3 = '${h.fasilitas.length} Fitur';
    } else if (type == 'suvenir') {
      title = s!.nama;
      imageUrl = s.gambar;
      description = s.deskripsi;
      rating = s.rating;
      tagLabel = 'Suvenir / Produk';

      infoIcon1 = Icons.payments_rounded;
      infoLabel1 = 'Harga';
      infoVal1 = 'Rp ${s.harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

      infoIcon2 = Icons.inventory_rounded;
      infoLabel2 = 'Stok';
      infoVal2 = s.stok > 0 ? '${s.stok} unit' : 'Habis';

      infoIcon3 = Icons.star_rounded;
      infoLabel3 = 'Rating';
      infoVal3 = '${s.rating.toStringAsFixed(1)} / 5.0';
    }

    final isBudaya = tagLabel.toLowerCase() == 'budaya' || tagLabel.toLowerCase() == 'sejarah';
    final tagBg = isBudaya ? AppConfig.tagBudayaBg : AppConfig.tagAlamBg;
    final tagText = isBudaya ? AppConfig.tagBudayaText : AppConfig.tagAlamText;

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image Panel with floating pill
            Stack(
              children: [
                Hero(
                  tag: 'img_${item.id}',
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: getAppImageProvider(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 340,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Back Button & Favorite Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: AppConfig.textColorPrimary,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          radius: 20,
                          child: IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating Rating Badge Pill over Image
                Positioned(
                  bottom: 46,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppConfig.accentColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppConfig.textColorPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(4.8)', // Mock review average count
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Panel (Translate upward slightly to overlap image)
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and tag row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.textColorPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tagLabel,
                            style: TextStyle(
                              color: tagText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Location Subtitle
                    if (type == 'wisata' && !w!.isPaket) ...[
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.pin_drop_rounded, size: 14, color: AppConfig.primaryColor),
                          SizedBox(width: 4),
                          Text(
                            'Desa Wisata Resun, Kabupaten Lingga',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppConfig.textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 3-Card info row
                    Row(
                      children: [
                        _buildInfoCard(infoIcon1, infoLabel1, infoVal1),
                        const SizedBox(width: 10),
                        _buildInfoCard(infoIcon2, infoLabel2, infoVal2),
                        const SizedBox(width: 10),
                        _buildInfoCard(infoIcon3, infoLabel3, infoVal3),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Deskripsi Wisata',
                      style: TextStyle(
                        fontFamily: 'serif',
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

                    // Specialized interactive widgets per type
                    if (type == 'wisata' && w != null && !w.isPaket) ...[
                      _buildCoordinatesInfo(context, w.lat, w.lng, w.nama, w.id),
                    ] else if (type == 'homestay' && h != null) ...[
                      const Text(
                        'Fasilitas Lengkap',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: h.fasilitas.map((f) {
                          return Chip(
                            label: Text(
                              f,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConfig.textColorPrimary),
                            ),
                            backgroundColor: AppConfig.backgroundColor,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      _buildCoordinatesInfo(context, h.lat, h.lng, h.nama, h.id),
                      const SizedBox(height: 24),
                      // Booking Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _openWhatsApp(context, h.kontak, h.nama),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Hubungi Pemilik via WhatsApp',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (type == 'suvenir' && s != null) ...[
                      // Order Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _openWhatsApp(context, s.kontak, s.nama),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConfig.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Pesan via WhatsApp Sekarang',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppConfig.sageGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppConfig.primaryColor, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppConfig.textColorSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppConfig.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesInfo(BuildContext context, double lat, double lng, String name, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConfig.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.map,
                arguments: {'lat': lat, 'lng': lng, 'selectedId': id},
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tampilkan Di Peta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
