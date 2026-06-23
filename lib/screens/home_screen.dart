import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_state_provider.dart';
import '../routes/app_routes.dart';
import '../screens/main_shell.dart';
import '../widgets/item_card.dart';
import '../models/wisata_model.dart';
import '../widgets/app_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _changeTab(int index) {
    final shellState = context.findAncestorStateOfType<MainNavigationShellState>();
    if (shellState != null) {
      shellState.setTabIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;

    // Filter wisata list based on search query
    final filteredWisata = state.wisataList.where((w) {
      return w.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final filteredTempatWisata = filteredWisata.where((w) => !w.isPaket).toList();

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppConfig.textColorSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'Pengunjung',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppConfig.textColorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Avatar
                  GestureDetector(
                    onTap: () => _changeTab(4), // Go to Profile Tab
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppConfig.primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppConfig.primaryColor,
                        child: Text(
                          state.isAdmin
                              ? 'A'
                              : (user != null && user.name.isNotEmpty)
                                  ? user.name[0].toUpperCase()
                                  : 'P',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Custom Elegant Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: AppConfig.textColorPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari tempat wisata resun...',
                    hintStyle: const TextStyle(
                      color: AppConfig.textColorSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppConfig.primaryColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Popular Destinations (If not searching)
              if (_searchQuery.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Destinasi Terpopuler',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _changeTab(1), // Go to Wisata Tab
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                filteredTempatWisata.isEmpty
                    ? _buildEmptyState()
                    : _buildCarousel(filteredTempatWisata),
                const SizedBox(height: 28),
              ] else ...[
                // Search Results
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hasil Pencarian (${filteredWisata.length})',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                filteredWisata.isEmpty
                    ? _buildEmptyState()
                    : _buildCarousel(filteredWisata),
                const SizedBox(height: 28),
              ],

              // Jelajahi Grid (4 custom cards)
              if (_searchQuery.isEmpty) ...[
                const Text(
                  'Jelajahi Resun',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textColorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.45,
                  children: [
                    _buildGridCard(
                      label: 'Peta Wisata',
                      icon: Icons.map_rounded,
                      imagePath: 'assets/images/air_terjun_resun.png',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                    ),
                    _buildGridCard(
                      label: 'Homestay',
                      icon: Icons.holiday_village_rounded,
                      imagePath: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=600',
                      onTap: () => _changeTab(2), // Homestay Tab
                    ),
                    _buildGridCard(
                      label: 'Suvenir',
                      icon: Icons.card_giftcard_rounded,
                      imagePath: 'https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?q=80&w=600',
                      onTap: () => _changeTab(3), // Suvenir Tab
                    ),
                    _buildGridCard(
                      label: 'Paket Wisata',
                      icon: Icons.explore_rounded,
                      imagePath: 'assets/images/wisata_mangrove_resun.png',
                      onTap: () => _changeTab(1), // Wisata Tab
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],

              // Map GIS Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppConfig.darkGlassGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Navigasi Peta GIS',
                            style: TextStyle(
                              fontFamily: 'serif',
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Temukan koordinat presisi wisata alam secara langsung di lapangan.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppConfig.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Buka Peta',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.pin_drop_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String label,
    required IconData icon,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              AppImage(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppConfig.sageGreen,
                ),
              ),
              // Dark gradient overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.55),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Icon + Label
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Destinasi tidak ditemukan',
              style: TextStyle(
                color: AppConfig.textColorSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(List<WisataModel> list) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return ItemCard(
            title: item.nama,
            imageUrl: item.gambar,
            tag: item.kategori,
            rating: item.rating,
            subtitle: item.jamBuka,
            width: 200,
            height: 250,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.detail,
                arguments: {'type': 'wisata', 'data': item},
              );
            },
          );
        },
      ),
    );
  }
}
