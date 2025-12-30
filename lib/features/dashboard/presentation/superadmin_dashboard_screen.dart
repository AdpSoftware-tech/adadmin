import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> data; // viene del provider / servicio

  const SuperAdminDashboardScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final totales = data['totalesGlobales'] ?? {};
    final asociaciones = (data['asociaciones'] ?? []) as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADAdmin - SuperADMIN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Resumen global",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 👉 Cards de totales
            _buildResumenGlobalCards(totales),

            const SizedBox(height: 24),

            const Text(
              "Asociaciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // 👉 Lista de asociaciones
            ...asociaciones.map(
              (a) => _buildAsociacionTile(a as Map<String, dynamic>),
            ),
          ],
        ),
      ),
    );
  }

  /// Cards de totales globales
  Widget _buildResumenGlobalCards(Map<String, dynamic> totales) {
    int asociaciones = totales['asociaciones'] ?? 0;
    int distritos = totales['distritos'] ?? 0;
    int iglesias = totales['iglesias'] ?? 0;
    int pastores = totales['pastores'] ?? 0;
    int miembros = totales['miembros'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard("Asociaciones", asociaciones, Icons.apartment),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard("Distritos", distritos, Icons.grid_view_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard("Iglesias", iglesias, Icons.church_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard("Pastores", pastores, Icons.person_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard("Miembros", miembros, Icons.group)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, int value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 👉 Una asociación con resumen + distritos adentro
  Widget _buildAsociacionTile(Map<String, dynamic> asociacion) {
    final nombre = asociacion['nombre'] ?? 'Sin nombre';
    final cantDistritos = asociacion['cantidadDistritos'] ?? 0;
    final cantIglesias = asociacion['cantidadIglesias'] ?? 0;
    final cantPastores = asociacion['cantidadPastores'] ?? 0;
    final cantMiembros = asociacion['cantidadMiembros'] ?? 0;
    final distritos = (asociacion['distritos'] ?? []) as List;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: -8,
          children: [
            _chipMini("Distritos: $cantDistritos"),
            _chipMini("Iglesias: $cantIglesias"),
            _chipMini("Pastores: $cantPastores"),
            _chipMini("Miembros: $cantMiembros"),
          ],
        ),
        children: [
          if (distritos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("Sin distritos registrados."),
            )
          else
            ...distritos.map(
              (d) => _buildDistritoTile(d as Map<String, dynamic>),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 👉 Un distrito con sus stats + pastores + iglesias
  Widget _buildDistritoTile(Map<String, dynamic> distrito) {
    final nombre = distrito['nombre'] ?? 'Sin nombre';
    final cantIglesias = distrito['cantidadIglesias'] ?? 0;
    final cantPastores = distrito['cantidadPastores'] ?? 0;
    final cantMiembros = distrito['cantidadMiembros'] ?? 0;
    final pastores = (distrito['pastores'] ?? []) as List;
    final iglesias = (distrito['iglesias'] ?? []) as List;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Wrap(
          spacing: 8,
          runSpacing: -8,
          children: [
            _chipMini("Iglesias: $cantIglesias"),
            _chipMini("Pastores: $cantPastores"),
            _chipMini("Miembros: $cantMiembros"),
          ],
        ),
        children: [
          if (pastores.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pastores",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            ...pastores.map((p) => _buildPastorRow(p as Map<String, dynamic>)),
            const SizedBox(height: 8),
          ],
          if (iglesias.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Iglesias",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            ...iglesias.map((i) => _buildIglesiaRow(i as Map<String, dynamic>)),
          ],
          if (pastores.isEmpty && iglesias.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Sin pastores ni iglesias asignadas."),
            ),
        ],
      ),
    );
  }

  Widget _buildPastorRow(Map<String, dynamic> pastor) {
    final usuario = pastor['usuario'] ?? {};
    final nombre = usuario['nombre'] ?? '';
    final apellidos = usuario['apellidos'] ?? '';
    final telefono = usuario['telefono'] ?? '';
    final email = usuario['email'] ?? '';

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.person_outline),
      title: Text("$nombre $apellidos"),
      subtitle: Text("$telefono • $email"),
    );
  }

  Widget _buildIglesiaRow(Map<String, dynamic> iglesia) {
    final nombre = iglesia['nombre'] ?? '';
    final codigo = iglesia['codigo'] ?? '';
    final miembros = iglesia['cantidadMiembros'] ?? 0;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.church_outlined),
      title: Text(nombre),
      subtitle: Text("Código: $codigo  •  Miembros: $miembros"),
    );
  }

  Widget _chipMini(String text) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class SuperAdminDashboardWrapper extends ConsumerWidget {
  const SuperAdminDashboardWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDashboard = ref.watch(dashboardProvider);

    return asyncDashboard.when(
      data: (data) => SuperAdminDashboardScreen(data: data),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
