class Partida {
  int? id;
  String? nombrePartida;
  String? jugadorUno;
  String? jugadorDos;
  String? ganador;
  String? estado;

  Partida(
      {this.id,
      this.nombrePartida,
      this.jugadorUno,
      this.jugadorDos,
      this.ganador,
      this.estado});

  Partida.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombrePartida = json['nombre_partida'];
    jugadorUno = json['jugador_uno'];
    jugadorDos = json['jugador_dos'];
    ganador = json['ganador'];
    estado = json['estado'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nombre_partida'] = this.nombrePartida;
    data['jugador_uno'] = this.jugadorUno;
    data['jugador_dos'] = this.jugadorDos;
    data['ganador'] = this.ganador;
    data['estado'] = this.estado;
    return data;
  }
}
