import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/app_state_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    await provider.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Nama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppConfig.textColorPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nama Baru',
            hintText: 'Masukkan nama baru',
            prefixIcon: const Icon(Icons.person_rounded, color: AppConfig.primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppConfig.primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppConfig.textColorSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                Navigator.pop(ctx);
                try {
                  final provider = Provider.of<AppStateProvider>(context, listen: false);
                  await provider.updateUserName(newName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama berhasil diperbarui!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal memperbarui nama: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              } else {
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: state.isAdmin
                        ? Colors.amber.shade600
                        : (state.isGuest ? Colors.grey.shade400 : AppConfig.primaryColor),
                    child: Text(
                      state.isAdmin
                          ? 'A'
                          : (state.isGuest ? 'T' : ((user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'P')),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!state.isGuest)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user?.name ?? 'Pengunjung',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppConfig.textColorPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showEditNameDialog(context, user?.name ?? ''),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppConfig.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (state.isGuest)
                    const Text(
                      'Pengunjung',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.textColorPrimary,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'pengunjung@visitresun.com',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppConfig.textColorSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Premium Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: state.isAdmin
                          ? AppConfig.accentColor.withOpacity(0.15)
                          : (state.isGuest ? Colors.grey.shade100 : AppConfig.primaryColor.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.isAdmin
                            ? AppConfig.accentColor
                            : (state.isGuest ? Colors.grey : AppConfig.primaryColor),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      state.isAdmin 
                          ? 'ADMINISTRATOR' 
                          : (state.isGuest ? 'MODE TAMU / GUEST' : 'VISITOR / PENGUNJUNG'),
                      style: TextStyle(
                        color: state.isAdmin
                            ? Colors.amber.shade900
                            : (state.isGuest ? Colors.grey.shade700 : AppConfig.primaryColor),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CONDITIONAL ADMIN PANEL TRIGGERS (Aesthetic Gold Gradient Entry Card)
            if (state.isAdmin) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConfig.accentColor, AppConfig.accentLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.accentColor.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.adminDashboard),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel Admin Kelola Data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kelola Wisata, Homestay, & Suvenir Desa Resun.',
                                  style: const TextStyle(
                                    color: Color(0xFFF1F1F1),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // General Profile Options List
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    Icons.settings_suggest_outlined,
                    'Pengaturan Aplikasi',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur pengaturan segera hadir!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildProfileOption(
                    Icons.help_center_outlined,
                    'Bantuan & FAQ',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pusat bantuan dapat diakses via email.',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildProfileOption(
                    Icons.info_outline,
                    'Tentang Visit Resun GIS',
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Visit Resun App',
                        applicationVersion: 'v1.0.0',
                        applicationIcon: const Icon(
                          Icons.map_rounded,
                          color: AppConfig.primaryColor,
                          size: 40,
                        ),
                        children: const [
                          Text(
                            'Aplikasi GIS pariwisata Desa Resun Lingga berbasis Flutter dan Firebase.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Logout Action Button
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isGuest ? AppConfig.primaryColor.withOpacity(0.1) : Colors.red.shade50,
                foregroundColor: state.isGuest ? AppConfig.primaryColor : Colors.redAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: state.isGuest ? AppConfig.primaryColor.withOpacity(0.2) : Colors.red.shade100, 
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(state.isGuest ? Icons.login_rounded : Icons.logout_rounded),
                  const SizedBox(width: 8),
                  Text(
                    state.isGuest ? 'Masuk / Daftar Akun' : 'Keluar Akun (Logout)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppConfig.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppConfig.textColorPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

// Colors helper extension
class ColorsConstants {
  static const Color whiteBD = Color(0xFFF1F1F1);
}

extension WhiteTextOpacity on TextStyle {
  TextStyle get whiteBD => copyWith(color: const Color(0xFFF1F1F1));
}
