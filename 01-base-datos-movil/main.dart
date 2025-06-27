import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App - Práctica BD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> tasks = [
    Task(
        id: '1',
        description: 'Hacer la práctica de bases de datos',
        completed: false),
    Task(id: '2', description: 'Configurar Firebase', completed: true),
    Task(id: '3', description: 'Crear app móvil', completed: false),
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App - Práctica BD'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Formulario para agregar tareas
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe una nueva tarea...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),

          // Estadísticas
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                    'Total', _getTotalTasks().toString(), Colors.blue),
                _buildStatCard('Completadas', _getCompletedTasks().toString(),
                    Colors.green),
                _buildStatCard(
                    'Pendientes', _getPendingTasks().toString(), Colors.orange),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Lista de tareas
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(task, index, 0);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Agregar Tarea',
      ),
    );
  }

  Widget _buildTaskCard(Task task, int index, int level) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(
              left: 16 + (level * 20.0), right: 16, top: 4, bottom: 4),
          child: ListTile(
            leading: Checkbox(
              value: task.completed,
              onChanged: (value) => _toggleTask(index),
            ),
            title: Text(
              task.description,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${task.id} | Fecha: ${task.createdAt}'),
                if (task.subtasks.isNotEmpty)
                  Text('${task.subtasks.length} subtareas',
                      style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.add_task, color: Colors.green),
                  onPressed: () => _addSubtask(index),
                  tooltip: 'Agregar Subtarea',
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onPressed: () => _openTaskDetails(task, index),
                  tooltip: 'Ver Detalles',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ),
        // Mostrar subtareas si las hay
        if (task.subtasks.isNotEmpty)
          ...task.subtasks.asMap().entries.map((entry) {
            int subtaskIndex = entry.key;
            Task subtask = entry.value;
            return _buildSubtaskCard(subtask, index, subtaskIndex, level + 1);
          }).toList(),
      ],
    );
  }

  Widget _buildSubtaskCard(
      Task subtask, int parentIndex, int subtaskIndex, int level) {
    return Card(
      margin: EdgeInsets.only(
          left: 16 + (level * 20.0), right: 16, top: 2, bottom: 2),
      color: Colors.grey[50],
      child: ListTile(
        leading: Checkbox(
          value: subtask.completed,
          onChanged: (value) => _toggleSubtask(parentIndex, subtaskIndex),
        ),
        title: Text(
          subtask.description,
          style: TextStyle(
            decoration: subtask.completed ? TextDecoration.lineThrough : null,
            color: subtask.completed ? Colors.grey : null,
            fontSize: 14,
          ),
        ),
        subtitle: Text('Subtarea | ${subtask.createdAt}',
            style: TextStyle(fontSize: 10)),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _deleteSubtask(parentIndex, subtaskIndex),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: _controller.text,
          completed: false,
        ));
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea agregada correctamente')),
      );
    }
  }

  void _addSubtask(int parentIndex) {
    final TextEditingController subtaskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Subtarea'),
        content: TextField(
          controller: subtaskController,
          decoration: InputDecoration(hintText: 'Descripción de la subtarea'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (subtaskController.text.isNotEmpty) {
                setState(() {
                  tasks[parentIndex].subtasks.add(Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: subtaskController.text,
                        completed: false,
                      ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subtarea agregada')),
                );
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _openTaskDetails(Task task, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              tasks[index] = updatedTask;
            });
          },
        ),
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Tarea ${tasks[index].completed ? "completada" : "marcada como pendiente"}')),
    );
  }

  void _toggleSubtask(int parentIndex, int subtaskIndex) {
    setState(() {
      tasks[parentIndex].subtasks[subtaskIndex].completed =
          !tasks[parentIndex].subtasks[subtaskIndex].completed;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarea eliminada')),
    );
  }

  void _deleteSubtask(int parentIndex, int subtaskIndex) {
    setState(() {
      tasks[parentIndex].subtasks.removeAt(subtaskIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subtarea eliminada')),
    );
  }

  int _getTotalTasks() {
    int total = tasks.length;
    for (var task in tasks) {
      total += task.subtasks.length;
    }
    return total;
  }

  int _getCompletedTasks() {
    int completed = tasks.where((t) => t.completed).length;
    for (var task in tasks) {
      completed += task.subtasks.where((s) => s.completed).length;
    }
    return completed;
  }

  int _getPendingTasks() {
    return _getTotalTasks() - _getCompletedTasks();
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nueva Tarea'),
        content: TextField(
          controller: dialogController,
          decoration: InputDecoration(hintText: 'Descripción de la tarea'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogController.text.isNotEmpty) {
                setState(() {
                  tasks.add(Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    description: dialogController.text,
                    completed: false,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarea agregada desde diálogo')),
                );
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  TaskDetailScreen({required this.task, required this.onTaskUpdated});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    task = Task.copy(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Tarea'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onTaskUpdated(task);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tarea actualizada')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la tarea principal
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarea Principal',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('ID: ${task.id}'),
                  Text('Creada: ${task.createdAt}'),
                  Text('Descripción: ${task.description}'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Completada: '),
                      Checkbox(
                        value: task.completed,
                        onChanged: (value) {
                          setState(() {
                            task.completed = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Agregar nueva subtarea
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Agregar nueva subtarea...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSubtask,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Lista de subtareas
          Expanded(
            child: ListView.builder(
              itemCount: task.subtasks.length,
              itemBuilder: (context, index) {
                final subtask = task.subtasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: subtask.completed,
                      onChanged: (value) {
                        setState(() {
                          subtask.completed = value!;
                        });
                      },
                    ),
                    title: Text(
                      subtask.description,
                      style: TextStyle(
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: subtask.completed ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text('ID: ${subtask.id} | ${subtask.createdAt}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          task.subtasks.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        task.subtasks.add(Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: _controller.text,
          completed: false,
        ));
        _controller.clear();
      });
    }
  }
}

class Task {
  String id;
  String description;
  bool completed;
  String createdAt;
  List<Task> subtasks;

  Task({
    required this.id,
    required this.description,
    required this.completed,
    List<Task>? subtasks,
  })  : createdAt = DateTime.now().toString().substring(0, 16),
        subtasks = subtasks ?? [];

  static Task copy(Task original) {
    return Task(
      id: original.id,
      description: original.description,
      completed: original.completed,
      subtasks: original.subtasks.map((s) => Task.copy(s)).toList(),
    );
  }
}
