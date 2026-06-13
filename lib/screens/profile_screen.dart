import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
                    backgroundImage: (user != null && user.photo.isNotEmpty && !state.isGuest)
                        ? NetworkImage(user.photo)
                        : null,
                    child: (user == null || user.photo.isEmpty || state.isGuest)
                        ? Text(
                            state.isAdmin
                                ? 'A'
                                : (state.isGuest ? 'T' : ((user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'P')),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (!state.isGuest) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            try {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Mengunggah foto profil...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              final provider = Provider.of<AppStateProvider>(context, listen: false);
                              await provider.updateProfilePhoto(image);
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Foto profil berhasil diperbarui!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal memperbarui foto profil: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppConfig.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        icon: const Icon(Icons.photo_camera_rounded, size: 18),
                        label: const Text(
                          'Ubah Foto Profil',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Pengunjung',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
