import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/iglesias_provider.dart';
import '../models/iglesia_models.dart';
import '../widgets/pastor_sheet.dart';
import '../../iglesias/services/iglesia_service.dart';

class SuperAdminIglesiasScreen extends ConsumerStatefulWidget {
  const SuperAdminIglesiasScreen({super.key});

  @override
  ConsumerState<SuperAdminIglesiasScreen> createState() =>
      _SuperAdminIglesiasScreenState();
}

class _SuperAdminIglesiasScreenState
    extends ConsumerState<SuperAdminIglesiasScreen> {
  final _searchCtrl = TextEditingController();
  String _filtroPastor = "TODOS"; // TODOS | CON | SIN

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Iglesia> _filtrar(List<Iglesia> list) {
    final q = _searchCtrl.text.trim().toLowerCase();

    return list.where((i) {
      final matchSearch =
          q.isEmpty ||
          i.nombre.toLowerCase().contains(q) ||
          i.codigo.toLowerCase().contains(q);

      final hasPastor = i.pastorId != null;
      final matchPastor =
          _filtroPastor == "TODOS" ||
          (_filtroPastor == "CON" && hasPastor) ||
          (_filtroPastor == "SIN" && !hasPastor);

      return matchSearch && matchPastor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncIglesias = ref.watch(iglesiasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Iglesias"),
        actions: [
          IconButton(
            tooltip: "Refrescar",
            onPressed: () => ref.invalidate(iglesiasProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: abrir form crear iglesia
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pendiente: Form Crear Iglesia")),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Crear"),
      ),
      body: asyncIglesias.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (list) {
          final filtradas = _filtrar(list);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(iglesiasProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                          labelText: "Buscar por nombre o código",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: DropdownButtonFormField<String>(
                        value: _filtroPastor,
                        decoration: const InputDecoration(
                          labelText: "Pastor",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "TODOS",
                            child: Text("Todos"),
                          ),
                          DropdownMenuItem(
                            value: "CON",
                            child: Text("Con pastor"),
                          ),
                          DropdownMenuItem(
                            value: "SIN",
                            child: Text("Sin pastor"),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _filtroPastor = v ?? "TODOS"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  "Iglesias: ${filtradas.length} / ${list.length}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                ...filtradas.map((i) => _iglesiaTile(context, i)),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iglesiaTile(BuildContext context, Iglesia i) {
    final distrito = i.distrito?.nombre ?? "—";
    final asociacion = i.distrito?.asociacion?.nombre;
    final pastorNombre = i.pastor?.usuario == null
        ? "Sin pastor"
        : "${i.pastor!.usuario!.nombre} ${i.pastor!.usuario!.apellidos}".trim();

    final miembros = i.count?.miembros ?? 0;
    final eventos = i.count?.eventos ?? 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.church_outlined)),
        title: Text("${i.nombre} (${i.codigo})"),
        subtitle: Text(
          [
            "Distrito: $distrito",
            if (asociacion != null) "Asociación: $asociacion",
            "Pastor: $pastorNombre",
          ].join("\n"),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == "editar") {
              // TODO: navegar a form edit iglesia
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pendiente: Form Editar Iglesia")),
              );
            }

            if (v == "pastor") {
              await showPastorSheet(context: context, ref: ref, iglesia: i);
            }

            if (v == "eliminar") {
              final ok = await _confirmDelete(context, i.nombre);
              if (!ok) return;

              try {
                final svc = ref.read(iglesiaServiceProvider);
                await svc.deleteIglesia(i.id);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Iglesia eliminada")),
                );

                ref.invalidate(iglesiasProvider); // ✅ refresh automático
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "editar", child: Text("Editar")),
            PopupMenuItem(
              value: "pastor",
              child: Text("Cambiar / Quitar pastor"),
            ),
            PopupMenuDivider(),
            PopupMenuItem(value: "eliminar", child: Text("Eliminar")),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        dense: false,
      ),
    ).withChips(miembros: miembros, eventos: eventos);
  }

  Future<bool> _confirmDelete(BuildContext context, String nombre) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar iglesia"),
        content: Text(
          "¿Seguro que deseas eliminar “$nombre”? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

extension _CardChips on Widget {
  Widget withChips({required int miembros, required int eventos}) {
    return Column(
      children: [
        this,
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Row(
            children: [
              Chip(label: Text("Miembros: $miembros")),
              const SizedBox(width: 8),
              Chip(label: Text("Eventos: $eventos")),
            ],
          ),
        ),
      ],
    );
  }
}
