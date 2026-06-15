import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/wisata_model.dart';
import '../models/homestay_model.dart';
import '../providers/app_state_provider.dart';
import '../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  dynamic _selectedItem; // Can be WisataModel or HomestayModel
  String _selectedType = ''; // 'wisata' or 'homestay'
  String _activeFilter = 'semua'; // 'semua', 'wisata', 'homestay'

  double _currentLat = -0.14746797422103605;
  double _currentLng = 104.60392575314476;
  bool _initializedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args.containsKey('lat')) _currentLat = args['lat'];
        if (args.containsKey('lng')) _currentLng = args['lng'];
        
        // Find if there is selected item
        if (args.containsKey('selectedId')) {
          final id = args['selectedId'];
          final state = Provider.of<AppStateProvider>(context, listen: false);
          
          final wisata = state.wisataList.firstWhere((w) => w.id == id, orElse: () => WisataModel(id: '', nama: '', deskripsi: '', gambar: '', kategori: '', lat: 0, lng: 0, rating: 0, jamBuka: '', tiketMasuk: ''));
          if (wisata.id.isNotEmpty) {
            _selectedItem = wisata;
            _selectedType = 'wisata';
          } else {
            final homestay = state.homestayList.firstWhere((h) => h.id == id, orElse: () => HomestayModel(id: '', nama: '', harga: 0, fasilitas: [], gambar: '', lat: 0, lng: 0, rating: 0, kontak: ''));
            if (homestay.id.isNotEmpty) {
              _selectedItem = homestay;
              _selectedType = 'homestay';
            }
          }
        }
      }
      _initializedArgs = true;
    }
  }

  void _recenterMap() {
    _mapController.move(LatLng(-0.14746797422103605, 104.60392575314476), 14.5);
    setState(() {
      _selectedItem = null;
      _selectedType = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    
    // Create markers list
    final List<Marker> markers = [];

    // 1. Add Wisata markers (Green Pins)
    if (_activeFilter == 'semua' || _activeFilter == 'wisata') {
      for (var w in state.wisataList) {
        if (w.isPaket) continue;
        markers.add(
          Marker(
            point: LatLng(w.lat, w.lng),
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = w;
                  _selectedType = 'wisata';
                });
                _mapController.move(LatLng(w.lat, w.lng), 15.5);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppConfig.primaryColor,
                    size: 38,
                  ),
                  const Positioned(
                    top: 6,
                    child: Icon(
                      Icons.forest_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // 2. Add Homestay markers (Teal/Dark pins to coordinate with green theme)
    if (_activeFilter == 'semua' || _activeFilter == 'homestay') {
      for (var h in state.homestayList) {
        markers.add(
          Marker(
            point: LatLng(h.lat, h.lng),
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = h;
                  _selectedType = 'homestay';
                });
                _mapController.move(LatLng(h.lat, h.lng), 15.5);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.teal,
                    size: 38,
                  ),
                  const Positioned(
                    top: 6,
                    child: Icon(
                      Icons.holiday_village_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentLat, _currentLng),
              initialZoom: 14.5,
              maxZoom: 18,
              minZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.visitresun.gis',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 54, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConfig.primaryColor,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Peta Geografis (GIS)',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Filter Chips
          Positioned(
            top: 116,
            left: 20,
            right: 20,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('semua', 'Semua Pin', Icons.pin_drop_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('wisata', 'Wisata (Hijau)', Icons.forest_rounded, color: AppConfig.primaryColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('homestay', 'Homestay (Teal)', Icons.holiday_village_rounded, color: Colors.teal),
                ],
              ),
            ),
          ),

          // Popup Details Card
          if (_selectedItem != null)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedItem.gambar,
                        width: 86,
                        height: 86,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 86,
                          height: 86,
                          color: AppConfig.primaryColor,
                          child: const Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'wisata'
                                      ? AppConfig.primaryColor.withOpacity(0.1)
                                      : Colors.teal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedType == 'wisata' ? 'Wisata' : 'Homestay',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedType == 'wisata'
                                        ? AppConfig.primaryColor
                                        : Colors.teal,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _selectedItem = null;
                                    _selectedType = '';
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedItem.nama,
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
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppConfig.accentColor, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                _selectedItem.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedType == 'wisata'
                                      ? (_selectedItem as WisataModel).kategori
                                      : 'Rp ${(_selectedItem as HomestayModel).harga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/malam',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppConfig.textColorSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.detail,
                                arguments: {'type': _selectedType, 'data': _selectedItem},
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              minimumSize: const Size(double.infinity, 32),
                            ),
                            child: const Text('Detail Lengkap', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Custom FAB Control Buttons (Zoom, Recenter)
          Positioned(
            right: 20,
            bottom: _selectedItem != null ? 220 : 24,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'btn_zoom_in',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppConfig.primaryColor,
                  elevation: 2,
                  onPressed: () {
                    final nextZoom = (_mapController.camera.zoom + 1).clamp(10.0, 18.0);
                    _mapController.move(_mapController.camera.center, nextZoom);
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'btn_zoom_out',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppConfig.primaryColor,
                  elevation: 2,
                  onPressed: () {
                    final nextZoom = (_mapController.camera.zoom - 1).clamp(10.0, 18.0);
                    _mapController.move(_mapController.camera.center, nextZoom);
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'btn_recenter',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppConfig.primaryColor,
                  elevation: 2,
                  onPressed: _recenterMap,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, {Color? color}) {
    final isSelected = _activeFilter == value;
    final activeColor = color ?? AppConfig.primaryColor;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = value;
          _selectedItem = null;
          _selectedType = '';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : AppConfig.textColorSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppConfig.textColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
