import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'superadmin_dashboard_screen.dart';
import 'superadmin_analiticas_screen.dart';
import 'superadmin_usuarios_screen.dart';
import 'superadmin_crear_usuario_screen.dart';
import 'superadmin_reportes_screen.dart';
import 'superadmin_distritos_screen.dart';

import '../providers/dashboard_provider.dart';
import '../../usuarios/providers/usuarios_provider.dart'; // 👈 donde está tu usuariosProvider
import '../../distritos/providers/distritos_provider.dart';

class SuperAdminShell extends ConsumerStatefulWidget {
  const SuperAdminShell({super.key});

  @override
  ConsumerState<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends ConsumerState<SuperAdminShell> {
  int _index = 0;

  final _pages = const [
    SuperAdminDashboardWrapper(),
    SuperAdminAnaliticasScreen(),
    SuperAdminUsuariosScreen(),
    SuperAdminDistritosScreen(),
    SuperAdminCrearUsuarioScreen(),
    SuperAdminReportesScreen(),
  ];

  final _titles = const [
    "ADAdmin - SuperADMIN",
    "Análisis",
    "Usuarios",
    "Distritos",
    "Crear usuario",
    "Reportes",
  ];

  void _onTap(int i) {
    // ✅ Refrescar Home/Dashboard cuando se toque Home
    if (i == 0) {
      ref.refresh(dashboardProvider);
    }

    // ✅ Refrescar Usuarios cuando se toque Usuarios
    if (i == 2) {
      ref.refresh(usuariosResumenProvider);
    }
    if (i == 3) ref.invalidate(distritosProvider);

    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: true),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "Análisis",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: "Usuarios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Distritos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: "Crear",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Reportes",
          ),
        ],
      ),
    );
  }
}
