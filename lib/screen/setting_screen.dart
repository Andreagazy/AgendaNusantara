// lib/screen/settings_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isLoading = false;

  final String _namaDeveloper = 'Andreagazy Iza Amerianto';
  final String _nimDeveloper = '2241720146';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _simpanPassword() async {
    // Validasi field tidak boleh kosong
    if (_currentPasswordController.text.trim().isEmpty) {
      _showSnackbar('Password saat ini tidak boleh kosong!', Colors.red);
      return;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      _showSnackbar('Password baru tidak boleh kosong!', Colors.red);
      return;
    }

    // Validasi panjang password baru minimal 4 karakter
    if (_newPasswordController.text.trim().length < 4) {
      _showSnackbar('Password baru minimal 4 karakter!', Colors.red);
      return;
    }

    // Validasi password baru tidak boleh sama dengan yang lama
    if (_currentPasswordController.text.trim() ==
        _newPasswordController.text.trim()) {
      _showSnackbar(
        'Password baru tidak boleh sama dengan yang lama!',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ambil username yang sedang login dari database
      // Karena hanya 1 akun, langsung ambil id = 1
      final account = await Database_helper.instance.getAccount('user');
      final username = account?['username'] as String? ?? 'user';

      await Database_helper.instance.updateAccount(
        username,
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      setState(() => _isLoading = false);

      // Bersihkan field setelah berhasil
      _currentPasswordController.clear();
      _newPasswordController.clear();

      if (!mounted) return;
      _showSnackbar('Password berhasil diperbarui!', Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackbar('Password saat ini salah!', Colors.red);
    }
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8B7A),
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== SECTION GANTI PASSWORD =====
            _buildLabel('GANTI PASSWORD'),
            const SizedBox(height: 12),
            _buildFormGantiPassword(),
            const SizedBox(height: 24),

            // ===== SECTION DEVELOPER =====
            _buildLabel('DEVELOPER'),
            const SizedBox(height: 12),
            _buildInfoDeveloper(),
            const SizedBox(height: 32),

            // ===== TOMBOL LOGOUT =====
            _buildTombolLogout(),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET FORM GANTI PASSWORD =====
  Widget _buildFormGantiPassword() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password Saat Ini
          const Text(
            'PASSWORD SAAT INI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _currentPasswordController,
            hint: '••••',
            obscure: _obscureCurrent,
            action: TextInputAction.next,
            onToggle: () {
              setState(() => _obscureCurrent = !_obscureCurrent);
            },
          ),
          const SizedBox(height: 16),

          // Password Baru
          const Text(
            'PASSWORD BARU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _newPasswordController,
            hint: '••••••••',
            obscure: _obscureNew,
            action: TextInputAction.done,
            onToggle: () {
              setState(() => _obscureNew = !_obscureNew);
            },
          ),
          const SizedBox(height: 20),

          // Tombol Simpan Password
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _simpanPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8B7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SIMPAN PASSWORD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGET INFO DEVELOPER =====
  Widget _buildInfoDeveloper() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar developer
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF2D8B7A), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/Foto.jpg',
                width: 64,
                height: 64,
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 36,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _namaDeveloper,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NIM: $_nimDeveloper',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              const Text(
                'DEVELOPER APLIKASI',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF2D8B7A),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "D-IV Teknik Informatika",
                  style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== WIDGET TOMBOL LOGOUT =====
  Widget _buildTombolLogout() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'LOGOUT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ===== HELPER: LABEL SECTION =====
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 1,
      ),
    );
  }

  // ===== HELPER: TEXT FIELD =====
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required TextInputAction action,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D8B7A), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
