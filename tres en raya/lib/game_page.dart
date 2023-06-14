import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_tic_tac_toe/model/partida.dart';

import 'package:http/http.dart' as http;

class GamePage extends StatefulWidget {
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String PLAYER_X = "X";
  static const String PLAYER_Y = "O";

  late String currentPlayer;
  late bool gameEnd;
  late List<String> occupied;
  late TextEditingController _playerOneController;
  late TextEditingController _playerTwoController;

  late Future<List<Partida>> _listadoPartidas;

  @override
  void initState() {
    _playerOneController = TextEditingController(text: "");
    _playerTwoController = TextEditingController(text: "");
    initializeGame();
    _listadoPartidas = _getPartidas();
    super.initState();
  }

  void initializeGame() {
    currentPlayer = PLAYER_X;
    gameEnd = false;
    occupied = ["", "", "", "", "", "", "", "", ""]; //9 empty places
  }

  Future<List<Partida>> _getPartidas() async {
    String url = "http://192.168.1.104:3000/api/partidas";
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);

    List<Partida> partidas = [];
    for (var item in responseData) {
      Partida partida = Partida(
        id: item["id"],
        nombrePartida: item["nombre_partida"],
        jugadorUno: item["jugador_uno"],
        jugadorDos: item["jugador_dos"],
        ganador: item["ganador"],
        estado: item["estado"],
      );
      partidas.add(partida);
    }
    return partidas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("3 EN RAYA #")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _inputPlayers(),
            //_headerText(),
            _gameContainer(),
            _restartButton(),
            // FutureBuilder(
            //   future: _listadoPartidas,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return ListView(
            //         scrollDirection: Axis.horizontal,
            //         children: _listPartidas(snapshot.data),
            //       );
            //     } else if (snapshot.hasError) {
            //       print(snapshot.error);
            //       return Text("error");
            //     }
            //     return Center(
            //       child: CircularProgressIndicator(),
            //     );
            //   },
            // )
          ],
        ),
      ),
    );
  }

  List<Widget> _listPartidas(data) {
    List<Widget> partidas = [];
    for (var party in data) {
      partidas.add(Text(party.jugadorUno.toString()));
    }
    return partidas;
  }

  Widget _inputPlayers() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
              controller: _playerOneController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text("Jugador 1"))),
          const SizedBox(
            height: 20,
          ),
          TextField(
              controller: _playerTwoController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), label: Text("Jugador 2"))),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.lightGreen[900]),
              onPressed: () async {
                //_getPartidas();
                final uri = Uri.parse("http://192.168.1.104:3000/api/partidas");
                final response = await http.get(uri);
                if (response.statusCode == 200) {
                  print("Todo salio bien partida registrada");
                  print(response.body);
                }
                // print(_playerOneController.text);
                // print(_playerTwoController.text);
              },
              child: Text("Comenzar"))
        ],
      ),
    );
  }

  // Widget _headerText() {
  //   return Column(
  //     children: [
  //       const Text(
  //         "Tic Tac Toe",
  //         style: TextStyle(
  //           color: Colors.green,
  //           fontSize: 32,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       Text(
  //         "$currentPlayer turn",
  //         style: const TextStyle(
  //           color: Colors.black87,
  //           fontSize: 32,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _gameContainer() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.height / 2,
      margin: const EdgeInsets.all(8),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3),
          itemCount: 9,
          itemBuilder: (context, int index) {
            return _box(index);
          }),
    );
  }

  Widget _box(int index) {
    return InkWell(
      onTap: () {
        //on click of box
        if (gameEnd || occupied[index].isNotEmpty) {
          //Return if game already ended or box already clicked
          return;
        }

        setState(() {
          occupied[index] = currentPlayer;
          changeTurn();
          checkForWinner();
          checkForDraw();
        });
      },
      child: Container(
        color: occupied[index].isEmpty
            ? Colors.black26
            : occupied[index] == PLAYER_X
                ? Colors.redAccent[900]
                : Colors.red[900],
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            occupied[index],
            style: TextStyle(
                fontSize: 50,
                color: occupied[index] == PLAYER_X ? Colors.red : Colors.white),
          ),
        ),
      ),
    );
  }

  _restartButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            initializeGame();
          });
        },
        child: const Text("Restart Game"));
  }

  changeTurn() {
    if (currentPlayer == PLAYER_X) {
      currentPlayer = PLAYER_Y;
    } else {
      currentPlayer = PLAYER_X;
    }
  }

  checkForWinner() {
    //Define winning positions
    List<List<int>> winningList = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var winningPos in winningList) {
      String playerPosition0 = occupied[winningPos[0]];
      String playerPosition1 = occupied[winningPos[1]];
      String playerPosition2 = occupied[winningPos[2]];

      if (playerPosition0.isNotEmpty) {
        if (playerPosition0 == playerPosition1 &&
            playerPosition0 == playerPosition2) {
          //all equal means player won
          if (playerPosition0 == "X") {
            var playerwin = _playerOneController.text;
            showGameOverMessage("Ganó jugador $playerwin");
          } else {
            var playerwin = _playerTwoController.text;
            showGameOverMessage("Ganó jugador $playerwin");
          }
          gameEnd = true;
          return;
        }
      }
    }
  }

  checkForDraw() {
    if (gameEnd) {
      return;
    }
    bool draw = true;
    for (var occupiedPlayer in occupied) {
      if (occupiedPlayer.isEmpty) {
        //at least one is empty not all are filled
        draw = false;
      }
    }

    if (draw) {
      showGameOverMessage("Empate");
      gameEnd = true;
    }
  }

  showGameOverMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "$message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
            ),
          )),
    );
  }
}
