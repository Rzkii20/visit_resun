import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../models/wisata_model.dart';
import '../../models/homestay_model.dart';
import '../../models/suvenir_model.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/app_image.dart';

class AdminFormScreen extends StatefulWidget {
  const AdminFormScreen({super.key});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isInit = false;
  bool _isPaket = false;

  // Form controllers
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _gambarController = TextEditingController();
  
  // Type-specific controllers
  final _kategoriController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _jamBukaController = TextEditingController();
  final _tiketMasukController = TextEditingController();

  final _hargaController = TextEditingController();
  final _fasilitasController = TextEditingController();
  final _kontakController = TextEditingController();
  final _stokController = TextEditingController();

  late String _type;
  dynamic _editData;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _gambarController.dispose();
    _kategoriController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _jamBukaController.dispose();
    _tiketMasukController.dispose();
    _hargaController.dispose();
    _fasilitasController.dispose();
    _kontakController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _type = args['type'];
      _editData = args.containsKey('data') ? args['data'] : null;

      // Prefill if editing
      if (_editData != null) {
        _namaController.text = _editData.nama;
        _gambarController.text = _editData.gambar;

        if (_type == 'wisata') {
          final w = _editData as WisataModel;
          _deskripsiController.text = w.deskripsi;
          _kategoriController.text = w.kategori;
          _latController.text = w.lat.toString();
          _lngController.text = w.lng.toString();
          _jamBukaController.text = w.jamBuka;
          _tiketMasukController.text = w.tiketMasuk;
          _isPaket = w.isPaket;
        } else if (_type == 'homestay') {
          final h = _editData as HomestayModel;
          _hargaController.text = h.harga.toStringAsFixed(0);
          _fasilitasController.text = h.fasilitas.join(', ');
          _latController.text = h.lat.toString();
          _lngController.text = h.lng.toString();
          _kontakController.text = h.kontak;
        } else if (_type == 'suvenir') {
          final s = _editData as SuvenirModel;
          _deskripsiController.text = s.deskripsi;
          _hargaController.text = s.harga.toStringAsFixed(0);
          _stokController.text = s.stok.toString();
          _kontakController.text = s.kontak;
        }
      } else {
        // Set default preset values to make it extremely easy to add new items!
        _gambarController.text = AppConfig.presetImages[0];
        _kontakController.text = '628123456789';
        
        if (_type == 'wisata') {
          _kategoriController.text = 'Alam';
          _latController.text = '-0.147468';
          _lngController.text = '104.603926';
          _jamBukaController.text = '08:00 - 17:00 WIB';
          _tiketMasukController.text = 'Rp 5.000';
          _isPaket = args['isPaketDefault'] ?? false;
        } else if (_type == 'homestay') {
          _hargaController.text = '150000';
          _fasilitasController.text = 'Wifi, AC, Parkir';
          _latController.text = '-0.146500';
          _lngController.text = '104.604200';
        } else if (_type == 'suvenir') {
          _hargaController.text = '25000';
          _stokController.text = '15';
        }
      }
      _isInit = true;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Mengunggah gambar...'),
            duration: Duration(seconds: 2),
          ),
        );
        final provider = Provider.of<AppStateProvider>(context, listen: false);
        final url = await provider.uploadImage(image, _type);
        setState(() {
          _gambarController.text = url;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Gambar berhasil diunggah!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengunggah gambar: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final isEditing = _editData != null;
    final id = isEditing ? _editData.id : '';

    if (_type == 'wisata') {
      final item = WisataModel(
        id: id,
        nama: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        gambar: _gambarController.text.trim(),
        kategori: _kategoriController.text.trim(),
        lat: double.tryParse(_latController.text) ?? -0.147468,
        lng: double.tryParse(_lngController.text) ?? 104.603926,
        rating: isEditing ? _editData.rating : 4.8,
        jamBuka: _jamBukaController.text.trim(),
        tiketMasuk: _tiketMasukController.text.trim(),
        isPaket: _isPaket,
      );

      if (isEditing) {
        await provider.updateWisata(item);
      } else {
        await provider.addWisata(item);
      }
    } else if (_type == 'homestay') {
      final facilities = _fasilitasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final item = HomestayModel(
        id: id,
        nama: _namaController.text.trim(),
        harga: double.tryParse(_hargaController.text) ?? 100000.0,
        fasilitas: facilities,
        gambar: _gambarController.text.trim(),
        lat: double.tryParse(_latController.text) ?? -0.146500,
        lng: double.tryParse(_lngController.text) ?? 104.604200,
        rating: isEditing ? _editData.rating : 4.5,
        kontak: _kontakController.text.trim(),
      );

      if (isEditing) {
        await provider.updateHomestay(item);
      } else {
        await provider.addHomestay(item);
      }
    } else if (_type == 'suvenir') {
      final item = SuvenirModel(
        id: id,
        nama: _namaController.text.trim(),
        harga: double.tryParse(_hargaController.text) ?? 10000.0,
        gambar: _gambarController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        rating: isEditing ? _editData.rating : 4.7,
        stok: int.tryParse(_stokController.text) ?? 5,
        kontak: _kontakController.text.trim(),
      );

      if (isEditing) {
        await provider.updateSuvenir(item);
      } else {
        await provider.addSuvenir(item);
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data $_type berhasil ${isEditing ? 'diperbarui' : 'ditambahkan'}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isEditing = _editData != null;

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Ubah Data ${_type.toUpperCase()}' : 'Tambah ${_type.toUpperCase()} Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
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
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppConfig.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shared Fields: Nama
                    _buildTextField(
                      controller: _namaController,
                      label: 'Nama $_type',
                      icon: Icons.title_rounded,
                      validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong!' : null,
                    ),
                    const SizedBox(height: 16),

                    // Shared Fields: Gambar (Hanya via Upload visual)
                    const Text(
                      'Foto/Gambar Wisata:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _gambarController.text.isEmpty
                        ? GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_upload_outlined, size: 48, color: AppConfig.primaryColor),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Unggah Gambar',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConfig.textColorPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Klik untuk memilih file gambar dari galeri',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AppImage(
                                  _gambarController.text,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: ElevatedButton.icon(
                                  onPressed: _pickAndUploadImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black.withOpacity(0.7),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.photo_camera_rounded, size: 16),
                                  label: const Text('Ganti Gambar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                    // Validator check during form save
                    FormField<String>(
                      validator: (value) {
                        if (_gambarController.text.isEmpty) {
                          return 'Gambar wajib diunggah!';
                        }
                        return null;
                      },
                      builder: (state) {
                        if (state.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Shared Fields: Deskripsi (Not for Homestay since it has fixed summary)
                    if (_type != 'homestay') ...[
                      _buildTextField(
                        controller: _deskripsiController,
                        label: 'Deskripsi',
                        icon: Icons.description_rounded,
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong!' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Dynamic Fields based on Type
                    if (_type == 'wisata') ...[
                      // Choice Chip to select between Tempat Wisata and Paket Wisata
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            const Text(
                              'Jenis Wisata:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConfig.textColorPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ChoiceChip(
                              label: const Text('Tempat Wisata'),
                              selected: !_isPaket,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _isPaket = false;
                                  });
                                }
                              },
                              selectedColor: AppConfig.primaryColor.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: !_isPaket ? AppConfig.primaryColor : AppConfig.textColorSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('Paket Wisata'),
                              selected: _isPaket,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _isPaket = true;
                                  });
                                }
                              },
                              selectedColor: AppConfig.primaryColor.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: _isPaket ? AppConfig.primaryColor : AppConfig.textColorSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTextField(
                        controller: _kategoriController,
                        label: 'Kategori (Alam, Budaya, Kuliner, dll.)',
                        icon: Icons.category_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Kategori tidak boleh kosong!' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latController,
                              label: 'Latitude',
                              icon: Icons.pin_drop_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Lat tidak valid!' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lngController,
                              label: 'Longitude',
                              icon: Icons.pin_drop_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Lng tidak valid!' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _jamBukaController,
                        label: 'Jam Operasional',
                        icon: Icons.access_time_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Jam operasional tidak boleh kosong!' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _tiketMasukController,
                        label: 'Harga Tiket Masuk',
                        icon: Icons.confirmation_num_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Tiket masuk tidak boleh kosong!' : null,
                      ),
                    ] else if (_type == 'homestay') ...[
                      _buildTextField(
                        controller: _hargaController,
                        label: 'Harga / Tarif per Malam (Rp)',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Tarif tidak valid!' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _fasilitasController,
                        label: 'Fasilitas (Pisahkan dengan koma, contoh: Wifi, AC)',
                        icon: Icons.room_service_rounded,
                        validator: (value) => value == null || value.isEmpty ? 'Fasilitas tidak boleh kosong!' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _latController,
                              label: 'Latitude',
                              icon: Icons.pin_drop_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Lat tidak valid!' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _lngController,
                              label: 'Longitude',
                              icon: Icons.pin_drop_rounded,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Lng tidak valid!' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kontakController,
                        label: 'No. WhatsApp Pemilik (Gunakan 628...)',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty || value.length < 10 ? 'No. WA tidak valid!' : null,
                      ),
                    ] else if (_type == 'suvenir') ...[
                      _buildTextField(
                        controller: _hargaController,
                        label: 'Harga Produk (Rp)',
                        icon: Icons.monetization_on_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty || double.tryParse(value) == null ? 'Harga tidak valid!' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _stokController,
                        label: 'Stok Produk',
                        icon: Icons.inventory_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty || int.tryParse(value) == null ? 'Stok tidak valid!' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _kontakController,
                        label: 'No. WhatsApp Penjual (Gunakan 628...)',
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty || value.length < 10 ? 'No. WA tidak valid!' : null,
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Save Action Button
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Simpan Perubahan' : 'Tambah Data Sekarang',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConfig.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppConfig.primaryColor, width: 2),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}
