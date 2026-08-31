import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3E9F7),
      ),
      home: const HomePage(),
    );
  }
}

// ================= MODEL =================
class Kontak {
  String nama;
  String email;
  String telepon;
  bool favorit;

  Kontak({
    required this.nama,
    required this.email,
    required this.telepon,
    this.favorit = false,
  });
}

// ================= HOME PAGE (dengan Tab & Drawer) =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Kontak> _daftarKontak = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Membuka halaman Tambah Kontak dan menerima data baliknya
  Future<void> _bukaTambahKontak() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

    if (hasil != null && hasil is Kontak) {
      setState(() {
        _daftarKontak.add(hasil);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hasil.nama} ditambahkan')),
        );
      }
    }
  }

  void _toggleFavorit(Kontak kontak) {
    setState(() {
      kontak.favorit = !kontak.favorit;
    });
  }

  void _hapusKontak(Kontak kontak) {
    setState(() {
      _daftarKontak.remove(kontak);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritList = _daftarKontak.where((k) => k.favorit).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'BUKU KONTAK',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFAB47BC),
          indicatorWeight: 3,
          labelColor: const Color(0xFFAB47BC),
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Kontak'),
            Tab(icon: Icon(Icons.star), text: 'Favorit'),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDaftarKontak(_daftarKontak, tampilkanHapus: true),
          _buildDaftarKontak(favoritList, tampilkanHapus: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahKontak,
        backgroundColor: const Color(0xFFE1BEE7),
        foregroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaftarKontak(List<Kontak> data, {required bool tampilkanHapus}) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final kontak = data[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF2196F3),
            child: Text(
              kontak.nama.isNotEmpty ? kontak.nama[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(kontak.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${kontak.telepon}${kontak.email.isNotEmpty ? ' | ${kontak.email}' : ''}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  kontak.favorit ? Icons.star : Icons.star_border,
                  color: kontak.favorit ? Colors.amber : Colors.grey,
                ),
                onPressed: () => _toggleFavorit(kontak),
              ),
              if (tampilkanHapus)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _hapusKontak(kontak),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2196F3)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Kontak'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Tambah Kontak'),
            onTap: () {
              Navigator.pop(context);
              _bukaTambahKontak();
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Favorit'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TentangPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= TAMBAH KONTAK PAGE =================
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (_formKey.currentState!.validate()) {
      final kontakBaru = Kontak(
        nama: _namaController.text.trim(),
        email: _emailController.text.trim(),
        telepon: _teleponController.text.trim(),
      );
      // Mengirim data kembali ke HomePage
      Navigator.pop(context, kontakBaru);
    }
  }

  InputDecoration _underlineDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Tambah Kontak',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: _underlineDecoration('Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _underlineDecoration('Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _teleponController,
                keyboardType: TextInputType.phone,
                decoration: _underlineDecoration('No Handphone'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: const Color(0xFFEDE7F6),
                    foregroundColor: const Color(0xFF5E35B1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _simpanKontak,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TENTANG PAGE =================
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Tentang',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto profil bulat.
              // Ganti path di bawah dengan foto asli kamu (taruh di folder
              // assets/images/ lalu daftarkan di pubspec.yaml).
              const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFFFB74D),
                backgroundImage: AssetImage('assets/images/profile.jpg'),
                // Jika foto belum ada, tampilan akan error saat load asset.
                // Sementara itu bisa pakai fallback di bawah ini:
                // child: Icon(Icons.person, size: 55, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Naufaal Zaidan Aufaa Chandra',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'XII RPL B',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              const Text(
                'SMK Negeri 5 Surakarta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}