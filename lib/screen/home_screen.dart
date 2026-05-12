// lib/screen/home_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tugasSelesai = 0;
  int _tugasBelumSelesai = 0;
  Map<String, int> _chartData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final selesai = await Database_helper.instance.hitungTugasSelesai();
    final belum = await Database_helper.instance.hitungTugasBelumSelesai();
    final chart = await Database_helper.instance.totalTugasSelesaiperHari();

    setState(() {
      _tugasSelesai = selesai;
      _tugasBelumSelesai = belum;
      _chartData = chart;
      _isLoading = false;
    });
  }

  // Nama hari dalam bahasa Indonesia
  String _namaHari(DateTime date) {
    const hari = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return hari[date.weekday % 7];
  }

  String _getNamaHari() {
    final now = DateTime.now();
    const hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                   'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${hari[now.weekday % 7]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D8B7A),
        title: const Text(
          'Beranda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // hilangkan tombol back
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== GREETING =====
                    _buildGreeting(),
                    const SizedBox(height: 16),

                    // ===== STATISTIK =====
                    _buildStatistik(),
                    const SizedBox(height: 16),

                    // ===== GRAFIK =====
                    _buildGrafik(),
                    const SizedBox(height: 16),

                    // ===== TOMBOL NAVIGASI =====
                    _buildTombolNavigasi(),
                  ],
                ),
              ),
            ),
    );
  }

  // ===== WIDGET GREETING =====
  Widget _buildGreeting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, User!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getNamaHari(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== WIDGET STATISTIK =====
  Widget _buildStatistik() {
    return Row(
      children: [
        // Tugas Selesai
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TUGAS SELESAI',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_tugasSelesai',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D8B7A),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Tugas Belum Selesai
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BELUM SELESAI',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_tugasBelumSelesai',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== WIDGET GRAFIK BATANG =====
  Widget _buildGrafik() {
  final List<DateTime> weekDays = List.generate(
    7,
    (i) => DateTime.now().subtract(Duration(days: 6 - i)),
  );

  final maxVal = _chartData.values.isEmpty
      ? 1
      : _chartData.values.reduce((a, b) => a > b ? a : b);

  const double chartHeight = 120.0; // tinggi area grafik

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TUGAS SELESAI / HARI',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Area grafik dengan tinggi tetap
        SizedBox(
          height: chartHeight + 40, // +40 untuk label hari di bawah
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((date) {
              final key =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                  '${date.day.toString().padLeft(2, '0')}';
              final val = _chartData[key] ?? 0;

              // Hitung tinggi bar proporsional
              final double barHeight = maxVal == 0
                  ? 0
                  : (val / maxVal) * chartHeight;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end, // semua rata bawah
                children: [
                  // Angka di atas bar
                  SizedBox(
                    height: 16,
                    child: Text(
                      val > 0 ? '$val' : '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Bar — tumbuh ke atas karena Column rata bawah
                  Container(
                    width: 28,
                    height: barHeight > 0 ? barHeight : 3,
                    // tinggi minimal 3 agar tetap terlihat garis tipis
                    decoration: BoxDecoration(
                      color: barHeight > 0
                          ? const Color(0xFF2D8B7A)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Label hari — selalu di posisi yang sama (bawah)
                  Text(
                    _namaHari(date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}
  // ===== WIDGET 4 TOMBOL NAVIGASI =====
  Widget _buildTombolNavigasi() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        // Tambah Tugas Penting
        _buildNavButton(
          label: 'Tambah Tugas Penting',
          icon: Icons.add,
          color: Colors.red,
          onTap: () async {
            await Navigator.pushNamed(context, '/add-penting');
            _loadData(); // refresh setelah kembali
          },
        ),
        // Tambah Tugas Biasa
        _buildNavButton(
          label: 'Tambah Tugas Biasa',
          icon: Icons.add,
          color: const Color(0xFF2D8B7A),
          onTap: () async {
            await Navigator.pushNamed(context, '/add-biasa');
            _loadData();
          },
        ),
        // Daftar Tugas
        _buildNavButton(
          label: 'Daftar Tugas',
          icon: Icons.list_alt,
          color: Colors.blue,
          onTap: () async {
            await Navigator.pushNamed(context, '/todo-list');
            _loadData();
          },
        ),
        // Pengaturan
        _buildNavButton(
          label: 'Pengaturan',
          icon: Icons.settings,
          color: Colors.grey[700]!,
          onTap: () async {
            await Navigator.pushNamed(context, '/pengaturan');
            _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}