import 'package:flutter/material.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Map<String, dynamic>> _todos = [
    {'title': 'Todo 1', 'checked': false},
    {'title': 'Todo 2', 'checked': false},
    {'title': 'Todo 3', 'checked': false},
  ];

  void _toggleCheck(int index) {
    setState(() {
      _todos[index]['checked'] = !_todos[index]['checked'];
    });
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (context) {
        String newTodoTitle = '';
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            onChanged: (value) {
              newTodoTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter todo title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todos.add({'title': newTodoTitle, 'checked': false});
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editTodo(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String updatedTitle = _todos[index]['title'];
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            onChanged: (value) {
              updatedTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter new title'),
            controller: TextEditingController(text: _todos[index]['title']),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todos[index]['title'] = updatedTitle;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _todos.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addTodo)],
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo['title']),
            onLongPress: () {
              _editTodo(index);
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todo['checked'],
                  onChanged: (value) {
                    _toggleCheck(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
