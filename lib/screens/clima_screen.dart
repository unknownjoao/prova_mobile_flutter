import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = 'e23324994434458eaef7d83a9fbebd34';

class ClimaScreen extends StatefulWidget {
  @override
  _ClimaScreenState createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  String _cidadeSelecionada = "Porto Velho";
  int _temperaturaAtual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Clima'),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _mostrarModalSelecao(context);
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clima em $_cidadeSelecionada',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Temperatura: $_temperaturaAtual °C',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            // Adicione mais widgets para mostrar outros dados climáticos.
          ],
        ),
      ),
    );
  }

  void _mostrarModalSelecao(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione a Cidade'),
          content: DropdownButton<String>(
            value: _cidadeSelecionada,
            items: [
              "Porto Velho",
              "Brasília",
              "São Paulo",
              "Rio de Janeiro",
              "Belo Horizonte",
              "Salvador"
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _cidadeSelecionada = value ?? "Porto Velho";
                _buscarTemperatura();
              });
              Navigator.of(context).pop(); // Feche o modal após a seleção.
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar fecha o modal.
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buscarTemperatura() async {
    final String cidade = _cidadeSelecionada.replaceAll(" ", "%20");
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$cidade&appid=$apiKey&units=metric';

    try {
      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _temperaturaAtual = data['main']['temp'].toInt();
        });
      } else {
        // Handle errors, ex: Cidade não encontrada.
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }
}
