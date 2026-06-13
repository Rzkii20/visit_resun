import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../models/wisata_model.dart';
import '../../models/homestay_model.dart';
import '../../models/suvenir_model.dart';
import '../../providers/app_state_provider.dart';
import '../../routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCurrentTabType() {
    switch (_tabController.index) {
      case 0:
      case 1:
        return 'wisata';
      case 2:
        return 'homestay';
      case 3:
        return 'suvenir';
      default:
        return 'wisata';
    }
  }

  void _confirmDelete(BuildContext context, String type, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('Hapus Data'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus "$name"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<AppStateProvider>(context, listen: false);
              
              if (type == 'wisata') {
                await provider.deleteWisata(id);
              } else if (type == 'homestay') {
                await provider.deleteHomestay(id);
              } else if (type == 'suvenir') {
                await provider.deleteSuvenir(id);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$name" berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSyncConfirmationDialog(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSyncing = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.cloud_upload_rounded, color: AppConfig.primaryColor),
                  SizedBox(width: 8),
                  Text('Sinkronisasi Data'),
                ],
              ),
              content: isSyncing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(height: 16),
                        CircularProgressIndicator(color: AppConfig.primaryColor),
                        SizedBox(height: 16),
                        Text(
                          'Mengunggah data ke Firestore...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mohon tunggu sebentar.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )
                  : const Text(
                      'Apakah Anda yakin ingin mengunggah seluruh data pariwisata, homestay, dan suvenir Desa Resun ke database Cloud Firestore?\n\nOperasi ini akan memperbarui data Anda secara online.',
                    ),
              actions: isSyncing
                  ? []
                  : [
                      TextButton(
                        child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Sinkronkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          setState(() {
                            isSyncing = true;
                          });
                          try {
                            await provider.syncMockDataToFirebase();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sinkronisasi data lapangan berhasil!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sinkronisasi gagal: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Panel Kelola Data',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          if (AppConfig.useFirebase)
            IconButton(
              icon: const Icon(Icons.sync_rounded, color: Colors.white),
              tooltip: 'Sinkronisasi Data Lapangan',
              onPressed: () => _showSyncConfirmationDialog(context),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConfig.accentColor,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Tempat Wisata', icon: Icon(Icons.pin_drop_rounded, size: 20)),
            Tab(text: 'Paket Wisata', icon: Icon(Icons.backpack_rounded, size: 20)),
            Tab(text: 'Homestay', icon: Icon(Icons.holiday_village_rounded, size: 20)),
            Tab(text: 'Suvenir', icon: Icon(Icons.card_giftcard_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tempat Wisata List View
          _buildItemTabList<WisataModel>(
            items: state.wisataList.where((w) => !w.isPaket).toList(),
            type: 'wisata',
            getName: (w) => w.nama,
            getImage: (w) => w.gambar,
            getSubtitle: (w) => w.kategori,
          ),
          // Paket Wisata List View
          _buildItemTabList<WisataModel>(
            items: state.wisataList.where((w) => w.isPaket).toList(),
            type: 'wisata',
            getName: (w) => w.nama,
            getImage: (w) => w.gambar,
            getSubtitle: (w) => w.kategori,
          ),
          // Homestay List View
          _buildItemTabList<HomestayModel>(
            items: state.homestayList,
            type: 'homestay',
            getName: (h) => h.nama,
            getImage: (h) => h.gambar,
            getSubtitle: (h) => 'Rp ${h.harga.toStringAsFixed(0)}/malam',
          ),
          // Suvenir List View
          _buildItemTabList<SuvenirModel>(
            items: state.suvenirList,
            type: 'suvenir',
            getName: (s) => s.nama,
            getImage: (s) => s.gambar,
            getSubtitle: (s) => 'Rp ${s.harga.toStringAsFixed(0)} - Stok: ${s.stok}',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final activeType = _getCurrentTabType();
          final isPaketDefault = _tabController.index == 1;
          Navigator.pushNamed(
            context,
            AppRoutes.adminForm,
            arguments: {
              'type': activeType,
              'isPaketDefault': isPaketDefault,
            },
          );
        },
        backgroundColor: AppConfig.accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildItemTabList<T>({
    required List<T> items,
    required String type,
    required String Function(T) getName,
    required String Function(T) getImage,
    required String Function(T) getSubtitle,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data tersedia.',
              style: TextStyle(color: AppConfig.textColorSecondary, fontWeight: FontWeight.w600),
            ),
            if (AppConfig.useFirebase) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showSyncConfirmationDialog(context),
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Sinkronisasi Data Lapangan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final name = getName(item);
        final image = getImage(item);
        final subtitle = getSubtitle(item);
        
        // Extracting ID dynamically
        String itemId = '';
        if (item is WisataModel) itemId = item.id;
        if (item is HomestayModel) itemId = item.id;
        if (item is SuvenirModel) itemId = item.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular Image Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 55,
                    height: 55,
                    color: AppConfig.primaryColor,
                    child: const Icon(Icons.broken_image, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConfig.textColorSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Action Button
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.adminForm,
                        arguments: {'type': type, 'data': item},
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Delete Action Button
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDelete(context, type, itemId, name),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


