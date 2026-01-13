import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/presentation/providers/auth_token_provider.dart';

import '../../distritos/providers/distritos_provider.dart';
import '../../distritos/providers/distritos_ui_state.dart';

// 👇 AJUSTA esta ruta a donde tengas tu catalogProvider
import '../../pastores/presentation/providers/catalog_providers.dart';

class SuperAdminDistritosScreen extends ConsumerWidget {
  const SuperAdminDistritosScreen({super.key});

  Future<void> _openCreateOrEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? distrito,
  }) async {
    final isEdit = distrito != null;

    final nombreCtrl = TextEditingController(
      text: distrito?["nombre"]?.toString() ?? "",
    );

    String? selectedAsociacionId = distrito?["asociacionId"]?.toString();

    final catalogAsync = ref.read(catalogProvider);

    // Si aún no está cargado el catálogo, hacemos un fallback simple
    final asociaciones = catalogAsync.maybeWhen(
      data: (c) => (c.asociaciones).cast<Map<String, dynamic>>(),
      orElse: () => <Map<String, dynamic>>[],
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Editar distrito" : "Crear distrito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre del distrito",
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Dropdown con asociaciones (nombre)
            DropdownButtonFormField<String>(
              value: selectedAsociacionId,
              decoration: const InputDecoration(
                labelText: "Asociación",
                border: OutlineInputBorder(),
              ),
              items: asociaciones.map((a) {
                final id = a["id"]?.toString() ?? "";
                final n = a["nombre"]?.toString() ?? "Sin nombre";
                return DropdownMenuItem(value: id, child: Text(n));
              }).toList(),
              onChanged: (v) => selectedAsociacionId = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isEdit ? "Guardar" : "Crear"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final token = ref.read(authSessionProvider).token;
    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sesión expirada")));
      return;
    }

    final nombre = nombreCtrl.text.trim();
    final asociacionId = (selectedAsociacionId ?? "").trim();

    if (nombre.isEmpty || asociacionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nombre y Asociación son obligatorios")),
      );
      return;
    }

    try {
      if (isEdit) {
        final id = distrito!["id"].toString();
        final resp = await DioClient.dio.put(
          "/api/distrito/$id",
          data: {"nombre": nombre, "asociacionId": asociacionId},
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

        final msg = (resp.data is Map && resp.data["message"] != null)
            ? resp.data["message"].toString()
            : "Distrito actualizado correctamente";

        ref.invalidate(distritosProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ $msg")));
      } else {
        final resp = await DioClient.dio.post(
          "/api/distrito",
          data: {"nombre": nombre, "asociacionId": asociacionId},
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );

        final msg = (resp.data is Map && resp.data["message"] != null)
            ? resp.data["message"].toString()
            : "Distrito creado correctamente";

        ref.invalidate(distritosProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ $msg")));
      }

      // reset UI: vuelve a página 1 para ver el cambio
      ref.read(distritosPageProvider.notifier).state = 1;
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : (e.response?.statusCode == 409
                ? "Ya existe un distrito con este nombre en esta asociación."
                : "Error de red");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $msg")));
    }
  }

  Future<void> _deleteDistrito(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar distrito"),
        content: const Text("¿Seguro que deseas eliminar este distrito?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final token = ref.read(authSessionProvider).token;
    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sesión expirada")));
      return;
    }

    try {
      final resp = await DioClient.dio.delete(
        "/api/distrito/$id",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      final msg = (resp.data is Map && resp.data["message"] != null)
          ? resp.data["message"].toString()
          : "Distrito eliminado correctamente";

      ref.invalidate(distritosProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ $msg")));

      // si borraste el último item de una página, corrige página
      ref.read(distritosPageProvider.notifier).state = 1;
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "Error eliminando distrito";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $msg")));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDistritos = ref.watch(distritosProvider);
    final catalogAsync = ref.watch(catalogProvider);

    final search = ref.watch(distritosSearchProvider);
    final asocFilter = ref.watch(distritosAsociacionFilterProvider);
    final page = ref.watch(distritosPageProvider);
    final pageSize = ref.watch(distritosPageSizeProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateOrEditDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ✅ Barra superior: Search + Filtro asociación + Page size
            catalogAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (catalog) {
                final asociaciones = (catalog.asociaciones)
                    .cast<Map<String, dynamic>>();

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 420,
                      child: TextField(
                        onChanged: (v) {
                          ref.read(distritosSearchProvider.notifier).state = v;
                          ref.read(distritosPageProvider.notifier).state = 1;
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: "Buscar distrito",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 420,
                      child: DropdownButtonFormField<String?>(
                        value: asocFilter,
                        decoration: const InputDecoration(
                          labelText: "Filtrar por asociación",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("Todas"),
                          ),
                          ...asociaciones.map((a) {
                            final id = a["id"]?.toString() ?? "";
                            final n = a["nombre"]?.toString() ?? "Sin nombre";
                            return DropdownMenuItem<String?>(
                              value: id,
                              child: Text(n),
                            );
                          }),
                        ],
                        onChanged: (v) {
                          ref
                                  .read(
                                    distritosAsociacionFilterProvider.notifier,
                                  )
                                  .state =
                              v;
                          ref.read(distritosPageProvider.notifier).state = 1;
                        },
                      ),
                    ),

                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<int>(
                        value: pageSize,
                        decoration: const InputDecoration(
                          labelText: "Por página",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 10, child: Text("10")),
                          DropdownMenuItem(value: 15, child: Text("15")),
                          DropdownMenuItem(value: 20, child: Text("20")),
                        ],
                        onChanged: (v) {
                          ref.read(distritosPageSizeProvider.notifier).state =
                              v ?? 15;
                          ref.read(distritosPageProvider.notifier).state = 1;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child: asyncDistritos.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (distritos) {
                  // mapa id->nombre asociación
                  final asocMap = catalogAsync.maybeWhen(
                    data: (c) {
                      final list = (c.asociaciones)
                          .cast<Map<String, dynamic>>();
                      return {
                        for (final a in list)
                          (a["id"]?.toString() ?? ""):
                              (a["nombre"]?.toString() ?? ""),
                      };
                    },
                    orElse: () => <String, String>{},
                  );

                  // ✅ filtro búsqueda + asociación
                  final q = search.trim().toLowerCase();
                  final filtered = distritos.where((d) {
                    final nombre = (d["nombre"] ?? "").toString().toLowerCase();
                    final aid = (d["asociacionId"] ?? "").toString();

                    final matchSearch = q.isEmpty || nombre.contains(q);
                    final matchAsoc = asocFilter == null || aid == asocFilter;

                    return matchSearch && matchAsoc;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text("No hay distritos para mostrar."),
                    );
                  }

                  // ✅ paginación client-side
                  final total = filtered.length;
                  final totalPages = (total / pageSize).ceil();
                  final safePage = page.clamp(1, totalPages);

                  if (safePage != page) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(distritosPageProvider.notifier).state = safePage;
                    });
                  }

                  final start = (safePage - 1) * pageSize;
                  final end = (start + pageSize).clamp(0, total);
                  final pageItems = filtered.sublist(start, end);

                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              ref.invalidate(distritosProvider),
                          child: ListView.builder(
                            itemCount: pageItems.length,
                            itemBuilder: (_, i) {
                              final d = pageItems[i];
                              final id = d["id"]?.toString() ?? "";
                              final nombre =
                                  d["nombre"]?.toString() ?? "Sin nombre";
                              final asociacionId =
                                  d["asociacionId"]?.toString() ?? "";
                              final asociacionNombre =
                                  asocMap[asociacionId] ?? asociacionId;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  title: Text(
                                    nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Asociación: $asociacionNombre",
                                  ),

                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () =>
                                            _openCreateOrEditDialog(
                                              context,
                                              ref,
                                              distrito: d,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: id.isEmpty
                                            ? null
                                            : () => _deleteDistrito(
                                                context,
                                                ref,
                                                id,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ✅ Paginación tipo "1 2 3 4 5 … 10"
                      _PaginationBar(
                        page: safePage,
                        totalPages: totalPages,
                        onPage: (p) =>
                            ref.read(distritosPageProvider.notifier).state = p,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final void Function(int page) onPage;

  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _buildPages(page, totalPages);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: page > 1 ? () => onPage(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            ...pages.map((p) {
              if (p == -1) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text("…"),
                );
              }

              final isActive = p == page;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onPage(p),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.black12 : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "$p",
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
            IconButton(
              onPressed: page < totalPages ? () => onPage(page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  /// retorna lista de páginas con -1 como "..."
  List<int> _buildPages(int current, int total) {
    // muestra: 1 2 3 4 5 … total, centrado
    const maxButtons = 7;

    if (total <= maxButtons) {
      return List.generate(total, (i) => i + 1);
    }

    final result = <int>[];

    result.add(1);

    int start = current - 1;
    int end = current + 1;

    if (start < 2) {
      start = 2;
      end = start + 2;
    }
    if (end > total - 1) {
      end = total - 1;
      start = end - 2;
    }

    if (start > 2) result.add(-1);

    for (int i = start; i <= end; i++) {
      result.add(i);
    }

    if (end < total - 1) result.add(-1);

    result.add(total);

    return result;
  }
}
