import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoedasScreen extends StatefulWidget {
  @override
  _MoedasScreenState createState() => _MoedasScreenState();
}

class _MoedasScreenState extends State<MoedasScreen> {
  String _moedaBase = "USD";
  double _valorBase = 1.0;
  TextEditingController _valorInputController = TextEditingController(text: "1.0");
  List<String> _outrasMoedas = ["EUR", "GBP", "CNY", "CAD", "AUD", "USD"];
  Map<String, double> _taxasDeCambio = {};

  @override
  void initState() {
    super.initState();
    _buscarTaxasDeCambio();
    _valorInputController.addListener(_atualizarConversao);
  }

  @override
  void dispose() {
    _valorInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Moedas'),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _construirDropdownMoedaBase(),
            SizedBox(height: 20.0),
            _construirCampoValorInput(),
            SizedBox(height: 20.0),
            _construirListaMoedas(),
          ],
        ),
      ),
    );
  }

  Widget _construirDropdownMoedaBase() {
    return DropdownButton<String>(
      value: _moedaBase,
      items: ["USD", "EUR", "GBP", "CNY", "CAD", "AUD"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _moedaBase = value;
            _buscarTaxasDeCambio();
          });
        }
      },
    );
  }

  Widget _construirCampoValorInput() {
    return TextField(
      controller: _valorInputController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Valor para Conversão',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _construirListaMoedas() {
    return Expanded(
      child: ListView.builder(
        itemCount: _outrasMoedas.length,
        itemBuilder: (context, index) {
          final moeda = _outrasMoedas[index];

          // Verifica se a moeda atual é diferente da moeda base
          if (moeda != _moedaBase) {
            final taxaDeCambio = _taxasDeCambio[moeda] ?? 0.0;
            final valorConvertido =
                (_valorBase / taxaDeCambio).toStringAsFixed(2);

            return ListTile(
              title: Text('$moeda para $_moedaBase'),
              subtitle: Text('1 $_moedaBase = $taxaDeCambio $moeda'),
              trailing: Text('Valor Convertido = $valorConvertido $_moedaBase'),
            );
          } else {
            return Container(); // Retorna um contêiner vazio para evitar a exibição da moeda base
          }
        },
      ),
    );
  }

  void _atualizarConversao() {
    setState(() {
      // Verifica se o valor da string é vazio ou não pode ser convertido para double
      _valorBase = double.tryParse(_valorInputController.text) ?? 0.0;
    });
  }

  Future<void> _buscarTaxasDeCambio() async {
    final String apiUrl = 'https://api.exchangerate-api.com/v4/latest/$_moedaBase';

    try {
      final http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _taxasDeCambio = Map<String, double>.from(data['rates']);
        });
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }
}
