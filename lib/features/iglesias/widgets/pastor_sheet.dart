import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/iglesia_models.dart';
import '../providers/iglesias_provider.dart';

// TODO: cuando ya tengas endpoint para listar pastores disponibles,
// remplazas esto con un provider real.
Future<List<Map<String, String>>> _fakePastores() async {
  return [
    {
      "id": "0ca5f781-7224-4e79-830d-53c86150767e",
      "nombre": "Miguel Gutierrez",
    },
    {"id": "0a2f6a81-dd57-4b84-8b60-54d62f5ee777", "nombre": "Adonis Aleman"},
  ];
}

Future<void> showPastorSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Iglesia iglesia,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PastorSheetBody(iglesia: iglesia, ref: ref),
  );
}

class _PastorSheetBody extends StatefulWidget {
  final Iglesia iglesia;
  final WidgetRef ref;
  const _PastorSheetBody({required this.iglesia, required this.ref});

  @override
  State<_PastorSheetBody> createState() => _PastorSheetBodyState();
}

class _PastorSheetBodyState extends State<_PastorSheetBody> {
  String? _nuevoPastorId;
  bool _loading = false;
  late Future<List<Map<String, String>>> _pastoresFuture;

  @override
  void initState() {
    super.initState();
    _pastoresFuture = _fakePastores();
    _nuevoPastorId = widget.iglesia.pastorId;
  }

  @override
  Widget build(BuildContext context) {
    final pastorActual = widget.iglesia.pastor?.usuario == null
        ? "Sin pastor"
        : "${widget.iglesia.pastor!.usuario!.nombre} ${widget.iglesia.pastor!.usuario!.apellidos}"
              .trim();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 8,
      ),
      child: FutureBuilder<List<Map<String, String>>>(
        future: _pastoresFuture,
        builder: (context, snap) {
          final pastores = snap.data ?? [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Iglesia: ${widget.iglesia.nombre}",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text("Pastor actual: $pastorActual"),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _nuevoPastorId,
                decoration: const InputDecoration(
                  labelText: "Seleccionar nuevo pastor",
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text("Sin pastor"),
                  ),
                  ...pastores.map(
                    (p) => DropdownMenuItem<String>(
                      value: p["id"],
                      child: Text(p["nombre"] ?? ""),
                    ),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _nuevoPastorId = v),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : () => _guardar(),
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Guardar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => _quitarPastor(),
                      child: const Text("Quitar pastor"),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _loading = true);
    try {
      final svc = widget.ref.read(iglesiaServiceProvider);

      // ✅ aquí solo actualizamos pastorId (y si quieres puedes mandar el resto)
      await svc.updateIglesia(widget.iglesia.id, {
        "pastorId": _nuevoPastorId, // puede ser null
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pastor actualizado")));

      widget.ref.invalidate(iglesiasProvider); // ✅ refresh lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quitarPastor() async {
    setState(() => _nuevoPastorId = null);
    await _guardar();
  }
}
