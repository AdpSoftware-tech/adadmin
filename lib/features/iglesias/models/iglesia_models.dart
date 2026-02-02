class Iglesia {
  final String id;
  final String nombre;
  final String codigo;
  final String direccion;
  final String? telefono;
  final String distritoId;
  final String? pastorId;

  final Distrito? distrito;
  final Pastor? pastor;
  final Conteos? count;

  Iglesia({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.direccion,
    required this.telefono,
    required this.distritoId,
    required this.pastorId,
    required this.distrito,
    required this.pastor,
    required this.count,
  });

  factory Iglesia.fromJson(Map<String, dynamic> json) => Iglesia(
    id: json["id"],
    nombre: json["nombre"] ?? "",
    codigo: json["codigo"] ?? "",
    direccion: json["direccion"] ?? "",
    telefono: json["telefono"],
    distritoId: json["distritoId"] ?? "",
    pastorId: json["pastorId"],
    distrito: json["distrito"] == null
        ? null
        : Distrito.fromJson(json["distrito"]),
    pastor: json["pastor"] == null ? null : Pastor.fromJson(json["pastor"]),
    count: json["_count"] == null ? null : Conteos.fromJson(json["_count"]),
  );
}

class Distrito {
  final String id;
  final String nombre;
  final Asociacion? asociacion;

  Distrito({required this.id, required this.nombre, required this.asociacion});

  factory Distrito.fromJson(Map<String, dynamic> json) => Distrito(
    id: json["id"],
    nombre: json["nombre"] ?? "",
    asociacion: json["asociacion"] == null
        ? null
        : Asociacion.fromJson(json["asociacion"]),
  );
}

class Asociacion {
  final String id;
  final String nombre;

  Asociacion({required this.id, required this.nombre});

  factory Asociacion.fromJson(Map<String, dynamic> json) =>
      Asociacion(id: json["id"], nombre: json["nombre"] ?? "");
}

class Pastor {
  final String id;
  final UsuarioMini? usuario;

  Pastor({required this.id, required this.usuario});

  factory Pastor.fromJson(Map<String, dynamic> json) => Pastor(
    id: json["id"],
    usuario: json["usuario"] == null
        ? null
        : UsuarioMini.fromJson(json["usuario"]),
  );
}

class UsuarioMini {
  final String id;
  final String nombre;
  final String apellidos;
  final String email;

  UsuarioMini({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
  });

  factory UsuarioMini.fromJson(Map<String, dynamic> json) => UsuarioMini(
    id: json["id"],
    nombre: json["nombre"] ?? "",
    apellidos: json["apellidos"] ?? "",
    email: json["email"] ?? "",
  );
}

class Conteos {
  final int miembros;
  final int eventos;

  Conteos({required this.miembros, required this.eventos});

  factory Conteos.fromJson(Map<String, dynamic> json) => Conteos(
    miembros: (json["miembros"] ?? 0) as int,
    eventos: (json["eventos"] ?? 0) as int,
  );
}
