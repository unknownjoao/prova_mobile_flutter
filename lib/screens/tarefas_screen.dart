import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});
}

class TarefasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  TextEditingController _taskController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  SlidableController slidableController = SlidableController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks.json');

      if (file.existsSync()) {
        final jsonData = json.decode(file.readAsStringSync());
        setState(() {
          tasks = (jsonData['tasks'] as List)
              .map((task) =>
                  Task(title: task['title'], completed: task['completed']))
              .toList();
          filteredTasks = List.from(tasks);
        });
      }
    } catch (e) {
      print("Erro ao carregar tarefas: $e");
    }
  }

  Future<void> _saveTasks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks.json');

      final jsonData = {
        'tasks': tasks
            .map((task) => {'title': task.title, 'completed': task.completed})
            .toList()
      };
      file.writeAsStringSync(json.encode(jsonData));
    } catch (e) {
      print("Erro ao salvar tarefas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: Text(
        'Lista de Tarefas',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar Tarefa',
        ),
        onChanged: (value) {
          setState(() {
            _filterTasks(value);
          });
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            setState(() {
              _filterTasks(_searchController.text);
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _showAddTaskModal();
          },
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return _buildSlidableTaskItem(task, index);
        },
      ),
    );
  }

  Widget _buildSlidableTaskItem(Task task, int index) {
    return Slidable(
      controller: slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      actions: [
        _buildSlideAction(
            'Excluir', Colors.red, Icons.delete, () => _deleteTask(index)),
      ],
      secondaryActions: [
        _buildSlideAction('Editar', Colors.green, Icons.edit,
            () => _showEditTaskModal(index)),
      ],
      child: _buildListTile(task),
    );
  }

  Widget _buildSlideAction(
      String caption, Color color, IconData icon, Function onTap) {
    return IconSlideAction(
      caption: caption,
      color: color,
      icon: icon,
      onTap: () => onTap(),
    );
  }

  Widget _buildListTile(Task task) {
    return ListTile(
      title: Text(task.title),
      leading: Checkbox(
        value: task.completed,
        onChanged: (value) {
          setState(() {
            task.completed = value!;
            _saveTasks();
          });
        },
      ),
      onTap: () {
        setState(() {
          task.completed = !task.completed;
          _saveTasks();
        });
      },
    );
  }

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTasks = List.from(tasks);
      } else if (query.toLowerCase() == "[true]") {
        // Filtrar tarefas com checkbox marcado
        filteredTasks = tasks.where((task) => task.completed).toList();
      } else if (query.toLowerCase() == "[false]") {
        // Filtrar tarefas com checkbox desmarcado
        filteredTasks = tasks.where((task) => !task.completed).toList();
      } else {
        // Filtro padrão para outras consultas
        filteredTasks = tasks
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _showAddTaskModal() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildAddEditTaskModal('Nova Tarefa', 'Criar', (String title) {
          _addTask(title);
        });
      },
    );
  }

  Future<void> _showEditTaskModal(int index) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildAddEditTaskModal('Editar Tarefa', 'Salvar',
            (String title) {
          _editTask(index, title);
        }, initialValue: filteredTasks[index].title);
      },
    );
  }

  Widget _buildAddEditTaskModal(
      String title, String buttonText, Function onSubmit,
      {String initialValue = ''}) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24.0),
          ),
          TextField(
            controller: _taskController..text = initialValue,
            decoration: InputDecoration(
              hintText: 'Digite o título da tarefa',
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  onSubmit(_taskController.text);
                  Navigator.pop(context);
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addTask(String title) {
    setState(() {
      tasks.add(Task(title: title));
      _taskController.clear();
      _saveTasks();
      _filterTasks(_searchController.text);
    });
  }

  void _editTask(int index, String newTitle) {
    setState(() {
      filteredTasks[index].title = newTitle;
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    Task deletedTask = filteredTasks[index];
    setState(() {
      tasks.remove(deletedTask);
      _filterTasks(_searchController.text);
      _saveTasks();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa excluída'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(index, deletedTask);
              _filterTasks(_searchController.text);
              _saveTasks();
            });
          },
        ),
      ),
    );
  }
}