import 'package:flutter/material.dart';
import 'screens/clima_screen.dart';
import 'screens/moedas_screen.dart';
import 'screens/tarefas_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ClimaScreen(),
    MoedasScreen(),
    TarefasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Clima',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Moedas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Tarefas',
          ),
        ],
      ),
    );
  }
}
