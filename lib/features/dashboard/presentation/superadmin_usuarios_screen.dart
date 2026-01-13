import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usuarios/widgets/usuarios_por_mes_chart.dart';
import '../../usuarios/providers/usuarios_provider.dart';

class SuperAdminUsuariosScreen extends ConsumerStatefulWidget {
  const SuperAdminUsuariosScreen({super.key});

  @override
  ConsumerState<SuperAdminUsuariosScreen> createState() =>
      _SuperAdminUsuariosScreenState();
}

class _SuperAdminUsuariosScreenState
    extends ConsumerState<SuperAdminUsuariosScreen> {
  final _searchCtrl = TextEditingController();
  String _rolFiltro = "TODOS";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtrarUsuarios(
    List<Map<String, dynamic>> users,
  ) {
    final q = _searchCtrl.text.trim().toLowerCase();

    final filtered = users.where((u) {
      final nombre = (u["nombre"] ?? "").toString().toLowerCase();
      final apellidos = (u["apellidos"] ?? "").toString().toLowerCase();
      final email = (u["email"] ?? "").toString().toLowerCase();
      final rol = (u["rol"] ?? "").toString();

      final matchSearch =
          q.isEmpty ||
          nombre.contains(q) ||
          apellidos.contains(q) ||
          email.contains(q);

      final matchRol = _rolFiltro == "TODOS" || rol == _rolFiltro;

      return matchSearch && matchRol;
    }).toList();

    filtered.sort((a, b) {
      final da = DateTime.tryParse((a["creadoEn"] ?? "").toString());
      final db = DateTime.tryParse((b["creadoEn"] ?? "").toString());
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final asyncBody = ref.watch(usuariosResumenProvider);

    return Scaffold(
      body: asyncBody.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (body) {
          final dataList = (body["data"] as List? ?? []);
          final stats = (body["stats"] as Map<String, dynamic>? ?? {});

          final usuarios = dataList.cast<Map<String, dynamic>>();
          final nuevosPorMes = (stats["nuevosPorMes"] as List? ?? [])
              .cast<Map<String, dynamic>>();

          final usuariosFiltrados = _filtrarUsuarios(usuarios);

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(usuariosResumenProvider.future);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 420,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: "Buscar por nombre o email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 420,
                        child: DropdownButtonFormField<String>(
                          value: _rolFiltro,
                          decoration: const InputDecoration(
                            labelText: "Rol",
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "TODOS",
                              child: Text("Todos"),
                            ),
                            DropdownMenuItem(
                              value: "SuperADMIN",
                              child: Text("SuperADMIN"),
                            ),
                            DropdownMenuItem(
                              value: "SECRETARIAAsociacion",
                              child: Text("Secret. Asociación"),
                            ),
                            DropdownMenuItem(
                              value: "SECRETARIAIglesia",
                              child: Text("Secret. Iglesia"),
                            ),
                            DropdownMenuItem(
                              value: "PASTOR",
                              child: Text("Pastor"),
                            ),
                            DropdownMenuItem(
                              value: "MIEMBRO",
                              child: Text("Miembro"),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _rolFiltro = v ?? "TODOS"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  UsuariosPorMesChart(nuevosPorMes: nuevosPorMes),

                  const SizedBox(height: 16),
                  Text(
                    "Usuarios: ${usuariosFiltrados.length} / ${usuarios.length}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  ...usuariosFiltrados.map((u) => _userTile(context, u)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _userTile(BuildContext context, Map<String, dynamic> u) {
    final usuarioId = (u["id"] ?? "").toString();
    final nombre = (u["nombre"] ?? "").toString();
    final apellidos = (u["apellidos"] ?? "").toString();
    final email = (u["email"] ?? "").toString();
    final telefono = (u["telefono"] ?? "").toString();
    final rol = (u["rol"] ?? "").toString();
    final codigoUnico = (u["codigoUnico"] ?? "").toString();

    final esPastor = rol == "PASTOR";

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text("$nombre $apellidos".trim()),
        subtitle: Text("$email\n$telefono"),
        isThreeLine: true,

        // ✅ Aquí va tu “Chip” + “⋮” solo si es PASTOR
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(rol)),
            if (esPastor) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: "Acciones",
                onSelected: (value) async {
                  if (usuarioId.isEmpty) return;

                  if (value == "asignar_mover") {
                    // Reusamos la misma pantalla de asignar,
                    // pero en "modo admin" (viene desde usuarios)
                    final ok = await Navigator.pushNamed(
                      context,
                      "/super/asignar-pastor",
                      arguments: {
                        "usuarioId": usuarioId,
                        "nombre": nombre,
                        "apellidos": apellidos,
                        "codigoUnico": codigoUnico,
                        "modo": "admin", // 👈 clave
                      },
                    );

                    // si esa pantalla hace pop(true) al finalizar,
                    // refrescamos la lista
                    if (ok == true && context.mounted) {
                      ref.invalidate(usuariosResumenProvider);
                    }
                  }

                  if (value == "quitar") {
                    // Abrimos la misma pantalla pero indicando acción quitar
                    final ok = await Navigator.pushNamed(
                      context,
                      "/super/asignar-pastor",
                      arguments: {
                        "usuarioId": usuarioId,
                        "nombre": nombre,
                        "apellidos": apellidos,
                        "codigoUnico": codigoUnico,
                        "modo": "admin",
                        "accion": "quitar",
                      },
                    );

                    if (ok == true && context.mounted) {
                      ref.invalidate(usuariosResumenProvider);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: "asignar_mover",
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.swap_horiz),
                      title: Text("Asignar / Mover"),
                    ),
                  ),
                  PopupMenuItem(
                    value: "quitar",
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.remove_circle_outline),
                      title: Text("Quitar del distrito"),
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
