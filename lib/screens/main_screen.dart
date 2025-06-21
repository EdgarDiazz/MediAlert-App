import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios/servicio_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

/// Pantalla principal que contiene la navegación por pestañas inferiores.
class MainScreen extends StatefulWidget {
  final String userId;

  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId),
      HistoryScreen(userId: widget.userId),
      ProfileScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color azulPrincipal = Color.fromARGB(255, 1, 215, 253);
    const Color fondoClaro = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: fondoClaro,
      appBar: AppBar(
        title: Text(
          '🩺 MediAlert',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: azulPrincipal,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: azulPrincipal,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12),
        backgroundColor: Colors.white,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Medicamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
