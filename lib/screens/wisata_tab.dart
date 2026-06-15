import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_state_provider.dart';
import '../routes/app_routes.dart';
import '../models/wisata_model.dart';
import '../widgets/app_image.dart';

class WisataTab extends StatefulWidget {
  const WisataTab({super.key});

  @override
  State<WisataTab> createState() => _WisataTabState();
}

class _WisataTabState extends State<WisataTab> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final _searchController = TextEditingController();

  final List<String> _categories = ['Semua', 'Alam', 'Budaya', 'Paket'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    
    // Filter logic
    final filteredList = state.wisataList.where((w) {
      final matchesSearch = w.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_selectedCategory == 'Semua') {
        return matchesSearch;
      } else if (_selectedCategory == 'Paket') {
        return w.isPaket && matchesSearch;
      } else {
        return !w.isPaket && w.kategori.toLowerCase() == _selectedCategory.toLowerCase() && matchesSearch;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Column(
        children: [
          // Forest Green Integrated Header
          Container(
            padding: const EdgeInsets.only(top: 54, bottom: 20, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: AppConfig.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Eksplorasi Wisata',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.map_rounded, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                      tooltip: 'Buka Peta GIS',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar inside Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari destinasi atau paket...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Category Chips
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConfig.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppConfig.textColorSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Vertical Destinations List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildWisataCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWisataCard(WisataModel w) {
    // Determine category tag style
    final isBudaya = w.kategori.toLowerCase() == 'budaya' || w.kategori.toLowerCase() == 'sejarah';
    final tagBg = isBudaya ? AppConfig.tagBudayaBg : AppConfig.tagAlamBg;
    final tagText = isBudaya ? AppConfig.tagBudayaText : AppConfig.tagAlamText;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.detail,
          arguments: {'type': 'wisata', 'data': w},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppImage(
                  w.gambar,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 96,
                    height: 96,
                    color: AppConfig.primaryColor,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        w.isPaket ? 'Paket Wisata' : w.kategori,
                        style: TextStyle(
                          color: tagText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      w.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description snippet
                    Text(
                      w.deskripsi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConfig.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Distance/Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppConfig.accentColor, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              w.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppConfig.textColorPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          w.isPaket ? 'Detail Paket' : w.tiketMasuk,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: w.isPaket ? AppConfig.primaryColor : AppConfig.textColorSecondary,
                          ),
                        ),
                      ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Destinasi tidak ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
