import 'package:flutter_riverpod/flutter_riverpod.dart';

/// búsqueda
final distritosSearchProvider = StateProvider<String>((ref) => "");

/// filtro asociación (id) - null = todas
final distritosAsociacionFilterProvider = StateProvider<String?>((ref) => null);

/// paginación
final distritosPageProvider = StateProvider<int>((ref) => 1); // 1-based
final distritosPageSizeProvider = StateProvider<int>((ref) => 15); // 10/15/20
